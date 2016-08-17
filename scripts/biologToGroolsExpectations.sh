#!/usr/bin/env bash
#set -x
mapper=''
biolog=''
output=''
declare -r version='1.0.0'
declare -A pm
declare -A genprop_desc
declare -A genprop_nrj_source

show_help(){
    echo $0' MAPPER BIOLOG OUTPUT'
    echo 'version: '${version}
    echo 'MAPPER is a tabulated file: "Plate" "Position" "Property name" "Property id" "Description"'
    echo 'BIOLOG is a tabulated file: "Plate" "Posistion" "Observation"'
    echo 'OUTPUT is a file path to store well formatted expectation'
    echo 'Observation value can be: TRUE,FALSE,NA'
    echo '-h --help     display this help'
}

argparse(){
  while [[  $@ = -* ]]; do
    case "$1" in
      -h|--help)      show_help   ; exit;;
    esac
  done
}

load_mapper(){
    local -r mapfile="$1"
    local genprop_id
    while IFS=$'\t' read -r plate position nrj_source id description; do
        if [[ ! -z ${id} ]]; then
            genprop_id=${id/ /}
            pm[${plate}'_'${position}]="${genprop_id}"
            genprop_desc[${genprop_id}]="${description}"
            genprop_nrj_source[${genprop_id}]="${nrj_source}"
        fi
    done < "${mapfile}"
}

write_expectation(){
    local biolog="$1"
    local output="$2"
    local name=''
    local name_id=''
    local -i counter
    local evidence=''
    local -r obs_type='EXPERIMENTATION'
    local -r obs_source='BIOLOG'
    local label=''
    local desc=''
    local -A ids
    local -A compounds=([PM01]=carbon [PM02]=carbon [PM03]=nitrogen [PM04]=sulfur )
    echo '"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"' > "${output}"
    while IFS=' ' read -r plate position observation; do
        name=${plate}'_'${position}
        evidence=${pm[${name}]}
        if [[ ! -z ${evidence} ]]; then
            if [[ ${ids[${name}]+_} ]]; then
                counter=${ids[${name}]}
                ((counter++))
            else
                counter=1    
            fi
            name_id=${name}'_'${counter}
            ids[${name}]=${counter}
            desc=${genprop_nrj_source[${evidence}]}' as '${compounds[${plate}]}' source'
            label=${genprop_desc[${evidence}]}
            if [[ "${observation}" == "TRUE" ]]; then
                echo '"'${name_id}'";"'${evidence}'";"'${obs_type}'";"T";"'${obs_source}'";"'${label}'";"Growth with '${desc}'"' >> "${output}"
            elif [[ "${observation}" == "FALSE" ]]; then
                echo '"'${name_id}'";"'${evidence}'";"'${obs_type}'";"F";"'${obs_source}'";"'${label}'";"No growth with '${desc}'"' >> "${output}"
            elif [[ "${observation}" == "NA" ]]; then
                echo '"'${name_id}'";"'${evidence}'";"'${obs_type}'";"T";"'${obs_source}'";"'${label}'";"Ambiguous growth with '${desc}'"' >> "${output}"
                ((counter++))
                name_id=${name}'_'${counter}
                ids[${name}]=${counter}
                echo '"'${name_id}'";"'${evidence}'";"'${obs_type}'";"F";"'${obs_source}'";"'${label}'";"Ambiguous growth with '${desc}'"' >> "${output}"
            else
                echo 'Error: biolog file is badly formatted. Unknown observation: '${observation} >&2
                exit 1
            fi
        fi
    done < "${biolog}"
}

if [[ $# -ne 3 ]]; then
    show_help
    exit 1
fi

argparse $@

if [[ ! -e "$1" || ! -f "$1" ]]; then
    echo 'Error File '"$1"' do not exists' >&2
    exit 1
fi

if [[ ! -e "$2" || ! -f "$2" ]]; then
    echo 'Error File '"$2"' do not exists' >&2
    exit 1
fi

dir=$(dirname "$3")
if [[ ! -e "${dir}" ]]; then
    mkdir -p "${dir}"
elif [[ ! -d "${dir}" ]]; then
    echo 'Error: '"${dir}"' exists and is not a directory!' >&2
    exit 1
fi

load_mapper "$1"
write_expectation "$2" "$3"
