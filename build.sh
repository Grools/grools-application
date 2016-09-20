#!/usr/bin/env bash
die () {
    local parent_lineno message code
    parent_lineno="$1"
    message="$2"
    [[ -n $3 ]] && code="$3" || code=1
    PATH=$OLDPATH
    if [[ -n "$message" ]] ; then
        echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}" >&2
    else
        echo "Error on or near line ${parent_lineno}; exiting with status ${code}" >&2
    fi
    exit "${code}"
}

trap 'die ${LINENO}' 1 15 ERR

declare -ar projects=(Grools/grools-reasoner institut-de-genomique/bio-scribe Grools/grools-genome-properties-plugins Grools/grools-obo-plugins Grools/grools-reporter)

command -v dot >/dev/null 2>&1 || { echo >&2 "I require dot but it's not installed.  Aborting."; exit 1; }
runner="gradle"

echo '============='
if command -v "${runner}"  2>&1 >/dev/null; then
    echo 'Using gradle'
else
    runner='./gradlew'
    echo 'Using gradlew'
fi
echo '============='
echo ''

[[ ! -e build/dependencies ]] && mkdir -p build/dependencies
pushd build/dependencies > /dev/null
    for project in "${projects[@]}"; do
        projectname="${project#*/}"
        msg='Installing '"${projectname}"

        echo "${msg}"
        printf '*%.0s' $(seq  1 ${#msg})
        echo ''

        if [[ ! -d "${projectname}" ]]; then
            git clone --quiet https://github.com/"${project}".git "${projectname}" 
        else
            ( pushd ${projectname}; git pull; popd ) > /dev/null
        fi
        pushd ${projectname} > /dev/null
          ${runner} -q clean build install
        popd > /dev/null

        echo ''
    done
popd > /dev/null

${runner} -q shadowJar

declare -ra jars=(build/libs/*.jar)

echo ''
echo '============================================================================================'
echo 'Generated files:'

for j in "${jars[@]]}"; do
    echo "  - $j"
done
echo '============================================================================================'
