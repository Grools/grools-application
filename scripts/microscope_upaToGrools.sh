#!/usr/bin/env bash
#set -x
declare appname=$(basename $0)
declare version='1.0.0'
declare grools='./grools-application.jar'
declare tmpDir=$(mktemp -d -t ${appname}.XXXXXX)
declare s_id_list=()
declare expectation_file=""
declare observations_file=""
declare output="$(pwd)"
declare grools_opts=( '-u' 'UCR' )
declare -A ids

show_help(){
  echo $"$0 [OPTIONS] sequence_id expectation_file
  -h --help      display this help
  -v --version   version ${version}
  -f --falsehood enable falsehood mode
  -s --specific  enable specific GROOLS mode
  -o --output    path to store output result (default: ${output})
  -j --jar       path to grools-application (default ${grools} )

Note: sequence id parameter can be :
  - a file where each line is an id
  - a list of id separated by comma example: 14,5,8"
}

show_version(){
  echo "version ${version}"
}


argparse(){
  while [[  $@ = -* ]]; do
    case "$1" in
      -h|--help)      show_help   ; exit;;
      -v|--version)   show_version; exit;;
      -f|--falsehood) grools_opts+=('-f') ;;
      -s|--specific)  grools_opts+=('-s') ;;
      -o|--output)    output=$2   ; shift;;
      -j|--jar)       grools=$2   ; shift;;
      *) echo 'Unexpected parameter '$1 >&2; exit;;
    esac
    shift
  done
  
  if [[ $# -ge 2 ]]; then
    if [[ -f "$1" ]]; then
        while read -r sid; do
            s_id_list+=( ${sid} )
        done < "$1"
    else
        s_id_list=( ${1//,/ } )
    fi
    expectation_file="$2"
  else
    show_help
    exit 1
  fi

  observations_file="${output}"'/observations.csv'
}

id_is_present () {
    # If the given key maps to a non-empty string (-n), the
    # key obviously exists. Otherwise, we need to check if
    # the special expansion produces an empty string or an
    # arbitrary non-empty string.
    [[ -n ${ids[$1]} || -z ${ids[$1]-foo} ]] && return 1 || return 0
}

observation_writer(){
  local -r line="${1}"
  local -r splitter="${2}"
  local -r source="${3}"
  local -r microscope_label="${4}"
  local -r microscope_gene="${5}"
  local -r microscope_product="${6}"
  local -r type="${7}"
  local -r isPresent="${8}"
  local -i id_counter=0
  local label=""
  local tmplabel=""
  local evidenceFor=""
  local name=""
  local description=""
  local priorknowledges=""
  while IFS="${splitter}" read -ra PKS; do
    for i in "${PKS[@]}"; do
      id_counter=0
      label="${microscope_label}"'_'"${i}"
      tmplabel="${label}"
      while ! id_is_present "${tmplabel}"; do
        ((id_counter++))
         tmplabel="${label}_${id_counter}"
      done
      label="${tmplabel}"
      evidenceFor=${i}
      if [[ "${microscope_gene}" == '-' ]]; then
        name=${microscope_label}
      else
        name=${microscope_label}','${microscope_gene}
      fi
      description=${microscope_product}
      echo '"'${label}'";"'${evidenceFor}'";"'${type}'";"'${isPresent}'";"'${source}'";"'${name}'";"'${description}'"' >> "${observations_file}"
    done
  done <<< "${line}"
}

grab_microscope_file(){
  local sId="$1"
  local label=""
  local evidenceFor=""
  local type="COMPUTATION"
  local isPresent=""
  local source="Microscope"
  local name=""
  local description=""
  local priorknowledges=""
  local -a Array
  curl -Lso ${tmpDir}/${sId}.csv 'https://www.genoscope.cns.fr/agc/microscope/search/export.php?format=csv&part=all&S_id='${sId}
  {
    read
    while read -r line
    do
      fields=$(tr '\t' '!' <<< "${line}")
      IFS='!'; read microscope_label microscope_type microscope_frame microscope_begin microscope_end microscope_length microscope_evidence microscope_mutation microscope_gene microscope_synonyms microscope_product microscope_class microscope_productType microscope_localization microscope_roles microscope_ECnumber microscope_microCycRid microscope_microCycPid microscope_rheaRid microscope_annotatedRid microscope_creationDate microscope_amigeneStatus microscope_pubmedID microscope_bioProcess microscope_matrix microscope_annotator microscope_Atot microscope_Ctot microscope_Gtot microscope_Ttot microscope_GCtot microscope_ATtot microscope_A1 microscope_C1 microscope_G1 microscope_T1 microscope_GC1 microscope_AT1 microscope_A2 microscope_C2 microscope_G2 microscope_T2 microscope_GC2 microscope_AT2 microscope_A3 microscope_C3 microscope_G3 microscope_T3 microscope_GC3 microscope_AT3 microscope_CAI microscope_MW microscope_KD microscope_tiny microscope_small microscope_aliphatic microscope_aromatic microscope_non_Polar microscope_polar microscope_charged microscope_basic microscope_acidic microscope_Pi microscope_OI  <<< "${fields}"
      if [[ -z "${microscope_gene}" ]]; then
        microscope_gene='-'
      fi
      if [[ "${microscope_mutation}" == pseudo || "${microscope_mutation}" == partial ]]; then
        isPresent="F"
      else
        isPresent="T"
      fi
      if [[ $microscope_evidence =~ validated* ]]; then
        type="CURATION"
      else
        type="COMPUTATION"
      fi
      observation_writer "${microscope_ECnumber}"     ',' 'EC'      "${microscope_label}" "${microscope_gene}" "${microscope_product}" "${type}" "${isPresent}"
      observation_writer "${microscope_microCycRid}"  '$' 'METACYC' "${microscope_label}" "${microscope_gene}" "${microscope_product}" "${type}" "${isPresent}"
      observation_writer "${microscope_rheaRid}"      '$' 'RHEA'    "${microscope_label}" "${microscope_gene}" "${microscope_product}" "${type}" "${isPresent}"
    done
  }< "${tmpDir}/${sId}.csv"
}

argparse $@

if [[ -e "${output}" ]]; then
  if [[ ! -d "${output}" ]]; then
    echo "Error: "${output}" is not a directory!" >&2
    exit 1
  fi
else
  mkdir -p ${output}
fi

echo '"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"' > "${observations_file}"

for sid in "${s_id_list[@]}"; do
    grab_microscope_file "${sid}"
done

tail -n +2 ${expectation_file} >> "${observations_file}"


java -jar -server -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -Xmn256m \
     -XX:+UseStringDeduplication -XX:CMSInitiatingOccupancyFraction=70 \
     -Xms2g -Xmx4g ${grools} ${grools_opts[@]} "${observations_file}" "${output}"

echo "Visualize results $(readlink -m ${output}/index.html)"