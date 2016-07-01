#!/usr/bin/env bash
#set -x
appname=$(basename $0)
version='1.0.0'
grools='./grools-application.jar'
tmpDir=$(mktemp -d -t ${appname}.XXXXXX)
proteome=0
expectation_file=""
hasCustomOutput=false
output=$(pwd)/proteome_number.csv
IFS_ORI="${IFS}"
hasFalsehood=false

show_help(){
  echo $"$0 [OPTIONS] proteome_number expectation_file
  -h --help      display this help
  -v --version   version ${version}
  -f --falsehood enable falsehood mode
  -o --output    path to store output result (default: ${output})
  -g --grools    path to grools-checker-genome-properties-application (default ${grools} )"
}

show_version(){
  echo "version ${version}"
}



argparse(){
  while [[  $@ = -* ]]; do
    case "$1" in
      -h|--help)      show_help   ; exit;;
      -v|--version)   show_version; exit;;
      -f|--falsehood) hasFalsehood=true;;
      -o|--output)    output=$2   ; hasCustomOutput=true; shift;;
      -g|--grools)    grools=$2   ;shift;;
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
  
  if ! ${hasCustomOutput}; then
    output=$(pwd)'/'${proteome}'.csv'
  fi
}


grab_uniprot_file(){
  local label=""
  local evidenceFor=""
  local -r type="COMPUTATION"
  local -r isPresent="T"
  local source=""
  local name=""
  local description=""
  local priorknowledges=""
  local -a Array
  echo '"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"' > "${output}"
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
          label=${entry}'_'${i}
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
          echo '"'${label}'";"'${evidenceFor}'";"'${type}'";"'${isPresent}'";"'${source}'";"'${name}'";"'${description}'"' >> "${output}"
        done
      done <<< "${priorknowledges}"
    done
  }< "${tmpDir}/${proteome}.csv"
}

argparse $@
dir=$(dirname ${output})

if [[ -e ${dir} ]]; then
  if [[ ! -d ${dir} ]]; then
    echo "Error: "${dir}" is not a directory!" >&2
    exit 1
  fi
else
  mkdir -p ${dir}
fi


grab_uniprot_file

tail -n +2 ${expectation_file} >> "${output}"

dir_report=$(dirname "${output}")/"${proteome}"

if ${hasFalsehood}; then
    java -jar ${grools} -d -f -g "${output}"  "${dir_report}"
else
    java -jar ${grools} -d -g "${output}"  "${dir_report}"
fi

echo "Visualize results ${dir_report}/index.html"


