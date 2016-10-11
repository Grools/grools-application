#!/usr/bin/env bash
#set -x
declare -r version='1.0.0'
declare -A pm
declare -A genprop_desc
declare -A genprop_nrj_source
declare    biolog=''
declare    mapper=''
declare    output=''
declare -a reader_results=()

show_help(){
    echo "$0"' MAPPER OUTPUT BIOLOG...'
    echo 'version: '${version}
    echo 'MAPPER is a tabulated file: "Plate" "Position" "Property name" "Property id" "Description"'
    echo 'OUTPUT is a file path to store well formatted expectation'
    echo 'BIOLOG is a tabulated file: "Plate" "Position" "Observation"'
    echo '    * Observation value can be: TRUE,FALSE,NA'
    echo '-h --help     display this help'
}


argparse(){
  while [[  $@ = -* ]]; do
    case "$1" in
      -h|--help)      show_help   ; exit;;
    esac
  done
}


# strindex
# can be use with 2 or 3 parameters.
# parameters:
# - 1) string 2) character to find
# - 1) string 2) index to start the search 3) character to find
# return  the index of char from original string or -1 if not found
strindex() {
    local -i index=0
    local result=''
    local string=''
    local needle=''
    local -i startIndex=0
    local substring=''
    if [[ $# -eq 2  ]]; then
        string="${1}"
        needle="${2}"
        substring="${1:$startIndex}"
    elif [[ $# -eq 3 ]]; then
        string="${1}"
        startIndex=$2
        needle="${3}"
        substring="${1:$startIndex}"
    else
        index=-1
    fi
    if [[ $index -ne -1 ]]; then
        result="${substring%%$needle*}"
        if [[ $result = "$substring" ]]; then
            index=-1
        else
            index=$(( ${#result} + startIndex ))
        fi
    fi
    echo $index
}


# read fields from delimited file with quoted string
reader(){
    local -r line="${1}"
    local delimiter=$'\t'
    local isProcessing=0
    local -i currentIndex=0
    local -i tabIndex=0
    local -i quoteStartIndex=0
    local -i quoteEndIndex=0
    local field=''
    local range=0
    while [[ isProcessing -eq 0 ]]; do
        tabIndex=$(strindex "$line" $currentIndex "${delimiter}")
        quoteStartIndex=$(strindex "$line" $currentIndex '"')
        if [[ $quoteStartIndex -ne -1 && $tabIndex -gt $quoteStartIndex ]]; then
            quoteEndIndex=$(strindex "$line" $(( quoteStartIndex + 1 )) '"')
            range=$(( quoteEndIndex - quoteStartIndex + 1 ))
            reader_results+=("${line:$quoteStartIndex:$range}") # +1 ?
            #echo ${line:$quoteStartIndex:$range}
            currentIndex=$((quoteEndIndex+2))  # assume +1 == ',' start at +2 to find next fields
        elif [[ $tabIndex -eq -1 ]]; then
            reader_results+=("${line:$currentIndex}") # +1 ?
            #echo ${line:$currentIndex}
            isProcessing=1
        else
            range=$(( tabIndex - currentIndex ))
            reader_results+=("${line:$currentIndex:$range}") # +1 ?
            #echo ${line:$currentIndex:$range}
            currentIndex=$((tabIndex+1))
        fi
    done
}


load_mapper(){
    local -r mapfile="$1"
    local priorknowledge_id
    while IFS=$'\t' read -r plate position nrj_source id description; do
        if [[ ! -z ${id} ]]; then
            priorknowledge_id=${id/ /}
            pm[${plate}'_'${position}]="${priorknowledge_id}"
            genprop_desc[${priorknowledge_id}]="${description}"
            genprop_nrj_source[${priorknowledge_id}]="${nrj_source}"
        fi
    done < "${mapfile}"
}


write_expectation(){
    local -r output="$1"
    local -r biolog="$2"
    local name=''
    local name_id=''
    local -i counter
    local evidence=''
    local -r obs_type='EXPERIMENTATION'
    local obs_source_suffix='BIOLOG experimentation: '
    local obs_source=''
    local label=''
    local desc=''
    local -A ids
    local -A compounds=( [PM01]=carbon [PM02]=carbon [PM03]=nitrogen [PM04]=sulfur )
    {
    read -r
    while read -r  line ; do
        reader "$line"
        plate="${reader_results[1]//\"/}"
        well="${reader_results[4]//\"/}"
        observation="${reader_results[20]//\"/}"
        # Date could be stored in various local as DE
        # $(date -d "${reader_results[3]//\"/}"  '+%Y%m%d%k%M')
        # remove quote
        experiment_date="${reader_results[0]//\"/}"
        # remove string before date
        experiment_date="${experiment_date##*_}"
        # remove file extension
        experiment_date="${experiment_date%.*csv}"
        # clear array
        reader_results=()
        name=${plate}'_'${well}
        evidence=${pm[${name}]}
        obs_source="${obs_source_suffix}${experiment_date}"
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
                echo '"'"${name_id}"'";"'"${evidence}"'";"'"${obs_type}"'";"T";"'"${obs_source}"'";"'"${label}"'";"Growth with '"${desc}"'"' >> "${output}"
            elif [[ "${observation}" == "FALSE" ]]; then
                echo '"'"${name_id}"'";"'"${evidence}"'";"'"${obs_type}"'";"F";"'"${obs_source}"'";"'"${label}"'";"No growth with '"${desc}"'"' >> "${output}"
            elif [[ "${observation}" == "NA" ]]; then
                echo '"'"${name_id}"'";"'"${evidence}"'";"'"${obs_type}"'";"T";"'"${obs_source}"'";"'"${label}"'";"Ambiguous growth with '"${desc}"'"' >> "${output}"
                ((counter++))
                name_id=${name}'_'${counter}
                ids[${name}]=${counter}
                echo '"'"${name_id}"'";"'"${evidence}"'";"'"${obs_type}"'";"F";"'"${obs_source}"'";"'"${label}"'";"Ambiguous growth with '"${desc}"'"' >> "${output}"
            else
                echo 'Error: biolog file is badly formatted. Unknown observation: '"${observation}" >&2
                exit 1
            fi
        fi
    done
    }< "${biolog}"
}

### Main ###

if [[ $# -lt 3 ]]; then
    show_help
    exit 1
fi

argparse "$@"

if [[ ! -e "$1" || ! -f "$1" ]]; then
    echo 'Error File '"$1"' do not exists' >&2
    exit 1
fi


dir=$(dirname "$2")
if [[ ! -e "${dir}" ]]; then
    mkdir -p "${dir}"
elif [[ ! -d "${dir}" ]]; then
    echo 'Error: '"${dir}"' exists and is not a directory!' >&2
    exit 1
fi

mapper="$1"
load_mapper "${mapper}"
output="$2"
shift;shift
echo '"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"' > "${output}"
for biolog_file in "${@}"; do
    if [[ ! -e "${biolog_file}" || ! -f "${biolog_file}" ]]; then
        echo 'Error File '"$2"' do not exists' >&2
        exit 1
    fi
    write_expectation "${output}" "${biolog_file}"
done