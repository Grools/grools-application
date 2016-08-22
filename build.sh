#!/usr/bin/env bash
declare -ar projects=(grools-reasoner bio-scribe grools-genome-properties grools-obo grools-reporter)

command -v dot >/dev/null 2>&1 || { echo >&2 "I require dot but it's not installed.  Aborting."; exit 1; }
runner="gradle"
if command -v "${runner}"  2>&1; then
    echo 'Using gradle'
else
    runner='./gradlew'
    echo 'Using gradlew'
fi

mkdir build
push build
    git clone https://github.com/Grools/grools-reasoner
    git clone https://github.com/institut-de-genomique/bio-scribe
    git clone https://github.com/Grools/grools-genome-properties-pugins
    git clone https://github.com/Grools/grools-obo-pugins
    git clone https://github.com/Grools/grools-reporter

    for project in "${projects[@]}"; do
        pushd ${project}
          ${runner} clean build install
        popd
    done
popd

gradle clean shadowJar

declare -ra jars=(build/libs/*.jar)

echo 'Generated files:'

for j in "${jars[@]]}"; do
    echo "  - $j"
done
