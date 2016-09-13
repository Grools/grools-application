# GROOLS Application

GROOLS is a powerful reasoner representing knowledge as graph and dealing with uncertainties and contradictions for predictions and expectations. This application is a standalone tool that illustrates a possible usage of GROOLS API.

**Cite me** [![DOI](https://zenodo.org/badge/61386938.svg)](https://zenodo.org/badge/latestdoi/61386938)


## Biological application
This GROOLS application is a bioinformatics software that helps biologists in the evaluation of genome functional annotation through biological processes like metabolic pathways.

Two different resources are used to represent biological knowledge:
 - [Genome Properties](http://www.jcvi.org/cgi-bin/genome-properties/index.cgi)
 - [Unipathway](http://nar.oxfordjournals.org/content/40/D1/D761.long)

### Results
As test case, the reasoner was launched on 14 prokaryotic genomes/proteomes using:
- UniPathway or Genome Properties as prior-knowledge to represent biological processes like  metabolic pathways
- and protein annotations from [MicroScope](https://www.genoscope.cns.fr/agc/microscope)  and [UniProt](http://www.uniprot.org).

Results are available [here](http://www.genoscope.cns.fr/agc/grools/).

### Usage from shell script

Two shell scripts are available to grab annotations from MicroScope or Uniprot using UniPathway or Genome Properties as prior-knowledge, respectively.

Shell scripts are easy to use. Once grools-application is build, you have to provide:
- the path to the jar file
- organism/proteome identifier
- expectation file in GROOLS CSV format

```bash
./scripts/uniprotTogrools.sh -g build/libs/grools-application-1.0.0.jar UP000000625 ~/expectation.csv
```
```bash
./scripts/microscopeTogrools.sh -g build/libs/grools-application-1.0.0.jar 36 ~/expectation.csv
```

### Usage from jar file
The application ca be launched directly with the jar file, as follow:
```bash
java -jar  build/libs/grools-application-1.0.0.jar [-u/-g] observations.csv results_dir/
```

This application require three parameters:
- file of observations (predictions and expectations) in GROOLS CSV format
- a directory to save results
- the option -g  or -u to chose between Genome Properties (-g) or UniPathway (-u) as resource of prior-knowledge.

## GROOLS CSV format
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
