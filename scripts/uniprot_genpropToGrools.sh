#!/usr/bin/env bash
declare appname=$(basename $0)
declare version='1.0.0'
declare grools='./grools-application.jar'
declare tmpDir=$(mktemp -d -t ${appname}.XXXXXX)
declare proteome=0
declare proteome_file=""
declare expectation_file=""
declare output="$(pwd)"
declare grools_opts=('-d' '-g')
declare -A ids

show_help(){
  echo $"$0 [OPTIONS] proteome_number expectation_file
  -h --help      display this help
  -v --version   version ${version}
  -f --falsehood enable falsehood mode
  -o --output    path to store output result (default: ${output})
  -j --jar       path to grools-application (default ${grools} )"
}

show_version(){
  echo "version ${version}"
}


argparse(){
  while [[  $@ = -* ]]; do
    case "$1" in
      -h|--help)      show_help         ; exit;;
      -v|--version)   show_version      ; exit;;
      -f|--falsehood) grools_opts+=('-f') ;;
      -o|--output)    output="$2"       ; shift;;
      -j|--jar)       grools="$2"       ; shift;;
      *) echo 'Unexpected parameter '$1 >&2; exit;;
    esac
    shift
  done
  
  if [[ $# -ge 2 ]]; then
    proteome=$1
    expectation_file=$2
  else
    show_help
    exit 1
  fi
  
  proteome_file="${output}"'/'"${proteome}"'.csv'
}

id_is_present () {
    # If the given key maps to a non-empty string (-n), the
    # key obviously exists. Otherwise, we need to check if
    # the special expansion produces an empty string or an
    # arbitrary non-empty string.
    if [[ -z $1 ]]; then
        (>&2 echo "Error: empty id")
        exit 1;
    fi
    [[ -n ${ids[$1]} || -z ${ids[$1]-foo} ]] && return 1 || return 0
}


grab_uniprot_file(){
  local label=""
  local tmplabel=""
  local evidenceFor=""
  local -r type="COMPUTATION"
  local -r isPresent="T"
  local -i id_counter=0
  local source=""
  local name=""
  local description=""
  local priorknowledges=""
  local -a Array
  echo '"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"' > "${proteome_file}"
  curl -Lso ${tmpDir}/${proteome}.csv 'http://www.uniprot.org/uniprot/?query=proteome:'${proteome}'&format=tab&columns=id,database%28Pfam%29,database%28TIGRFAMS%29,genes,protein%20names'
  {
    read
    while read -r line
    do
      fields=$(tr '\t' '$' <<< "${line}")
      IFS='$'; read entry pfams tigrfams genes bio_function  <<< "${fields}"
      priorknowledges="${pfams}${tigrfams}"
      while IFS=';' read -ra PKS; do
        for i in "${PKS[@]}"; do
          id_counter=0
          tmplabel=${entry}'_'${i}
          while ! id_is_present "${tmplabel}"; do
            ((id_counter++))
             tmplabel="${label}_${id_counter}"
          done
          label="${tmplabel}"
          evidenceFor=${i}
          if [[ ${evidenceFor} == PF* ]]; then
            source="PFAM"
          elif [[ ${evidenceFor} == TIGR* ]]; then
            source="TIGRFAM"
          else
            source="uniprot"
          fi
          name=${entry}','${genes}
          description=${bio_function}
          echo '"'${label}'";"'${evidenceFor}'";"'${type}'";"'${isPresent}'";"'${source}'";"'${name}'";"'${description}'"' >> "${proteome_file}"
        done
      done <<< "${priorknowledges}"
    done
  }< "${tmpDir}/${proteome}.csv"
}

argparse $@

if [[ -e "${output}" ]]; then
  if [[ ! -d "${output}" ]]; then
    echo "Error: "${output}" is not a directory!" >&2
    exit 1
  fi
else
  mkdir -p "${output}"
fi


grab_uniprot_file

tail -n +2 ${expectation_file} >> "${proteome_file}"

java -jar -server -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -Xmn256m \
     -XX:+UseStringDeduplication -XX:CMSInitiatingOccupancyFraction=70 \
     -Xms2g -Xmx4g ${grools} ${grools_opts[@]} ${proteome_file} ${output}

echo "Visualize results $(readlink -m ${output}/index.html)"


