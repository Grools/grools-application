# GROOLS Application
[![CeCILL](https://img.shields.io/badge/license-CeCCILL-blue.svg)](https://raw.githubusercontent.com/Grools/grools-application/master/LICENSE) [![Java](https://img.shields.io/badge/language-Java-orange.svg)](http://www.java.com/)

GROOLS is a powerful reasoner representing knowledge as graph and dealing with uncertainties and contradictions for predictions and expectations. This application is a standalone tool that illustrates a possible usage of GROOLS API.


## How to cite

| Method      | [![DOI](https://img.shields.io/badge/DOI-10.1101%2F117994-green.svg)](https://doi.org/10.1101/117994) |
|-------------|-------------------------------------------------------------------------------------------------------|
| Application | [![DOI](https://zenodo.org/badge/61386938.svg)](https://zenodo.org/badge/latestdoi/61386938)          |


## Biological application
This GROOLS application is a bioinformatics software that helps biologists in the evaluation of genome functional annotation through biological processes like metabolic pathways.

Two different resources are used to represent biological knowledge:
 - [Genome Properties](http://www.jcvi.org/cgi-bin/genome-properties/index.cgi)
 - [UniPathway](http://nar.oxfordjournals.org/content/40/D1/D761.long)

### Results
As a test case, the reasoner was launched on 14 prokaryotic genomes/proteomes using:
- UniPathway or Genome Properties as prior-knowledge to represent biological processes like  metabolic pathways
- and protein annotations from [MicroScope](https://www.genoscope.cns.fr/agc/microscope)  and [UniProt](http://www.uniprot.org).

Results of this test case are available [here](http://www.genoscope.cns.fr/agc/grools/).

## Installation

GROOLS application requires: 
- java 1.8 or later
- dot from [Graphviz](https://github.com/ellson/graphviz)

### From release
Download and unzip GROOLS.zip file for the last [realease](https://github.com/Grools/grools-application/releases)

### Build from source

```bash
git clone https://github.com/Grools/grools-application
pushd grools-application
bash build.sh
popd
```
The executable jar file will be located in `grools-application/build/libs/` directory

Java library dependencies that are downloaded and installed
- [grools-reasoner](https://github.com/Grools/grools-reasoner)
- [bio-scribe](https://github.com/institut-de-genomique/bio-scribe)
- [grools-genome-properties](https://github.com/Grools/grools-genome-properties-plugins)
- [grools-obo](https://github.com/Grools/grools-obo-plugins)
- [grools-reporter](https://github.com/Grools/grools-reporter)

## Usage

### Usage from shell script

Three shell scripts are available to grab annotations from MicroScope or UniProt using UniPathway or Genome Properties as prior-knowledge, respectively.

UniProt TIGRFAM/PFAM predictions with Genome Properties
```bash
./scripts/uniprot_genpropToGrools.sh
```

UniProt annotations with UniPathway
```bash
./scripts/uniprot_upaToGrools.sh
```
MicroScope  annotations with UniPathway
```bash
./scripts/microscope_upaToGrools.sh  
```

### Usage from jar file
The application can be launched directly with the jar file, as follow:
```bash
java -jar  build/libs/grools-application-1.0.0.jar [-u/-g] observations.csv results_dir/
```

This application requires three parameters:
- file of observations (predictions and expectations) in GROOLS CSV format
- a directory to save results
- the option -g  or -u to choose between Genome Properties (-g) or UniPathway (-u) as a resource of prior-knowledge.

### GROOLS CSV file format
This file format allows user to declare observations that will be propagated on the prior-knowledge graph.
The header of the CSV file should be:
```csv
Name;EvidenceFor;Type;isPresent;Source;Label;Description
```
#### Fields
- **Name:** is a unique identifier
- **EvidenceFor:** is the name of the related prior-knowledge
- **Type:** CURATION,EXPERIMENTATION,COMPUTATION
- **isPresent:** T or F (True/False)
- **Source:** is the origin of the given observation (e.g. UniProt, MicroScope, BIOLOG)
- **Label:** is a short description of the observation 
- **Description:** is a complete description of the observation

### Examples
Files containing Acinetobacter baylyi ADP1 observations for:
- UniProt (PFAM and TIGRFAM) and Biolog results related to Genome Properties ([link](https://www.genoscope.cns.fr/agc/grools/UP000000430-AbaylyiADP1/genome-properties/uniprot/falsehood/UP000000430.csv))
- MicroScope (EC number, RHEA and MetaCyc reactions) and Biolog results related to UniPathway ([link](https://www.genoscope.cns.fr/agc/grools/UP000000430-AbaylyiADP1/unipathway/microscope/specific/observations.csv))


## Tutorial
Example Directory contains a set of data to learn how to use GROOLS application:

```
examples/
├── biolog
│   ├── AbaylyiADP1
│   │   └── PM1_A_101117.tab
│   └── pk_observation_mapper
│       ├── biolog_plates_cells_name_evidencesForGenProp_description.tsv
│       └── biolog_plates_cells_name_evidencesForUPA_description.tsv
├── expectation_genprop_aa.csv
└── expectation_upa_aa.csv

```

### Using UniPathway as Prior-Knowledge graph

#### Expectations: grab and formatting tasks

##### Background knowkedge

Often you expect to retrieve a list of metabolic pathways as you have acquired a background knwoledge on your studied organism (from your experience and the litterarure). Thus we provides a tool to convert your expectations list to GROOLS csv file format.
You can to define a list of expected presence of metabolic pathways in your organism. As example a proptotroph organism should have all amino acid biosynthesis pathways.
Such expectations are stored into the file `expectation_upa_aa.csv` as follow :

```csv
$ cat examples/expectation_upa_aa.csv
Accession;Name
UPA00031;L-histidine biosynthesis
UPA00035;L-tryptophan biosynthesis
UPA00047;L-isoleucine biosynthesis
UPA00048;L-leucine biosynthesis
UPA00049;L-valine biosynthesis
UPA00050;L-threonine biosynthesis
UPA00068;L-arginine biosynthesis
UPA00098;L-proline biosynthesis
UPA00121;L-phenylalanine biosynthesis
UPA00122;L-tyrosine biosynthesis
UPA00133;L-alanine biosynthesis
UPA00134;L-asparagine biosynthesis
UPA00135;L-serine biosynthesis
UPA00136;L-cysteine biosynthesis
UPA00288;glycine biosynthesis
UPA00404;L-lysine biosynthesis
UPA00633;L-glutamate biosynthesis
UPA00051;L-methionine biosynthesis via de novo pathway
UPA01012;L-aspartate biosynthesis
UPA01013;L-glutamine biosynthesis
```

Once this file is made you ave to convert this list to GROOLS csv file format (see section [GROOLS CSV file format](#grools-csv-file-format)).
To perform this task, simply run:

```bash
$ ./scripts/expectations_list_to_grools_csv.sh examples/expectation_upa_aa.csv examples/expectation_upa_aa.grools.csv
```

This command generate a file named `expectation_upa_aa.grools.csv`:

```csv
"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"
"Exp_UPA00031";"UPA00031";"EXPERIMENTATION";"T";"";"Exp_UPA00031";"L-histidine biosynthesis"
"Exp_UPA00035";"UPA00035";"EXPERIMENTATION";"T";"";"Exp_UPA00035";"L-tryptophan biosynthesis"
"Exp_UPA00047";"UPA00047";"EXPERIMENTATION";"T";"";"Exp_UPA00047";"L-isoleucine biosynthesis"
"Exp_UPA00048";"UPA00048";"EXPERIMENTATION";"T";"";"Exp_UPA00048";"L-leucine biosynthesis"
"Exp_UPA00049";"UPA00049";"EXPERIMENTATION";"T";"";"Exp_UPA00049";"L-valine biosynthesis"
"Exp_UPA00050";"UPA00050";"EXPERIMENTATION";"T";"";"Exp_UPA00050";"L-threonine biosynthesis"
"Exp_UPA00068";"UPA00068";"EXPERIMENTATION";"T";"";"Exp_UPA00068";"L-arginine biosynthesis"
"Exp_UPA00098";"UPA00098";"EXPERIMENTATION";"T";"";"Exp_UPA00098";"L-proline biosynthesis"
"Exp_UPA00121";"UPA00121";"EXPERIMENTATION";"T";"";"Exp_UPA00121";"L-phenylalanine biosynthesis"
"Exp_UPA00122";"UPA00122";"EXPERIMENTATION";"T";"";"Exp_UPA00122";"L-tyrosine biosynthesis"
"Exp_UPA00133";"UPA00133";"EXPERIMENTATION";"T";"";"Exp_UPA00133";"L-alanine biosynthesis"
"Exp_UPA00134";"UPA00134";"EXPERIMENTATION";"T";"";"Exp_UPA00134";"L-asparagine biosynthesis"
"Exp_UPA00135";"UPA00135";"EXPERIMENTATION";"T";"";"Exp_UPA00135";"L-serine biosynthesis"
"Exp_UPA00136";"UPA00136";"EXPERIMENTATION";"T";"";"Exp_UPA00136";"L-cysteine biosynthesis"
"Exp_UPA00288";"UPA00288";"EXPERIMENTATION";"T";"";"Exp_UPA00288";"glycine biosynthesis"
"Exp_UPA00404";"UPA00404";"EXPERIMENTATION";"T";"";"Exp_UPA00404";"L-lysine biosynthesis"
"Exp_UPA00633";"UPA00633";"EXPERIMENTATION";"T";"";"Exp_UPA00633";"L-glutamate biosynthesis"
"Exp_UPA00051";"UPA00051";"EXPERIMENTATION";"T";"";"Exp_UPA00051";"L-methionine biosynthesis via de novo pathway"
"Exp_UPA01012";"UPA01012";"EXPERIMENTATION";"T";"";"Exp_UPA01012";"L-aspartate biosynthesis"
"Exp_UPA01013";"UPA01013";"EXPERIMENTATION";"T";"";"Exp_UPA01013";"L-glutamine biosynthesis"
```
&#x1F536; Indeed you can to write directly a such file.

##### Biolog experimentations

Biolog experimations observations are representated with numerical growth values. That is why, these quantitatives growth phenotypes data should be first discretized to three states `FALSE` (no growth), `TRUE` (growth), `NA` (growth maybe). To achieve this, we use the [omp](http://bioinformatics.oxfordjournals.org/content/29/14/1823.short) R package with "grofit" aggregation method and weak discretization (-a, -w and -z options of run_opm.R program).
Sample of a file after discretization of Biolog numerical values:

```csv
"File"	"Plate_Type"	"Position"	"Setup_Time"	"Well"	"mu"	"lambda"	"A"	"AUC"	"mu_CI95_low"	"lambda_CI95_low"	"A_CI95_low"	"AUC_CI95_low"	"mu_CI95_high"	"lambda_CI95_high"	"A_CI95_high"	"AUC_CI95_high"	"Aggr_software"	"Aggr_version"	"Aggr_method"	"Discretized"	"Disc_software"	"Disc_version"	"Disc_method"
".//01_Abaylyi_PM1_A_101117.csv"	"PM01"	"15-A"	"Nov 17 2010 5:28 PM"	"A01"	11.0239490374402	0.101998280074103	50.0586437522741	4437.423792864	10.8538314459345	-51.4322872382767	50.2978431840183	4398.07750163227	16.5264325297181	85.9780629028097	53.0550158798986	4463.39457157138	"opm"	"1.3.51"	"grofit"	FALSE	"opm"	"1.3.51"	"kmeans"
".//01_Abaylyi_PM1_A_101117.csv"	"PM01"	"15-A"	"Nov 17 2010 5:28 PM"	"A02"	6.47772286994336	-1.17233134884521	50.2660273428748	4294.08252281865	5.46716638240377	-34.66207762553	50.201817207401	4251.13805006296	14.7111400864039	119.317927831985	54.03143182126	4316.55817358922	"opm"	"1.3.51"	"grofit"	FALSE	"opm"	"1.3.51"	"kmeans"
".//01_Abaylyi_PM1_A_101117.csv"	"PM01"	"15-A"	"Nov 17 2010 5:28 PM"	"A03"	5.4787776379894	-0.0367891891096806	29.6073109885561	2566.50462868851	3.31739323527425	-17.3502549023257	29.7878444150652	2537.08932176093	17.0850517869014	148.128379766773	34.4615301314378	2582.13004990163	"opm"	"1.3.51"	"grofit"	FALSE	"opm"	"1.3.51"	"kmeans"
".//01_Abaylyi_PM1_A_101117.csv"	"PM01"	"15-A"	"Nov 17 2010 5:28 PM"	"A04"	28.2949132058871	2.32411771576596	280.974739519407	24314.2418801986	24.6195674041815	-1.88104660891929	279.792049404854	24166.4620590466	33.2211611953979	8.79005432069948	282.364609613145	24389.7797251403	"opm"	"1.3.51"	"grofit"	TRUE	"opm"	"1.3.51"	"kmeans"
```

These tabulated files are converted to GROOLS csv file format using `biologToGroolsExpectations.py` script as follow:

```bash
$ ./scripts/biologToGroolsExpectations.py examples/biolog/pk_observation_mapper/biolog_plates_cells_name_evidencesForUPA_description.tsv biolog_list_of_expectations_upa.csv  examples/biolog/AbaylyiADP1/*.tab
```

This command generate a file `biolog_list_of_expectations_upa.csv`

```csv
"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"
"PM01_A02_1";"UPA00463";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"L-arabinose degradation";"No growth with L-Arabinose as carbon source"
"PM01_A08_1";"UPA00532";"EXPERIMENTATION";"T";"BIOLOG experimentation: 101117";"L-proline degradation";"Growth with L-Proline as carbon source"
"PM01_A09_1";"UPA00043";"EXPERIMENTATION";"T";"BIOLOG experimentation: 101117";"D-alanine degradation";"Growth with D-Alanine as carbon source"
"PM01_B02_1";"UPA00812";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"D-sorbitol degradation";"No growth with D-Sorbitol as carbon source"
"PM01_B03_1";"UPA00616";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"glycerol degradation";"No growth with Glycerol as carbon source"
"PM01_B04_1";"UPA00563";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"L-fucose degradation";"No growth with L-Fucose as carbon source"
"PM01_B06_1";"UPA00792";"EXPERIMENTATION";"T";"BIOLOG experimentation: 101117";"D-gluconate degradation";"Growth with D-Gluconic Acid as carbon source"
"PM01_B08_1";"UPA00810";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"D-xylose degradation";"No growth with D-Xylose as carbon source"
"PM01_B12_1";"UPA00351";"EXPERIMENTATION";"T";"BIOLOG experimentation: 101117";"L-glutamate degradation";"Growth with L-Glutamic Acid as carbon source"
"PM01_C04_1";"UPA00916";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"D-ribose degradation";"No growth with D-Ribose as carbon source"
"PM01_C06_1";"UPA00541";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"L-rhamnose degradation";"No growth with L-Rhamnose as carbon source"
"PM01_D04_1";"UPA00621";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"1,2-propanediol degradation";"No growth with 1,2-Propanediol as carbon source"
"PM01_F03_1";"UPA00405";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"myo-inositol degradation";"No growth with myo-Inositol as carbon source"
"PM01_F09_1";"UPA00864";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"glycolate degradation";"No growth with Glycolic Acid as carbon source"
"PM01_G04_1";"UPA00493";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"L-threonine degradation";"No growth with L-Threonine as carbon source"
"PM01_H10_1";"UPA01047";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"D-galacturonate degradation";"No growth with D-Galacturonic Acid as carbon source"
"PM01_H12_1";"UPA00560";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"ethanolamine degradation";"No growth with Ethanolamine as carbon source"
```

##### Unification of background knwoledge and Biololg experimentations

To merge these expectations:

```bash
$ cp biolog_list_of_expectations_upa.csv complete_list_of_expecations_upa.csv
$ tail -n +2 examples/expectation_upa_aa.grools.csv  >> complete_list_of_expecations_upa.csv  >> complete_list_of_expecations_upa.csv
```

#### Run GROOLS application

##### With MicroScope annotation

Normal reasoning mode:

```bash
$ ./scripts/microscope_upaToGrools.sh -o res/microscope_upa_normal 36 complete_list_of_expecations_upa.csv
```

Results are viewable with a browser, open: `res/microscope_upa_normal/index.html`

Specific reasoning mode:

```bash
$ ./scripts/microscope_upaToGrools.sh -s -o res/microscope_upa_specific 36 complete_list_of_expecations_upa.csv
```

Results are viewable with a browser, open: `res/microscope_upa_specific/index.html`
