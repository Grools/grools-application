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

#### From shell script
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

#### From jar file
The application ca be launch directly with the jar file, as follow:
```bash
java -jar  build/libs/grools-application-1.0.0.jar [-u/-g] observations.csv results_dir/
```

This application require three parameters:
- list of observations in well formatted csv file (see section CSV format)
- a directory to save results
- the option -g or -u need to be provided to let the reasoner took the right prior-knowledge model (genome properties or unipathway )

## CSV format
The file need to start with the corresponding header:
```csv
Name;EvidenceFor;Type;isPresent;Source;Label;Description
```
### Fields
- Name: is a unique string usable as an id
- EvidenceFor: is the name to related prior-knowledge
- Type: CURATION,EXPECTATION,COMPUTATION
- isPresent: T or F (True/False)
- Source: is the origin of the given observation as: EC,METACYC,TIGRFAM,PFAM,RHEA...
- Label: A strings fields
- Description: An description of the given observation. This is displayed on the user interface.

## Build

Grools-application require to pre-install some libraries:
- dot from [Graphviz](https://github.com/ellson/graphviz)
- [grools-reasoner](https://github.com/Grools/grools-reasoner)
- [bio-scribe](https://github.com/institut-de-genomique/bio-scribe)
- [grools-genome-properties](https://github.com/Grools/grools-genome-properties-plugins)
- [grools-obo](https://github.com/Grools/grools-obo-plugins)
- [grools-reporter](https://github.com/Grools/grools-reporter)

These projects use the powerful Gradle as build system. If you do not have or you can not install it.
Instead of `gradle` use the corresponding wrapper on each projects:
- gradlew for unix
- gradlew.bat for windows

### Install script

```bash
bash build.sh

git clone https://github.com/Grools/grools-application
pushd grools-application
  gradle clean shadowJar
popd
```

The executable jar file will be located into `grools-application/build/libs/` directory
