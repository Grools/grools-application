#!/usr/bin/env bash
#set -x
appname=$(basename $0)
version='1.0.0'
grools='./grools-application.jar'
tmpDir=$(mktemp -d -t ${appname}.XXXXXX)
proteome=0
proteome_file=""
expectation_file=""
output="$(pwd)"
IFS_ORI="${IFS}"
grools_opts=('-d' '-g')

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
      -j|--jar)    grools="$2"       ; shift;;
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

java -jar -server -XX:+UseParallelGC -Xmx4g -Xms2g ${grools} ${grools_opts[@]} ${proteome_file} ${output}

echo "Visualize results $(readlink -m ${output}/index.html)"


