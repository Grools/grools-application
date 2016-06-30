# GROOLS Application

GROOLS is a powerfull reasoner to deal with uncertainties and contradiction. This application is a standalone tools to show a possible usage of GROOLS API.

## Biology
GROOLS is applied here on biology and bioinformatics fields. Indeed in biology we have a lot of uncertainties. We propose here two different knowledge models:
 - GenomeProperties from J. Craig Venter Institute
 - Unipathway from SwissProt

### Scripts
As example of usage we made two shell scripts that grab data from Microscope Platform and Uniprot.
Predicted prior-knowledge are tooks from Uniprot for genome properties knowlede model.
Predicted prior-knowledge are tooks from Microscope for unipathway knwoledge model.

### Usage
Shell scripts are  easy to use. Once grools-application is build, you have to provide:
- the path to the jar file
- organism/proteome number
- expectation list

```bash
./scripts.uniprotTogrools.sh -g build/libs/grools-application-1.0.0.jar UP000000625 ~/expectation.csv
```
```bash
./scripts/microscopeTogrools.sh -g build/libs/grools-application-1.0.0.jar 36 ~/expectation.csv
```

## CSV format
The file need start with the corresponding header:
```csv
Name;EvidenceFor;Type;isPresent;Source;Label;Description
```
### Fields
- Name: is a unique string usable as an id
- EvidenceFor: is the name to related prior-knowledge
- Type: ANNOTATION,EXPECTATION,COMPUATATION
- isPresent: T or F (True/False)
- Source: is the origin of the given observation as: EC,METACYC,TIGRFAM,PFAM,RHEA...
- Label: A strings fields
- Description: An description of the given observation. This is displayed on the user interface.

## Build

Grools-application require to pre-install some libraries:
- [grools-checker](https://github.com/Grools/grools-checker)
- [grools-drools-checker](https://github.com/Grools/grools-drools-checker)
- [genome-properties-model](https://github.com/institut-de-genomique/genome-properties-model)
- [genome-properties-parser](https://github.com/institut-de-genomique/genome-properties-parser)
- [grools-checker-genome-properties](https://github.com/Grools/grools-checker-genome-properties)
- [obo-model](https://github.com/institut-de-genomique/obo-model)
- [obo-parser](https://github.com/institut-de-genomique/obo-parser)
- [grools-checker-obo](https://github.com/Grools/grools-checker-obo)
- [grools-checker-reporter](https://github.com/Grools/grools-checker-reporter)

These projects use the powerfull Gradle as build system. If you do not have or you can not install it.
Instead of `gradle` use the corresponfing wrapper on each projects:
- gradlew for unix
- gradlew.bat for windows

```bash
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

for project in "${projects[@]}"; do
    pushd ${project}
      gradle clean build install
    popd
done

git clone https://github.com/Grools/grools-application
pushd grools-application
  gradle clean shadowJar
popd
```

The executable jar file will be located into `grools-application/build/libs/` directory
