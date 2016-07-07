#!/usr/bin/env bash
projects=(grools-checker grools-drools-checker genome-properties-model genome-properties-parser grools-checker-genome-properties obo-model obo-parser grools-checker-obo grools-checker-reporter)
git clone https://github.com/Grools/grools-checker
git clone https://github.com/Grools/grools-drools-checker
git clone https://github.com/institut-de-genomique/genome-properties-model
git clone https://github.com/institut-de-genomique/genome-properties-parser
git clone https://github.com/Grools/grools-checker-genome-properties
git clone https://github.com/institut-de-genomique/obo-model
git clone https://github.com/institut-de-genomique/obo-parser
git clone https://github.com/Grools/grools-checker-obo
git clone https://github.com/Grools/grools-checker-reporter

command -v dot >/dev/null 2>&1 || { echo >&2 "I require dot but it's not installed.  Aborting."; exit 1; }
runner="gradle"
if command -v "${runner}"  2>&1; then
    echo 'Using gradle'
else
    runner='./gradlew'
    echo 'Using gradlew'
fi

for project in "${projects[@]}"; do
    pushd ${project}
      ${runner} clean build install
    popd
done

git clone https://github.com/Grools/grools-application
pushd grools-application
  gradle clean shadowJar
popd
