#!/usr/bin/env bash
declare -a reader_results=()
declare appname=$(basename $0)
declare version='1.0.0'
declare grools='./grools-application.jar'
declare proteome=0
declare proteome_file=""
declare expectation_file=""
declare grools_opts=( '-u' 'UER' )
declare output="$(pwd)"

show_help(){
  echo $"$0 [OPTIONS] proteome_number expectation_file
  -h --help      display this help
  -v --version   version ${version}
  -s --specific  enable specific mode
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
      -s|--specific)  grools_opts+=('-s') ;;
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
        if [[ $result = $substring ]]; then
            index=-1
        else
            index=$(( ${#result} + startIndex ))
        fi
    fi
    echo $index
}

# read fields from delimited file with quoted string
reader(){
    local line="${1}"
    local delimiter=','
    local isProcessing=0
    local -i currentIndex=0
    local -i commaIndex=0
    local -i quoteStartIndex=0
    local -i quoteEndIndex=0
    local field=''
    local range=0
    while [[ isProcessing -eq 0 ]]; do
        commaIndex=$(strindex "$line" $currentIndex ',')
        quoteStartIndex=$(strindex "$line" $currentIndex '"')
        if [[ $quoteStartIndex -ne -1 && $commaIndex -gt $quoteStartIndex ]]; then
            quoteEndIndex=$(strindex "$line" $(( quoteStartIndex + 1 )) '"')
            range=$(( quoteEndIndex - quoteStartIndex + 1 ))
            reader_results+=("${line:$quoteStartIndex:$range}") # +1 ?
            #echo ${line:$quoteStartIndex:$range}
           currentIndex=$((quoteEndIndex+2))  # assume +1 == ',' start at +2 to find next fields
        elif [[ $commaIndex -eq -1 ]]; then
            reader_results+=("${line:$currentIndex}") # +1 ?
            #echo ${line:$currentIndex}
            isProcessing=1
        else
            range=$(( commaIndex - currentIndex ))
            reader_results+=("${line:$currentIndex:$range}") # +1 ?
            #echo ${line:$currentIndex:$range}
            currentIndex=$((commaIndex+1))
        fi
    done
}


grab_uniprot_file(){
    local line
    local protein_url
    local protein
    local description
    local gene_name
    local ec_url
    local ec
    local upa_url
    local upa
    local name
    local label
    local priorknowledge
    local source

    :>"${proteome_file}"
    {
        {
            # skip first line
            read
            echo "Name"';'"EvidenceFor"';'"Type"';'"isPresent"';'"Source"';'"Label"';'"Description"
            #while IFS=',' read protein_url description gene_name ec upa_url; do
            while read line; do
                reader "$line"
                protein_url="${reader_results[0]}"
                description="${reader_results[1]}"
                gene_name="${reader_results[2]}"
                ec_url="${reader_results[3]}"
                upa_url="${reader_results[4]}"
                # clear array
                reader_results=()
                #echo $protein_url','$description','$gene_name','$ec','$upa_url
                gene_name="${gene_name//\"/}"
                protein="${protein_url##*/}"
                if [[ ! -z "$ec_url" ]]; then
                    ec="${ec_url##*/}"
                    label="${protein}"'_'"${ec}"
                    priorknowledge="${ec}"
                    source='EC'
                elif [[ ! -z "$upa_url" ]]; then
                    IFS='.' read -a upa_components <<< "${upa_url##*/}"
                    #if [[ ${#upa_components[@]} -eq 3 ]]; then
                    #    priorknowledge=$(printf "ULS%05d" "${upa_component[2]}")
                    #    label="${protein}"'_'"${priorknowledge}"
                    #    source='unipathway'
                    if [[ ${#upa_components[@]} -eq 4 ]]; then
                        priorknowledge=$(printf "UER%05d" "${upa_components[3]}")
                        label="${protein}"'_'"${priorknowledge}"
                        source='unipathway'
                    fi
                fi
                if [[ ! -z "$source" ]]; then
                    name="${label}"','"${gene_name}"
                    echo '"'${label}'";"'${priorknowledge}'";"COMPUTATION";"'T'";"'${source}'";"'${name}'";'${description}
                fi
                source=''
            done
        } < <(curl -s -G -H "Accept: text/csv" http://sparql.uniprot.org/sparql --data-urlencode  query='
PREFIX up:<http://purl.uniprot.org/core/>
PREFIX uniprot:<http://purl.uniprot.org/uniprot/>
PREFIX proteomes:<http://purl.uniprot.org/proteomes/>
PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
SELECT ?protein (group_concat(CONCAT(?recdesc, ?subdesc) ; separator=" ") AS ?description)  (group_concat(distinct ?gene_name ; separator="-") AS ?gene_name)   ?ec ?pathwayAnnotationXref
WHERE {
  ?protein a up:Protein .
  ?protein up:proteome ?proteomeComponent .
  ?proteome skos:narrower ?proteomeComponent .
  OPTIONAL {
  ?protein up:encodedBy ?gene .
  ?gene skos:prefLabel ?gene_name .
  }
  OPTIONAL {
  ?protein up:recommendedName ?recommended .
  ?recommended up:fullName ?recdesc .
  }
  OPTIONAL {
  ?protein up:submittedName ?submitted .
  ?submitted up:fullName ?subdesc .
  }
  {
  ?protein up:annotation ?pathwayAnnotation .
  ?pathwayAnnotation a up:Pathway_Annotation  .
  ?pathwayAnnotation rdfs:seeAlso ?pathwayAnnotationXref .
   }
  UNION
  {
  ?protein up:enzyme ?ec .
  }
  FILTER (?proteome = proteomes:'"${proteome}"')
}
group by ?protein ?ec ?pathwayAnnotationXref')
    } > "${proteome_file}"

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


