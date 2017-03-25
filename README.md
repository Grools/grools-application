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


## Tutorial using UniPathway as Prior-Knowledge graph
`examples` Directory contains a set of data to learn how to use GROOLS application:

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

### Describe expectations using organism background knowkedge

You may indicate a list of pathways that are expected according to organism background knowkedge.
As example, a proptotroph organism should have all amino acid biosynthesis pathways: see file `expectation_upa_aa.csv` 

```csv
$ cat examples/expectation_upa_aa.csv
Accession;Name
UPA00031;L-histidine biosynthesis
UPA00035;L-tryptophan biosynthesis
UPA00047;L-isoleucine biosynthesis
...
```

This file should be converted in GROOLS csv file format (see section [GROOLS CSV file format](#grools-csv-file-format)) using:

```bash
$ ./scripts/expectations_list_to_grools_csv.sh examples/expectation_upa_aa.csv examples/expectation_upa_aa.grools.csv
```

This command generates a file named `expectation_upa_aa.grools.csv`:

```csv
"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"
"Exp_UPA00031";"UPA00031";"EXPERIMENTATION";"T";"";"Exp_UPA00031";"L-histidine biosynthesis"
"Exp_UPA00035";"UPA00035";"EXPERIMENTATION";"T";"";"Exp_UPA00035";"L-tryptophan biosynthesis"
"Exp_UPA00047";"UPA00047";"EXPERIMENTATION";"T";"";"Exp_UPA00047";"L-isoleucine biosynthesis"
...
```
&#x1F536; Indeed you can directly write a such file.

### Expectations from Biolog experimentations

Biolog results are representated with numerical values. These quantitative growth phenotypes data should be first discretized in three states `FALSE` (no growth), `TRUE` (growth), `NA` (growth maybe). 
For that, you may use the [omp](http://bioinformatics.oxfordjournals.org/content/29/14/1823.short) R package with "grofit" aggregation method and weak discretization (-a, -w and -z options of run_opm.R program).

See `examples/biolog/AbaylyiADP1/PM1_A_101117.tab` file as example of omp output:

```csv
"File"	"Plate_Type"	"Position"	"Setup_Time"	"Well"	"mu"	"lambda"	"A"	"AUC"	"mu_CI95_low"	"lambda_CI95_low"	"A_CI95_low"	"AUC_CI95_low"	"mu_CI95_high"	"lambda_CI95_high"	"A_CI95_high"	"AUC_CI95_high"	"Aggr_software"	"Aggr_version"	"Aggr_method"	"Discretized"	"Disc_software"	"Disc_version"	"Disc_method"
".//01_Abaylyi_PM1_A_101117.csv"	"PM01"	"15-A"	"Nov 17 2010 5:28 PM"	"A01"	11.0239490374402	0.101998280074103	50.0586437522741	4437.423792864	10.8538314459345	-51.4322872382767	50.2978431840183	4398.07750163227	16.5264325297181	85.9780629028097	53.0550158798986	4463.39457157138	"opm"	"1.3.51"	"grofit"	FALSE	"opm"	"1.3.51"	"kmeans"
".//01_Abaylyi_PM1_A_101117.csv"	"PM01"	"15-A"	"Nov 17 2010 5:28 PM"	"A02"	6.47772286994336	-1.17233134884521	50.2660273428748	4294.08252281865	5.46716638240377	-34.66207762553	50.201817207401	4251.13805006296	14.7111400864039	119.317927831985	54.03143182126	4316.55817358922	"opm"	"1.3.51"	"grofit"	FALSE	"opm"	"1.3.51"	"kmeans"
".//01_Abaylyi_PM1_A_101117.csv"	"PM01"	"15-A"	"Nov 17 2010 5:28 PM"	"A03"	5.4787776379894	-0.0367891891096806	29.6073109885561	2566.50462868851	3.31739323527425	-17.3502549023257	29.7878444150652	2537.08932176093	17.0850517869014	148.128379766773	34.4615301314378	2582.13004990163	"opm"	"1.3.51"	"grofit"	FALSE	"opm"	"1.3.51"	"kmeans"
...
```

To convert omp files in GROOLS csv file format, you may use `biologToGroolsExpectations.py` script as follow:

```bash
$ ./scripts/biologToGroolsExpectations.py examples/biolog/pk_observation_mapper/biolog_plates_cells_name_evidencesForUPA_description.tsv biolog_list_of_expectations_upa.csv  examples/biolog/AbaylyiADP1/*.tab
```

This command generates the `biolog_list_of_expectations_upa.csv` file

```csv
"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"
"PM01_A02_1";"UPA00463";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"L-arabinose degradation";"No growth with L-Arabinose as carbon source"
"PM01_A08_1";"UPA00532";"EXPERIMENTATION";"T";"BIOLOG experimentation: 101117";"L-proline degradation";"Growth with L-Proline as carbon source"
"PM01_A09_1";"UPA00043";"EXPERIMENTATION";"T";"BIOLOG experimentation: 101117";"D-alanine degradation";"Growth with D-Alanine as carbon source"
"PM01_B02_1";"UPA00812";"EXPERIMENTATION";"F";"BIOLOG experimentation: 101117";"D-sorbitol degradation";"No growth with D-Sorbitol as carbon source"
...
```

### To merge expectation file

```bash
$ cp biolog_list_of_expectations_upa.csv complete_list_of_expecations_upa.csv
$ tail -n +2 examples/expectation_upa_aa.grools.csv  >> complete_list_of_expecations_upa.csv
```

### Run GROOLS application

#### Using UniProt annotations

The proteom id of A. baylyi ADP1 is `UP000000430` in UniProt. 

Normal reasoning mode:

```bash
$ ./scripts/uniprot_upaToGrools.sh -o res/uniprot_upa_normal UP000000430 complete_list_of_expecations_upa.csv
```
Specific reasoning mode:

```bash
$ ./scripts/uniprot_upaToGrools.sh -s -o res/uniprot_upa_normal UP000000430 complete_list_of_expecations_upa.csv
```

Results are viewable with a browser, open: `res/uniprot_upa_normal/index.html` or  `res/uniprot_upa_specific/index.html`


#### Using MicroScope annotations

The sequence id of A. baylyi ADP1 is `36` in MiscroScope platform. 

Normal reasoning mode:

```bash
$ ./scripts/microscope_upaToGrools.sh -o res/microscope_upa_normal 36 complete_list_of_expecations_upa.csv
```

Specific reasoning mode:

```bash
$ ./scripts/microscope_upaToGrools.sh -s -o res/microscope_upa_specific 36 complete_list_of_expecations_upa.csv
```

Results are viewable with a browser, open: `res/microscope_upa_normal/index.html` or  `res/microscope_upa_specific/index.html`

##### The correspondence table Organim <-> Sequence ID 

| Organism name                                                             | Sequences ID list                                                                                           | 
|---------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------| 
| Bacillus halodurans C-125                                                 | 1                                                                                                           | 
| Escherichia coli O157:H7 EDL933                                           | 6274,2                                                                                                      | 
| Yersinia pestis CO92                                                      | 678,679,680,681                                                                                             | 
| Mycobacterium tuberculosis H37Rv                                          | 1745                                                                                                        | 
| Mycobacterium tuberculosis CDC1551                                        | 354                                                                                                         | 
| Bacillus subtilis 168                                                     | 843                                                                                                         | 
| Photorhabdus luminescens TT01                                             | 10                                                                                                          | 
| Yersinia pestis KIM                                                       | 682,683                                                                                                     | 
| Sulfolobus solfataricus P2                                                | 14                                                                                                          | 
| Methanothermobacter thermautotrophicus Delta H                            | 15                                                                                                          | 
| Methanocaldococcus jannaschii DSM 2661                                    | 16,1742,1743                                                                                                | 
| Pyrococcus abyssi GE5                                                     | 17,1741                                                                                                     | 
| Chlamydia trachomatis D/UW-3/CX                                           | 18                                                                                                          | 
| Chlamydophila pneumoniae J138                                             | 19                                                                                                          | 
| Synechocystis sp. PCC 6803                                                | 20,4487,4488,4489,4490                                                                                      | 
| Mycoplasma pneumoniae M129                                                | 1625                                                                                                        | 
| Neisseria meningitidis Z2491                                              | 24                                                                                                          | 
| Rickettsia prowazekii Madrid E                                            | 25                                                                                                          | 
| Borrelia burgdorferi B31                                                  | 2480,2481,26,2482,2467,2483,2468,2484,2469,2485,2470,2486,2471,2487,2472,2473,2474,2475,2476,2477,2478,2479 | 
| Thermotoga maritima MSB8                                                  | 27                                                                                                          | 
| Pseudomonas aeruginosa PAO1                                               | 3745                                                                                                        | 
| Pseudoalteromonas haloplanktis TAC125                                     | 75,76                                                                                                       | 
| Salmonella enterica subsp. enterica serovar Typhi CT18                    | 32                                                                                                          | 
| Salmonella typhimurium LT2                                                | 35,2496                                                                                                     | 
| Neisseria meningitidis MC58                                               | 486                                                                                                         | 
| Acinetobacter baylyi ADP1                                                 | 36                                                                                                          | 
| Kuenenia stuttgartiensis NULL                                             | 256,257,258,259,260                                                                                         | 
| Neisseria gonorrhoeae FA 1090                                             | 142                                                                                                         | 
| Aeropyrum pernix K1                                                       | 41                                                                                                          | 
| Streptococcus pneumoniae TIGR4                                            | 8591                                                                                                        | 
| Clostridium acetobutylicum ATCC 824                                       | 1744,44                                                                                                     | 
| Haemophilus influenzae Rd KW20                                            | 47                                                                                                          | 
| Vibrio cholerae N16961                                                    | 387,388                                                                                                     | 
| Xylella fastidiosa 9a5c                                                   | 49                                                                                                          | 
| Shigella flexneri 2a 2457T                                                | 50                                                                                                          | 
| Campylobacter jejuni subsp. jejuni NCTC 11168                             | 52                                                                                                          | 
| Pseudomonas syringae pv. tomato DC3000                                    | 53                                                                                                          | 
| Ralstonia solanacearum GMI1000                                            | 55,215                                                                                                      | 
| Bacillus cereus ATCC 14579                                                | 56,68                                                                                                       | 
| Bacillus cereus ATCC 10987                                                | 58,67                                                                                                       | 
| Bacillus anthracis Ames                                                   | 59                                                                                                          | 
| Frankia alni ACN14a                                                       | 284                                                                                                         | 
| Streptomyces coelicolor A3(2)                                             | 397,398,399                                                                                                 | 
| Acinetobacter baumannii AYE                                               | 231,232,62,70,71                                                                                            | 
| Bacillus anthracis 'Ames Ancestor'                                        | 63,65,66                                                                                                    | 
| Pseudomonas entomophila L48                                               | 180                                                                                                         | 
| Acinetobacter baumannii SDF                                               | 73,74,234,623                                                                                               | 
| Bacillus licheniformis ATCC 14580                                         | 77                                                                                                          | 
| Xenorhabdus bovienii SS2004                                               | 248                                                                                                         | 
| Yersinia enterocolitica 8081                                              | 666,667                                                                                                     | 
| Bacillus thuringiensis serovar konkukian 97-27                            | 80                                                                                                          | 
| Desulfotalea psychrophila LSv54                                           | 81,82,83                                                                                                    | 
| Oceanobacillus iheyensis HTE831                                           | 84                                                                                                          | 
| Mycoplasma genitalium G37                                                 | 85                                                                                                          | 
| Photorhabdus asymbiotica ATCC43949                                        | 1053,1054                                                                                                   | 
| Bordetella bronchiseptica RB50                                            | 87                                                                                                          | 
| Bordetella parapertussis 12822                                            | 88                                                                                                          | 
| Bordetella pertussis Tohama I                                             | 89                                                                                                          | 
| Borrelia garinii PBi                                                      | 91,92,93                                                                                                    | 
| Treponema pallidum subsp. pallidum Nichols                                | 94                                                                                                          | 
| Treponema denticola ATCC 35405                                            | 95                                                                                                          | 
| Leptospira interrogans serovar lai 56601                                  | 96,97                                                                                                       | 
| Leptospira interrogans serovar Copenhageni Fiocruz L1-130                 | 98,99                                                                                                       | 
| Corynebacterium glutamicum ATCC 13032                                     | 9783                                                                                                        | 
| Leptospira biflexa serovar Patoc Patoc 1                                  | 262,324,325                                                                                                 | 
| Escherichia coli O157:H7 Sakai                                            | 104,105,103                                                                                                 | 
| Escherichia coli CFT073                                                   | 106                                                                                                         | 
| Buchnera aphidicola APS                                                   | 107,108,109                                                                                                 | 
| Buchnera aphidicola Bp                                                    | 110                                                                                                         | 
| Buchnera aphidicola Sg                                                    | 111                                                                                                         | 
| Erwinia carotovora subsp. atroseptica SCRI1043                            | 113                                                                                                         | 
| Wigglesworthia glossinidia endosymbiont of Glossina brevipalpis NULL      | 545,546                                                                                                     | 
| Burkholderia mallei ATCC 23344                                            | 115,116                                                                                                     | 
| Burkholderia pseudomallei K96243                                          | 119,120                                                                                                     | 
| Pyrococcus furiosus DSM 3638                                              | 121                                                                                                         | 
| Pyrococcus horikoshii OT3                                                 | 122                                                                                                         | 
| Thermoplasma volcanium GSS1                                               | 123                                                                                                         | 
| Vibrio vulnificus CMCP6                                                   | 124,125                                                                                                     | 
| Herminiimonas arsenicoxydans NULL                                         | 158                                                                                                         | 
| Psychrobacter arcticus 273-4                                              | 138                                                                                                         | 
| Neisseria meningitidis NEM8013                                            | 566                                                                                                         | 
| Bradyrhizobium japonicum USDA 110                                         | 149                                                                                                         | 
| Mesorhizobium loti MAFF303099                                             | 150,151,152                                                                                                 | 
| Sinorhizobium meliloti 1021                                               | 153,154,155                                                                                                 | 
| Frankia sp. CcI3                                                          | 1122                                                                                                        | 
| Frankia sp. EAN1pec                                                       | 1121                                                                                                        | 
| Bradyrhizobium sp. ORS278                                                 | 246                                                                                                         | 
| Bradyrhizobium sp. BTAi1                                                  | 252,312                                                                                                     | 
| Salmonella enterica subsp. enterica serovar Choleraesuis SC-B67           | 162,163,164                                                                                                 | 
| Bdellovibrio bacteriovorus HD100                                          | 165                                                                                                         | 
| Rhizobium leguminosarum bv. viciae 3841                                   | 166,167,168,169,170,171,172                                                                                 | 
| Rhodopseudomonas palustris CGA009                                         | 173,174                                                                                                     | 
| Pseudomonas fluorescens Pf-5                                              | 179                                                                                                         | 
| Pseudomonas syringae pv. syringae B728a                                   | 181                                                                                                         | 
| Helicobacter hepaticus ATCC 51449                                         | 182                                                                                                         | 
| Helicobacter pylori J99                                                   | 183                                                                                                         | 
| Helicobacter pylori 26695                                                 | 184                                                                                                         | 
| Campylobacter jejuni RM1221                                               | 185                                                                                                         | 
| Wolinella succinogenes DSM 1740                                           | 186                                                                                                         | 
| Escherichia coli S88                                                      | 278,279                                                                                                     | 
| Escherichia coli IAI1                                                     | 556                                                                                                         | 
| Shigella sonnei Ss046                                                     | 190,191                                                                                                     | 
| Candidatus Cloacamonas acidaminovorans Evry                               | 192                                                                                                         | 
| Escherichia coli ED1a                                                     | 275,822                                                                                                     | 
| Escherichia coli IAI39                                                    | 544                                                                                                         | 
| Escherichia coli UMN026                                                   | 372,373,823                                                                                                 | 
| Escherichia coli 55989                                                    | 357,462                                                                                                     | 
| Escherichia coli 042                                                      | 202,203                                                                                                     | 
| Ralstonia eutropha JMP134                                                 | 209,210,211,212                                                                                             | 
| Escherichia fergusonii ATCC 35469T                                        | 365,366                                                                                                     | 
| Pseudomonas syringae pv. phaseolicola 1448A                               | 216,217,218                                                                                                 | 
| Shigella boydii Sb227                                                     | 219,220                                                                                                     | 
| Shigella dysenteriae Sd197                                                | 222,2495,221                                                                                                | 
| Burkholderia sp. 383                                                      | 225,226,227                                                                                                 | 
| Cupriavidus taiwanensis LMG19424                                          | 280,411,560                                                                                                 | 
| Helicobacter pylori B38                                                   | 561                                                                                                         | 
| Methylobacterium extorquens DM4                                           | 240,241,242                                                                                                 | 
| Marinobacter hydrocarbonoclasticus ATCC 49840                             | 329                                                                                                         | 
| Escherichia coli K12                                                      | 244                                                                                                         | 
| Francisella tularensis subsp. tularensis SCHU S4                          | 247                                                                                                         | 
| Xenorhabdus nematophila ATCC19061                                         | 249,273                                                                                                     | 
| Methylobacterium extorquens AM1                                           | 415,416,417,418,419                                                                                         | 
| Escherichia coli UTI89                                                    | 264,265                                                                                                     | 
| Rhizobium etli CFN 42                                                     | 852,266,267,268,269,270,271                                                                                 | 
| Legionella pneumophila subsp. pneumophila Philadelphia 1                  | 276                                                                                                         | 
| Legionella pneumophila Lens                                               | 281,636                                                                                                     | 
| Coxiella burnetii RSA 493                                                 | 2490,2491                                                                                                   | 
| Rickettsia felis URRWXCal2                                                | 283,358,359                                                                                                 | 
| Fusobacterium nucleatum subsp. nucleatum ATCC 25586                       | 286                                                                                                         | 
| Cupriavidus metallidurans CH34                                            | 290,291,539,540                                                                                             | 
| Burkholderia cenocepacia AU 1054                                          | 294,295,296                                                                                                 | 
| Burkholderia thailandensis E264                                           | 297,298                                                                                                     | 
| Burkholderia xenovorans LB400                                             | 299,300,301                                                                                                 | 
| Mycobacterium avium subsp. paratuberculosis K-10                          | 302                                                                                                         | 
| Mycobacterium bovis AF2122/97                                             | 303                                                                                                         | 
| Mycobacterium sp. MCS                                                     | 305,306                                                                                                     | 
| Helicobacter pylori HPAG1                                                 | 307,308                                                                                                     | 
| Mycobacterium marinum M                                                   | 720,721                                                                                                     | 
| Mycobacterium smegmatis MC2 155                                           | 722                                                                                                         | 
| Helicobacter acinonychis Sheeba                                           | 313,314                                                                                                     | 
| Sulfurimonas denitrificans DSM 1251                                       | 315                                                                                                         | 
| Borrelia afzelii PKo                                                      | 316,317,318                                                                                                 | 
| Clostridium perfringens ATCC 13124                                        | 319                                                                                                         | 
| Clostridium tetani E88                                                    | 320,321                                                                                                     | 
| Escherichia coli 536                                                      | 322                                                                                                         | 
| Ralstonia eutropha H16                                                    | 323,335,350                                                                                                 | 
| Thiomonas sp. 3As                                                         | 327,326                                                                                                     | 
| Burkholderia phymatum STM815                                              | 599,602,603,604                                                                                             | 
| Leptospira borgpetersenii serovar Hardjo-bovis JB197                      | 344,345                                                                                                     | 
| Leptospira borgpetersenii serovar Hardjo-bovis L550                       | 346,347                                                                                                     | 
| Candidatus Nitrospira defluvii NULL                                       | 364                                                                                                         | 
| Magnetospirillum magneticum AMB-1 v2                                      | 349                                                                                                         | 
| Escherichia coli APEC O1                                                  | 351                                                                                                         | 
| Rickettsia conorii Malish 7                                               | 360                                                                                                         | 
| Rickettsia bellii RML369-C                                                | 361                                                                                                         | 
| Rickettsia typhi Wilmington                                               | 362                                                                                                         | 
| Nitrobacter hamburgensis X14                                              | 368,369,370,367                                                                                             | 
| Nitrobacter winogradskyi Nb-255                                           | 375                                                                                                         | 
| Nitrosomonas europaea ATCC 19718                                          | 376                                                                                                         | 
| Nitrosomonas eutropha C71                                                 | 378,379,380                                                                                                 | 
| Vibrio fischeri ES114                                                     | 389,390,391                                                                                                 | 
| Vibrio parahaemolyticus RIMD 2210633                                      | 392,393                                                                                                     | 
| Vibrio vulnificus YJ016                                                   | 394,395,396                                                                                                 | 
| Photobacterium profundum SS9                                              | 402,403,404                                                                                                 | 
| Vibrio tasmaniensis LGP32                                                 | 405,406                                                                                                     | 
| Bartonella bacilliformis KC583                                            | 407                                                                                                         | 
| Bartonella henselae Houston-1                                             | 408                                                                                                         | 
| Bartonella quintana Toulouse                                              | 409                                                                                                         | 
| Streptococcus pneumoniae D39                                              | 412                                                                                                         | 
| Streptococcus pneumoniae R6                                               | 413                                                                                                         | 
| Alkalilimnicola ehrlichei MLHE-1                                          | 420                                                                                                         | 
| Pyrobaculum arsenaticum DSM 13514                                         | 421                                                                                                         | 
| Streptococcus agalactiae 2603V/R                                          | 422                                                                                                         | 
| Streptococcus agalactiae A909                                             | 423                                                                                                         | 
| Streptococcus agalactiae NEM316                                           | 424                                                                                                         | 
| Streptococcus mutans UA159                                                | 425                                                                                                         | 
| Methylobacterium extorquens PA1                                           | 702                                                                                                         | 
| Streptococcus pyogenes SF370                                              | 428                                                                                                         | 
| Streptococcus pyogenes MGAS10394                                          | 429                                                                                                         | 
| Streptococcus pyogenes MGAS10750                                          | 430                                                                                                         | 
| Streptococcus pyogenes MGAS6180                                           | 431                                                                                                         | 
| Streptococcus pyogenes MGAS8232                                           | 432                                                                                                         | 
| Streptococcus pyogenes MGAS9429                                           | 433                                                                                                         | 
| Streptococcus pyogenes SSI-1                                              | 434                                                                                                         | 
| Streptococcus sanguinis SK36                                              | 435                                                                                                         | 
| Streptococcus thermophilus CNRZ1066                                       | 436                                                                                                         | 
| Streptococcus thermophilus LMD-9                                          | 437,438,439                                                                                                 | 
| Streptococcus thermophilus LMG 18311                                      | 440                                                                                                         | 
| Streptococcus suis 05ZYH33                                                | 441                                                                                                         | 
| Streptococcus suis 98HAH33                                                | 442                                                                                                         | 
| Streptococcus pyogenes Manfredo                                           | 443                                                                                                         | 
| Shigella flexneri 2a 301                                                  | 444,445                                                                                                     | 
| Nocardia cyriacigeorgica GUH-2                                            | 3482                                                                                                        | 
| Methanosarcina acetivorans C2A                                            | 447                                                                                                         | 
| Methanosarcina barkeri Fusaro                                             | 448,449                                                                                                     | 
| Methanosarcina mazei Go1                                                  | 450                                                                                                         | 
| Clostridium sticklandii DSM 519                                           | 654                                                                                                         | 
| Azospirillum lipoferum 4B                                                 | 1024,1025,1026,1027,1028,1029,1033                                                                          | 
| Acinetobacter baumannii ATCC 17978                                        | 459,460,461                                                                                                 | 
| Streptomyces cattleya NRRL 8057                                           | 1349,1350                                                                                                   | 
| Neisseria meningitidis FAM18                                              | 465                                                                                                         | 
| Archaeoglobus fulgidus DSM 4304                                           | 466                                                                                                         | 
| Haloarcula marismortui ATCC 43049                                         | 474,467,475,468,469,470,471,472,473                                                                         | 
| Corynebacterium glutamicum R                                              | 476,477                                                                                                     | 
| Halobacterium sp. NRC-1                                                   | 478,479,480                                                                                                 | 
| Haloquadratum walsbyi DSM 16790                                           | 481,482                                                                                                     | 
| Hyperthermus butylicus DSM 5456                                           | 483                                                                                                         | 
| Metallosphaera sedula DSM 5348                                            | 484                                                                                                         | 
| Methanococcoides burtonii DSM 6242                                        | 485                                                                                                         | 
| Methanococcus maripaludis C5                                              | 487,488                                                                                                     | 
| Methanococcus maripaludis S2                                              | 489                                                                                                         | 
| Methanocorpusculum labreanum Z                                            | 490                                                                                                         | 
| Methanobrevibacter smithii ATCC 35061                                     | 491                                                                                                         | 
| Methanoculleus marisnigri JR1                                             | 492                                                                                                         | 
| Methanopyrus kandleri AV19                                                | 493                                                                                                         | 
| Methanosaeta thermophila PT                                               | 494                                                                                                         | 
| Methanosphaera stadtmanae DSM 3091                                        | 495                                                                                                         | 
| Methanospirillum hungatei JF-1                                            | 496                                                                                                         | 
| Nanoarchaeum equitans Kin4-M                                              | 497                                                                                                         | 
| Natronomonas pharaonis DSM 2160                                           | 498,499,500                                                                                                 | 
| Picrophilus torridus DSM 9790                                             | 501                                                                                                         | 
| Pyrobaculum aerophilum IM2                                                | 502                                                                                                         | 
| Pyrobaculum calidifontis JCM 11548                                        | 503                                                                                                         | 
| Pyrobaculum islandicum DSM 4184                                           | 504                                                                                                         | 
| Staphylothermus marinus F1                                                | 505                                                                                                         | 
| Sulfolobus acidocaldarius DSM 639                                         | 506                                                                                                         | 
| Sulfolobus tokodaii 7                                                     | 507                                                                                                         | 
| Thermococcus kodakarensis KOD1                                            | 508                                                                                                         | 
| Thermofilum pendens Hrk 5                                                 | 509,510                                                                                                     | 
| Thermoplasma acidophilum DSM 1728                                         | 511                                                                                                         | 
| uncultured methanogenic archaeon RC-I                                     | 512                                                                                                         | 
| Methanococcus aeolicus Nankai-3                                           | 513                                                                                                         | 
| Methanococcus maripaludis C7                                              | 514                                                                                                         | 
| Methanococcus vannielii SB                                                | 515                                                                                                         | 
| Nocardia farcinica IFM 10152                                              | 516,517,518                                                                                                 | 
| Buchnera aphidicola Cc (Cinara cedri)                                     | 521,1504                                                                                                    | 
| Baumannia cicadellinicola Hc (Homalodisca coagulata)                      | 522                                                                                                         | 
| Candidatus Blochmannia floridanus NULL                                    | 523                                                                                                         | 
| Candidatus Blochmannia pennsylvanicus BPEN                                | 524                                                                                                         | 
| Sodalis glossinidius 'morsitans'                                          | 525,526,527,528                                                                                             | 
| Wolbachia endosymbiont TRS of Brugia malayi                               | 529                                                                                                         | 
| Wolbachia pipientis wMel                                                  | 530                                                                                                         | 
| Candidatus Carsonella ruddii PV                                           | 531                                                                                                         | 
| Mycoplasma hyopneumoniae 232                                              | 532                                                                                                         | 
| Mycoplasma hyopneumoniae 7448                                             | 533                                                                                                         | 
| Mycoplasma hyopneumoniae J                                                | 534                                                                                                         | 
| Lawsonia intracellularis PHE/MN1-00                                       | 535,536,537,538                                                                                             | 
| Mycobacterium canettii STB-D                                              | 1701                                                                                                        | 
| Candidatus Methylomirabilis oxyfera NULL                                  | 913                                                                                                         | 
| Legionella pneumophila subsp. pneumophila HL06041035                      | 845                                                                                                         | 
| Bacillus amyloliquefaciens FZB42                                          | 558                                                                                                         | 
| Escherichia coli HS                                                       | 559                                                                                                         | 
| Methylobacterium sp. 4-46                                                 | 699,700,701                                                                                                 | 
| Legionella pneumophila subsp. pneumophila Lorraine                        | 751,846                                                                                                     | 
| Janthinobacterium sp. Marseille                                           | 570                                                                                                         | 
| Escherichia coli W3110                                                    | 571                                                                                                         | 
| Shigella flexneri 5 8401                                                  | 572                                                                                                         | 
| Legionella hackeliae NULL                                                 | 2315,2316                                                                                                   | 
| Legionella micdadei NULL                                                  | 2317                                                                                                        | 
| Legionella-Like Amoebal Pathogens 10                                      | 2319,2370,5013                                                                                              | 
| Azorhizobium caulinodans ORS 571                                          | 583                                                                                                         | 
| Enterobacter sp. 638                                                      | 584,585                                                                                                     | 
| Serratia proteamaculans 568                                               | 586,587                                                                                                     | 
| Methylobacterium radiotolerans JCM 2831                                   | 704,984,985,986,987,989,990,991,703                                                                         | 
| Carnoules 1 NULL                                                          | 591                                                                                                         | 
| Carnoules 2 NULL                                                          | 592                                                                                                         | 
| Carnoules 3 NULL                                                          | 593                                                                                                         | 
| Carnoules 4 NULL                                                          | 594                                                                                                         | 
| Carnoules 5 NULL                                                          | 595                                                                                                         | 
| Carnoules 6 NULL                                                          | 596                                                                                                         | 
| Carnoules 7 NULL                                                          | 597                                                                                                         | 
| Magnetococcus sp. MC-1                                                    | 601                                                                                                         | 
| Rhodospirillum rubrum ATCC 11170                                          | 605,606                                                                                                     | 
| Rhodobacter sphaeroides ATCC 17029                                        | 614,615,616                                                                                                 | 
| Rhodobacter sphaeroides ATCC 17025                                        | 617,618,619,620,621,622                                                                                     | 
| Legionella pneumophila Paris                                              | 624,625                                                                                                     | 
| Legionella pneumophila Corby                                              | 875                                                                                                         | 
| Vibrio harveyi ATCC BAA-1116                                              | 627,628,629                                                                                                 | 
| Mycobacterium canettii STB-L                                              | 1939                                                                                                        | 
| Mycobacterium canettii STB-K                                              | 1940                                                                                                        | 
| Agrobacterium tumefaciens C58                                             | 632,633,634,635                                                                                             | 
| Bartonella tribocorum CIP 105476                                          | 638,637                                                                                                     | 
| Orientia tsutsugamushi Boryong                                            | 640                                                                                                         | 
| Rickettsia massiliae MTU5                                                 | 641,642                                                                                                     | 
| Rickettsia rickettsii Iowa                                                | 643                                                                                                         | 
| Rickettsia rickettsii 'Sheila Smith'                                      | 644                                                                                                         | 
| Rickettsia akari Hartford                                                 | 645                                                                                                         | 
| Rickettsia bellii OSU 85-389                                              | 646                                                                                                         | 
| Rickettsia canadensis McKiel                                              | 647                                                                                                         | 
| Mycobacterium canettii STB-J                                              | 1700                                                                                                        | 
| Ralstonia solanacearum CMR15                                              | 1667,1668,1669                                                                                              | 
| Trichodesmium erythraeum IMS101                                           | 655                                                                                                         | 
| Nostoc sp. PCC 7120                                                       | 4485,4486,656,4481,4482,4483,4484                                                                           | 
| Anabaena variabilis ATCC 29413                                            | 657,1966,1967,1968,1969                                                                                     | 
| Synechococcus elongatus PCC6301                                           | 658                                                                                                         | 
| Synechococcus sp. CC9311                                                  | 659                                                                                                         | 
| Synechococcus sp. CC9605                                                  | 660                                                                                                         | 
| Thermosynechococcus elongatus BP-1                                        | 661                                                                                                         | 
| Prochlorococcus marinus AS9601                                            | 662                                                                                                         | 
| Prochlorococcus marinus MIT 9301                                          | 663                                                                                                         | 
| Microcystis aeruginosa NIES-843                                           | 664                                                                                                         | 
| Oscillatoria sp. PCC 6506                                                 | 1461                                                                                                        | 
| Yersinia pestis Angola                                                    | 668,669,670                                                                                                 | 
| Yersinia pestis Antiqua                                                   | 674,675,676,677                                                                                             | 
| Yersinia pestis Nepal516                                                  | 684,685,686                                                                                                 | 
| Yersinia pestis Pestoides F                                               | 687,688,689                                                                                                 | 
| Yersinia pestis biovar Microtus str. 91001                                | 690                                                                                                         | 
| Yersinia pseudotuberculosis IP 32953                                      | 691,692,693                                                                                                 | 
| Yersinia pseudotuberculosis IP 31758                                      | 694,695,696                                                                                                 | 
| Yersinia pseudotuberculosis YPIII                                         | 697                                                                                                         | 
| Mycobacterium sp. JLS                                                     | 708                                                                                                         | 
| Mycobacterium sp. KMS                                                     | 709,710,711                                                                                                 | 
| Mycobacterium abscessus ATCC 19977                                        | 712,713                                                                                                     | 
| Mycobacterium avium 104                                                   | 714                                                                                                         | 
| Mycobacterium bovis BCG Pasteur 1173P2                                    | 715                                                                                                         | 
| Mycobacterium gilvum PYR-GCK                                              | 716,717,718,719                                                                                             | 
| Mycobacterium tuberculosis F11                                            | 723                                                                                                         | 
| Neisseria lactamica ST640                                                 | 724,725                                                                                                     | 
| Mycobacterium tuberculosis H37Ra; ATCC 25177                              | 726                                                                                                         | 
| Mycobacterium ulcerans Agy99                                              | 727                                                                                                         | 
| Mycobacterium vanbaalenii PYR-1                                           | 728                                                                                                         | 
| Neisseria meningitidis 053442                                             | 729                                                                                                         | 
| Candidatus Sulcia muelleri GWSS                                           | 730                                                                                                         | 
| Rhizobium sp. NT-26                                                       | 1514,1620,1621                                                                                              | 
| Ochrobactrum anthropi ATCC 49188                                          | 735,736,737,738,739,734                                                                                     | 
| Helicobacter pylori Shi470                                                | 741                                                                                                         | 
| Campylobacter fetus 82-40                                                 | 742                                                                                                         | 
| Campylobacter hominis ATCC BAA-381                                        | 743,744                                                                                                     | 
| Stenotrophomonas maltophilia K279a                                        | 745                                                                                                         | 
| Alkaliphilus oremlandii OhILAs                                            | 747                                                                                                         | 
| Clostridium beijerinckii NCIMB 8052                                       | 748                                                                                                         | 
| Clostridium difficile 630                                                 | 752,754                                                                                                     | 
| Clostridium botulinum A Hall                                              | 753                                                                                                         | 
| Clostridium kluyveri DSM 555                                              | 755,756                                                                                                     | 
| Clostridium novyi NT                                                      | 757                                                                                                         | 
| Clostridium perfringens str. 13                                           | 758,759                                                                                                     | 
| Staphylococcus aureus subsp. aureus JH1                                   | 760,761                                                                                                     | 
| Clostridium phytofermentans ISDg                                          | 762                                                                                                         | 
| Listeria monocytogenes EGD-e                                              | 763                                                                                                         | 
| Clostridium thermocellum ATCC 27405                                       | 764                                                                                                         | 
| Ralstonia solanacearum Ipo1609                                            | 767                                                                                                         | 
| Marinobacter aquaeolei VT8                                                | 772,773,774                                                                                                 | 
| Nostoc punctiforme ATCC 29133; PCC 73102                                  | 781,782,783,784,785,777                                                                                     | 
| Agrobacterium vitis S4                                                    | 786,787,788,789,790,791,792                                                                                 | 
| Agrobacterium radiobacter K84                                             | 801,793,794,795,796                                                                                         | 
| Microcystis aeruginosa PCC 7806                                           | 800                                                                                                         | 
| Alkaliphilus metalliredigens QYMF                                         | 802                                                                                                         | 
| Ralstonia solanacearum PSI07                                              | 1165,1254,1255                                                                                              | 
| Agrobacterium tumefaciens K84                                             | 805                                                                                                         | 
| Azospirillum brasilense Sp245                                             | 811,812,1545,1546,1547,1548,1549                                                                            | 
| Xenorhabdus doucetiae FRM16                                               | 1936,1937                                                                                                   | 
| Xenorhabdus bovienii CS03                                                 | 1902,1903,1904                                                                                              | 
| Helicobacter pylori G27                                                   | 817,818                                                                                                     | 
| Vibrio nigripulchritudo SFn1                                              | 1610,1611,1718,1719                                                                                         | 
| Helicobacter pylori P12                                                   | 829,830                                                                                                     | 
| Thermodesulfovibrio yellowstonii DSM 11347                                | 831                                                                                                         | 
| Alcanivorax borkumensis SK2                                               | 832                                                                                                         | 
| Neisseria gonorrhoeae NCCP11945                                           | 833,834                                                                                                     | 
| Salinispora arenicola CNS-205                                             | 835                                                                                                         | 
| Salinispora tropica CNB-440                                               | 836                                                                                                         | 
| Delftia acidovorans SPH-1                                                 | 841                                                                                                         | 
| Bordetella petrii DSM 12804                                               | 842                                                                                                         | 
| Xenorhabdus poinarii G6                                                   | 1907                                                                                                        | 
| Desulfotomaculum hydrothermale Lam5(T)                                    | 2590                                                                                                        | 
| Methylobacterium nodulans ORS 2060                                        | 994,993,992,995,996,997,998,999                                                                             | 
| Burkholderia vietnamiensis G4                                             | 862,855,856,857,858,859,860,861                                                                             | 
| Microcystis sp. T1-4                                                      | 2203                                                                                                        | 
| Microcystis aeruginosa 7941                                               | 2198                                                                                                        | 
| Microcystis aeruginosa 9443                                               | 2197                                                                                                        | 
| Microcystis aeruginosa 9717                                               | 2196                                                                                                        | 
| Microcystis aeruginosa 9806                                               | 2199                                                                                                        | 
| Microcystis aeruginosa 9807                                               | 2200                                                                                                        | 
| Microcystis aeruginosa 9808                                               | 2201                                                                                                        | 
| Desulfotomaculum reducens MI-1                                            | 874                                                                                                         | 
| Escherichia coli F11                                                      | 876                                                                                                         | 
| Escherichia coli B7A                                                      | 877                                                                                                         | 
| Escherichia coli E22                                                      | 878                                                                                                         | 
| Escherichia coli 101-1                                                    | 879                                                                                                         | 
| Escherichia coli B171                                                     | 880                                                                                                         | 
| Escherichia coli E110019                                                  | 881                                                                                                         | 
| Escherichia coli E24377A                                                  | 882,883,884,885,886,887,888                                                                                 | 
| Escherichia coli ATCC 8739                                                | 889                                                                                                         | 
| Escherichia coli LF82                                                     | 890,909                                                                                                     | 
| Escherichia coli O127:H6 E2348/69                                         | 891,892,893                                                                                                 | 
| Escherichia coli O157:H7 EC4115                                           | 894,895,896                                                                                                 | 
| Escherichia coli SE11                                                     | 897,898,899,900,901,902,903                                                                                 | 
| Escherichia coli SMS-3-5                                                  | 904,905,906,907,908                                                                                         | 
| Ralstonia solanacearum CFBP2957                                           | 1630,1675                                                                                                   | 
| Geodermatophilus obscurus DSM 43160                                       | 1258                                                                                                        | 
| Oligotropha carboxidovorans OM5; ATCC 49405                               | 972                                                                                                         | 
| Azospirillum brasilense CBG497                                            | 2128,2545,2546,2124,2125,2127                                                                               | 
| Candidatus Glomeribacter gigasporarum BEG34                               | 6766                                                                                                        | 
| Candidatus Koribacter versatilis Ellin345                                 | 977                                                                                                         | 
| Lactobacillus fermentum IFO 3956                                          | 1004                                                                                                        | 
| Lactobacillus plantarum WCFS                                              | 1005,1006,1007,1008                                                                                         | 
| Lactobacillus salivarius UCC118                                           | 1012,1009,1010,1011                                                                                         | 
| Pediococcus pentosaceus ATCC 25745                                        | 1013                                                                                                        | 
| Bartonella grahamii as4aup                                                | 1014,1015                                                                                                   | 
| Polynucleobacter necessarius subsp. necessarius STIR1                     | 1035                                                                                                        | 
| Polynucleobacter necessarius subsp. asymbioticus QLW-P1DMWA-1             | 1036                                                                                                        | 
| Neisseria meningitidis alpha14                                            | 1037                                                                                                        | 
| Blood disease bacterium R229                                              | 2259,2260                                                                                                   | 
| Acidithiobacillus ferrooxidans ATCC 53993                                 | 1041                                                                                                        | 
| Methylococcus capsulatus Bath                                             | 1043                                                                                                        | 
| Methylocella silvestris BL2                                               | 1044                                                                                                        | 
| Methylobacillus flagellatus KT                                            | 1045                                                                                                        | 
| Ralstonia pickettii 12J                                                   | 1059,1060,1061                                                                                              | 
| Comamonas testosteroni KF-1                                               | 1062                                                                                                        | 
| Escherichia coli B REL606                                                 | 1063                                                                                                        | 
| Moorella thermoacetica ATCC 39073                                         | 1070                                                                                                        | 
| Carboxydothermus hydrogenoformans Z-2901                                  | 1071                                                                                                        | 
| Magnetospirillum gryphiswaldense MSR-1                                    | 1078,1124                                                                                                   | 
| Pseudomonas putida F1                                                     | 1082                                                                                                        | 
| Pseudomonas putida GB-1                                                   | 1083                                                                                                        | 
| Gloeobacter violaceus PCC 7421                                            | 1084                                                                                                        | 
| Synechococcus sp. JA-2-3B a 2-13                                          | 1085                                                                                                        | 
| Synechococcus sp. JA-3-3Ab                                                | 1086                                                                                                        | 
| Cyanothece sp. PCC 7425                                                   | 1087,1088,1089,1090                                                                                         | 
| Cyanothece sp. PCC 7424                                                   | 1091,1092,1093,1094,1095,1096,1097                                                                          | 
| Synechococcus sp. PCC 7002                                                | 1101,1102,1103,1104,1098,1099,1100                                                                          | 
| Cyanothece sp. PCC 8802                                                   | 1105,1106,1107,1108,1109                                                                                    | 
| Acaryochloris marina MBIC11017                                            | 1117,1118,1119,1110,1111,1112,1113,1114,1115,1116                                                           | 
| Streptomyces griseus subsp. griseus NBRC 13350                            | 1123                                                                                                        | 
| Brucella abortus S19                                                      | 1125,1126                                                                                                   | 
| Brucella abortus bv 1 9-941                                               | 1127,1128                                                                                                   | 
| Brucella canis ATCC 23365                                                 | 1129,1130                                                                                                   | 
| Brucella melitensis ATCC 23457                                            | 1131,1132                                                                                                   | 
| Lactobacillus casei ATCC 334                                              | 1137,1138                                                                                                   | 
| Lactobacillus casei BL23                                                  | 1139                                                                                                        | 
| Lactobacillus rhamnosus GG (ATCC 53103)                                   | 1140                                                                                                        | 
| Lactobacillus rhamnosus Lc 705                                            | 1141,1142                                                                                                   | 
| Lactobacillus rhamnosus HN001                                             | 1143,1144,1152                                                                                              | 
| Brucella melitensis biovar Abortus 2308                                   | 1145,1146                                                                                                   | 
| Arthrobacter aurescens TC1 TC1; ATCC BAA-1386                             | 1147,1148,1149                                                                                              | 
| Brucella melitensis bv 1 16M                                              | 1150,1151                                                                                                   | 
| Arthrobacter chlorophenolicus A6                                          | 1155,1153,1154                                                                                              | 
| Arthrobacter sp. FB24                                                     | 1156,1157,1158,1159                                                                                         | 
| Micrococcus luteus NCTC 2665                                              | 1160                                                                                                        | 
| Pseudomonas sp. UK4                                                       | 1170                                                                                                        | 
| Candidatus Sulcia muelleri SMDSEM                                         | 1171                                                                                                        | 
| Candidatus Hamiltonella defensa T5A (Acyrthosiphon pisum)                 | 1172,1173                                                                                                   | 
| Tetrasphaera australiensis Ben110                                         | 2552                                                                                                        | 
| Candidatus Hodgkinia cicadicola Dsem                                      | 1483                                                                                                        | 
| Tetrasphaera elongata Lp2                                                 | 2093                                                                                                        | 
| Tetrasphaera japonica T1-X7                                               | 1540                                                                                                        | 
| Propionibacterium acnes KPA171202                                         | 1184                                                                                                        | 
| Tropheryma whipplei TW08 27                                               | 1185                                                                                                        | 
| Nocardioides sp. JS614                                                    | 1187,1186                                                                                                   | 
| Thiomonas intermedia K12                                                  | 2433,2434,2435                                                                                              | 
| Ralstonia syzygii R24                                                     | 2230,2231                                                                                                   | 
| Desulfovibrio magneticus RS-1                                             | 1191,1192,1193                                                                                              | 
| Xylanimonas cellulosilytica DSM 15894                                     | 1194,1195                                                                                                   | 
| Escherichia albertii TW07627                                              | 1197                                                                                                        | 
| Janibacter HTCC2649                                                       | 1198                                                                                                        | 
| Methylibium petroleiphilum PM1                                            | 1199,1200                                                                                                   | 
| Aeromicrobium marinum DSM_15272                                           | 1201                                                                                                        | 
| Kribbella flavida DSM 17836                                               | 1202                                                                                                        | 
| Propionibacterium sp. oral taxon 191 F0233                                | 1203                                                                                                        | 
| Pseudomonas fluorescens Pf0-1                                             | 1204                                                                                                        | 
| Pseudomonas aeruginosa UCBPP-PA14                                         | 1205                                                                                                        | 
| Pseudomonas aeruginosa LESB58                                             | 1209                                                                                                        | 
| Pseudomonas fluorescens SBW25                                             | 1210,1211                                                                                                   | 
| Brucella microti CCM 4915                                                 | 1212,1213                                                                                                   | 
| Leptothrix cholodnii SP-6                                                 | 1214                                                                                                        | 
| Brucella ovis ATCC 25840                                                  | 1215,1216                                                                                                   | 
| Brucella suis 1330                                                        | 1217,1218                                                                                                   | 
| Brucella suis ATCC 23445                                                  | 1219,1220                                                                                                   | 
| Yersinia pseudotuberculosis PB1/+                                         | 1221,1222                                                                                                   | 
| Yersinia pestis D106004                                                   | 1226,1223,1224,1225                                                                                         | 
| Yersinia pestis D182038                                                   | 1227,1228,1229,1230                                                                                         | 
| Yersinia pestis Pestoides A                                               | 1231                                                                                                        | 
| Yersinia pestis biovar Orientalis India 195                               | 1232                                                                                                        | 
| Yersinia pestis biovar Orientalis PEXU2                                   | 1233                                                                                                        | 
| Yersinia pestis CA88-4125                                                 | 1234,1235,1236                                                                                              | 
| Yersinia pestis biovar Antiqua B42003004                                  | 1237                                                                                                        | 
| Yersinia pestis biovar Antiqua E1979001                                   | 1238                                                                                                        | 
| Yersinia pestis biovar Antiqua UG05-0454                                  | 1239                                                                                                        | 
| Yersinia pestis biovar Mediaevalis K1973002                               | 1240                                                                                                        | 
| Yersinia pestis biovar Orientalis F1991016                                | 1241                                                                                                        | 
| Yersinia pestis biovar Orientalis IP275                                   | 1242,1243                                                                                                   | 
| Yersinia pestis biovar Orientalis MG05-1020                               | 1244                                                                                                        | 
| Rhodococcus erythropolis PR4 (= NBRC 100887)                              | 1288,1289,1290,1291                                                                                         | 
| Rhodococcus opacus B4                                                     | 1292                                                                                                        | 
| Rhodococcus jostii RHA1                                                   | 1293,1294,1295,1296                                                                                         | 
| Azospirillum sp. B510                                                     | 1306,1307,1308,1309,1303,1304,1305                                                                          | 
| Cyanobacterium sp. UCYN-A                                                 | 1317                                                                                                        | 
| Variovorax paradoxus S110                                                 | 1318,1319                                                                                                   | 
| Thiomicrospira crunogena XCL-2                                            | 1327                                                                                                        | 
| Francisella novicida U112                                                 | 1328                                                                                                        | 
| Francisella tularensis mediasiatica FSC147                                | 1329                                                                                                        | 
| Francisella tularensis subsp. holarctica OSU18                            | 1330                                                                                                        | 
| Francisella tularensis subsp. tularensis WY96-3418                        | 1333                                                                                                        | 
| Francisella tularensis subsp. tularensis FSC 198                          | 1335                                                                                                        | 
| Magnetite-containing magnetic vibrio MV-1                                 | 1336                                                                                                        | 
| Francisella tularensis subsp. holarctica FTNF002-00                       | 1337                                                                                                        | 
| Francisella philomiragia subsp. philomiragia ATCC 25017                   | 1339,1338                                                                                                   | 
| Candidatus Accumulibacter phosphatis clade IIA UW-1                       | 1342,1343,1344,1345                                                                                         | 
| Blattabacterium sp. Blattella germanica Bge Alboraia                      | 1351                                                                                                        | 
| Blattabacterium sp. Periplaneta americana BPLAN                           | 1352,1353                                                                                                   | 
| Wolbachia sp. wRi                                                         | 1354                                                                                                        | 
| Wolbachia endosymbiont of Culex quinquefasciatus Pel wPip                 | 1355                                                                                                        | 
| Sinorhizobium sp. Rm41                                                    | 1358                                                                                                        | 
| Sinorhizobium sp. A321                                                    | 1359                                                                                                        | 
| Sinorhizobium sp. HM006-1                                                 | 1360                                                                                                        | 
| Sinorhizobium sp. HM007-10                                                | 1361                                                                                                        | 
| Sinorhizobium sp. HM013-1                                                 | 1362                                                                                                        | 
| Sinorhizobium sp. HM015-1                                                 | 1363                                                                                                        | 
| Sinorhizobium sp. KH12g                                                   | 1364                                                                                                        | 
| Sinorhizobium sp. KH16b                                                   | 1365                                                                                                        | 
| Sinorhizobium sp. KH30a                                                   | 1366                                                                                                        | 
| Sinorhizobium sp. KH35b                                                   | 1367                                                                                                        | 
| Sinorhizobium sp. KH35c                                                   | 1368                                                                                                        | 
| Sinorhizobium sp. KH36b                                                   | 1369                                                                                                        | 
| Sinorhizobium sp. KH36c                                                   | 1370                                                                                                        | 
| Sinorhizobium sp. KH36d                                                   | 1371                                                                                                        | 
| Sinorhizobium sp. KH46b                                                   | 1372                                                                                                        | 
| Sinorhizobium sp. KH46c                                                   | 1373                                                                                                        | 
| Sinorhizobium sp. KH48e                                                   | 1374                                                                                                        | 
| Sinorhizobium sp. KH53a                                                   | 1375                                                                                                        | 
| Sinorhizobium sp. KH53b                                                   | 1376                                                                                                        | 
| Sinorhizobium sp. M10                                                     | 1377                                                                                                        | 
| Sinorhizobium sp. M102                                                    | 1378                                                                                                        | 
| Sinorhizobium sp. M156                                                    | 1379                                                                                                        | 
| Sinorhizobium sp. M161                                                    | 1380                                                                                                        | 
| Sinorhizobium sp. M162                                                    | 1381                                                                                                        | 
| Sinorhizobium sp. M195                                                    | 1382                                                                                                        | 
| Sinorhizobium sp. M2                                                      | 1383                                                                                                        | 
| Sinorhizobium sp. M210                                                    | 1384                                                                                                        | 
| Sinorhizobium sp. M22                                                     | 1385                                                                                                        | 
| Sinorhizobium sp. M243                                                    | 1386                                                                                                        | 
| Sinorhizobium sp. M249                                                    | 1387                                                                                                        | 
| Sinorhizobium sp. M268                                                    | 1388                                                                                                        | 
| Sinorhizobium sp. M270                                                    | 1389                                                                                                        | 
| Sinorhizobium sp. M30                                                     | 1390                                                                                                        | 
| Sinorhizobium sp. M58                                                     | 1391                                                                                                        | 
| Sinorhizobium sp. N6B1                                                    | 1392                                                                                                        | 
| Sinorhizobium sp. N6B7                                                    | 1393                                                                                                        | 
| Sinorhizobium sp. M1                                                      | 1394                                                                                                        | 
| Sinorhizobium sp. T027                                                    | 1395                                                                                                        | 
| Sinorhizobium sp. T073                                                    | 1396                                                                                                        | 
| Sinorhizobium sp. T094                                                    | 1397                                                                                                        | 
| Sinorhizobium sp. USDA1002                                                | 1398                                                                                                        | 
| Sinorhizobium sp. USDA205                                                 | 1399                                                                                                        | 
| Sinorhizobium sp. USDA207                                                 | 1400                                                                                                        | 
| Sinorhizobium sp. USDA4893                                                | 1401                                                                                                        | 
| Sinorhizobium sp. USDA4894                                                | 1402                                                                                                        | 
| Sinorhizobium sp. USDA1021                                                | 1403                                                                                                        | 
| Escherichia coli APEC AGI-5                                               | 1404                                                                                                        | 
| Cyanobium gracile PCC 6307                                                | 3513                                                                                                        | 
| Lactobacillus acidophilus NCFM                                            | 1410                                                                                                        | 
| Lactobacillus delbrueckii subsp. bulgaricus ATCC BAA-365                  | 1411                                                                                                        | 
| Lactobacillus delbrueckii subsp. bulgaricus ATCC 11842                    | 1412                                                                                                        | 
| Lactococcus lactis subsp. cremoris MG1363                                 | 1413                                                                                                        | 
| Lactococcus lactis subsp. cremoris SK11                                   | 1415,1416,1417,1418,1419,1414                                                                               | 
| Bifidobacterium animalis subsp. lactis AD011                              | 1420                                                                                                        | 
| Bifidobacterium animalis subsp. lactis Bl-04; ATCC SD5219                 | 1421                                                                                                        | 
| Bifidobacterium animalis subsp. lactis DSM 10140                          | 1422                                                                                                        | 
| Bifidobacterium longum NCC2705                                            | 1423,1424                                                                                                   | 
| Lactococcus lactis subsp. lactis KF147                                    | 1425,1426                                                                                                   | 
| Bifidobacterium animalis subsp. lactis HN019                              | 1427                                                                                                        | 
| Bifidobacterium bifidum NCIMB 41171                                       | 1428                                                                                                        | 
| Bifidobacterium breve DSM 20213                                           | 1429                                                                                                        | 
| Escherichia coli O26:H11 11368                                            | 1433,1434,1435,1432                                                                                         | 
| Escherichia coli O103:H2 12009                                            | 1436,1437                                                                                                   | 
| Escherichia coli O111:H- 11128                                            | 1438,1439,1440,1441,1442,1443                                                                               | 
| Acidaminococcus fermentans DSM 20731                                      | 1448                                                                                                        | 
| Lactobacillus plantarum JDM1                                              | 1449                                                                                                        | 
| Lactobacillus johnsonii FI9785                                            | 1450,1451,1452                                                                                              | 
| Lactobacillus johnsonii NCC 533                                           | 1453                                                                                                        | 
| Thermus thermophilus HB8                                                  | 1454,1455,1456                                                                                              | 
| Burkholderia sp. CCGE1002                                                 | 1476,1477,1478,1479                                                                                         | 
| Listeria monocytogenes HCC23                                              | 1480                                                                                                        | 
| Clostridium difficile R20291                                              | 1481                                                                                                        | 
| Clostridium difficile CD196                                               | 1482                                                                                                        | 
| Lactococcus lactis subsp. lactis IL1403                                   | 1484                                                                                                        | 
| Lactobacillus paracasei subsp. paracasei 8700:2                           | 1485                                                                                                        | 
| Methylosinus trichosporium OB3b                                           | 5870                                                                                                        | 
| Rhodospirillum centenum SW; ATCC 51521                                    | 1505                                                                                                        | 
| Desulfovibrio vulgaris DP4                                                | 1507,1508                                                                                                   | 
| Desulfovibrio vulgaris Hildenborough                                      | 1509,1510                                                                                                   | 
| Desulfovibrio desulfuricans subsp. desulfuricans G20                      | 1513                                                                                                        | 
| Ralstonia solanacearum K60                                                | 2364,2363                                                                                                   | 
| Dehalococcoides sp. BAV1                                                  | 1519                                                                                                        | 
| Dehalococcoides sp. GT                                                    | 1521                                                                                                        | 
| Dehalococcoides sp. VS                                                    | 1522                                                                                                        | 
| Dehalococcoides ethenogenes 195                                           | 1523                                                                                                        | 
| Microcystis aeruginosa 9701                                               | 2204                                                                                                        | 
| Tetrasphaera jenkinsii Ben74                                              | 1541                                                                                                        | 
| Jonesia denitrificans DSM 20603                                           | 1542                                                                                                        | 
| Sanguibacter keddieii DSM 10542                                           | 1544                                                                                                        | 
| Beutenbergia cavernae DSM 12333                                           | 1550                                                                                                        | 
| Clostridium ljungdahlii ATCC 49587                                        | 1551                                                                                                        | 
| Sinorhizobium medicae WSM419                                              | 1552,1553,1554,1555                                                                                         | 
| Acinetobacter sp. DR1                                                     | 1561                                                                                                        | 
| Acinetobacter baumannii AB0057                                            | 1562,1563                                                                                                   | 
| Acinetobacter baumannii AB307-0294                                        | 1564                                                                                                        | 
| Acinetobacter baumannii ACICU                                             | 1565,1566,1567                                                                                              | 
| Acinetobacter baumannii AB056                                             | 1571                                                                                                        | 
| Acinetobacter baumannii AB058                                             | 1572                                                                                                        | 
| Acinetobacter baumannii AB059                                             | 1573                                                                                                        | 
| Acinetobacter baumannii AB900                                             | 1574                                                                                                        | 
| Acinetobacter baumannii ATCC 19606                                        | 1575                                                                                                        | 
| Acinetobacter calcoaceticus RUH2202                                       | 1576                                                                                                        | 
| Acinetobacter haemolyticus ATCC 19194                                     | 1577                                                                                                        | 
| Acinetobacter johnsonii SH046                                             | 1578                                                                                                        | 
| Acinetobacter junii SH205                                                 | 1579                                                                                                        | 
| Acinetobacter lwoffii SH145                                               | 1580                                                                                                        | 
| Acinetobacter radioresistens SH164                                        | 1581                                                                                                        | 
| Acinetobacter radioresistens SK82                                         | 1582                                                                                                        | 
| Acinetobacter baumannii 6013113                                           | 1583                                                                                                        | 
| Acinetobacter baumannii 6013150                                           | 1584                                                                                                        | 
| Cyanothece sp. PCC 8801                                                   | 1585,1586,1587,1588                                                                                         | 
| Acinetobacter baumannii 6014059                                           | 1589                                                                                                        | 
| Acinetobacter sp. ATCC 27244                                              | 1590                                                                                                        | 
| Acinetobacter sp. RUH2624                                                 | 1591                                                                                                        | 
| Acinetobacter sp. SH024                                                   | 1592                                                                                                        | 
| Cyanothece sp. PCC 7822                                                   | 2912,2913,2914,2915,2916,2917,2918                                                                          | 
| Clostridium cellulolyticum H10; ATCC 35319                                | 1599                                                                                                        | 
| Gallionella capsiferriformans ES-2                                        | 1607                                                                                                        | 
| Xanthomonas campestris pv musacearum NCPPB4381                            | 1614                                                                                                        | 
| Mycoplasma hominis PG21                                                   | 1624                                                                                                        | 
| Mesorhizobium sp. STM4661                                                 | 1632,1633                                                                                                   | 
| Mesorhizobium metallidurans STM2683                                       | 1634,1635                                                                                                   | 
| Rhizobium mesoamericanum STM3625                                          | 1639,1640,1641,1642,2301,1636,1637                                                                          | 
| Rhizobium leguminosarum bv trifolii WSM1325                               | 1648,1649,1650,1651,1652,1653                                                                               | 
| Rhizobium leguminosarum bv trifolii WSM2304                               | 1654,1655,1656,1657,1658                                                                                    | 
| Clostridium cellulovorans 743B                                            | 1662                                                                                                        | 
| Clostridium saccharolyticum WM1                                           | 1663                                                                                                        | 
| Amycolatopsis mediterranei U32                                            | 1664                                                                                                        | 
| Corynebacterium diphtheriae NCTC 13129                                    | 1677                                                                                                        | 
| Gordonia bronchialis DSM 43247                                            | 1678,1679                                                                                                   | 
| Segniliparus rotundus DSM 44985                                           | 1680                                                                                                        | 
| Tsukamurella paurometabola DSM 20162                                      | 1681,1682                                                                                                   | 
| Methyloversatilis universalis FAM5                                        | 3944                                                                                                        | 
| Methylomonas methanica MC09                                               | 4045                                                                                                        | 
| Candidatus Zinderia insecticola CARI                                      | 1717                                                                                                        | 
| Candidatus Sulcia muelleri CARI                                           | 1698                                                                                                        | 
| Cenarchaeum symbiosum A                                                   | 1703                                                                                                        | 
| Syntrophus aciditrophicus SB NULL                                         | 1704                                                                                                        | 
| Syntrophomonas wolfei subsp. wolfei Goettingen                            | 1705                                                                                                        | 
| Klebsiella pneumoniae 342                                                 | 1706,1707,1708                                                                                              | 
| Klebsiella pneumoniae subsp. pneumoniae MGH 78578                         | 1709,1710,1711,1712,1713,1714                                                                               | 
| Klebsiella pneumoniae NTUH-K2044                                          | 1715,1716                                                                                                   | 
| Nitrososphaera viennensis EN76                                            | 2920                                                                                                        | 
| Escherichia coli ETEC H10407                                              | 1725,1726,1727,1728,1724                                                                                    | 
| Escherichia coli SE15                                                     | 1729,1730                                                                                                   | 
| Shewanella piezotolerans WP3                                              | 1731                                                                                                        | 
| Desulfovibrio salexigens DSM 2638                                         | 1732                                                                                                        | 
| Desulfovibrio vulgaris Miyazaki F                                         | 1733                                                                                                        | 
| Desulfovibrio aespoeensis Aspo-2                                          | 6968                                                                                                        | 
| Desulfovibrio desulfuricans subsp. desulfuricans ATCC 27774               | 1735                                                                                                        | 
| Desulfovibrio piger ATCC 29098                                            | 1736                                                                                                        | 
| Desulfovibrio sp. 3_1_syn3                                                | 1737,7100                                                                                                   | 
| Desulfovibrio fructosovorans JJ                                           | 1738                                                                                                        | 
| Desulfovibrio sp. FW1012B                                                 | 1739                                                                                                        | 
| Shewanella violacea DSS12                                                 | 1740                                                                                                        | 
| Opitutus terrae PB90-1                                                    | 1746                                                                                                        | 
| Vibrio mimicus MB451                                                      | 1747                                                                                                        | 
| Halomonas elongata DSM 2581                                               | 1860                                                                                                        | 
| Helicobacter pylori B8                                                    | 1861,1862,2966                                                                                              | 
| Helicobacter pylori PeCan4                                                | 1863,1864                                                                                                   | 
| Helicobacter pylori SJM180                                                | 1865                                                                                                        | 
| Aminobacterium colombiense DSM 12261                                      | 1866                                                                                                        | 
| Thermanaerovibrio acidaminovorans DSM 6589                                | 1867                                                                                                        | 
| Bacteroides fragilis ATCC 25285; NCTC 9343                                | 1869,1870                                                                                                   | 
| Bacteroides fragilis YCH46                                                | 1872,1871                                                                                                   | 
| Bacteroides thetaiotaomicron VPI-5482                                     | 1873,1874                                                                                                   | 
| Bacteroides vulgatus ATCC 8482                                            | 1875                                                                                                        | 
| Bacteroides helcogenes P 36-108                                           | 1876                                                                                                        | 
| Zunongwangia profunda SM-A87                                              | 1877                                                                                                        | 
| Gramella forsetii KT0803                                                  | 1878                                                                                                        | 
| Croceibacter atlanticus HTCC2559                                          | 1879                                                                                                        | 
| Flavobacterium johnsoniae UW101; ATCC 17061                               | 1880                                                                                                        | 
| Flavobacteriaceae bacterium 3519-10                                       | 1882                                                                                                        | 
| Candidatus Nitrosotenuis uzonensis N4                                     | 1883                                                                                                        | 
| Escherichia coli K-12 DH10B                                               | 1884                                                                                                        | 
| Escherichia coli BL21-Gold(DE3)pLysS AG                                   | 1885                                                                                                        | 
| Escherichia coli K-12 BW2952                                              | 1886                                                                                                        | 
| Escherichia coli DH1                                                      | 1887                                                                                                        | 
| Escherichia coli 53638                                                    | 1888                                                                                                        | 
| Escherichia coli O157:H7_EC4042                                           | 1889,1890                                                                                                   | 
| Escherichia coli O157:H7_EC4045                                           | 1891,1892                                                                                                   | 
| Escherichia coli O157:H7_EC4206                                           | 1893,1894                                                                                                   | 
| Escherichia coli O157:H7_TW14588                                          | 1895,1896                                                                                                   | 
| Burkholderia rhizoxinica HKI 454                                          | 1905,1906,7188                                                                                              | 
| Aliivibrio salmonicida LFI1238                                            | 1914,1915,1910,1911,1912,1913                                                                               | 
| Vibrio cholerae M66-2                                                     | 1916,1917                                                                                                   | 
| Vibrio cholerae MJ-1236                                                   | 1918,1919                                                                                                   | 
| Vibrio cholerae O395                                                      | 1920,1921                                                                                                   | 
| Vibrio fischeri MJ11                                                      | 1922,1923,1924                                                                                              | 
| Vibrio furnissii NCTC 11218                                               | 1925,1926                                                                                                   | 
| Vibrio sp. EX25                                                           | 1927,1928                                                                                                   | 
| Vibrio vulnificus MO6-24/O                                                | 1930,1929                                                                                                   | 
| Sinorhizobium sp. HM007-12                                                | 1941                                                                                                        | 
| Sinorhizobium sp. HM007-17                                                | 1942                                                                                                        | 
| Agrobacterium sp. H13-3                                                   | 1943,1944,1945                                                                                              | 
| Xenorhabdus nematophila F1                                                | 2627                                                                                                        | 
| Arthrospira platensis NIES-39                                             | 1947                                                                                                        | 
| Archaeoglobus profundus DSM 5631                                          | 1948,1949                                                                                                   | 
| Micromonospora sp. L5                                                     | 1952                                                                                                        | 
| Clostridium difficile MID11 7032989                                       | 2122                                                                                                        | 
| Caulobacter crescentus CB15                                               | 1976                                                                                                        | 
| Chlamydia muridarum MopnTet14                                             | 1978                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhi Ty2                     | 1980                                                                                                        | 
| Chlamydia muridarum Nigg MoPn                                             | 1981,1982                                                                                                   | 
| Chlamydia muridarum Weiss                                                 | 1983                                                                                                        | 
| Chlamydia trachomatis 434 Bu                                              | 1984                                                                                                        | 
| Chlamydia trachomatis L2b UCH-1 proctitis                                 | 1985                                                                                                        | 
| Chlamydia trachomatis A HAR-13 A/HAR-13                                   | 1986,1987                                                                                                   | 
| Chlamydophila abortus S26/3                                               | 1988                                                                                                        | 
| Chlamydophila caviae GPIC NULL                                            | 1989,1990                                                                                                   | 
| Chlamydophila felis Fe/C-56                                               | 1991,1992                                                                                                   | 
| Chlamydophila pneumoniae AR39                                             | 1993                                                                                                        | 
| Chlamydophila pneumoniae CWL029                                           | 1994                                                                                                        | 
| Chlamydophila pneumoniae TW-183                                           | 1995                                                                                                        | 
| Candidatus Protochlamydia amoebophila UWE25                               | 1996                                                                                                        | 
| Waddlia chondrophila WSU 86-1044                                          | 1997,1998                                                                                                   | 
| Parachlamydia acanthamoebae Halls coccus                                  | 1999                                                                                                        | 
| Parachlamydia acanthamoebae UV7                                           | 2000                                                                                                        | 
| Simkania negevensis Z                                                     | 2001,2002                                                                                                   | 
| Candidatus Amoebophilus asiaticus 5a2                                     | 2012                                                                                                        | 
| Candidatus Azobacteroides pseudotrichonymphae genomovar CFP2 NULL         | 2013,2014,2015,2016,2017                                                                                    | 
| Candidatus Sulcia muelleri DMIN                                           | 2018                                                                                                        | 
| Candidatus Sulcia muelleri Hc                                             | 2019                                                                                                        | 
| Candidatus Microthrix parvicella RN1                                      | 2605                                                                                                        | 
| Methanosaeta concilii GP-6                                                | 2049,2048                                                                                                   | 
| Brachybacterium faecium DSM 4810                                          | 2051                                                                                                        | 
| Chitinophaga pinensis DSM 2588                                            | 2052                                                                                                        | 
| Pedobacter heparinus DSM 2366                                             | 2053                                                                                                        | 
| Dyadobacter fermentans DSM 18053                                          | 2054                                                                                                        | 
| Kytococcus sedentarius DSM 20547                                          | 2055                                                                                                        | 
| Spirosoma linguale DSM 74                                                 | 2056,2057,2058,2059,2060,2061,2062,2063,2064                                                                | 
| Escherichia coli O104:H4 LB226692                                         | 2065                                                                                                        | 
| Escherichia coli O104:H4 TY-2482                                          | 2076,2077,2078,2079                                                                                         | 
| Roseobacter denitrificans OCh 114                                         | 2067,2068,2069,2070,2071                                                                                    | 
| Neisseria cinerea ATCC 14685                                              | 2072                                                                                                        | 
| Stigmatella aurantiaca DW4/3-1                                            | 2073                                                                                                        | 
| Conexibacter woesei DSM 14684                                             | 2074                                                                                                        | 
| Capnocytophaga ochracea DSM 7271                                          | 2075                                                                                                        | 
| Pirellula staleyi DSM 6068                                                | 2080                                                                                                        | 
| Haloterrigena turkmenica DSM 5511                                         | 2083,2084,2085,2086,2087,2081,2082                                                                          | 
| Candidatus Nitrosoarchaeum limnia SFB1                                    | 4671                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhimurium SL1344            | 2098,2099,2100,2101                                                                                         | 
| Methylacidiphilum fumariolicum SolV                                       | 5365                                                                                                        | 
| Xenorhabdus szentirmaii DSM16338                                          | 2115                                                                                                        | 
| Xenorhabdus cabanillasii JM26                                             | 2134                                                                                                        | 
| Methylacidiphilum infernorum V4                                           | 2148                                                                                                        | 
| Mesorhizobium opportunistum WSM2075                                       | 2154                                                                                                        | 
| Mesorhizobium ciceri biovar biserrulae WSM1271                            | 2155,2156                                                                                                   | 
| Chelativorans sp. BNC1                                                    | 2157,2158,2159,2160                                                                                         | 
| Nitrosospira multiformis ATCC 25196                                       | 2162,2163,2164,2165                                                                                         | 
| Nitrosomonas sp. AL212                                                    | 2166,2167,2168                                                                                              | 
| Nitrosomonas sp. Is79A3                                                   | 2169                                                                                                        | 
| Nitrosococcus oceani AFC27                                                | 2178                                                                                                        | 
| Nitrosococcus oceani ATCC 19707                                           | 2171,2172                                                                                                   | 
| Nitrosococcus watsonii C-113                                              | 2173,2174,2175                                                                                              | 
| Nitrosococcus halophilus Nc4                                              | 2176,2177                                                                                                   | 
| Nitrosopumilus maritimus SCM1                                             | 2179                                                                                                        | 
| Nitrosopumilus sp. MY1                                                    | 2206                                                                                                        | 
| Agrobacterium tumefaciens F2                                              | 2208                                                                                                        | 
| Xanthomonas oryzae pv oryzae KACC10331                                    | 2213                                                                                                        | 
| Xanthomonas oryzae pv oryzae MAFF 311018                                  | 2214                                                                                                        | 
| Xanthomonas oryzae pv oryzae PXO99A                                       | 2215                                                                                                        | 
| Xanthomonas axonopodis pv citrumelo F1                                    | 2216                                                                                                        | 
| Xanthomonas oryzae pv. oryzicola BLS256                                   | 2217                                                                                                        | 
| Xanthomonas campestris pv vesicatoria 85-10                               | 2218,2219,2220,2221,2222                                                                                    | 
| Xanthomonas fuscans subsp. aurantifolii ICPB 10535                        | 2223                                                                                                        | 
| Xanthomonas axonopodis pv citri 306                                       | 2225,2226,2227                                                                                              | 
| Ralstonia solanacearum Po82                                               | 2234,2235                                                                                                   | 
| Ralstonia solanacearum Y45                                                | 2236,2237                                                                                                   | 
| Streptosporangium roseum DSM 43021                                        | 2244,2245                                                                                                   | 
| Catenulispora acidiphila DSM 44928                                        | 2247                                                                                                        | 
| Magnetospirillum gryphiswaldense MSR-1 v2                                 | 2298                                                                                                        | 
| Verrucosispora maris AB-18-032                                            | 2250,2251                                                                                                   | 
| Deinococcus deserti VCD115                                                | 2262,2263,2264,2265                                                                                         | 
| Azospirillum amazonense Y2                                                | 2261                                                                                                        | 
| Desulfobacterium autotrophicum HRM2                                       | 2290,2291                                                                                                   | 
| Desulfurivibrio alkaliphilus AHT2                                         | 2292                                                                                                        | 
| Thioalkalivibrio sulfidophilus HL-EbGR7                                   | 2293                                                                                                        | 
| Allochromatium vinosum DSM 180                                            | 2295,2296,2297                                                                                              | 
| Nitrobacter sp. Nb-311A                                                   | 2300                                                                                                        | 
| Nitrosotalea devanaterra NULL                                             | 5376                                                                                                        | 
| Delta proteobacterium NaphS2                                              | 2327                                                                                                        | 
| Clostridium difficile MID12 7032985                                       | 2341                                                                                                        | 
| Staphylococcus aureus subsp. aureus MW2                                   | 2348                                                                                                        | 
| Staphylococcus aureus subsp. aureus N315                                  | 2349,2350                                                                                                   | 
| Staphylococcus aureus subsp. aureus Newman                                | 2351                                                                                                        | 
| Staphylococcus aureus subsp. aureus TW20                                  | 2352,2353,2354                                                                                              | 
| Mesorhizobium australicum WSM2073                                         | 2374                                                                                                        | 
| Mesorhizobium amorphae CCNWGS0123                                         | 2375                                                                                                        | 
| Xanthomonas citri pv. citri C40                                           | 3429,2653,2654                                                                                              | 
| Xanthomonas citri pv. citri JK2-10                                        | 2380,2381,3430                                                                                              | 
| Arthrobacter phenanthrenivorans Sphe3                                     | 2386,2387,2388                                                                                              | 
| Stenotrophomonas maltophilia JV3                                          | 2389                                                                                                        | 
| Stenotrophomonas sp. SKA14                                                | 2391                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum ST-III                           | 2392,2393                                                                                                   | 
| Lactobacillus plantarum subsp. plantarum ATCC 14917                       | 2394                                                                                                        | 
| Thermosediminibacter oceani DSM 16646                                     | 2395                                                                                                        | 
| Thermincola potens JR                                                     | 2396                                                                                                        | 
| Klebsiella variicola At-22                                                | 2398                                                                                                        | 
| Agrobacterium tumefaciens CCNWGS0286                                      | 2400                                                                                                        | 
| Cupriavidus necator N-1                                                   | 2402,2403,2404,2401                                                                                         | 
| Stenotrophomonas maltophilia R551-3                                       | 2390                                                                                                        | 
| Agrobacterium tumefaciens 5A v2                                           | 2440                                                                                                        | 
| Tepidanaerobacter sp. Re1                                                 | 2441                                                                                                        | 
| Desulfosporosinus orientis DSM 765                                        | 2504                                                                                                        | 
| Syntrophobacter fumaroxidans MPOB                                         | 2443                                                                                                        | 
| Pelotomaculum thermopropionicum SI                                        | 2444                                                                                                        | 
| Dehalogenimonas lykanthroporepellens BL-DC-9                              | 2445                                                                                                        | 
| Ignicoccus hospitalis KIN4/I                                              | 2446                                                                                                        | 
| Thermomicrobium roseum DSM 5159                                           | 2447,2448                                                                                                   | 
| Thermoanaerobacter sp. X514                                               | 2449                                                                                                        | 
| Chloroflexus aurantiacus J-10-fl                                          | 2450                                                                                                        | 
| Candidatus Pelagibacter ubique HTCC1062                                   | 2451                                                                                                        | 
| Mycobacterium canettii CIPT 140010059                                     | 2453                                                                                                        | 
| Candidatus Korarchaeum cryptofilum OPF8 NULL                              | 2454                                                                                                        | 
| Aquifex aeolicus VF5                                                      | 2455,2456                                                                                                   | 
| Salinibacter ruber DSM 13855 DSM 13855; M31                               | 2457,2458                                                                                                   | 
| Prochlorococcus marinus subsp. marinus CCMP1375 SS120                     | 2459                                                                                                        | 
| Deinococcus radiodurans R1                                                | 2460,2461,2462,2463                                                                                         | 
| Dictyoglomus turgidum DSM 6724                                            | 2464                                                                                                        | 
| Staphylococcus aureus subsp. aureus NCTC 8325                             | 2465                                                                                                        | 
| Mycoplasma mycoides subsp. mycoides SC PG1                                | 2466                                                                                                        | 
| Mesoplasma florum L1 L1; ATCC 33453                                       | 2488                                                                                                        | 
| Xanthomonas campestris pv campestris ATCC 33913                           | 2489                                                                                                        | 
| Clostridium botulinum A ATCC 3502                                         | 2492,2493                                                                                                   | 
| Leptospira interrogans serovar Manilae L495                               | 5570                                                                                                        | 
| Enterococcus faecalis V583                                                | 2499,2500,2501,2502                                                                                         | 
| Lactobacillus helveticus MTCC 5463                                        | 2505                                                                                                        | 
| Lactobacillus helveticus DPC 4571                                         | 2506                                                                                                        | 
| Lactobacillus helveticus DSM 20075                                        | 2507                                                                                                        | 
| Thermosipho africanus TCF52B                                              | 2516                                                                                                        | 
| Thermosipho melanesiensis BI429                                           | 2517                                                                                                        | 
| Fervidobacterium nodosum Rt17-B1                                          | 2518                                                                                                        | 
| Fervidobacterium pennivorans DSM 9078                                     | 2519                                                                                                        | 
| Thermotoga thermarum DSM 5069                                             | 2520                                                                                                        | 
| Thermotoga naphthophila RKU-10                                            | 2521                                                                                                        | 
| Thermotoga petrophila RKU-1                                               | 2522                                                                                                        | 
| Thermotoga lettingae TMO                                                  | 2523                                                                                                        | 
| Thermotoga neapolitana DSM 4359                                           | 2524                                                                                                        | 
| Thermotoga sp. RQ2                                                        | 2525                                                                                                        | 
| Kosmotoga olearia TBF 19.5.1                                              | 2526                                                                                                        | 
| Marinitoga piezophila KA3                                                 | 2527,2528                                                                                                   | 
| Petrotoga mobilis SJ95                                                    | 2529                                                                                                        | 
| Lactobacillus rhamnosus ATCC 21052                                        | 2539                                                                                                        | 
| Lactobacillus rhamnosus LMS2-1                                            | 2540                                                                                                        | 
| Lactobacillus rhamnosus MTCC 5462                                         | 2541                                                                                                        | 
| Lactobacillus rhamnosus R0011                                             | 2542                                                                                                        | 
| Lactobacillus rhamnosus CASL                                              | 2543                                                                                                        | 
| Desulfosporosinus youngiae DSM 17734                                      | 2551                                                                                                        | 
| Desulfitobacterium hafniense DCB-2                                        | 3786                                                                                                        | 
| Desulfitobacterium hafniense Y51                                          | 3791                                                                                                        | 
| Desulfosporosinus sp. OT                                                  | 2556                                                                                                        | 
| Burkholderia phytofirmans PsJN                                            | 2564,2565,2563                                                                                              | 
| Burkholderia gladioli BSR3                                                | 2566,2567,2568,2569,2570,2571                                                                               | 
| Burkholderia ambifaria AMMD                                               | 2576,2577,2578,2579                                                                                         | 
| Thermococcus barophilus MP v2                                             | 2583,2582                                                                                                   | 
| Thermococcus sp. AM4                                                      | 2584                                                                                                        | 
| Thermococcus gammatolerans EJ3 EJ3; DSM 15229                             | 2585                                                                                                        | 
| Thermococcus onnurineus NA1                                               | 2586                                                                                                        | 
| Thermococcus sibiricus MM 739                                             | 2587                                                                                                        | 
| Thermococcus sp. 4557                                                     | 2588                                                                                                        | 
| Thermococcus litoralis DSM 5473                                           | 2589                                                                                                        | 
| Listeria monocytogenes 10403S                                             | 2596                                                                                                        | 
| Listeria monocytogenes FSL R2-561                                         | 2597                                                                                                        | 
| Listeria monocytogenes Finland 1988                                       | 2598                                                                                                        | 
| Listeria monocytogenes J0161                                              | 2599                                                                                                        | 
| Listeria monocytogenes L99                                                | 2600                                                                                                        | 
| Listeria monocytogenes M7                                                 | 2601                                                                                                        | 
| Listeria seeligeri serovar 1/2b SLCC3954                                  | 2602                                                                                                        | 
| Listeria innocua Clip11262                                                | 2603,2604                                                                                                   | 
| Listeria welshimeri serovar 6b SLCC5334                                   | 2607                                                                                                        | 
| Listeria ivanovii FSL F6-596                                              | 2608                                                                                                        | 
| Listeria marthii FSL S4-120                                               | 2609                                                                                                        | 
| Listeria monocytogenes F6900                                              | 2610                                                                                                        | 
| Listeria monocytogenes FSL F2-515                                         | 2611                                                                                                        | 
| Listeria monocytogenes FSL J1-175                                         | 2612                                                                                                        | 
| Listeria monocytogenes FSL J1-194                                         | 2613                                                                                                        | 
| Listeria monocytogenes FSL J2-003                                         | 2615                                                                                                        | 
| Listeria monocytogenes FSL J2-064                                         | 2616                                                                                                        | 
| Listeria monocytogenes FSL J2-071                                         | 2617                                                                                                        | 
| Listeria monocytogenes FSL N1-017                                         | 2618                                                                                                        | 
| Listeria monocytogenes FSL N3-165                                         | 2619                                                                                                        | 
| Listeria monocytogenes FSL R2-503                                         | 2620                                                                                                        | 
| Listeria monocytogenes HPB2262                                            | 2621                                                                                                        | 
| Listeria grayi DSM 20601                                                  | 2622                                                                                                        | 
| Listeria monocytogenes J2818                                              | 2623                                                                                                        | 
| Listeria monocytogenes LO28                                               | 2624                                                                                                        | 
| Listeria monocytogenes serotype 1-2a F6854                                | 2625                                                                                                        | 
| Listeria monocytogenes serotype 4b H7858                                  | 2626                                                                                                        | 
| Bradyrhizobium sp. S23321                                                 | 2655                                                                                                        | 
| Klebsiella oxytoca KCTC 1686                                              | 2659                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Agona SL483                   | 2663,2664                                                                                                   | 
| Salmonella enterica subsp. enterica serovar Paratyphi B SPB7              | 2665                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Enteritidis P125109           | 2666                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Heidelberg SL476              | 2667,2668,2669                                                                                              | 
| Salmonella enterica subsp. enterica serovar Paratyphi C RKS4594           | 2670,2671                                                                                                   | 
| Salmonella enterica subsp. enterica serovar Schwarzengrund CVM19633       | 2673,2674,2675                                                                                              | 
| Salmonella enterica subsp. arizonae serovar 62:z4,z23:-- RSK2980          | 2676                                                                                                        | 
| Salmonella bongori NCTC 12419                                             | 2677                                                                                                        | 
| Candidatus Saccharimonas aalborgensis TM7.1v7                             | 2689                                                                                                        | 
| TM7.2 v5                                                                  | 2690                                                                                                        | 
| TM7.3 v2                                                                  | 2691                                                                                                        | 
| TM7.4 v3                                                                  | 2692                                                                                                        | 
| Candidatus Competibacter denitrificans Run_A_D11                          | 2693,2694                                                                                                   | 
| Candidatus Contendobacter odensis Run_B_J11                               | 2695                                                                                                        | 
| Candidatus Hamiltonella defensa MED                                       | 2696                                                                                                        | 
| Cyanobium sp. PCC 7001                                                    | 2697                                                                                                        | 
| Synechococcus elongatus PCC 7942                                          | 2698,2699                                                                                                   | 
| Synechococcus sp. BL 107                                                  | 2700                                                                                                        | 
| Synechococcus sp. CB0101                                                  | 2702                                                                                                        | 
| Synechococcus sp. CB0205                                                  | 2703                                                                                                        | 
| Synechococcus sp. CC9902                                                  | 2704                                                                                                        | 
| Prochlorococcus marinus subsp. pastoris CCMP1986 MED4                     | 2705                                                                                                        | 
| Lyngbya sp. CCY 9616                                                      | 2706                                                                                                        | 
| Prochlorococcus marinus MIT 9202                                          | 2710                                                                                                        | 
| Prochlorococcus marinus MIT 9211                                          | 2711                                                                                                        | 
| Prochlorococcus marinus MIT 9215                                          | 2712                                                                                                        | 
| Prochlorococcus marinus MIT 9303                                          | 2713                                                                                                        | 
| Prochlorococcus marinus MIT 9312                                          | 2714                                                                                                        | 
| Prochlorococcus marinus MIT 9313                                          | 2716                                                                                                        | 
| Prochlorococcus marinus MIT 9515                                          | 2717                                                                                                        | 
| Mycobacterium africanum GM041182                                          | 2718                                                                                                        | 
| Prochlorococcus marinus NATL1A                                            | 2719                                                                                                        | 
| Prochlorococcus marinus NATL2A                                            | 2720                                                                                                        | 
| Synechococcus sp. RCC307                                                  | 2721                                                                                                        | 
| Synechococcus sp. RS9916                                                  | 2722                                                                                                        | 
| Synechococcus sp. RS9917                                                  | 2723                                                                                                        | 
| Synechococcus sp. WH 7803                                                 | 2724                                                                                                        | 
| Synechococcus sp. WH 5701                                                 | 2725                                                                                                        | 
| Synechococcus sp. WH 7805                                                 | 2726                                                                                                        | 
| Synechococcus sp. WH 8102                                                 | 2727                                                                                                        | 
| Synechococcus sp. WH 8016                                                 | 2728                                                                                                        | 
| Mycobacterium canettii STB-E                                              | 2729                                                                                                        | 
| Mycobacterium canettii STB-G                                              | 2731                                                                                                        | 
| Mycobacterium canettii STB-H                                              | 2732                                                                                                        | 
| Mycobacterium canettii STB-I                                              | 2733                                                                                                        | 
| Synechococcus sp. WH 8109                                                 | 2734                                                                                                        | 
| Rubrivivax gelatinosus IL144                                              | 2737                                                                                                        | 
| Rubrivivax benzoatilyticus JA2                                            | 2740                                                                                                        | 
| Thermobifida fusca YX                                                     | 2750                                                                                                        | 
| Nocardiopsis dassonvillei subsp. dassonvillei DSM 43111                   | 2751,2752                                                                                                   | 
| Xenorhabdus bovienii feltiae Moldova                                      | 3523                                                                                                        | 
| Xenorhabdus bovienii feltiae Florida                                      | 3524                                                                                                        | 
| Xenorhabdus bovienii feltiae France                                       | 3525                                                                                                        | 
| Xenorhabdus bovienii kraussei Becker Underwood                            | 3526                                                                                                        | 
| Xenorhabdus bovienii kraussei Quebec                                      | 3535                                                                                                        | 
| Xenorhabdus bovienii oregonense                                           | 3527                                                                                                        | 
| Xenorhabdus bovienii puntauvense                                          | 3528                                                                                                        | 
| Xenorhabdus bovienii intermedium                                          | 3529                                                                                                        | 
| Xenorhabdus bovienii jollieti                                             | 3531                                                                                                        | 
| Francisella tularensis subsp. holarctica LVS                              | 2766                                                                                                        | 
| Caldicellulosiruptor saccharolyticus DSM 8903                             | 2771                                                                                                        | 
| Klebsiella pneumoniae KCTC 2242                                           | 2779,2778                                                                                                   | 
| Klebsiella pneumoniae subsp. pneumoniae HS11286                           | 2780,2781,2782,2783,2784,2785,2786                                                                          | 
| Enterobacter cloacae 1623                                                 | 2787                                                                                                        | 
| Klebsiella pneumoniae CG43                                                | 2788,4630                                                                                                   | 
| Klebsiella oxytoca KOX105                                                 | 2789                                                                                                        | 
| Listeria monocytogenes 08-5923                                            | 2802                                                                                                        | 
| Listeria monocytogenes 07PF0776                                           | 2803                                                                                                        | 
| Listeria monocytogenes 08-5578                                            | 2804,2805                                                                                                   | 
| Listeria monocytogenes serotype 4b F2365                                  | 2806                                                                                                        | 
| Listeria monocytogenes J1-220                                             | 2807                                                                                                        | 
| Listeria monocytogenes J1816                                              | 2808                                                                                                        | 
| Listeria monocytogenes Scott A                                            | 2809                                                                                                        | 
| Listeria innocua FSL S4-378                                               | 2810                                                                                                        | 
| Listeria innocua FSL S1-023                                               | 2811                                                                                                        | 
| Listeria innocua ATCC 33091                                               | 2812                                                                                                        | 
| Listeria seeligeri FSL N1-067                                             | 2813                                                                                                        | 
| Listeria seeligeri FSL N4-171                                             | 2814                                                                                                        | 
| Mesotoga prima MesG1.Ag.4.2                                               | 2850,2851                                                                                                   | 
| Candidatus Nitrososphaera gargensis Ga9.2                                 | 2853                                                                                                        | 
| Staphylococcus aureus subsp. aureus JKD6008                               | 2873                                                                                                        | 
| Staphylococcus aureus subsp. aureus T0131                                 | 2874                                                                                                        | 
| Staphylococcus aureus 16K                                                 | 2875                                                                                                        | 
| Mycobacterium chubuense NBB4                                              | 2877,2878,2876                                                                                              | 
| Mycobacterium rhodesiae NBB3                                              | 2879                                                                                                        | 
| Mycobacterium sp. MOTT36Y                                                 | 2880                                                                                                        | 
| Mycobacterium mageritense JR2009                                          | 2881                                                                                                        | 
| Mycobacterium sp. JDM601                                                  | 2895                                                                                                        | 
| Mycobacterium gilvum Spyr1                                                | 2896,2897,2898                                                                                              | 
| Mycobacterium abscessus subsp. bolletii F1725                             | 2899                                                                                                        | 
| Clostridium phage phiC2 NULL                                              | 2900                                                                                                        | 
| Clostridium phage phiCD27 NULL                                            | 2901                                                                                                        | 
| Clostridium phage phiCD38-2 NULL                                          | 2902                                                                                                        | 
| Clostridium phage phiCD119 NULL                                           | 2903                                                                                                        | 
| Clostridium phage phiCD6356 NULL                                          | 2904                                                                                                        | 
| Chlorobium tepidum TLS                                                    | 2905                                                                                                        | 
| Micromonospora aurantiaca ATCC 27029                                      | 2909                                                                                                        | 
| Mycobacterium phlei RIVM601174                                            | 2910                                                                                                        | 
| Mycobacterium thermoresistibile ATCC 19527                                | 2911                                                                                                        | 
| Kitasatospora setae KM-6054                                               | 2936                                                                                                        | 
| Streptomyces scabiei 87.22                                                | 2937                                                                                                        | 
| Streptomyces bingchenggensis BCW-1                                        | 2938                                                                                                        | 
| Streptomyces sp. SirexAA-E                                                | 2939                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhimurium 14028S            | 2940,2941                                                                                                   | 
| Xanthomonas citri pv. citri LD71a                                         | 3419                                                                                                        | 
| Xanthomonas citri pv. citri NCPPB 3608                                    | 3428                                                                                                        | 
| Xanthomonas citri pv. citri JS584                                         | 3413                                                                                                        | 
| Xanthomonas citri pv. citri LE20-1                                        | 3420                                                                                                        | 
| Xanthomonas citri pv. citri CFBP 2852                                     | 3779                                                                                                        | 
| Xanthomonas citri pv. citri NCPPB 3562                                    | 3398                                                                                                        | 
| Xanthomonas citri pv. citri FDC 1083                                      | 3400                                                                                                        | 
| Xanthomonas citri pv. citri FDC 217                                       | 3401                                                                                                        | 
| Xanthomonas citri pv. citri JJ238-10                                      | 3405                                                                                                        | 
| Xanthomonas citri pv. citri JW160-1                                       | 3414                                                                                                        | 
| Xanthomonas citri pv. citri LC80                                          | 3417                                                                                                        | 
| Xanthomonas citri pv. citri CFBP 2911                                     | 3396                                                                                                        | 
| Xanthomonas citri pv. citri X2003-3218                                    | 3397                                                                                                        | 
| Xanthomonas citri pv. citri JF90-2                                        | 3402                                                                                                        | 
| Xanthomonas citri pv. citri JF90-8                                        | 3403                                                                                                        | 
| Xanthomonas citri pv. citri JJ238-24                                      | 3406                                                                                                        | 
| Staphylococcus aureus subsp. aureus MRSA252                               | 3011                                                                                                        | 
| Staphylococcus aureus subsp. aureus USA300_FPR3757                        | 3016,3017,3018,3019                                                                                         | 
| Staphylococcus aureus subsp. aureus USA300_TCH1516                        | 3020,3021,3022                                                                                              | 
| Staphylococcus aureus subsp. aureus COL                                   | 3023,3024                                                                                                   | 
| Staphylococcus aureus subsp. aureus S0385                                 | 3027,3028,3029,3030                                                                                         | 
| Staphylococcus aureus subsp. aureus 11819-97                              | 3036                                                                                                        | 
| Desulfovibrio magneticus Maddingley MBC34                                 | 3177                                                                                                        | 
| Rhizobium sp. IRBG74                                                      | 3473,3475,3916                                                                                              | 
| Acidithiobacillus ferrivorans SS3                                         | 3201                                                                                                        | 
| Acidithiobacillus caldus SM-1                                             | 3202,3203,3204,3205,3206                                                                                    | 
| Acidithiobacillus thiooxidans ATCC 19377                                  | 3207                                                                                                        | 
| Acidithiobacillus caldus ATCC 51756                                       | 3208                                                                                                        | 
| Bacillus amyloliquefaciens DSM 7                                          | 3209                                                                                                        | 
| Bacillus amyloliquefaciens LL3                                            | 3210,3211                                                                                                   | 
| Bacillus amyloliquefaciens TA208                                          | 3212                                                                                                        | 
| Bacillus amyloliquefaciens XH7                                            | 3213                                                                                                        | 
| Bacillus amyloliquefaciens Y2                                             | 3214                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum YAU B9601-Y2                  | 3215                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum CAU B946                      | 3216                                                                                                        | 
| Clostridium difficile MID13 7032994                                       | 3220                                                                                                        | 
| Listeria monocytogenes SLCC2755                                           | 3221,3222                                                                                                   | 
| Listeria monocytogenes SLCC2372                                           | 3223,3224                                                                                                   | 
| Listeria monocytogenes SLCC2540                                           | 3225                                                                                                        | 
| Listeria monocytogenes SLCC2479                                           | 3226                                                                                                        | 
| Listeria monocytogenes SLCC5850                                           | 3227                                                                                                        | 
| Listeria monocytogenes SLCC7179                                           | 3228                                                                                                        | 
| Listeria monocytogenes SLCC2376                                           | 3229                                                                                                        | 
| Listeria monocytogenes ATCC 19117                                         | 3230                                                                                                        | 
| Listeria monocytogenes SLCC2378                                           | 3231                                                                                                        | 
| Listeria monocytogenes serotype 7 SLCC2482                                | 3232,3233                                                                                                   | 
| Bacillus sp. 5B6                                                          | 3240                                                                                                        | 
| Bacillus sp. 916                                                          | 3241                                                                                                        | 
| Clostridium acidurici 9a                                                  | 3243,3244                                                                                                   | 
| Listeria monocytogenes L312                                               | 3245                                                                                                        | 
| Streptomyces hygroscopicus subsp. jinggangensis 5008                      | 3247,3248,3249                                                                                              | 
| Roseovarius nubinhibens ISM                                               | 3250                                                                                                        | 
| Streptococcus sanguinis 2908                                              | 3252                                                                                                        | 
| Anabaena sp. 90                                                           | 3273,3274,3275,3276,3277                                                                                    | 
| Leptospira borgpetersenii 200901122                                       | 3278                                                                                                        | 
| Leptospira licerasiae serovar Varillal VAR 010                            | 3279                                                                                                        | 
| Listeria monocytogenes serotype 4b LL195                                  | 3284                                                                                                        | 
| Acidithiobacillus ferrooxidans ATCC 23270                                 | 3338                                                                                                        | 
| Halomonas sp. HAL1                                                        | 3339                                                                                                        | 
| Halomonas sp. GFAJ-1                                                      | 3340                                                                                                        | 
| Halomonas sp. KM-1                                                        | 3341                                                                                                        | 
| Staphylococcus haemolyticus JCSC1435                                      | 3342,3343,3344,3345                                                                                         | 
| Staphylococcus saprophyticus subsp. saprophyticus ATCC 15305              | 3346,3347,3348                                                                                              | 
| Staphylococcus epidermidis RP62A                                          | 3349,3350                                                                                                   | 
| Staphylococcus capitis SK14                                               | 3351                                                                                                        | 
| Staphylococcus capitis VCU116                                             | 3352                                                                                                        | 
| Staphylococcus epidermidis ATCC 12228                                     | 3355,3356,3357,3358,3359,3353,3354                                                                          | 
| Staphylococcus lugdunensis HKU09-01                                       | 3360                                                                                                        | 
| Staphylococcus lugdunensis N920143                                        | 3361                                                                                                        | 
| Staphylococcus carnosus subsp. carnosus TM300                             | 3363                                                                                                        | 
| Staphylococcus pseudintermedius HKU10-03                                  | 3364                                                                                                        | 
| Staphylococcus aureus 08BA02176                                           | 3365                                                                                                        | 
| Burkholderia glumae BGR1                                                  | 3382,3383,3384,3385,3386,3387                                                                               | 
| Burkholderia sp. CCGE1003                                                 | 3388,3389                                                                                                   | 
| Burkholderia phenoliruptrix BR3459a                                       | 3390,3391,3392                                                                                              | 
| Halomonas sp. A3H3                                                        | 3393,3394                                                                                                   | 
| Actinobacillus pleuropneumoniae serovar 3 JL03                            | 3426                                                                                                        | 
| Actinobacillus pleuropneumoniae serovar 5b L20                            | 3427                                                                                                        | 
| Xanthomonas citri pv. bilvae NCPPB 3213                                   | 3438                                                                                                        | 
| Actinobacillus suis H91-0380                                              | 3439                                                                                                        | 
| Bordetella bronchiseptica 253                                             | 3440                                                                                                        | 
| Bordetella bronchiseptica MO149                                           | 3441                                                                                                        | 
| Haemophilus parasuis SH0165                                               | 3442                                                                                                        | 
| Mycoplasma hyopneumoniae 168                                              | 3455                                                                                                        | 
| Mycoplasma hyorhinis HUB-1                                                | 3456                                                                                                        | 
| Mycoplasma hyorhinis SK76                                                 | 3457                                                                                                        | 
| Streptococcus agalactiae FSL S3-026                                       | 3458                                                                                                        | 
| Pasteurella multocida subsp. multocida 3480                               | 3461                                                                                                        | 
| Pasteurella multocida subsp. multocida HN06                               | 3462,3463                                                                                                   | 
| Streptococcus suis JS14                                                   | 3464                                                                                                        | 
| Streptococcus suis SS12                                                   | 3466                                                                                                        | 
| Streptococcus suis ST1                                                    | 3467                                                                                                        | 
| Streptococcus suis ST3                                                    | 3468                                                                                                        | 
| Methylophaga aminisulfidivorans MP                                        | 3469                                                                                                        | 
| Methylobacterium sp. GXF4                                                 | 3470                                                                                                        | 
| Methylobacterium extorquens DSM 13060                                     | 3471                                                                                                        | 
| Pseudomonas aeruginosa PA7                                                | 3472                                                                                                        | 
| Pseudomonas aeruginosa DK2                                                | 3476                                                                                                        | 
| Pseudomonas aeruginosa M18                                                | 3477                                                                                                        | 
| Pseudomonas aeruginosa NCGM2.S1                                           | 3478                                                                                                        | 
| Nocardia brasiliensis ATCC 700358 HUJEG-1                                 | 3483                                                                                                        | 
| Stenotrophomonas maltophilia D457                                         | 3504                                                                                                        | 
| Thermacetogenium phaeum DSM 12270                                         | 3522                                                                                                        | 
| Acetobacterium woodii DSM 1030                                            | 3530                                                                                                        | 
| Stenotrophomonas maltophilia PML168                                       | 3536                                                                                                        | 
| Stenotrophomonas maltophilia RR-10                                        | 3537                                                                                                        | 
| Streptococcus sanguinis ATCC 29667                                        | 3538                                                                                                        | 
| Streptococcus sanguinis ATCC 49296                                        | 3539                                                                                                        | 
| Streptococcus sanguinis SK1                                               | 3540                                                                                                        | 
| Streptococcus sanguinis SK1056                                            | 3541                                                                                                        | 
| Streptococcus sanguinis SK1057                                            | 3542                                                                                                        | 
| Streptococcus sanguinis SK1058                                            | 3543                                                                                                        | 
| Streptococcus sanguinis SK1059                                            | 3544                                                                                                        | 
| Streptococcus sanguinis SK1087                                            | 3545                                                                                                        | 
| Streptococcus sanguinis SK115                                             | 3546                                                                                                        | 
| Streptococcus sanguinis SK150                                             | 3547                                                                                                        | 
| Streptococcus sanguinis SK160                                             | 3548                                                                                                        | 
| Streptococcus sanguinis SK330                                             | 3549                                                                                                        | 
| Streptococcus sanguinis SK340                                             | 3550                                                                                                        | 
| Streptococcus sanguinis SK353                                             | 3551                                                                                                        | 
| Streptococcus sanguinis SK355                                             | 3552                                                                                                        | 
| Streptococcus sanguinis SK405                                             | 3553                                                                                                        | 
| Streptococcus sanguinis SK408                                             | 3554                                                                                                        | 
| Streptococcus sanguinis SK49                                              | 3555                                                                                                        | 
| Streptococcus sanguinis SK678                                             | 3556                                                                                                        | 
| Streptococcus sanguinis SK72                                              | 3557                                                                                                        | 
| Streptococcus sanguinis VMC66                                             | 3558                                                                                                        | 
| Leptospira santarosai serovar Shermani 1342KT                             | 3559                                                                                                        | 
| Leptospira borgpetersenii serovar Mini 200901116                          | 3560                                                                                                        | 
| Listeria monocytogenes FSL F2-208                                         | 3561                                                                                                        | 
| Halomonas boliviensis LC1                                                 | 3562                                                                                                        | 
| Halomonas sp. TD01                                                        | 3563                                                                                                        | 
| Arthrospira platensis C1                                                  | 3564                                                                                                        | 
| Methylocystis parvus OBBP                                                 | 3565                                                                                                        | 
| Methylophaga thiooxydans DMS010                                           | 3566                                                                                                        | 
| Methylococcus capsulatus Texas                                            | 3567                                                                                                        | 
| Methylobacterium sp. MB200                                                | 3568                                                                                                        | 
| Methylobacterium sp. B1                                                   | 3569                                                                                                        | 
| Methanobrevibacter sp. JH1                                                | 3570                                                                                                        | 
| Cupriavidus sp. BIS7                                                      | 3573                                                                                                        | 
| Niastella koreensis GR20-10                                               | 3637                                                                                                        | 
| Methylocystis sp. SC2                                                     | 3668                                                                                                        | 
| Beijerinckia indica subsp. indica ATCC 9039                               | 3669,3670,3671                                                                                              | 
| Desulfomonile tiedjei DSM 6799                                            | 3673,3672                                                                                                   | 
| Stenotrophomonas maltophilia Ab55555                                      | 3686                                                                                                        | 
| Stenotrophomonas maltophilia S028                                         | 3687                                                                                                        | 
| Pseudomonas aeruginosa B136-33                                            | 3746                                                                                                        | 
| Escherichia coli Nissle 1917                                              | 3749                                                                                                        | 
| Aeromonas hydrophila subsp. hydrophila ATCC 7966                          | 3754                                                                                                        | 
| Aeromonas salmonicida subsp. salmonicida A449                             | 3755,3756,3757,3758,3759,3760                                                                               | 
| Aeromonas veronii B565                                                    | 3762                                                                                                        | 
| Citrobacter koseri ATCC BAA-895                                           | 3765,3763,3764                                                                                              | 
| Citrobacter rodentium ICC168                                              | 3766,3767,3768,3769                                                                                         | 
| Serratia plymuthica AS9                                                   | 3770                                                                                                        | 
| Serratia marcescens FGI94                                                 | 3771                                                                                                        | 
| Serratia symbiotica Cinara cedri                                          | 3772                                                                                                        | 
| Desulfovibrio africanus Walvis Bay                                        | 3773                                                                                                        | 
| Desulfovibrio desulfuricans ND132                                         | 3774                                                                                                        | 
| Desulfovibrio vulgaris RCH1                                               | 3775,3776                                                                                                   | 
| Anaeromyxobacter dehalogenans 2CP-1                                       | 3777                                                                                                        | 
| Anaeromyxobacter dehalogenans 2CP-C                                       | 3780                                                                                                        | 
| Desulfitobacterium dehalogenans ATCC 51507                                | 3783                                                                                                        | 
| Desulfitobacterium dichloroeliminans LMG P-21439                          | 3784                                                                                                        | 
| Anaeromyxobacter sp. K                                                    | 3792                                                                                                        | 
| Anaeromyxobacter sp. Fw109-5                                              | 3794                                                                                                        | 
| Dehalococcoides mccartyi BTF08                                            | 3795                                                                                                        | 
| Dehalococcoides mccartyi DCMB5                                            | 3796                                                                                                        | 
| Dehalobacter sp. DCA                                                      | 3797                                                                                                        | 
| Dehalobacter sp. CF                                                       | 3798                                                                                                        | 
| Citrobacter freundii GTC 09479                                            | 3799                                                                                                        | 
| Citrobacter freundii ATCC 8090 MTCC 1658                                  | 3800                                                                                                        | 
| Citrobacter freundii ballerup 7851/39                                     | 3801                                                                                                        | 
| Citrobacter sp. L17                                                       | 3802                                                                                                        | 
| Citrobacter sp. A1                                                        | 3803                                                                                                        | 
| Gordonia malaquae NBRC 108250                                             | 3804                                                                                                        | 
| Pseudomonas sp. M47T1                                                     | 3805                                                                                                        | 
| Burkholderia sp. TJI49                                                    | 3806                                                                                                        | 
| Gordonia effusa NBRC 100432                                               | 3807                                                                                                        | 
| Vibrio brasiliensis LMG 20546                                             | 3808                                                                                                        | 
| Rickettsiella grylli NULL                                                 | 3809                                                                                                        | 
| Diplorickettsia massiliensis 20B                                          | 3810                                                                                                        | 
| Pseudomonas aeruginosa PA21_ST175                                         | 3811                                                                                                        | 
| Micavibrio aeruginosavorus ARL-13                                         | 3812                                                                                                        | 
| Candidatus Nitrosoarchaeum koreensis MY1                                  | 3815                                                                                                        | 
| Candidatus Nitrosoarchaeum limnia BG20                                    | 3816                                                                                                        | 
| Candidatus Nitrosopumilus salaria BD31                                    | 3817                                                                                                        | 
| Burkholderia kururiensis M130                                             | 3818                                                                                                        | 
| Burkholderia gladioli 3848s-5                                             | 3819                                                                                                        | 
| Burkholderia glumae 3252-8                                                | 3820                                                                                                        | 
| Burkholderia glumae AU6208                                                | 3821                                                                                                        | 
| Burkholderia glumae LMG 2196                                              | 3822                                                                                                        | 
| Pseudomonas aeruginosa 138244                                             | 3823                                                                                                        | 
| Pseudomonas aeruginosa ATCC 14886                                         | 3824                                                                                                        | 
| Austwickia chelonae NBRC 105200                                           | 3825                                                                                                        | 
| Amycolatopsis azurea DSM 43854                                            | 3826                                                                                                        | 
| Methanoculleus bourgensis MS2 type strain:MS2                             | 3827                                                                                                        | 
| Amycolatopsis decaplanina DSM 44594                                       | 3828                                                                                                        | 
| Dehalococcoides sp. CBDB1                                                 | 3832                                                                                                        | 
| Sinorhizobium sp. M14                                                     | 3833                                                                                                        | 
| Burkholderia terrae BS001                                                 | 3837                                                                                                        | 
| Providencia stuartii Ps                                                   | 3860                                                                                                        | 
| Sphingobium sp. SYK-6                                                     | 3869,3870                                                                                                   | 
| Sphingobium indicum B90A                                                  | 3879                                                                                                        | 
| Serratia plymuthica 4Rx13                                                 | 3880,3881                                                                                                   | 
| Serratia marcescens WW4                                                   | 3882,3883                                                                                                   | 
| Serratia symbiotica Tucson                                                | 3884                                                                                                        | 
| Bacillus amyloliquefaciens IT-45                                          | 3885,3886                                                                                                   | 
| Bacillus amyloliquefaciens subsp. plantarum AS43.3                        | 3887                                                                                                        | 
| Thauera sp. MZ1T                                                          | 3888,3889                                                                                                   | 
| Thauera aminoaromatica S2                                                 | 3890                                                                                                        | 
| Thauera terpenica 58Eu                                                    | 3891                                                                                                        | 
| Thauera selenatis AX ATCC 55363                                           | 3892                                                                                                        | 
| Methanomassiliicoccus luminyensis B10                                     | 3893                                                                                                        | 
| Agrobacterium albertimagni AOL15                                          | 3894                                                                                                        | 
| Agrobacterium tumefaciens Cherry 2E-2-2                                   | 3895                                                                                                        | 
| Rhizobium sp. PDO1-076 PDO-076                                            | 3896                                                                                                        | 
| Magnetospirillum sp. SO-1                                                 | 3918                                                                                                        | 
| Methylobacterium sp. 88A                                                  | 3925                                                                                                        | 
| Hyphomicrobium sp. 99                                                     | 3926                                                                                                        | 
| Methylobacterium mesophilicum SR1.6/6                                     | 3927                                                                                                        | 
| Hyphomicrobium denitrificans 1NES1                                        | 3928                                                                                                        | 
| Enterobacter cloacae subsp. dissolvens SDM                                | 3929                                                                                                        | 
| Enterobacter cloacae subsp. cloacae ATCC 13047                            | 3930,3931,3932                                                                                              | 
| Enterobacter sp. R4-368                                                   | 3933,3934                                                                                                   | 
| Enterobacter cloacae subsp. cloacae ENHKU01                               | 3935                                                                                                        | 
| Enterobacter lignolyticus SCF1                                            | 3936                                                                                                        | 
| Enterobacter cloacae subsp. dissolvens SP1                                | 3937                                                                                                        | 
| Enterobacter sp. SST3                                                     | 3938                                                                                                        | 
| Enterobacter cloacae subsp. cloacae GS1                                   | 3939                                                                                                        | 
| Methyloversatilis sp. RZ18-153                                            | 3940                                                                                                        | 
| Methylobacter sp. UW 659-2-H10                                            | 3941                                                                                                        | 
| Methylobacter sp. UW 659-2-G11                                            | 3942                                                                                                        | 
| Methylopila sp. M107                                                      | 3943                                                                                                        | 
| Agrobacterium sp. 224MFTsu3.1                                             | 3958                                                                                                        | 
| Agrobacterium radiobacter DSM 30147                                       | 3961                                                                                                        | 
| Rhodococcus ruber IEGM 231                                                | 3966                                                                                                        | 
| Carnobacterium maltaromaticum ATCC 35586                                  | 3969                                                                                                        | 
| Carnobacterium sp. AT7                                                    | 3970                                                                                                        | 
| Carnobacterium sp. 17-4                                                   | 3971,3972                                                                                                   | 
| Acinetobacter sp. HA                                                      | 3980                                                                                                        | 
| Candidatus Nitrosopumilus koreensis AR1                                   | 3998                                                                                                        | 
| Candidatus Nitrosopumilus sp. AR2                                         | 3999                                                                                                        | 
| Stenotrophomonas maltophilia EPM1                                         | 4002                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 81-176                                 | 4004,4005,4006                                                                                              | 
| Campylobacter jejuni subsp. jejuni M1                                     | 4007                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 81116; NCTC 11828                      | 4008                                                                                                        | 
| Campylobacter jejuni subsp. jejuni DFVF1099                               | 4009                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 305                                    | 4010                                                                                                        | 
| Methylomonas sp. MK1                                                      | 4019                                                                                                        | 
| Methylophaga lonarensis MPL                                               | 4020                                                                                                        | 
| Methylotenera sp. 1P/1                                                    | 4025                                                                                                        | 
| Methylotenera sp. 73s                                                     | 4026                                                                                                        | 
| Methylotenera versatilis 79                                               | 4027                                                                                                        | 
| Methylotenera mobilis JLW8                                                | 4028                                                                                                        | 
| Methylophaga sp. JAM1                                                     | 4033                                                                                                        | 
| Methylophaga sp. JAM7                                                     | 4034,4035                                                                                                   | 
| Methylotenera versatilis 301                                              | 4036                                                                                                        | 
| Methylovorus glucosetrophus SIP3-4                                        | 4037,4038,4039                                                                                              | 
| Methylovorus sp. MP688                                                    | 4040                                                                                                        | 
| Candidatus Methanomethylophilus alvus Mx1201                              | 4041                                                                                                        | 
| Methanomethylovorans hollandica DSM 15978                                 | 4042,4043                                                                                                   | 
| Rhizobium tropici CIAT 899                                                | 4065,4066,4067,4068                                                                                         | 
| Herbaspirillum seropedicae SmR1                                           | 4099                                                                                                        | 
| Bacteroides xylanisolvens XB1A                                            | 4108                                                                                                        | 
| Candidatus Microthrix parvicella Bio17-1                                  | 4113                                                                                                        | 
| Bacteroides xylanisolvens SD CC 1b                                        | 4116                                                                                                        | 
| Bacteroides ovatus SD CMC 3f                                              | 4117                                                                                                        | 
| Bacteroides ovatus SD CC 2a                                               | 4118                                                                                                        | 
| Acinetobacter baumannii BJAB07104                                         | 4122,4120,4121                                                                                              | 
| Campylobacter jejuni subsp. jejuni S3                                     | 4124,4125                                                                                                   | 
| Campylobacter jejuni 4031                                                 | 4126                                                                                                        | 
| Campylobacter jejuni subsp. jejuni ICDCCJ07001                            | 4127,4128                                                                                                   | 
| Campylobacter jejuni subsp. jejuni IA3902 NULL                            | 4129,4130                                                                                                   | 
| Campylobacter jejuni subsp. jejuni PT14                                   | 4131                                                                                                        | 
| Leptospira borgpetersenii Noumea 25                                       | 4140                                                                                                        | 
| Leptospira borgpetersenii serovar Mini 201000851                          | 4141                                                                                                        | 
| Leptospira borgpetersenii serovar Castellonis 200801910                   | 4142                                                                                                        | 
| Leptospira kirschneri 200801774                                           | 4143                                                                                                        | 
| Leptospira kirschneri 200803703                                           | 4144                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhimurium NULL              | 4164,4165                                                                                                   | 
| Campylobacter jejuni subsp. doylei 269.97                                 | 4168                                                                                                        | 
| Campylobacter jejuni subsp. jejuni NCTC 11168-BN148                       | 4169                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 00-2425                                | 4170                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 00-2426                                | 4171                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 00-2538                                | 4172                                                                                                        | 
| Pseudomonas stutzeri TS44                                                 | 4177                                                                                                        | 
| uncultured archaeon ANME-1                                                | 4188                                                                                                        | 
| Mucispirillum schaedleri ASF457                                           | 4189                                                                                                        | 
| Mycoplasma capricolum subsp. capricolum ATCC 27343                        | 4192                                                                                                        | 
| Mycoplasma leachii PG50                                                   | 4193                                                                                                        | 
| Mycoplasma mycoides subsp. capri LC 95010                                 | 4194,4195                                                                                                   | 
| Mycoplasma mycoides subsp. mycoides SC Gladysdale                         | 4196                                                                                                        | 
| Mycoplasma putrefaciens Mput9231                                          | 4197                                                                                                        | 
| Halomonas titanicae BH1                                                   | 4212                                                                                                        | 
| Mycoplasma agalactiae PG2                                                 | 4213                                                                                                        | 
| Mycoplasma bovis PG45                                                     | 4214                                                                                                        | 
| Mycoplasma fermentans PG18                                                | 4215                                                                                                        | 
| Mycoplasma haemocanis Illinois                                            | 4216                                                                                                        | 
| Mycoplasma pneumoniae FH                                                  | 4217                                                                                                        | 
| Bacillus amyloliquefaciens CC178                                          | 4219                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum NAU-B3                        | 4220,4221                                                                                                   | 
| Corynebacterium striatum BM4687                                           | 4223                                                                                                        | 
| Pedobacter saltans DSM 12145                                              | 4224                                                                                                        | 
| Caulobacter segnis ATCC 21756                                             | 4225                                                                                                        | 
| Deinococcus maricopensis DSM 21211                                        | 4226                                                                                                        | 
| Roseobacter litoralis Och 149                                             | 4227,4228,4229,4230                                                                                         | 
| Photobacterium angustum S14                                               | 4247                                                                                                        | 
| Photobacterium damselae subsp. damselae CIP 102761                        | 4248                                                                                                        | 
| Photobacterium profundum 3TCK                                             | 4492                                                                                                        | 
| Photobacterium sp. AK15                                                   | 4250                                                                                                        | 
| Photobacterium sp. SKA34                                                  | 4251                                                                                                        | 
| Photobacterium leiognathi subsp. mandapamensis svers.1.1.                 | 4252                                                                                                        | 
| Elusimicrobium minutum Pei191                                             | 4253                                                                                                        | 
| uncultured Termite group 1 bacterium phylotype Rs-D17 NULL                | 4254,4256,4258,4260                                                                                         | 
| Dysgonomonas gadei ATCC BAA-286                                           | 4291                                                                                                        | 
| Dysgonomonas mossii DSM 22836 v1                                          | 4292                                                                                                        | 
| Dysgonomonas mossii DSM 22836                                             | 4293                                                                                                        | 
| Enterobacteria phage P1 NULL                                              | 4294                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 2008-1025                              | 4299                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 2008-894                               | 4300                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 2008-979                               | 4301                                                                                                        | 
| Campylobacter jejuni subsp. jejuni ICDCCJ07002                            | 4302                                                                                                        | 
| Campylobacter jejuni subsp. jejuni ICDCCJ07004                            | 4303                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 84-25                                  | 4304                                                                                                        | 
| Campylobacter jejuni subsp. jejuni CF93-6                                 | 4305                                                                                                        | 
| Campylobacter jejuni subsp. jejuni CG8486                                 | 4306                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 00-2544                                | 4307,4308                                                                                                   | 
| Campylobacter jejuni subsp. jejuni H22082                                 | 4309                                                                                                        | 
| Campylobacter jejuni subsp. jejuni HB93-13                                | 4310                                                                                                        | 
| Campylobacter jejuni subsp. jejuni LMG 9872                               | 4311                                                                                                        | 
| Campylobacter jejuni subsp. jejuni NW                                     | 4312                                                                                                        | 
| Campylobacter jejuni subsp. jejuni LMG 9081                               | 4313                                                                                                        | 
| Campylobacter jejuni X                                                    | 4314                                                                                                        | 
| Streptomyces clavuligerus ATCC 27064                                      | 4322                                                                                                        | 
| Helicobacter pylori 35A                                                   | 4335                                                                                                        | 
| Helicobacter pylori 51                                                    | 4336                                                                                                        | 
| Helicobacter pylori 83                                                    | 4337                                                                                                        | 
| Helicobacter pylori HLJHP193                                              | 4338                                                                                                        | 
| Pseudomonas chlororaphis subsp. chlororaphis GP72                         | 4347                                                                                                        | 
| Pseudomonas fluorescens R124                                              | 4348,4368                                                                                                   | 
| Pseudomonas chlororaphis subsp. aureofaciens 30-84                        | 4349                                                                                                        | 
| Pseudomonas chlororaphis O6                                               | 4350                                                                                                        | 
| Pseudomonas fluorescens F113                                              | 4351                                                                                                        | 
| Pseudomonas fluorescens A506                                              | 4352,4353                                                                                                   | 
| Pseudomonas fluorescens NZ052                                             | 4354                                                                                                        | 
| Pseudomonas fluorescens Q8r1-96                                           | 4355                                                                                                        | 
| Pseudomonas fluorescens BS2                                               | 4356                                                                                                        | 
| Pseudomonas fluorescens Wayne1                                            | 4357                                                                                                        | 
| Pseudomonas fluorescens SS101                                             | 4358                                                                                                        | 
| Pseudomonas fluorescens HK44                                              | 4359                                                                                                        | 
| Pseudomonas fluorescens BRIP34879                                         | 4360                                                                                                        | 
| Pseudomonas fluorescens NZ007                                             | 4361                                                                                                        | 
| Pseudomonas fluorescens WH6                                               | 4362                                                                                                        | 
| Pseudomonas fluorescens NCIMB 11764                                       | 4363                                                                                                        | 
| Pseudomonas fluorescens Q2-87                                             | 4364                                                                                                        | 
| Pseudomonas fluorescens EGD-AQ6                                           | 4365                                                                                                        | 
| Pseudomonas fluorescens BBc6R8                                            | 4366                                                                                                        | 
| Pseudomonas fluorescens NZ011                                             | 4367                                                                                                        | 
| Helicobacter pylori India7                                                | 4371                                                                                                        | 
| Helicobacter pylori Lithuania75                                           | 4372,4373                                                                                                   | 
| Helicobacter pylori PeCan18                                               | 4374                                                                                                        | 
| Helicobacter pylori Puno120                                               | 4375,4376                                                                                                   | 
| Helicobacter pylori Puno135                                               | 4377                                                                                                        | 
| Helicobacter pylori Rif1                                                  | 4378                                                                                                        | 
| Helicobacter pylori Rif2                                                  | 4379                                                                                                        | 
| Helicobacter pylori Sat464                                                | 4380,4381                                                                                                   | 
| Helicobacter pylori Shi112                                                | 4382                                                                                                        | 
| Helicobacter pylori Shi169                                                | 4383                                                                                                        | 
| Helicobacter pylori Shi417                                                | 4384                                                                                                        | 
| Helicobacter pylori SouthAfrica7                                          | 4385,4386                                                                                                   | 
| Helicobacter pylori XZ274                                                 | 4387,4388                                                                                                   | 
| Helicobacter pylori 52                                                    | 4389                                                                                                        | 
| Helicobacter pylori v225d                                                 | 4390,4391                                                                                                   | 
| Helicobacter pylori SNT49 Santal49                                        | 4392,4393                                                                                                   | 
| Helicobacter pylori HLJHP256                                              | 4394                                                                                                        | 
| Helicobacter pylori HLJHP271                                              | 4395                                                                                                        | 
| Thauera linaloolentis 47Lol = DSM 12138                                   | 4403                                                                                                        | 
| Thauera phenylacetica B4P                                                 | 4404                                                                                                        | 
| Thauera sp. 28                                                            | 4405                                                                                                        | 
| Thauera sp. 27                                                            | 4406                                                                                                        | 
| Thauera sp. 63                                                            | 4407                                                                                                        | 
| Helicobacter pylori 2017                                                  | 4414                                                                                                        | 
| Helicobacter pylori 2018                                                  | 4415                                                                                                        | 
| Helicobacter pylori 908                                                   | 4416                                                                                                        | 
| Helicobacter pylori Aklavik117                                            | 4417,4418,4419                                                                                              | 
| Helicobacter pylori Aklavik86                                             | 4420,4421,4422                                                                                              | 
| Helicobacter pylori Cuz20                                                 | 4423                                                                                                        | 
| Helicobacter pylori ELS37                                                 | 4425,4424                                                                                                   | 
| Helicobacter pylori F16                                                   | 4426                                                                                                        | 
| Helicobacter pylori F30                                                   | 4427,4428                                                                                                   | 
| Helicobacter pylori F32                                                   | 4429,4430                                                                                                   | 
| Helicobacter pylori F57                                                   | 4431                                                                                                        | 
| Helicobacter pylori Gambia94/24                                           | 4432,4433                                                                                                   | 
| Helicobacter pylori HUP-B14                                               | 4434,4435                                                                                                   | 
| Marinobacter santoriniensis NKSG1                                         | 4436                                                                                                        | 
| Novosphingobium aromaticivorans DSM 12444                                 | 4437,4438,4439                                                                                              | 
| Sphingopyxis alaskensis RB2256                                            | 4441,4440                                                                                                   | 
| Sphingopyxis baekryungensis DSM 16222                                     | 4442                                                                                                        | 
| Sphingopyxis sp. MC1                                                      | 4443                                                                                                        | 
| Novosphingobium pentaromativorans US6-1                                   | 4444                                                                                                        | 
| Bacillus selenitireducens MLS10                                           | 4450                                                                                                        | 
| Shewanella sp. ANA-3                                                      | 4451,4452                                                                                                   | 
| Achromobacter arsenitoxydans SY8                                          | 4453                                                                                                        | 
| Methanotorris igneus Kol 5                                                | 4456                                                                                                        | 
| Methanococcus voltae A3                                                   | 4457                                                                                                        | 
| Methanococcus maripaludis X1                                              | 4458                                                                                                        | 
| Methanococcus maripaludis C6                                              | 4459                                                                                                        | 
| Methanocaldococcus fervens AG86                                           | 4460,4461                                                                                                   | 
| Desulfotomaculum alcoholivorax DSM 16058                                  | 4478                                                                                                        | 
| Desulfurispora thermophila DSM 16022                                      | 4479                                                                                                        | 
| Acidiphilium multivorum AIU301                                            | 4498,4499,4501,4503,4504,4505,4506,4507,4508                                                                | 
| Thermus scotoductus SA-01                                                 | 4500,4502                                                                                                   | 
| Starkeya novella DSM 506                                                  | 4509                                                                                                        | 
| Xanthobacter autotrophicus Py2                                            | 4510,4511                                                                                                   | 
| Chlorobium phaeobacteroides BS1                                           | 4512                                                                                                        | 
| Chlorobium limicola DSM 245                                               | 4513                                                                                                        | 
| Burkholderia multivorans ATCC 17616                                       | 4514,4515,4516,4517                                                                                         | 
| Achromobacter piechaudii HLE                                              | 4518                                                                                                        | 
| Alcaligenes faecalis subsp. faecalis NCIB 8687                            | 4519                                                                                                        | 
| Nitrosopumilus sp. AR                                                     | 4520                                                                                                        | 
| Methylophilus sp. 1                                                       | 4521                                                                                                        | 
| Methyloglobulus morosus KoM1                                              | 4522                                                                                                        | 
| Methylobacterium sp. 285MFTsu5.1                                          | 4523                                                                                                        | 
| Methylobacterium sp. 77                                                   | 4524                                                                                                        | 
| Methylophilus sp. 42                                                      | 4525                                                                                                        | 
| Methylobacterium sp. WSM2598                                              | 4526                                                                                                        | 
| Methylohalobius crimeensis 10Ki                                           | 4527                                                                                                        | 
| Hyphomicrobium nitrativorans NL23                                         | 4528                                                                                                        | 
| Brucella suis VBI22                                                       | 4529,4530                                                                                                   | 
| Brucella pinnipedialis B2/94                                              | 4531,4532                                                                                                   | 
| Brucella melitensis NI                                                    | 4533,4534                                                                                                   | 
| Brucella melitensis M5-90                                                 | 4535,4536                                                                                                   | 
| Brucella melitensis M28                                                   | 4537,4538                                                                                                   | 
| Brucella canis HSK A52141                                                 | 4539,4540                                                                                                   | 
| Brucella abortus A13334                                                   | 4541,4542                                                                                                   | 
| Paenibacillus polymyxa M1                                                 | 4553,4554                                                                                                   | 
| Natronomonas moolapensis 8.8.11                                           | 4555                                                                                                        | 
| Halobacterium salinarum R1 R1; DSM 671                                    | 4556,4557,4558,4559,4560                                                                                    | 
| Caldisphaera lagunensis DSM 15908                                         | 4561                                                                                                        | 
| Acholeplasma laidlawii PG-8A                                              | 4562                                                                                                        | 
| Mesoplasma florum W37                                                     | 4563                                                                                                        | 
| Mycoplasma mobile 163K                                                    | 4564                                                                                                        | 
| Spiroplasma apis B31                                                      | 4565                                                                                                        | 
| Spiroplasma chrysopicola DF-1                                             | 4566                                                                                                        | 
| Spiroplasma syrphidicola EA-1                                             | 4567                                                                                                        | 
| Spiroplasma diminutum CUAS-1                                              | 4568                                                                                                        | 
| Spiroplasma taiwanense CT-1                                               | 4569,4570                                                                                                   | 
| Verrucomicrobium spinosum DSM 4136                                        | 4571                                                                                                        | 
| Variovorax sp. CF313                                                      | 4572                                                                                                        | 
| Nitrosopumilus sp. SJ                                                     | 4573                                                                                                        | 
| Pseudaminobacter salicylatoxidans KCT001                                  | 4574                                                                                                        | 
| Verrucomicrobiae bacterium DG1235                                         | 4575                                                                                                        | 
| Aminomonas paucivorans DSM 12260                                          | 4576                                                                                                        | 
| Variovorax paradoxus 4MFCol3.1                                            | 4577                                                                                                        | 
| Methylophilus methylotrophus DSM 46235 = ATCC 53528                       | 4578                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 1336                                   | 4606                                                                                                        | 
| Campylobacter jejuni subsp. jejuni 414                                    | 4607                                                                                                        | 
| Lactococcus garvieae ATCC 49156                                           | 4609                                                                                                        | 
| Lactococcus raffinolactis 4877                                            | 4610                                                                                                        | 
| Enterobacter cloacae MR2                                                  | 4611                                                                                                        | 
| Klebsiella pneumoniae SB3432                                              | 4626,4627                                                                                                   | 
| Chromobacterium violaceum ATCC 12472                                      | 4631                                                                                                        | 
| Lactobacillus sakei subsp. sakei 23K                                      | 4632                                                                                                        | 
| Leuconostoc gelidum JB7                                                   | 4633                                                                                                        | 
| Macrococcus caseolyticus JCSC5402                                         | 4634,4635,4636,4637,4638,4639,4640,4641,4642                                                                | 
| Rothia mucilaginosa DY-18                                                 | 4643                                                                                                        | 
| Serratia liquefaciens ATCC 27592                                          | 4644,4645                                                                                                   | 
| Acinetobacter lwoffii NIPH 512                                            | 4646                                                                                                        | 
| Acinetobacter lwoffii WJ10621                                             | 4647                                                                                                        | 
| Pseudomonas fragi B25                                                     | 4648                                                                                                        | 
| Pseudomonas fragi A22                                                     | 4649                                                                                                        | 
| Moraxella catarrhalis RH4                                                 | 4650                                                                                                        | 
| Shewanella putrefaciens 200                                               | 4651                                                                                                        | 
| Shewanella putrefaciens CN-32                                             | 4652                                                                                                        | 
| Lactobacillus curvatus CRL 705                                            | 4653                                                                                                        | 
| Hafnia alvei ATCC 51873                                                   | 4668                                                                                                        | 
| Candidatus Hamiltonella symbiont of Bemisia tabaci MEAM1                  | 4687                                                                                                        | 
| Wolbachia pipientis wRec                                                  | 4689                                                                                                        | 
| Chromohalobacter salexigens DSM 3043                                      | 4690                                                                                                        | 
| Streptococcus agalactiae STIR-CD-07                                       | 4711                                                                                                        | 
| Streptococcus agalactiae STIR-CD-17                                       | 4712                                                                                                        | 
| Vibrio cholerae HC-22A1                                                   | 4727                                                                                                        | 
| Saccharothrix espanaensis DSM 44229                                       | 4730                                                                                                        | 
| Fluoribacter dumoffii Tex-KL                                              | 4731                                                                                                        | 
| Streptomyces albulus CCRC 11814                                           | 4732                                                                                                        | 
| Streptomyces sviceus ATCC 29083                                           | 4733                                                                                                        | 
| Legionella longbeachae D-4968                                             | 4734                                                                                                        | 
| Candidatus Odyssella thessalonicensis L13                                 | 4735                                                                                                        | 
| Streptomyces somaliensis DSM 40738                                        | 4736                                                                                                        | 
| Parabacteroides sp. 20_3                                                  | 4737                                                                                                        | 
| Moorea producens 3L                                                       | 4738                                                                                                        | 
| Saccharopolyspora spinosa NRRL 18395                                      | 4739                                                                                                        | 
| Marinomonas mediterranea MMB-1                                            | 4744                                                                                                        | 
| Micavibrio aeruginosavorus EPB                                            | 4745                                                                                                        | 
| Sphingobium japonicum BiD32                                               | 4746                                                                                                        | 
| Pseudomonas putida KT2440                                                 | 4747                                                                                                        | 
| Akkermansia muciniphila ATCC BAA-835                                      | 4748                                                                                                        | 
| Akkermansia muciniphila CAG:154                                           | 4749                                                                                                        | 
| Akkermansia sp. CAG:344                                                   | 4750                                                                                                        | 
| Cedecea davisae DSM 4568                                                  | 4751                                                                                                        | 
| Sphingobium japonicum UT26S                                               | 4767,4768,4769,4770,4771                                                                                    | 
| Streptomyces sp. AA4                                                      | 4772                                                                                                        | 
| Pyrococcus yayanosii CH1                                                  | 4773                                                                                                        | 
| Bacillus amyloliquefaciens LFB112                                         | 4781                                                                                                        | 
| Carnobacterium sp. WN1359                                                 | 4782,4783,4784,4785,4786,4787                                                                               | 
| Clostridium lentocellum DSM 5427                                          | 4788                                                                                                        | 
| Desulfovibrio gigas DSM 1382 = ATCC 19364                                 | 4789,4790                                                                                                   | 
| Burkholderia graminis C4D1M                                               | 4792                                                                                                        | 
| Candidatus Burkholderia kirkii UZHbot1                                    | 4793                                                                                                        | 
| Burkholderia pyrrocinia CH-67                                             | 4794                                                                                                        | 
| Burkholderia sp. WSM4176                                                  | 4795                                                                                                        | 
| Burkholderia sp. JPY347                                                   | 4796                                                                                                        | 
| Burkholderia sp. JPY251                                                   | 4797                                                                                                        | 
| Burkholderia bryophila 376MFSha3.1                                        | 4798                                                                                                        | 
| Burkholderia vietnamiensis AU4i                                           | 4799                                                                                                        | 
| Streptomyces violaceusniger Tu 4113                                       | 4800,4801,4802                                                                                              | 
| Nonomuraea coxensis DSM 45129                                             | 4803                                                                                                        | 
| Pantoea sp. YR343                                                         | 4804                                                                                                        | 
| Pantoea sp. GM01                                                          | 4805                                                                                                        | 
| Pantoea agglomerans IG1                                                   | 4806                                                                                                        | 
| Pantoea agglomerans Tx10                                                  | 4807                                                                                                        | 
| Pantoea agglomerans 299R                                                  | 4808                                                                                                        | 
| Pantoea ananatis B1-9                                                     | 4809                                                                                                        | 
| Pantoea ananatis BRT175                                                   | 4810                                                                                                        | 
| Pantoea dispersa EGD-AAK13                                                | 4811                                                                                                        | 
| Neisseria gonorrhoeae MS11                                                | 4813                                                                                                        | 
| Microcystis aeruginosa TAIHU98                                            | 4814                                                                                                        | 
| Microcystis aeruginosa SPC777                                             | 4815                                                                                                        | 
| Microcystis aeruginosa DIANCHI905                                         | 4816                                                                                                        | 
| Pleomorphomonas koreensis DSM 23070                                       | 4817                                                                                                        | 
| Pleomorphomonas oryzae DSM 16300                                          | 4818                                                                                                        | 
| Klebsiella pneumoniae subsp. pneumoniae Kp13                              | 4826,4827,4828,4829,4830,4831,4832                                                                          | 
| Aeromonas hydrophila ML09-119                                             | 4835                                                                                                        | 
| Aeromonas dhakensis AAK1                                                  | 4836                                                                                                        | 
| Aeromonas hydrophila SSU                                                  | 4837                                                                                                        | 
| Magnetospirillum magneticum AMB-1                                         | 4838                                                                                                        | 
| Rhodospirillum rubrum F11                                                 | 4839                                                                                                        | 
| Shinella zoogloeoides DD12                                                | 4844                                                                                                        | 
| Rhizobium sp. AP16                                                        | 4845                                                                                                        | 
| Rhizobium lupini HPC(L)                                                   | 4846                                                                                                        | 
| Rhizobium phaseoli Ch24-10                                                | 4847                                                                                                        | 
| Rhizobium giardinii bv. giardinii H152                                    | 4848                                                                                                        | 
| Rhizobium gallicum bv. gallicum R602sp                                    | 4849                                                                                                        | 
| Rhizobium grahamii CCGE 502                                               | 4850                                                                                                        | 
| Rhizobium freirei PRF 81                                                  | 4851                                                                                                        | 
| Rhizobium mongolense USDA 1844                                            | 4852                                                                                                        | 
| Agrobacterium tumefaciens MAFF 301001                                     | 4853                                                                                                        | 
| Agrobacterium tumefaciens NULL                                            | 4854                                                                                                        | 
| Agrobacterium rhizogenes MAFF03-01724                                     | 4855                                                                                                        | 
| Agrobacterium tumefaciens Bo542                                           | 4856                                                                                                        | 
| Rhizobium leguminosarum bv. phaseoli 4292                                 | 4862                                                                                                        | 
| Agrobacterium sp. 10MFCol1.1                                              | 4863                                                                                                        | 
| Raoultella ornithinolytica B6                                             | 4864                                                                                                        | 
| Klebsiella pneumoniae subsp. pneumoniae DSM 30104                         | 4878                                                                                                        | 
| Pandoraea sp. RB-44                                                       | 4881                                                                                                        | 
| Porphyromonas gingivalis W83                                              | 4882                                                                                                        | 
| Porphyromonas gingivalis TDC60                                            | 4883                                                                                                        | 
| Porphyromonas gingivalis ATCC 33277                                       | 4884                                                                                                        | 
| Acinetobacter baumannii 1656-2                                            | 4885,4886,4887                                                                                              | 
| Desulfococcus multivorans DSM 2059                                        | 4896                                                                                                        | 
| Rhodococcus erythropolis CCM2595                                          | 4916,4917                                                                                                   | 
| Rhodococcus pyridinivorans SB3094                                         | 4918,4919,4920                                                                                              | 
| Rhodococcus equi 103S                                                     | 4921                                                                                                        | 
| Mycobacterium tuberculosis CCDC5079                                       | 4923                                                                                                        | 
| Mycobacterium tuberculosis Beijing/NITR203                                | 4924                                                                                                        | 
| Mycobacterium tuberculosis 210                                            | 4925                                                                                                        | 
| Mycobacterium tuberculosis CTRI-4                                         | 4926                                                                                                        | 
| Mycobacterium tuberculosis 94_M4241A                                      | 4927                                                                                                        | 
| Mycobacterium tuberculosis 02_1987                                        | 4928                                                                                                        | 
| Mycobacterium tuberculosis T85                                            | 4929                                                                                                        | 
| Mycobacterium tuberculosis W-148                                          | 4930                                                                                                        | 
| Mycobacterium tuberculosis HN878                                          | 4931                                                                                                        | 
| Mycobacterium tuberculosis X122                                           | 4932                                                                                                        | 
| Rahnella sp. Y9602                                                        | 4935,4936,4937                                                                                              | 
| Candidatus Regiella insecticola R5.15                                     | 4938                                                                                                        | 
| Candidatus Regiella insecticola LSR1                                      | 4939                                                                                                        | 
| Sporomusa ovata DSM 2662                                                  | 4940                                                                                                        | 
| Neisseria gonorrhoeae UM01                                                | 4942                                                                                                        | 
| Dickeya dadantii Ech586                                                   | 4949                                                                                                        | 
| Dickeya dadantii Ech703                                                   | 4950                                                                                                        | 
| Dickeya zeae Ech1591                                                      | 4951                                                                                                        | 
| Dickeya dadantii 3937                                                     | 4952                                                                                                        | 
| Bradyrhizobium oligotrophicum S58                                         | 4953                                                                                                        | 
| Bradyrhizobium elkanii USDA 76                                            | 4954                                                                                                        | 
| Bradyrhizobium japonicum USDA 124                                         | 4955                                                                                                        | 
| Capnocytophaga canimorsus Cc5                                             | 4965                                                                                                        | 
| Paenibacillus elgii B69                                                   | 4966                                                                                                        | 
| Acidianus hospitalis W1                                                   | 4967                                                                                                        | 
| Haloferax volcanii DS2                                                    | 4968,4969,4970,4971,4973                                                                                    | 
| Halorhabdus utahensis DSM 12940                                           | 4972                                                                                                        | 
| Metallosphaera cuprina Ar-4                                               | 4974                                                                                                        | 
| Methanoregula boonei 6A8                                                  | 4975                                                                                                        | 
| Methanothermobacter marburgensis Marburg                                  | 4976,4977                                                                                                   | 
| Pyrococcus sp. NA2                                                        | 4978                                                                                                        | 
| Sulfolobus islandicus M.16.27                                             | 4979                                                                                                        | 
| Vulcanisaeta moutnovskia 768-28                                           | 4980                                                                                                        | 
| Natrinema pellirubrum DSM 15624                                           | 4982,4983,4981                                                                                              | 
| Paenibacillus terrae HPL-003                                              | 4985                                                                                                        | 
| Paenibacillus sp. JDR-2                                                   | 4986                                                                                                        | 
| Paenibacillus sp. Y412MC10                                                | 4987                                                                                                        | 
| Paenibacillus polymyxa E681                                               | 4988                                                                                                        | 
| Paenibacillus polymyxa SC2                                                | 4989,4990                                                                                                   | 
| Paenibacillus polymyxa CR1                                                | 4991                                                                                                        | 
| Caulobacter crescentus NA1000                                             | 4999                                                                                                        | 
| Caulobacter sp. K31                                                       | 5003,5004,5005                                                                                              | 
| Caulobacter crescentus OR37                                               | 5006                                                                                                        | 
| Bacillus anthracis A1055                                                  | 5010                                                                                                        | 
| Mycoplasma capricolum subsp. capripneumoniae M1601                        | 5039                                                                                                        | 
| Mycoplasma ovipneumoniae SC01                                             | 5040                                                                                                        | 
| Mycoplasma agalactiae 14628                                               | 5041                                                                                                        | 
| Mycoplasma mycoides subsp. capri PG3                                      | 5042                                                                                                        | 
| Mycoplasma alkalescens 14918                                              | 5043                                                                                                        | 
| Mycoplasma arginini 7264                                                  | 5044                                                                                                        | 
| Mycoplasma bovigenitalium 51080                                           | 5045                                                                                                        | 
| Mycoplasma auris 15026                                                    | 5046                                                                                                        | 
| Mycoplasma yeatsii 13926                                                  | 5047                                                                                                        | 
| Mycoplasma synoviae ATCC 25204 WVU 1853                                   | 5048                                                                                                        | 
| Mycoplasma agalactiae 5632                                                | 5049                                                                                                        | 
| Mycoplasma bovis HB0801                                                   | 5050                                                                                                        | 
| Mycoplasma conjunctivae HRC/581                                           | 5051                                                                                                        | 
| Mycoplasma crocodyli MP145                                                | 5052                                                                                                        | 
| Mycoplasma cynos C142                                                     | 5053                                                                                                        | 
| Mycoplasma haemofelis Langford 1                                          | 5054                                                                                                        | 
| Mycoplasma leachii 99/014/6                                               | 5055                                                                                                        | 
| Mycoplasma putrefaciens KS1                                               | 5056                                                                                                        | 
| Mycoplasma synoviae 53                                                    | 5057                                                                                                        | 
| Mycoplasma wenyonii Massachusetts                                         | 5058                                                                                                        | 
| Aster yellows witches-broom phytoplasma AYWB NULL                         | 5079,5080,5081,5082,5083                                                                                    | 
| Candidatus Phytoplasma australiense NULL                                  | 5084                                                                                                        | 
| Candidatus Phytoplasma mali AT                                            | 5085                                                                                                        | 
| Onion yellows phytoplasma OY-M onion yellows                              | 5086                                                                                                        | 
| Strawberry lethal yellows phytoplasma (CPA) NZSb11                        | 5087                                                                                                        | 
| Candidatus Phytoplasma solani 284/09                                      | 5088                                                                                                        | 
| Serratia fonticola AU-AP2C                                                | 5103                                                                                                        | 
| Serratia fonticola AU-P3(3)                                               | 5104                                                                                                        | 
| Serratia plymuthica A30                                                   | 5105                                                                                                        | 
| Azospirillum brasilense FP2                                               | 5157                                                                                                        | 
| Azospirillum halopraeferens DSM 3675                                      | 5158                                                                                                        | 
| Azospirillum irakense DSM 11586                                           | 5159                                                                                                        | 
| Azospirillum brasilense Az39                                              | 5173,5174,5175,5170,5171,5172                                                                               | 
| Pelosinus fermentans A11                                                  | 5176                                                                                                        | 
| Pelosinus fermentans B4                                                   | 5177                                                                                                        | 
| Pelosinus fermentans JBW45                                                | 5178                                                                                                        | 
| Pelosinus fermentans DSM 17108 R7                                         | 5179                                                                                                        | 
| Pelosinus sp. HCF1                                                        | 5180                                                                                                        | 
| Pelosinus fermentans A12                                                  | 5181                                                                                                        | 
| Pelosinus fermentans B3                                                   | 5182                                                                                                        | 
| Rhizobium sullae WSM1592                                                  | 5221                                                                                                        | 
| Pyrococcus sp. ST04                                                       | 5229                                                                                                        | 
| Thermococcus sp. CL1                                                      | 5230                                                                                                        | 
| Thermococcus barophilus MP                                                | 5231,5232                                                                                                   | 
| Bacteroides reticulotermitis JCM 10512                                    | 5243                                                                                                        | 
| Bifidobacterium bifidum PRL2010                                           | 5245                                                                                                        | 
| Bifidobacterium breve ACS-071-V-Sch8b                                     | 5246                                                                                                        | 
| Alteromonas macleodii Aegean Sea MED64                                    | 5249                                                                                                        | 
| Alteromonas macleodii ATCC 27126                                          | 5250                                                                                                        | 
| Alteromonas macleodii Balearic Sea AD45                                   | 5251,5252                                                                                                   | 
| Alteromonas macleodii Black Sea 11                                        | 5253                                                                                                        | 
| Alteromonas macleodii Deep ecotype                                        | 5254                                                                                                        | 
| Alteromonas macleodii English Channel 615                                 | 5255,5256                                                                                                   | 
| Alteromonas macleodii Ionian Sea U4                                       | 5258,5257                                                                                                   | 
| Pseudoalteromonas atlantica T6c                                           | 5259                                                                                                        | 
| Pseudoalteromonas sp. SM9913                                              | 5260,5261                                                                                                   | 
| Alteromonas macleodii AltDE1                                              | 5282,5283                                                                                                   | 
| Alteromonas macleodii English Channel 673                                 | 5284                                                                                                        | 
| Alteromonas macleodii Ionian Sea U7                                       | 5285                                                                                                        | 
| Alteromonas macleodii Ionian Sea U8                                       | 5286                                                                                                        | 
| Alteromonas macleodii Ionian Sea UM4b                                     | 5287                                                                                                        | 
| Alteromonas macleodii Ionian Sea UM7                                      | 5288,5289                                                                                                   | 
| Alteromonas sp. SN2                                                       | 5290                                                                                                        | 
| Glaciecola psychrophila 170                                               | 5291                                                                                                        | 
| Marinobacter adhaerens HP15                                               | 5294,5292,5293                                                                                              | 
| Oscillatoria formosa PCC 6407                                             | 5296                                                                                                        | 
| Thermoanaerobacter tengcongensis MB4 MB4T                                 | 5301                                                                                                        | 
| Escherichia sp. 3_2_53FAA                                                 | 5304                                                                                                        | 
| Escherichia sp. 4_1_40B                                                   | 5305                                                                                                        | 
| Candidatus Nitrososphaera evergladensis SR1                               | 5306                                                                                                        | 
| Pseudoalteromonas luteoviolacea 2ta16                                     | 5313                                                                                                        | 
| Pseudoalteromonas luteoviolacea B = ATCC 29581                            | 5314                                                                                                        | 
| Myxococcus stipitatus DSM 14675                                           | 5317                                                                                                        | 
| Myxococcus fulvus HW-1                                                    | 5318                                                                                                        | 
| Myxococcus xanthus DK 1622                                                | 5319                                                                                                        | 
| Brevibacillus agri BAB-2500                                               | 5325                                                                                                        | 
| Brevibacillus panacihumi W25                                              | 5326                                                                                                        | 
| Brevibacillus massiliensis NULL                                           | 5327                                                                                                        | 
| Brevibacillus brevis NBRC 100599                                          | 5328                                                                                                        | 
| Brevibacillus laterosporus DSM 25                                         | 5329                                                                                                        | 
| Clostridium butyricum 5521                                                | 5342                                                                                                        | 
| Clostridium butyricum 60E.3                                               | 5343                                                                                                        | 
| Clostridium butyricum DKU-01                                              | 5344                                                                                                        | 
| Clostridium butyricum E4 BoNT E BL5262                                    | 5345                                                                                                        | 
| Clostridium beijerinckii G117                                             | 5346                                                                                                        | 
| candidate division SR1 bacterium RAAC1_SR1_1                              | 5353                                                                                                        | 
| Lactobacillus salivarius ATCC 11741                                       | 5359                                                                                                        | 
| Lactobacillus salivarius GJ-24                                            | 5360                                                                                                        | 
| Lactobacillus salivarius NIAS840                                          | 5361                                                                                                        | 
| Lactobacillus salivarius SMXD51                                           | 5362                                                                                                        | 
| Leptospira interrogans serovar Icterohaemorrhagiae Verdun LP              | 5364                                                                                                        | 
| Citrobacter amalonaticus L8A                                              | 5377                                                                                                        | 
| Treponema pedis T A4                                                      | 5381                                                                                                        | 
| Treponema medium ATCC 700293                                              | 5382                                                                                                        | 
| Treponema vincentii ATCC 35580                                            | 5383                                                                                                        | 
| Burkholderia cenocepacia H111                                             | 5388                                                                                                        | 
| Burkholderia cenocepacia K56-2Valvano                                     | 5389                                                                                                        | 
| Burkholderia cenocepacia BC7 NULL                                         | 5390                                                                                                        | 
| Burkholderia cenocepacia J2315                                            | 5394,5395,5392,5393                                                                                         | 
| Shewanella benthica KT99                                                  | 5397                                                                                                        | 
| Moritella dasanensis ArB 0140                                             | 5398                                                                                                        | 
| Moritella marina ATCC 15381                                               | 5399                                                                                                        | 
| Moritella marina ATCC 15381 MP-1                                          | 5400                                                                                                        | 
| Moritella sp. PE36                                                        | 5401                                                                                                        | 
| Mannheimia haemolytica D153                                               | 5411                                                                                                        | 
| Mannheimia haemolytica D171                                               | 5412                                                                                                        | 
| Mannheimia haemolytica D174                                               | 5413                                                                                                        | 
| Mannheimia haemolytica M42548                                             | 5414                                                                                                        | 
| Mannheimia haemolytica USDA-ARS-USMARC-183                                | 5415                                                                                                        | 
| Mannheimia haemolytica USDA-ARS-USMARC-185                                | 5416                                                                                                        | 
| Mannheimia haemolytica USMARC_2286                                        | 5417                                                                                                        | 
| Acidovorax avenae subsp. avenae ATCC 19860                                | 5420                                                                                                        | 
| Acidovorax citrulli AAC00-1                                               | 5421                                                                                                        | 
| Acidovorax ebreus TPSY                                                    | 5422                                                                                                        | 
| Acidovorax sp. JS42                                                       | 5423,5424,5425                                                                                              | 
| Acidovorax sp. KKS102                                                     | 5426                                                                                                        | 
| Verminephrobacter eiseniae EF01-2                                         | 5427,5428                                                                                                   | 
| Leptospirillum ferriphilum ML-04                                          | 5449                                                                                                        | 
| Thermus sp. RL RLM                                                        | 5520                                                                                                        | 
| Staphylococcus equorum subsp. equorum Mu2                                 | 5560                                                                                                        | 
| Corynebacterium casei UCMA 3821                                           | 5561                                                                                                        | 
| Brevibacterium linens BL2                                                 | 5562                                                                                                        | 
| Arthrobacter arilaitensis Re117                                           | 5564,5565,5563                                                                                              | 
| Sulfolobus solfataricus 98/2                                              | 5572                                                                                                        | 
| Caldivirga maquilingensis IC-167                                          | 5573                                                                                                        | 
| Vulcanisaeta distributa DSM 14429                                         | 5574                                                                                                        | 
| Staphylococcus aureus subsp. aureus Z172                                  | 5622,5623,5624                                                                                              | 
| Staphylococcus aureus CA-347                                              | 5625,5626                                                                                                   | 
| Staphylococcus aureus subsp. aureus TW20                                  | 5627,5628,5629                                                                                              | 
| Staphylococcus aureus subsp. aureus Mu50                                  | 5630,5631                                                                                                   | 
| Deinococcus geothermalis DSM 11300                                        | 5657,5658,5659                                                                                              | 
| Deinococcus gobiensis I-0                                                 | 5660,5661,5662,5663,5664,5665,5666                                                                          | 
| Deinococcus peraridilitoris DSM 19664                                     | 5669,5667,5668                                                                                              | 
| Deinococcus proteolyticus MRP                                             | 5670,5671,5672,5673,5674                                                                                    | 
| Photorhabdus temperata subsp. temperata M1021                             | 5692                                                                                                        | 
| Photorhabdus temperata J3                                                 | 5693                                                                                                        | 
| Alteromonadales bacterium TW-7                                            | 5694                                                                                                        | 
| Vibrio alginolyticus 12G01                                                | 5695                                                                                                        | 
| Vibrio campbellii HY01                                                    | 5696                                                                                                        | 
| Vibrio alginolyticus 40B                                                  | 5697                                                                                                        | 
| Shewanella oneidensis MR-1                                                | 5701,5702                                                                                                   | 
| Vibrio orientalis CIP 102891 = ATCC 33934                                 | 5732                                                                                                        | 
| Providencia rettgeri Dmel1                                                | 5769                                                                                                        | 
| Providencia rettgeri DSM 1131                                             | 5770                                                                                                        | 
| Staphylococcus saprophyticus subsp. saprophyticus KACC 16562              | 5778                                                                                                        | 
| Carnobacterium maltaromaticum DSM 20342 MX5                               | 5781                                                                                                        | 
| Clostridium tetanomorphum DSM 665                                         | 5782                                                                                                        | 
| Escherichia coli UMNF18                                                   | 5794                                                                                                        | 
| Escherichia coli TW10598                                                  | 5795                                                                                                        | 
| Escherichia coli TW11681                                                  | 5796                                                                                                        | 
| Brucella abortus bv. 3 Tulya                                              | 5811                                                                                                        | 
| Brucella ceti B1/94                                                       | 5812                                                                                                        | 
| Brucella melitensis bv. 1 Rev.1                                           | 5813                                                                                                        | 
| Brucella neotomae 5K33                                                    | 5814                                                                                                        | 
| Brucella pinnipedialis M163/99/10                                         | 5815                                                                                                        | 
| Brucella pinnipedialis M292/94/1                                          | 5816                                                                                                        | 
| Brucella sp. 83/13                                                        | 5817                                                                                                        | 
| Brucella suis bv. 5 513                                                   | 5818                                                                                                        | 
| Psychromonas ossibalaenae ATCC BAA-1528 JAMM 0738                         | 5824                                                                                                        | 
| Clostridium sp. ASF502                                                    | 5826                                                                                                        | 
| Eubacterium plexicaudatum ASF492                                          | 5827                                                                                                        | 
| Clostridium sp. ASF356                                                    | 5828                                                                                                        | 
| Firmicutes bacterium ASF500                                               | 5829                                                                                                        | 
| Lactobacillus murinus ASF361                                              | 5830                                                                                                        | 
| Lactobacillus sp. ASF360                                                  | 5831                                                                                                        | 
| Parabacteroides sp. ASF519                                                | 5832                                                                                                        | 
| Nitrospina gracilis 3/211                                                 | 5837                                                                                                        | 
| Burkholderia cepacia ATCC 25416                                           | 5838                                                                                                        | 
| Methylobacterium sp. 10                                                   | 5852                                                                                                        | 
| Methylobacterium sp. EUR3 AL-11                                           | 5853                                                                                                        | 
| Aminobacter sp. J41                                                       | 5854                                                                                                        | 
| Methylocystis sp. LW5                                                     | 5855                                                                                                        | 
| Methylobacterium sp. UNCCL110                                             | 5856                                                                                                        | 
| Methylobacter sp. BBA5.1                                                  | 5857                                                                                                        | 
| Methylosinus sp. PW1                                                      | 5858                                                                                                        | 
| Methylacidiphilum kamchatkense Kam1                                       | 5859                                                                                                        | 
| Methylobacterium sp. ZNC0032                                              | 5860                                                                                                        | 
| Methylomonas denitrificans FJG1                                           | 5861                                                                                                        | 
| Methylobacterium sp. L2-4                                                 | 5862                                                                                                        | 
| Methylococcaceae bacterium 73a                                            | 5863                                                                                                        | 
| Methylocapsa aurea KYG T                                                  | 5864                                                                                                        | 
| Methylobacterium sp. B34                                                  | 5865                                                                                                        | 
| Lactobacillus brevis ATCC 14869 = DSM 20054 ATCC 14869                    | 5915                                                                                                        | 
| Lactobacillus brevis subsp. gravesensis ATCC 27305                        | 5916                                                                                                        | 
| Candidatus Nitrosocosmicus exaquare G61                                   | 5917                                                                                                        | 
| Leuconostoc gasicomitatum LMG 18811                                       | 9220                                                                                                        | 
| Leuconostoc carnosum JB16                                                 | 9221,9222,9223,9224,9225                                                                                    | 
| Leuconostoc citreum KM20                                                  | 9218,9219,9215,9216,9217                                                                                    | 
| Leuconostoc kimchii IMSNU 11154                                           | 9226,9227,9228,9229,9230,9231                                                                               | 
| Leuconostoc mesenteroides subsp. mesenteroides ATCC 8293                  | 9235,9236                                                                                                   | 
| Leuconostoc mesenteroides subsp. mesenteroides J18                        | 9237,9238,9239,9240,9241,9242                                                                               | 
| Serratia plymuthica S13 NULL                                              | 5957                                                                                                        | 
| Serratia sp. AS12                                                         | 5958                                                                                                        | 
| Serratia sp. AS13                                                         | 5959                                                                                                        | 
| Serratia sp. ATCC 39006                                                   | 5960                                                                                                        | 
| Serratia sp. S4                                                           | 5961                                                                                                        | 
| Pseudomonas extremaustralis 14-3 substr. 14-3b                            | 5971                                                                                                        | 
| Pseudomonas psychrophila HA-4                                             | 5972                                                                                                        | 
| Pseudomonas psychrotolerans L19                                           | 5973                                                                                                        | 
| Xanthomonas gardneri ATCC 19865                                           | 5974                                                                                                        | 
| Xanthomonas hortorum pv. carotae M081                                     | 5975                                                                                                        | 
| Xanthomonas oryzae X11-5A                                                 | 5976                                                                                                        | 
| Xanthomonas oryzae X8-1A                                                  | 5977                                                                                                        | 
| Xanthomonas translucens DAR61454                                          | 5978                                                                                                        | 
| Xanthomonas translucens pv. graminis ART-Xtg29                            | 5979                                                                                                        | 
| Xanthomonas translucens pv. translucens DSM 18974                         | 5980                                                                                                        | 
| Halorubrum lacusprofundi ATCC 49239                                       | 5983,5981,5982                                                                                              | 
| Haloquadratum walsbyi C23 DSM 16854                                       | 5984,5985,5986,5987                                                                                         | 
| Weissella koreensis KACC 15510                                            | 5994,5995                                                                                                   | 
| Weissella koreensis KCTC 3621                                             | 5996                                                                                                        | 
| Weissella halotolerans DSM 20190                                          | 5997                                                                                                        | 
| Weissella paramesenteroides ATCC 33313                                    | 5998                                                                                                        | 
| Weissella confusa LBAE C39-2                                              | 5999                                                                                                        | 
| Weissella ceti NC36                                                       | 6000                                                                                                        | 
| Weissella cibaria KACC 11862                                              | 6001                                                                                                        | 
| Pseudomonas aeruginosa VRFPA04                                            | 6006                                                                                                        | 
| Rhodopirellula baltica SH 1                                               | 6009                                                                                                        | 
| Enterococcus mundtii QU 25 QU25                                           | 6013,6014,6015,6016,6011,6012                                                                               | 
| Enterococcus hirae ATCC 9790                                              | 6017,6018                                                                                                   | 
| Enterococcus avium ATCC 14025                                             | 6019                                                                                                        | 
| Enterococcus durans ATCC 6056                                             | 6020                                                                                                        | 
| Cellulophaga algicola DSM 14237                                           | 6030                                                                                                        | 
| Cellulophaga baltica NN016038                                             | 6040                                                                                                        | 
| Cellulophaga lytica HI1                                                   | 6041                                                                                                        | 
| Lactococcus piscium MKFS47                                                | 6042,6043,6044                                                                                              | 
| Brochothrix campestris FSL F6-1037                                        | 6045                                                                                                        | 
| Brochothrix thermosphacta DSM 20171 FSL F6-1036                           | 6046                                                                                                        | 
| Brochothrix thermosphacta DSM 20171                                       | 6047                                                                                                        | 
| Burkholderia vietnamiensis LMG 10929                                      | 6049,6050,6051,6048                                                                                         | 
| Microbacterium testaceum StLB037                                          | 6055                                                                                                        | 
| Rhodobacter sphaeroides 2.4.1 2.4.1; ATCC BAA-808                         | 6074,6068,6069,6070,6071,6072,6073                                                                          | 
| Halogeometricum borinquense DSM 11551 NULL                                | 6075,6076,6077,6078,6079,6080                                                                               | 
| Rhodobacter capsulatus SB 1003                                            | 6081,6082                                                                                                   | 
| Actinosynnema mirum DSM 43827                                             | 6083                                                                                                        | 
| Kineococcus radiotolerans SRS30216 = ATCC BAA-149 SRS30216                | 6084,6085,6086                                                                                              | 
| Slackia heliotrinireducens DSM 20476                                      | 6087                                                                                                        | 
| Stackebrandtia nassauensis DSM 44728                                      | 6088                                                                                                        | 
| Cellulomonas flavigena DSM 20109                                          | 6089                                                                                                        | 
| Cyanothece sp. ATCC 51142                                                 | 6090,6091,6092,6093,6094,6095                                                                               | 
| Sphaerochaeta globosa Buddy                                               | 6097                                                                                                        | 
| Spirochaeta smaragdinae DSM 11293                                         | 6098                                                                                                        | 
| Treponema caldaria DSM 7334                                               | 6099                                                                                                        | 
| Sphaerochaeta pleomorpha Grapes                                           | 6115                                                                                                        | 
| Formosa agariphila KMM 3901                                               | 6130                                                                                                        | 
| Arthrospira sp. TJSD091                                                   | 6131                                                                                                        | 
| Staphylococcus capitis LNZR-1                                             | 6150                                                                                                        | 
| Staphylococcus epidermidis NGS-ED-1107                                    | 6151                                                                                                        | 
| Staphylococcus epidermidis NGS-ED-1109                                    | 6152                                                                                                        | 
| Staphylococcus epidermidis NGS-ED-1110                                    | 6153                                                                                                        | 
| Staphylococcus epidermidis NGS-ED-1111                                    | 6154                                                                                                        | 
| Staphylococcus epidermidis NGS-ED-1118                                    | 6155                                                                                                        | 
| Staphylococcus capitis QN1                                                | 6156                                                                                                        | 
| Staphylococcus caprae C87                                                 | 6157                                                                                                        | 
| Leptospira kirschneri 201402975                                           | 6177                                                                                                        | 
| Leptospira kirschneri 201401993                                           | 6178                                                                                                        | 
| Leptospira kirschneri 200703021                                           | 6179                                                                                                        | 
| Leptospira kirschneri 200703020                                           | 6180                                                                                                        | 
| Leptospira kirschneri 20021189                                            | 6181                                                                                                        | 
| Leptospira kirschneri 200801774 v2                                        | 6182                                                                                                        | 
| Klebsiella oxytoca E718                                                   | 6248,6249,6250                                                                                              | 
| Klebsiella pneumoniae JM45 NULL                                           | 6251,6252,6253                                                                                              | 
| Klebsiella pneumoniae subsp. pneumoniae 1084                              | 6254                                                                                                        | 
| Frankia sp. EuI1c                                                         | 6263                                                                                                        | 
| Frankia sp. BCU110501                                                     | 6264                                                                                                        | 
| Frankia sp. BMG5.12                                                       | 6265                                                                                                        | 
| Frankia sp. CcI6                                                          | 6266                                                                                                        | 
| Frankia sp. Iso899                                                        | 6267                                                                                                        | 
| Frankia sp. QA3                                                           | 6268                                                                                                        | 
| Frankia sp. DC12                                                          | 6269                                                                                                        | 
| Frankia sp. CpI1-S                                                        | 6270                                                                                                        | 
| Frankia sp. CN3                                                           | 6271                                                                                                        | 
| Frankia sp. BMG5.1                                                        | 6272                                                                                                        | 
| Sporomusa sp. An4                                                         | 6273                                                                                                        | 
| Burkholderia sp. YI23                                                     | 6377,6378,6379,6380,6381,6376                                                                               | 
| Burkholderia sp. RPE64                                                    | 6382,6383,6384,6385,6386                                                                                    | 
| Fusobacterium gonidiaformans ATCC 25563                                   | 6395                                                                                                        | 
| Fusobacterium mortiferum ATCC 9817                                        | 6396                                                                                                        | 
| Fusobacterium necrophorum subsp. funduliforme ATCC 51357                  | 6397                                                                                                        | 
| Fusobacterium nucleatum ChDC F128                                         | 6398                                                                                                        | 
| Fusobacterium nucleatum subsp. vincentii ATCC 49256                       | 6399                                                                                                        | 
| Fusobacterium periodonticum ATCC 33693                                    | 6400                                                                                                        | 
| Fusobacterium russii ATCC 25533 593A                                      | 6401                                                                                                        | 
| Fusobacterium sp. CAG:649 NULL                                            | 6402                                                                                                        | 
| Fusobacterium ulcerans ATCC 49185                                         | 6403                                                                                                        | 
| Fusobacterium varium ATCC 27725                                           | 6404                                                                                                        | 
| Klebsiella pneumoniae B1                                                  | 6433                                                                                                        | 
| Klebsiella pneumoniae CH4                                                 | 6434                                                                                                        | 
| Klebsiella pneumoniae MGH92                                               | 6435                                                                                                        | 
| Klebsiella pneumoniae MGH114                                              | 6436                                                                                                        | 
| Klebsiella pneumoniae BIDMC88                                             | 6437                                                                                                        | 
| Klebsiella pneumoniae BIDMC90                                             | 6438                                                                                                        | 
| Lactobacillus fermentum 3872                                              | 6444                                                                                                        | 
| Lactobacillus fermentum F-6                                               | 6445                                                                                                        | 
| Lactobacillus fermentum CECT 5716                                         | 6446                                                                                                        | 
| Candidatus Methanomassiliicoccus intestinalis Issoire-Mx1 Mx1-Issoire     | 6472                                                                                                        | 
| Thermoplasmatales archaeon BRNA1                                          | 6473                                                                                                        | 
| Nitrosotenuis aquariensis AQ6f                                            | 7525                                                                                                        | 
| Bacillus amyloliquefaciens EGD-AQ14                                       | 6493                                                                                                        | 
| Bacillus amyloliquefaciens UASWS BA1                                      | 6494                                                                                                        | 
| Bacillus amyloliquefaciens subsp. amyloliquefaciens DC-12                 | 6495                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum M27                           | 6496                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum UCMB5036                      | 6497                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum UCMB5113                      | 6498                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum UCMB5033 UCMB-5033            | 6499                                                                                                        | 
| Paenibacillus dendritiformis C454                                         | 6625                                                                                                        | 
| Rahnella aquatilis HX2                                                    | 6632,6633,6634,6635                                                                                         | 
| Citrobacter youngae ATCC 29220                                            | 6636                                                                                                        | 
| Enterobacter mori LMG 25706                                               | 6637                                                                                                        | 
| Leuconostoc citreum LBAE C11                                              | 6638                                                                                                        | 
| Enterococcus durans IPLA 655                                              | 6639                                                                                                        | 
| Lactobacillus malefermentans KCTC 3548                                    | 6640                                                                                                        | 
| Enterococcus malodoratus ATCC 43197                                       | 6654                                                                                                        | 
| Aerococcus viridans ATCC 11563                                            | 6655                                                                                                        | 
| Agrobacterium tumefaciens P4                                              | 6670                                                                                                        | 
| Agrobacterium tumefaciens WRT31                                           | 6671                                                                                                        | 
| Agrobacterium tumefaciens GW4                                             | 6672                                                                                                        | 
| Agrobacterium sp. UNC420CL41Cvi                                           | 6673                                                                                                        | 
| Rhizobium rubi NBRC 13261                                                 | 6674                                                                                                        | 
| Agrobacterium tumefaciens S2                                              | 6675                                                                                                        | 
| Rhizobium larrymoorei ATCC 51759                                          | 6676                                                                                                        | 
| Agrobacterium tumefaciens S33                                             | 8679,8680                                                                                                   | 
| Agrobacterium tumefaciens LBA4404                                         | 6678                                                                                                        | 
| Agrobacterium sp. 33MFTa1.1                                               | 6679                                                                                                        | 
| Rhizobium sp. H41                                                         | 6680                                                                                                        | 
| Agrobacterium sp. KFB 330                                                 | 6681                                                                                                        | 
| Rhizobium nepotum 39-7                                                    | 6682                                                                                                        | 
| Rhizobium sp. UR51a                                                       | 6683                                                                                                        | 
| Agrobacterium tumefaciens F4                                              | 6684                                                                                                        | 
| Rhizobium sp. LMB-1                                                       | 6685                                                                                                        | 
| Agrobacterium sp. LC34                                                    | 6686                                                                                                        | 
| Agrobacterium sp. SUL3                                                    | 6687                                                                                                        | 
| Agrobacterium tumefaciens LBA4213 (Ach5)                                  | 6688,6689,6690,6691                                                                                         | 
| Agrobacterium tumefaciens Ach5                                            | 6693,6694,6695,6692                                                                                         | 
| Carnobacterium gallinarum DSM 4847 MT44                                   | 6697                                                                                                        | 
| Flavobacterium branchiophilum FL-15                                       | 6767,6768                                                                                                   | 
| Flavobacterium indicum GPTSA100-9                                         | 6769                                                                                                        | 
| Edwardsiella ictaluri 93-146                                              | 6770                                                                                                        | 
| Edwardsiella tarda FL6-60                                                 | 6771,6772                                                                                                   | 
| Edwardsiella tarda EIB202                                                 | 6773,6774                                                                                                   | 
| Edwardsiella piscicida C07-087                                            | 6775                                                                                                        | 
| Klebsiella quasipneumoniae subsp. quasipneumoniae FI_HV_2014              | 6796                                                                                                        | 
| Hassallia byssoidea VB512170                                              | 6797                                                                                                        | 
| Escherichia coli ABU 83972                                                | 6799,6800                                                                                                   | 
| Escherichia coli NA114                                                    | 6801                                                                                                        | 
| Escherichia coli JJ1886                                                   | 6805,6806,6807,6802,6803,6804                                                                               | 
| Escherichia coli ATCC 25922                                               | 6812                                                                                                        | 
| Citrobacter amalonaticus 3e8A                                             | 6818                                                                                                        | 
| Citrobacter amalonaticus YG8                                              | 6819                                                                                                        | 
| Citrobacter amalonaticus Y19                                              | 6820,6821                                                                                                   | 
| Pseudomonas syringae CC440                                                | 6844                                                                                                        | 
| Campylobacter lari RM2100 RM2100; ATCC BAA-1060D                          | 6845,6846                                                                                                   | 
| Campylobacter jejuni subsp. jejuni ATCC 33560                             | 6850                                                                                                        | 
| Campylobacter concisus 13826                                              | 6851,6852,6853                                                                                              | 
| Campylobacter curvus 525.92                                               | 6854                                                                                                        | 
| Campylobacter coli 76339                                                  | 6855                                                                                                        | 
| Campylobacter jejuni subsp. jejuni ATCC 33560 - NZ_AIJN                   | 6856                                                                                                        | 
| delta proteobacterium BABL1 NULL                                          | 6857                                                                                                        | 
| Acidobacterium capsulatum ATCC 51196                                      | 6858                                                                                                        | 
| Candidatus Chloracidobacterium thermophilum B                             | 6860,6859                                                                                                   | 
| Candidatus Solibacter usitatus Ellin6076                                  | 6861                                                                                                        | 
| Granulicella mallensis MP5ACTX8                                           | 6862                                                                                                        | 
| Granulicella tundricola MP5ACTX9                                          | 6863,6864,6865,6866,6867,6868                                                                               | 
| Terriglobus roseus DSM 18391                                              | 6869                                                                                                        | 
| Terriglobus saanensis SP1PR4                                              | 6870                                                                                                        | 
| Acidobacteriaceae bacterium KBS 83                                        | 6871                                                                                                        | 
| Acidobacteriaceae bacterium KBS 89                                        | 6872                                                                                                        | 
| Acidobacteriaceae bacterium KBS 96                                        | 6873                                                                                                        | 
| Gemmatimonas aurantiaca T-27 T-27 (= NBRC 100505)                         | 6875                                                                                                        | 
| Rhodopseudomonas palustris TIE-1                                          | 6882                                                                                                        | 
| Sinorhizobium fredii HH103                                                | 6884,6885,6887,6888,6890,6891,6892,6894,6896,6897                                                           | 
| Sinorhizobium fredii USDA 257                                             | 6904,6905,6906,6907,6908,6909,6910,6911,6912,6913,6914,6898,6915,6899,6916,6900,6901,6902,6903              | 
| Sinorhizobium fredii NGR234                                               | 6917,6918,6919                                                                                              | 
| Ilyobacter polytropus DSM 2926                                            | 6943,6944,6945                                                                                              | 
| Pseudoalteromonas agarivorans S816                                        | 6946                                                                                                        | 
| Pseudoalteromonas arctica A 37-1-2                                        | 9967                                                                                                        | 
| Pseudoalteromonas haloplanktis ATCC 14393                                 | 6948                                                                                                        | 
| Pseudoalteromonas piscicida ATCC 15057                                    | 6949                                                                                                        | 
| Pseudoalteromonas spongiae UST010723-006                                  | 9966                                                                                                        | 
| Pseudoalteromonas tunicata D2                                             | 6951                                                                                                        | 
| Pseudoalteromonas undina NCIMB 2128                                       | 6952                                                                                                        | 
| Pseudoalteromonas citrea DSM 8771 NCIMB 1889                              | 6953                                                                                                        | 
| Pseudoalteromonas rubra DSM 6842 ATCC 29570                               | 6954                                                                                                        | 
| Desulfovibrio piezophilus C1TLV30                                         | 6958                                                                                                        | 
| Desulfovibrio africanus PCS                                               | 6959                                                                                                        | 
| Desulfovibrio longus DSM 6739                                             | 6960                                                                                                        | 
| Desulfovibrio oxyclinae DSM 11498                                         | 6961                                                                                                        | 
| Desulfovibrio inopinatus DSM 10711                                        | 6966                                                                                                        | 
| Desulfovibrio putealis DSM 16056                                          | 6967                                                                                                        | 
| Microcystis aeruginosa NIES-2549                                          | 6969,7801                                                                                                   | 
| Photorhabdus luminescens LN2                                              | 6978                                                                                                        | 
| Photorhabdus temperata subsp. khanii NC19                                 | 6979                                                                                                        | 
| Photorhabdus temperata subsp. temperata Meg1                              | 6980                                                                                                        | 
| Photorhabdus temperata subsp. thracensis DSM 15199                        | 6981                                                                                                        | 
| Xanthomonas sacchari NCPPB 4393                                           | 6983                                                                                                        | 
| Microcystis aeruginosa PCC 9809                                           | 7007                                                                                                        | 
| Microcystis aeruginosa PCC 9432                                           | 7008                                                                                                        | 
| Leptolyngbya sp. JSC-1                                                    | 7020                                                                                                        | 
| Vibrio sp. MITpop13 9CS106                                                | 7021                                                                                                        | 
| Vibrio sp. MITpop13 9ZC13                                                 | 7022                                                                                                        | 
| Vibrio sp. MITpop13 9ZC77                                                 | 7023                                                                                                        | 
| Vibrio sp. MITpop13 9ZC88                                                 | 7024                                                                                                        | 
| Vibrio sp. MITpop13 ZF-91                                                 | 7025                                                                                                        | 
| Candidatus Caldiarchaeum subterraneum NULL                                | 7039                                                                                                        | 
| Cytophaga hutchinsonii ATCC 33406                                         | 7051                                                                                                        | 
| Leptospira interrogans 201101846                                          | 7052                                                                                                        | 
| Leptospira interrogans 201502083                                          | 7053                                                                                                        | 
| Leptospira interrogans 201502084                                          | 7054                                                                                                        | 
| Microcystis panniformis FACHB-1757                                        | 7057                                                                                                        | 
| Bacillus anthracis A0248                                                  | 7059,7060,7058                                                                                              | 
| Bacillus anthracis CDC 684                                                | 7061,7062,7063                                                                                              | 
| Bacillus anthracis Sterne                                                 | 7064                                                                                                        | 
| Bacillus atrophaeus 1942                                                  | 7065                                                                                                        | 
| Bacillus cellulosilyticus DSM 2522                                        | 7066                                                                                                        | 
| Bacillus cereus 03BB102                                                   | 7067,7068                                                                                                   | 
| Bacillus cereus AH187                                                     | 7071,7072,7073,7069,7070                                                                                    | 
| Bacillus cereus AH820                                                     | 7074,7075,7076,7077                                                                                         | 
| Bacillus cereus B4264                                                     | 7078                                                                                                        | 
| Bacillus cereus E33L                                                      | 7079,7080,7081,7082,7083,7084                                                                               | 
| Lactobacillus helveticus R0052                                            | 7087                                                                                                        | 
| Lactobacillus helveticus H10                                              | 7088,7089                                                                                                   | 
| Lactobacillus helveticus CNRZ32                                           | 7090                                                                                                        | 
| Desulfovibrio hydrothermalis AM13 = DSM 14728                             | 7091,7093                                                                                                   | 
| Desulfovibrio desulfuricans subsp. aestuarii DSM 17919 = ATCC 29578       | 7095                                                                                                        | 
| Desulfovibrio desulfuricans subsp. desulfuricans DSM 642                  | 7096                                                                                                        | 
| Desulfovibrio alkalitolerans DSM 16529                                    | 7097                                                                                                        | 
| Desulfovibrio sp. A2                                                      | 7098                                                                                                        | 
| Desulfovibrio sp. X2                                                      | 7099                                                                                                        | 
| Microcystis aeruginosa NIES-44                                            | 7102                                                                                                        | 
| Celeribacter indicus P73                                                  | 7103,7104,7105,7106,7107,7108                                                                               | 
| Nitrosomonas cryotolerans ATCC 49181                                      | 7109                                                                                                        | 
| Bacillus cereus G9842                                                     | 7111,7112,7113                                                                                              | 
| Bacillus cereus Q1                                                        | 7114,7115,7116                                                                                              | 
| Bacillus cereus biovar anthracis CI                                       | 7117,7118,7119,7120                                                                                         | 
| Bacillus clausii KSM-K16                                                  | 7121                                                                                                        | 
| Bacillus cytotoxicus NVH 391-98                                           | 7122,7123                                                                                                   | 
| Bacillus megaterium DSM 319                                               | 7124                                                                                                        | 
| Bacillus megaterium QM B1551                                              | 7125,7126,7127,7128,7129,7130,7131,7132                                                                     | 
| Bacillus pseudofirmus OF4                                                 | 7135,7133,7134                                                                                              | 
| Bacillus pumilus SAFR-032                                                 | 7136                                                                                                        | 
| Bacillus subtilis subsp. natto BEST195                                    | 7137,7138                                                                                                   | 
| Bacillus subtilis subsp. spizizenii W23                                   | 7150                                                                                                        | 
| Bacillus thuringiensis Al Hakam                                           | 7151,7152                                                                                                   | 
| Bacillus thuringiensis BMB171                                             | 7154,7153                                                                                                   | 
| Bacillus weihenstephanensis KBAB4                                         | 7156,7157,7158,7159,7155                                                                                    | 
| Burkholderia ambifaria MC40-6                                             | 7160,7161,7162,7163                                                                                         | 
| Burkholderia cenocepacia HI2424                                           | 7164,7165,7166,7167                                                                                         | 
| Burkholderia cenocepacia MC0-3                                            | 7168,7169,7170                                                                                              | 
| Burkholderia cepacia GG4                                                  | 7171,7172                                                                                                   | 
| Burkholderia mallei NCTC 10229                                            | 7173,7174                                                                                                   | 
| Burkholderia mallei NCTC 10247                                            | 7175,7176                                                                                                   | 
| Burkholderia mallei SAVP1                                                 | 7177,7178                                                                                                   | 
| Burkholderia pseudomallei 1026b                                           | 7179,7180                                                                                                   | 
| Burkholderia pseudomallei 1106a                                           | 7181,7182                                                                                                   | 
| Burkholderia pseudomallei 668                                             | 7183,7184                                                                                                   | 
| Burkholderia pseudomallei BPC006                                          | 7185,7186                                                                                                   | 
| Burkholderia pseudomallei MSHR346                                         | 7187                                                                                                        | 
| Burkholderia pseudomallei MSHR305                                         | 7189,7190                                                                                                   | 
| Burkholderia sp. CCGE1001                                                 | 7191,7192                                                                                                   | 
| Burkholderia sp. KJ006                                                    | 7193,7194,7195,7196                                                                                         | 
| Burkholderia pseudomallei NCTC 13179                                      | 7198,7197                                                                                                   | 
| Burkholderia thailandensis MSMB121                                        | 7199,7200                                                                                                   | 
| Burkholderia pseudomallei 1106b                                           | 7203                                                                                                        | 
| Burkholderia pseudomallei 1710a                                           | 7205                                                                                                        | 
| Flavobacterium rivuli DSM 21788                                           | 7221                                                                                                        | 
| Flavobacterium columnare ATCC 49512                                       | 9932                                                                                                        | 
| Burkholderia lata LK27                                                    | 7223                                                                                                        | 
| Burkholderia lata LK13                                                    | 7224                                                                                                        | 
| Burkholderia pseudomallei MSHR146                                         | 7225,7226                                                                                                   | 
| Burkholderia pseudomallei MSHR511                                         | 7227,7229                                                                                                   | 
| Burkholderia pseudomallei MSHR520                                         | 7228,7230                                                                                                   | 
| Burkholderia pseudomallei NAU20B-16                                       | 7231,7233                                                                                                   | 
| Burkholderia pseudomallei NCTC 13178                                      | 7232,7234                                                                                                   | 
| Burkholderia thailandensis E444                                           | 7235,7237                                                                                                   | 
| Burkholderia thailandensis H0587                                          | 7236,7238                                                                                                   | 
| Kyrpidia tusciae DSM 2912                                                 | 7239                                                                                                        | 
| Burkholderia multivorans ATCC 17616 PRJNA58697                            | 7240,7241,7242,7243                                                                                         | 
| Burkholderia pseudomallei 1710b                                           | 7244,7245                                                                                                   | 
| Methylobacterium sp. Leaf100                                              | 7255                                                                                                        | 
| Methylobacterium sp. Leaf102                                              | 7256                                                                                                        | 
| Methylobacterium sp. Leaf104                                              | 7257                                                                                                        | 
| Sphingomonas sp. Leaf11                                                   | 7258                                                                                                        | 
| Methylobacterium sp. Leaf119                                              | 7259                                                                                                        | 
| Methylobacterium sp. Leaf121                                              | 7260                                                                                                        | 
| Methylobacterium sp. Leaf122                                              | 7261                                                                                                        | 
| Methylobacterium sp. Leaf123                                              | 7262                                                                                                        | 
| Methylobacterium sp. Leaf125                                              | 7263                                                                                                        | 
| Methylobacterium sp. Leaf361                                              | 7264                                                                                                        | 
| Methylobacterium sp. Leaf399                                              | 7265                                                                                                        | 
| Devosia sp. Leaf420                                                       | 7266                                                                                                        | 
| Methylobacterium sp. Leaf456                                              | 7267                                                                                                        | 
| Methylobacterium sp. Leaf465                                              | 7268                                                                                                        | 
| Methylobacterium sp. Leaf466                                              | 7269                                                                                                        | 
| Methylobacterium sp. Leaf469                                              | 7270                                                                                                        | 
| Devosia sp. Leaf64                                                        | 7271                                                                                                        | 
| Methylobacterium sp. Leaf85                                               | 7272                                                                                                        | 
| Methylobacterium sp. Leaf86                                               | 7273                                                                                                        | 
| Methylobacterium sp. Leaf87                                               | 7274                                                                                                        | 
| Methylobacterium sp. Leaf88                                               | 7275                                                                                                        | 
| Methylobacterium sp. Leaf89                                               | 7276                                                                                                        | 
| Methylobacterium sp. Leaf90                                               | 7277                                                                                                        | 
| Methylobacterium sp. Leaf91                                               | 7278                                                                                                        | 
| Methylobacterium sp. Leaf93                                               | 7279                                                                                                        | 
| Methylobacterium sp. Leaf94                                               | 7280                                                                                                        | 
| Methylobacterium sp. Leaf99                                               | 7281                                                                                                        | 
| Aminobacter sp. Root100                                                   | 7282                                                                                                        | 
| Devosia sp. Root105                                                       | 7283                                                                                                        | 
| Bosea sp. Root381                                                         | 7284                                                                                                        | 
| Devosia sp. Root413D1                                                     | 7285                                                                                                        | 
| Devosia sp. Root436                                                       | 7286                                                                                                        | 
| Devosia sp. Root685                                                       | 7287                                                                                                        | 
| Bosea sp. Root483D1                                                       | 7288                                                                                                        | 
| Mycobacterium smegmatis MC2 155 PRJNA224116                               | 7289                                                                                                        | 
| Mycobacterium tuberculosis H37Rv PRJNA224116                              | 7290                                                                                                        | 
| Lactobacillus plantarum 16                                                | 7301,7291,7292,7293,7294,7295,7296,7297,7298,7299,7300                                                      | 
| Lactobacillus plantarum ZJ316                                             | 7302,7303,7304,7305                                                                                         | 
| Devosia sp. Root635                                                       | 7306                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum P-8                              | 7307,7308,7309,7310,7311,7312,7313                                                                          | 
| Lactococcus lactis subsp. cremoris A76                                    | 7318,7314,7315,7316,7317                                                                                    | 
| Lactococcus lactis subsp. cremoris KW2                                    | 7319                                                                                                        | 
| Lactococcus lactis subsp. cremoris NZ9000                                 | 7320                                                                                                        | 
| Lactococcus lactis subsp. cremoris UC509.9                                | 7321,7322,7323,7324,7325,7326,7327,7328,7329                                                                | 
| Lactococcus lactis subsp. lactis CV56                                     | 7334,7335,7330,7331,7332,7333                                                                               | 
| Lactococcus lactis subsp. lactis IO-1                                     | 7336                                                                                                        | 
| Lactococcus lactis subsp. lactis KLDS 4.0325                              | 7337,7338                                                                                                   | 
| Photorhabdus luminescens NBAII H75HRPL105                                 | 7339                                                                                                        | 
| Photorhabdus luminescens subsp. laumondii HP88                            | 7340                                                                                                        | 
| Photorhabdus luminescens BA1                                              | 7341                                                                                                        | 
| Photorhabdus asymbiotica subsp. australis DSM 17609                       | 7342                                                                                                        | 
| Photorhabdus luminescens NBAII HiPL101                                    | 7343                                                                                                        | 
| Photorhabdus luminescens subsp. luminescens DSM 3368                      | 7344                                                                                                        | 
| Photorhabdus luminescens NBAII Hb105                                      | 7345                                                                                                        | 
| Photorhabdus heterorhabditis VMG                                          | 7346                                                                                                        | 
| Xenorhabdus nematophila C2-3                                              | 7347                                                                                                        | 
| Xenorhabdus sp. NBAII XenSa04                                             | 7348                                                                                                        | 
| Xenorhabdus griffiniae BMMCB                                              | 7349                                                                                                        | 
| Xenorhabdus khoisanae MCB                                                 | 7350                                                                                                        | 
| Xenorhabdus sp. GDc328                                                    | 7351                                                                                                        | 
| Fibrobacter succinogenes subsp. succinogenes S85                          | 7352                                                                                                        | 
| Fibrobacter succinogenes subsp. succinogenes S85 PRJNA224116              | 7353                                                                                                        | 
| Lysinibacillus sphaericus C3-41                                           | 7354,7355                                                                                                   | 
| Lysinibacillus fusiformis ZB2                                             | 7356                                                                                                        | 
| Lysinibacillus sphaericus OT4b.31                                         | 7357                                                                                                        | 
| Desulfobacter postgatei 2ac9                                              | 7360                                                                                                        | 
| Lactococcus lactis subsp. lactis S0                                       | 7374                                                                                                        | 
| Lactococcus lactis AI06                                                   | 7375                                                                                                        | 
| Lactobacillus plantarum L31-1                                             | 7376                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum CGMCC 1.557                      | 7377                                                                                                        | 
| Lactobacillus plantarum B21                                               | 7378                                                                                                        | 
| Lactobacillus plantarum 5-2                                               | 7379                                                                                                        | 
| Propionibacterium freudenreichii subsp. shermanii CIRM-BIA1 CIRM-B1AI     | 7380                                                                                                        | 
| Desulfotomaculum acetoxidans DSM 771 PRJNA224116                          | 7381                                                                                                        | 
| Desulfotomaculum carboxydivorans CO-1-SRB                                 | 7382                                                                                                        | 
| Desulfotomaculum gibsoniae DSM 7213                                       | 7383                                                                                                        | 
| Desulfotomaculum kuznetsovii DSM 6115                                     | 7384                                                                                                        | 
| Desulfotomaculum ruminis DSM 2154                                         | 7385                                                                                                        | 
| Desulfotomaculum hydrothermale Lam5 = DSM 18033                           | 7386                                                                                                        | 
| Cobetia marina KMM 296                                                    | 7389                                                                                                        | 
| Lactococcus lactis subsp. lactis YF11                                     | 7390                                                                                                        | 
| Lactococcus lactis subsp. lactis bv. diacetylactis TIFN2                  | 7391                                                                                                        | 
| Lactobacillus plantarum WJL                                               | 7392                                                                                                        | 
| Lactobacillus plantarum EGD-AQ4                                           | 7393                                                                                                        | 
| Lactococcus lactis subsp. cremoris TIFN1                                  | 7394                                                                                                        | 
| Lactococcus lactis subsp. cremoris TIFN3                                  | 7395                                                                                                        | 
| Lactococcus lactis subsp. lactis bv. diacetylactis str. TIFN4             | 7396                                                                                                        | 
| Lactobacillus plantarum IPLA88                                            | 7397                                                                                                        | 
| Lactobacillus plantarum 2165                                              | 7398                                                                                                        | 
| Burkholderia gladioli ATCC 10248                                          | 7424,7425,7426,7427,7428                                                                                    | 
| Limnohabitans sp. Rim28                                                   | 7450                                                                                                        | 
| Limnohabitans sp. Rim47                                                   | 7451                                                                                                        | 
| Desulfurococcus fermentans DSM 16532                                      | 7457                                                                                                        | 
| Desulfosporosinus acidiphilus SJ4                                         | 7460,7461,7462                                                                                              | 
| Desulfosporosinus meridiei DSM 13257 PRJNA224116                          | 7463                                                                                                        | 
| Bacteriovorax marinus SJ                                                  | 7464,7465                                                                                                   | 
| Bdellovibrio exovorus JSS                                                 | 7466                                                                                                        | 
| Desulfarculus baarsii DSM 2075                                            | 7467                                                                                                        | 
| Desulfatibacillum alkenivorans AK-01                                      | 7468                                                                                                        | 
| Desulfobacula toluolica Tol2                                              | 7469                                                                                                        | 
| Desulfobulbus propionicus DSM 2032                                        | 7470                                                                                                        | 
| Desulfocapsa sulfexigens DSM 10523                                        | 7471,7472                                                                                                   | 
| Desulfococcus oleovorans Hxd3                                             | 7473                                                                                                        | 
| Desulfohalobium retbaense DSM 5692                                        | 7474,7475                                                                                                   | 
| Desulfomicrobium baculatum DSM 4028                                       | 7476                                                                                                        | 
| Candidatus Endolissoclinum faulkneri L2                                   | 7514                                                                                                        | 
| Haliangium ochraceum DSM 14365                                            | 7515                                                                                                        | 
| Pelobacter carbinolicus DSM 2380                                          | 7516                                                                                                        | 
| Rhodospirillum photometricum DSM 122                                      | 7517                                                                                                        | 
| Sorangium cellulosum So ce56 So ce 56                                     | 7518                                                                                                        | 
| Pseudomonas fluorescens PA4C2                                             | 7519                                                                                                        | 
| Lactococcus lactis subsp. lactis NCDO 2118                                | 7521,7520                                                                                                   | 
| Lactococcus lactis subsp. cremoris GE214                                  | 7522                                                                                                        | 
| Lactobacillus plantarum AG30                                              | 7523                                                                                                        | 
| Lactococcus lactis subsp. lactis 511                                      | 7524                                                                                                        | 
| Lactobacillus plantarum 90sk                                              | 7526                                                                                                        | 
| Tistrella mobilis KA081020-065                                            | 7533,7534,7535,7536,7537                                                                                    | 
| Desulfotignum balticum DSM 7044                                           | 7538                                                                                                        | 
| Niveispirillum irakense DSM 11586                                         | 7539                                                                                                        | 
| Desulforegula conservatrix Mb1Pa                                          | 7540                                                                                                        | 
| Thalassobaculum salexigens DSM 19539                                      | 7541                                                                                                        | 
| Skermanella stibiiresistens SB22                                          | 7542                                                                                                        | 
| Desulfatitalea tepidiphila S28bF                                          | 7543                                                                                                        | 
| Desulfovibrio cf. magneticus IFRC170                                      | 7544                                                                                                        | 
| Fodinicurvata fenggangensis DSM 21160                                     | 7545                                                                                                        | 
| Desulfurella acetivorans A63                                              | 7546,7547                                                                                                   | 
| Geoalkalibacter subterraneus Red1                                         | 7549,7548                                                                                                   | 
| Thalassospira xiamenensis  = DSM 17429 M-5                                | 7550,7551                                                                                                   | 
| Caenispirillum salinarum AK4                                              | 7552                                                                                                        | 
| Desulfospira joergensenii DSM 10085                                       | 7553                                                                                                        | 
| Desulfotignum phosphitoxidans DSM 13687                                   | 7554                                                                                                        | 
| Fodinicurvata sediminis DSM 21159                                         | 7555                                                                                                        | 
| Novispirillum itersonii subsp. itersonii ATCC 12639                       | 7556                                                                                                        | 
| Oceanibaculum indicum P24                                                 | 7557                                                                                                        | 
| Phaeospirillum molischianum DSM 120                                       | 7558                                                                                                        | 
| Thalassospira lucentensis QMT2 = DSM 14000                                | 7559                                                                                                        | 
| Phaeospirillum fulvum MGU-K5                                              | 7560                                                                                                        | 
| Clostridium ultunense DSM 10521                                           | 7600                                                                                                        | 
| Candidatus Desulforudis audaxviator MP104C                                | 7612                                                                                                        | 
| Syntrophobotulus glycolicus DSM 8271                                      | 7613                                                                                                        | 
| Dehalobacter sp. E1                                                       | 7614                                                                                                        | 
| Dehalobacter sp. FTH1                                                     | 7615                                                                                                        | 
| Dehalobacter sp. UNSWDHB                                                  | 7616                                                                                                        | 
| Desulfitobacterium hafniense DP7                                          | 7617                                                                                                        | 
| Desulfitobacterium hafniense PCP-1                                        | 7618                                                                                                        | 
| Desulfitobacterium hafniense TCP-A                                        | 7619                                                                                                        | 
| Desulfitobacterium sp. PCE1                                               | 7620                                                                                                        | 
| Magnetospirillum sp. XM-1 NULL                                            | 7621,7622                                                                                                   | 
| Arthrobacter crystallopoietes BAB-32                                      | 7623                                                                                                        | 
| Arthrobacter gangotriensis Lz1y                                           | 7624                                                                                                        | 
| Arthrobacter globiformis NBRC 12137                                       | 7625                                                                                                        | 
| Arthrobacter sp. AK-YN10                                                  | 7626                                                                                                        | 
| Lysinibacillus sphaericus KCTC 3346                                       | 7630                                                                                                        | 
| Lysinibacillus sphaericus CBAM5                                           | 7631                                                                                                        | 
| Lysinibacillus fusiformis H1k                                             | 7632                                                                                                        | 
| Lysinibacillus sphaericus 1987                                            | 7633                                                                                                        | 
| Lysinibacillus sphaericus 2297                                            | 7634                                                                                                        | 
| Lysinibacillus sphaericus SSII-1                                          | 7635                                                                                                        | 
| Lysinibacillus sphaericus LP1-G                                           | 7636                                                                                                        | 
| Lysinibacillus sphaericus NRS1693                                         | 7637                                                                                                        | 
| Lysinibacillus sp. BF-4                                                   | 7638                                                                                                        | 
| Lysinibacillus manganicus DSM 26584                                       | 7639                                                                                                        | 
| Lysinibacillus sinduriensis BLB-1 JCM 15800                               | 7640                                                                                                        | 
| Lysinibacillus odysseyi NBRC 100172                                       | 7641                                                                                                        | 
| Lysinibacillus massiliensis CCUG 49529                                    | 7642                                                                                                        | 
| Lysinibacillus boronitolerans JCM 21713 NBRC 103108                       | 7643                                                                                                        | 
| Lysinibacillus fusiformis SW-B9                                           | 7644                                                                                                        | 
| Lysinibacillus sp. A1                                                     | 7645                                                                                                        | 
| Lysinibacillus sp. LK3                                                    | 7646                                                                                                        | 
| Lysinibacillus xylanilyticus DSM 23493                                    | 7647                                                                                                        | 
| Lysinibacillus varians GY32                                               | 7648                                                                                                        | 
| Lysinibacillus fusiformis RB-21                                           | 7649,7650                                                                                                   | 
| Ralstonia solanacearum UY031                                              | 7677,7678                                                                                                   | 
| Burkholderia sp. RPE67                                                    | 7823,7824,7825,7826,7827,7828                                                                               | 
| Hoeflea phototrophica DFL-43                                              | 7831                                                                                                        | 
| Hoeflea sp. 108                                                           | 7832                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 50594                             | 7833,7834,7835                                                                                              | 
| Mycobacterium abscessus subsp. bolletii GO 06                             | 7837                                                                                                        | 
| Mycobacterium kansasii ATCC 12478                                         | 7838,7839                                                                                                   | 
| Mycobacterium liflandii 128FXT                                            | 7841,7842                                                                                                   | 
| Mycobacterium smegmatis JS623                                             | 7843,7844,7845,7846                                                                                         | 
| Pseudomonas aeruginosa Cu1510                                             | 7848                                                                                                        | 
| Mycobacterium yongonense 05-1390                                          | 7849,7851,7852                                                                                              | 
| Mycobacterium abscessus 3A-0119-R                                         | 7853                                                                                                        | 
| Mycobacterium abscessus 3A-0122-R                                         | 7855                                                                                                        | 
| Mycobacterium abscessus 3A-0731                                           | 7857                                                                                                        | 
| Mycobacterium abscessus 3A-0810-R                                         | 7859                                                                                                        | 
| Mycobacterium abscessus 3A-0930-S                                         | 7861                                                                                                        | 
| Mycobacterium abscessus 47J26                                             | 7864                                                                                                        | 
| Mycobacterium abscessus 4S-0116-R                                         | 7866                                                                                                        | 
| Mycobacterium abscessus 4S-0206                                           | 7868                                                                                                        | 
| Mycobacterium abscessus 4S-0303                                           | 7870                                                                                                        | 
| Mycobacterium abscessus 4S-0726-RA                                        | 7872                                                                                                        | 
| Mycobacterium abscessus 5S-0304                                           | 7874                                                                                                        | 
| Mycobacterium abscessus 5S-0421                                           | 7875                                                                                                        | 
| Mycobacterium abscessus 5S-0422                                           | 7877                                                                                                        | 
| Mycobacterium abscessus 5S-0708                                           | 7879                                                                                                        | 
| Mycobacterium abscessus 5S-0817                                           | 7881                                                                                                        | 
| Mycobacterium abscessus 5S-0921                                           | 7883                                                                                                        | 
| Mycobacterium abscessus 5S-1212                                           | 7884                                                                                                        | 
| Mycobacterium abscessus 5S-1215                                           | 7886                                                                                                        | 
| Mycobacterium abscessus 6G-0125-R                                         | 7888                                                                                                        | 
| Mycobacterium abscessus 6G-0212                                           | 7890                                                                                                        | 
| Mycobacterium abscessus 6G-0728-R                                         | 7891                                                                                                        | 
| Mycobacterium abscessus 6G-1108                                           | 7893                                                                                                        | 
| Mycobacterium abscessus 9808                                              | 7895                                                                                                        | 
| Mycobacterium abscessus M115                                              | 7897                                                                                                        | 
| Mycobacterium abscessus M139                                              | 7898                                                                                                        | 
| Mycobacterium abscessus M148                                              | 7899                                                                                                        | 
| Mycobacterium abscessus M152                                              | 7900                                                                                                        | 
| Mycobacterium abscessus M154                                              | 7901                                                                                                        | 
| Mycobacterium abscessus M156                                              | 7902                                                                                                        | 
| Mycobacterium abscessus M159                                              | 7903                                                                                                        | 
| Mycobacterium abscessus M172                                              | 7904                                                                                                        | 
| Mycobacterium abscessus M93                                               | 7905                                                                                                        | 
| Mycobacterium abscessus M94                                               | 7906                                                                                                        | 
| Mycobacterium abscessus MAB_082312_2258                                   | 7907                                                                                                        | 
| Mycobacterium abscessus MAB_091912_2446                                   | 7908                                                                                                        | 
| Mycobacterium abscessus V06705                                            | 7909                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 1S-151-0930                       | 7910                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 1S-152-0914                       | 7911                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 1S-153-0915                       | 7913                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 1S-154-0310                       | 7914                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 2B-0107                           | 7916                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 2B-0307                           | 7917                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 2B-0626                           | 7919                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 2B-0912-R                         | 7920                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii 2B-1231                           | 7922                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii BD                                | 7923                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii CRM-0020                          | 7925                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii M18                               | 7926                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii CCUG 48898 = JCM 15300 CCUG 48898 | 7928                                                                                                        | 
| Mycobacterium fortuitum subsp. fortuitum DSM 46621                        | 7929                                                                                                        | 
| Mycobacterium avium 05-4293                                               | 7931                                                                                                        | 
| Mycobacterium avium 09-5983                                               | 7933                                                                                                        | 
| Mycobacterium avium 10-5581                                               | 7934                                                                                                        | 
| Mycobacterium avium subsp. avium 10-9275                                  | 7936                                                                                                        | 
| Mycobacterium avium subsp. avium 11-4751                                  | 7938                                                                                                        | 
| Mycobacterium avium subsp. avium ATCC 25291                               | 7939                                                                                                        | 
| Mycobacterium avium subsp. avium Env 77                                   | 7941                                                                                                        | 
| Mycobacterium avium subsp. hominissuis 10-4249                            | 7942                                                                                                        | 
| Mycobacterium avium subsp. hominissuis 10-5606                            | 7944                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis 08-8281                       | 7946                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis 10-4404                       | 7947                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis 10-5864                       | 7949                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis 10-5975                       | 7951                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis 11-1786                       | 7952                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis 4B                            | 7954                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis CLIJ623                       | 7955                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis CLIJ644                       | 7957                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis DT 3                          | 7958                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis Env 210                       | 7960                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis JQ5                           | 7961                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis Pt139                         | 7963                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis Pt144                         | 7965                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis Pt145                         | 7966                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis Pt146                         | 7968                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis Pt155                         | 7969                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis Pt164                         | 7971                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis S397                          | 7972                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis S5                            | 7974                                                                                                        | 
| Mycobacterium avium subsp. silvaticum ATCC 49884                          | 7975                                                                                                        | 
| Vibrio alginolyticus NBRC 15630 = ATCC 17749                              | 7977,7978                                                                                                   | 
| Vibrio sp. EJY3                                                           | 7979,7980                                                                                                   | 
| Vibrio halioticoli NBRC 102217                                            | 7982                                                                                                        | 
| Vibrio harveyi 1DA3                                                       | 7983                                                                                                        | 
| Vibrio harveyi AOD131                                                     | 7985                                                                                                        | 
| Vibrio harveyi CAIM 1792                                                  | 7987                                                                                                        | 
| Vibrio harveyi ZJ0603                                                     | 7988                                                                                                        | 
| Sinorhizobium meliloti AK83                                               | 7991,7992,7993,7994,7990                                                                                    | 
| Sinorhizobium meliloti BL225C                                             | 7996,7997,7998                                                                                              | 
| Sinorhizobium meliloti GR4                                                | 7999,8000,8001,8002,8003                                                                                    | 
| Sinorhizobium meliloti SM11                                               | 8005,8006,8007                                                                                              | 
| Sinorhizobium meliloti Rm41                                               | 8009,8010,8012,8008                                                                                         | 
| Sinorhizobium meliloti 2011                                               | 8013,8014,8015                                                                                              | 
| Mycobacterium indicus pranii MTCC 9506 NULL                               | 8017                                                                                                        | 
| Mycobacterium colombiense CECT 3035                                       | 8020                                                                                                        | 
| Cellulophaga lytica DSM 7489                                              | 8033                                                                                                        | 
| Mycobacterium avium subsp. hominissuis TH135                              | 8034,8035                                                                                                   | 
| Mycobacterium haemophilum DSM 44634 ATCC 29548                            | 8036                                                                                                        | 
| Mycobacterium immunogenum SMUC14                                          | 8037                                                                                                        | 
| Mycobacterium immunogenum H088                                            | 8038                                                                                                        | 
| Mycobacterium immunogenum H106                                            | 8039                                                                                                        | 
| Mycobacterium immunogenum HXV                                             | 8040                                                                                                        | 
| Fructobacillus fructosus KCTC 3544                                        | 8050                                                                                                        | 
| Shewanella decolorationis S12                                             | 8073                                                                                                        | 
| Magnetospirillum magnetotacticum MS-1                                     | 8076                                                                                                        | 
| Curtobacterium sp. MR_MD2014                                              | 8082                                                                                                        | 
| Streptomyces sp. CCM_MD2014                                               | 8083                                                                                                        | 
| Acetobacter pasteurianus IFO 3283-01                                      | 8087,8088,8089,8090,8091,8092,8093                                                                          | 
| Brucella ceti TE10759-12                                                  | 8094,8095                                                                                                   | 
| Methylobacterium populi BJ001 PRJNA19559                                  | 8097,8098,8096                                                                                              | 
| Parvibaculum lavamentivorans DS-1                                         | 8099                                                                                                        | 
| Rickettsia rickettsii Hlp#2                                               | 8100                                                                                                        | 
| Sphingomonas wittichii RW1                                                | 8101,8102,8103                                                                                              | 
| Terasakiella pusilla DSM 6293                                             | 8130                                                                                                        | 
| Martelella endophytica YC6887                                             | 8131                                                                                                        | 
| Pseudovibrio sp. FO-BEG1                                                  | 8163,8164                                                                                                   | 
| Staphylococcus warneri SG1                                                | 8165,8166,8167,8168,8169,8170,8171,8172,8173                                                                | 
| Staphylococcus pasteuri SP1                                               | 8174                                                                                                        | 
| Streptomyces lividans TK24                                                | 8175                                                                                                        | 
| Streptomyces coelicoflavus ZG0656                                         | 8176                                                                                                        | 
| Lactococcus garvieae Lg2                                                  | 8178                                                                                                        | 
| Lactococcus garvieae TB25                                                 | 8179                                                                                                        | 
| Lactococcus garvieae IPLA 31405                                           | 8180                                                                                                        | 
| Lactococcus garvieae Tac2                                                 | 8181                                                                                                        | 
| Lactococcus garvieae I113                                                 | 8182                                                                                                        | 
| Lactobacillus plantarum UCMA 3037                                         | 8183                                                                                                        | 
| Lactobacillus plantarum AY01                                              | 8184                                                                                                        | 
| Lactobacillus plantarum 2025                                              | 8185                                                                                                        | 
| Lactobacillus plantarum 4_3                                               | 8186                                                                                                        | 
| Lactobacillus brevis KB290                                                | 8187,8188,8189,8190,8191,8192,8193,8194,8195,8196                                                           | 
| Escherichia coli J53                                                      | 8197                                                                                                        | 
| Elizabethkingia anophelis CSID_3015183678                                 | 8228                                                                                                        | 
| Steroidobacter denitrificans DSM 18526                                    | 8261                                                                                                        | 
| Citrobacter amalonaticus FDAARGOS_165                                     | 8277,8278                                                                                                   | 
| Citrobacter amalonaticus FDAARGOS_122                                     | 8279                                                                                                        | 
| Citrobacter amalonaticus GTA-817-RBA-P2                                   | 8280                                                                                                        | 
| Citrobacter amalonaticus YG6                                              | 8281                                                                                                        | 
| Citrobacter amalonaticus 3e8B                                             | 8282                                                                                                        | 
| Citrobacter amalonaticus FDAARGOS_166                                     | 8283                                                                                                        | 
| Clostridium acetobutylicum DSM 1731                                       | 8284,8285,8286                                                                                              | 
| Clostridium acetobutylicum EA 2018                                        | 8287,8288                                                                                                   | 
| Clostridium kluyveri NBRC 12016                                           | 8289,8290                                                                                                   | 
| Clostridium pasteurianum BC1                                              | 8291,8292                                                                                                   | 
| Escherichia coli O25b:H4-ST131 EC958                                      | 8335,8336,8337                                                                                              | 
| Achromobacter piechaudii ATCC 43553                                       | 8339                                                                                                        | 
| Achromobacter xylosoxidans AXX-A                                          | 8340                                                                                                        | 
| Leptospirillum ferriphilum DSM 14647-PRJNA248540                          | 8343                                                                                                        | 
| Klebsiella pneumoniae 30684/NJST258_2                                     | 8360,8361,8362,8363                                                                                         | 
| Klebsiella pneumoniae 30660/NJST258_1                                     | 8364,8365,8366,8367,8368,8369                                                                               | 
| Microcystis aeruginosa NIES-88                                            | 8372                                                                                                        | 
| Treponema azotonutricium ZAS-9                                            | 8407                                                                                                        | 
| Acidobacteriaceae bacterium TAA166 TAA 166                                | 8408                                                                                                        | 
| Serratia marcescens EGD-HP20                                              | 8409                                                                                                        | 
| Synechococcus sp. PCC 73109                                               | 8426,8427,8428,8429,8430,8431                                                                               | 
| Synechocystis sp. PCC 6714                                                | 8434,8435,8432,8433                                                                                         | 
| Tolypothrix sp. PCC 7601  UTEX B 481                                      | 8436                                                                                                        | 
| Micromonospora sp. HK10                                                   | 8437                                                                                                        | 
| Streptomyces aurantiacus JA 4570                                          | 8438                                                                                                        | 
| Streptomyces auratus AGR0001                                              | 8439                                                                                                        | 
| Streptomyces griseus XylebKG-1                                            | 8440                                                                                                        | 
| Streptomyces pristinaespiralis ATCC 25486                                 | 8441                                                                                                        | 
| Streptomyces roseochromogenes subsp. oscitans DS 12.976                   | 8442                                                                                                        | 
| Streptomyces viridochromogenes DSM 40736                                  | 8443                                                                                                        | 
| Streptomyces viridochromogenes Tue57                                      | 8444                                                                                                        | 
| Nocardioides sp. CF8                                                      | 8445                                                                                                        | 
| Nocardioides sp. Iso805N                                                  | 8446                                                                                                        | 
| Streptomyces afghaniensis 772                                             | 8447                                                                                                        | 
| Streptomyces bottropensis ATCC 25435                                      | 8448                                                                                                        | 
| Streptomyces chartreusis NRRL 12338                                       | 8449                                                                                                        | 
| Streptomyces ghanaensis ATCC 14672                                        | 8450                                                                                                        | 
| Streptomyces ipomoeae 91-03                                               | 8451                                                                                                        | 
| Streptomyces mobaraensis NBRC 13819 = DSM 40847                           | 8452                                                                                                        | 
| Streptomyces rimosus subsp. rimosus ATCC 10970                            | 8453                                                                                                        | 
| Streptomyces scabrisporus DSM 41855                                       | 8454                                                                                                        | 
| Streptomyces sp. CNQ766                                                   | 8455                                                                                                        | 
| Streptomyces tsukubaensis NRRL18488                                       | 8456                                                                                                        | 
| Streptomyces acidiscabies 84-104                                          | 8457                                                                                                        | 
| Streptomyces albus J1074                                                  | 8458                                                                                                        | 
| Streptomyces canus 299MFChir4.1                                           | 8459                                                                                                        | 
| Streptomyces gancidicus BKS 13-15                                         | 8460                                                                                                        | 
| Streptomyces sp. 303MFCol5.2                                              | 8461                                                                                                        | 
| Streptomyces sp. 351MFTsu5.1                                              | 8462                                                                                                        | 
| Streptomyces sp. AA0539                                                   | 8463                                                                                                        | 
| Streptomyces sp. AA1529                                                   | 8464                                                                                                        | 
| Streptomyces sp. Amel2xE9                                                 | 8465                                                                                                        | 
| Streptomyces sp. ATexAB-D23                                               | 8466                                                                                                        | 
| Streptomyces sp. BoleA5                                                   | 8467                                                                                                        | 
| Streptomyces sp. C                                                        | 8468                                                                                                        | 
| Streptomyces sp. CcalMP-8W                                                | 8469                                                                                                        | 
| Streptomyces sp. CNB091                                                   | 8470                                                                                                        | 
| Streptomyces sp. CNS335                                                   | 8471                                                                                                        | 
| Streptomyces sp. CNS615                                                   | 8472                                                                                                        | 
| Streptomyces sp. CNT302                                                   | 8473                                                                                                        | 
| Streptomyces sp. CNT372                                                   | 8474                                                                                                        | 
| Streptomyces sp. CNY228                                                   | 8475                                                                                                        | 
| Streptomyces sp. CNY243                                                   | 8476                                                                                                        | 
| Streptomyces sp. DvalAA-83                                                | 8477                                                                                                        | 
| Streptomyces sp. e14                                                      | 8478                                                                                                        | 
| Streptomyces sp. FxanaC1                                                  | 8479                                                                                                        | 
| Streptomyces sp. FxanaD5                                                  | 8480                                                                                                        | 
| Streptomyces clavuligerus ATCC 27064 PRJNA28551                           | 8481                                                                                                        | 
| Streptomyces clavuligerus ATCC 27064 PRJNA42475                           | 8482                                                                                                        | 
| Streptomyces griseoaurantiacus M045                                       | 8484                                                                                                        | 
| Streptomyces griseoflavus Tu4000                                          | 8485                                                                                                        | 
| Streptomyces himastatinicus ATCC 53653                                    | 8486                                                                                                        | 
| Streptomyces lividans 1326                                                | 8487                                                                                                        | 
| Streptomyces niveus NCIMB 11891                                           | 8488                                                                                                        | 
| Streptomyces prunicolor NBRC 13075                                        | 8489                                                                                                        | 
| Streptomyces purpureus KA281                                              | 8490                                                                                                        | 
| Streptomyces roseosporus NRRL 11379                                       | 8491                                                                                                        | 
| Streptomyces roseosporus NRRL 15998                                       | 8492                                                                                                        | 
| Burkholderia gladioli NBRC 13700                                          | 8493                                                                                                        | 
| Methylophilales bacterium HTCC2181                                        | 8496                                                                                                        | 
| beta proteobacterium KB13                                                 | 8497                                                                                                        | 
| Pseudomonas aeruginosa N002 N002                                          | 8514                                                                                                        | 
| Streptomyces avermitilis MA-4680 = NBRC 14893                             | 8527,8528                                                                                                   | 
| Streptomyces cattleya NRRL 8057 = DSM 46488 NRRL 8057                     | 8529,8530                                                                                                   | 
| Streptomyces collinus Tu 365                                              | 8531,8532,8533                                                                                              | 
| Streptomyces davawensis JCM 4913                                          | 8535,8534                                                                                                   | 
| Streptomyces fulvissimus DSM 40593                                        | 8536                                                                                                        | 
| Streptomyces hygroscopicus subsp. jinggangensis TL01 NULL                 | 8537,8538,8539                                                                                              | 
| Streptomyces rapamycinicus NRRL 5491                                      | 8540                                                                                                        | 
| Streptomyces venezuelae ATCC 10712                                        | 8541                                                                                                        | 
| Nocardiopsis alba ATCC BAA-2165                                           | 8544                                                                                                        | 
| Streptomyces albus J1074                                                  | 8545                                                                                                        | 
| Streptomyces sp. GBA 94-10                                                | 8546                                                                                                        | 
| Streptomyces sp. HCCB10043                                                | 8547                                                                                                        | 
| Streptomyces sp. HGB0020                                                  | 8548                                                                                                        | 
| Streptomyces sp. HmicA12                                                  | 8549                                                                                                        | 
| Streptomyces sp. HPH0547                                                  | 8550                                                                                                        | 
| Streptomyces sp. KhCrAH-244                                               | 8552                                                                                                        | 
| Streptomyces sp. KhCrAH-340                                               | 8553                                                                                                        | 
| Streptomyces sp. LaPpAH-108                                               | 8554                                                                                                        | 
| Streptomyces bottropensis ATCC 25435 PRJNA104983                          | 8555                                                                                                        | 
| Polaribacter sp. MED152                                                   | 8556                                                                                                        | 
| Rhizobium etli CIAT 652                                                   | 8557,8558,8559,8560                                                                                         | 
| Rhizobium etli bv. mimosae Mim1                                           | 8562,8563,8564,8565,8566,8567,8561                                                                          | 
| Rickettsia rickettsii Arizona                                             | 8568                                                                                                        | 
| Streptomyces cattleya NRRL 8057 = DSM 46488                               | 8569,8570                                                                                                   | 
| Streptomyces pratensis ATCC 33331                                         | 8571,8572,8573                                                                                              | 
| Streptomyces sp. PAMC26508                                                | 8574,8575                                                                                                   | 
| [Eubacterium] siraeum 70/3                                                | 8576                                                                                                        | 
| Streptococcus pneumoniae TCH8431/19A                                      | 8577                                                                                                        | 
| Streptococcus pneumoniae SPN034156 SNP034156                              | 8578                                                                                                        | 
| Streptococcus pneumoniae SPN034183 SNP034183                              | 8579                                                                                                        | 
| Streptococcus pneumoniae SPN994038 SNP994038                              | 8580                                                                                                        | 
| Streptococcus pneumoniae SPN994039 SNP994039                              | 8582                                                                                                        | 
| Streptococcus pneumoniae SPNA45 A45                                       | 8583                                                                                                        | 
| Streptococcus pseudopneumoniae IS7493                                     | 8584,8585                                                                                                   | 
| Streptococcus pyogenes HSC5                                               | 8587                                                                                                        | 
| Streptococcus pyogenes MGAS10270                                          | 8588                                                                                                        | 
| Lysinibacillus parviboronicapiens JCM 18861                               | 8662                                                                                                        | 
| Agrobacterium arsenijevicii KFB 330                                       | 8676                                                                                                        | 
| Agrobacterium vitis NCPPB 3554                                            | 8677                                                                                                        | 
| Agrobacterium sp. R89-1                                                   | 8678                                                                                                        | 
| Bifidobacterium longum subsp. longum JCM 1217                             | 8681                                                                                                        | 
| Leptolinea tardivitalis YMTK-2                                            | 8684                                                                                                        | 
| bacterium endosymbiont of Mortierella elongata FMR23-6 NULL               | 8699                                                                                                        | 
| Actinoplanes friuliensis DSM 7358                                         | 8701                                                                                                        | 
| Actinoplanes missouriensis 431                                            | 8702                                                                                                        | 
| Actinoplanes sp. N902-109                                                 | 8703                                                                                                        | 
| Actinoplanes sp. SE50/110                                                 | 8704                                                                                                        | 
| Amycolatopsis mediterranei RB                                             | 8705                                                                                                        | 
| Amycolatopsis mediterranei S699                                           | 8706                                                                                                        | 
| Amycolatopsis orientalis HCCB10007                                        | 8707,8708                                                                                                   | 
| Amycolatopsis mediterranei S699 PRJNA224116                               | 8709                                                                                                        | 
| Magnetospirillum moscoviense BB-1                                         | 8710                                                                                                        | 
| Magnetospirillum marisnigri SP-1                                          | 8711                                                                                                        | 
| Epulopiscium sp. N.t. morphotype B                                        | 8715                                                                                                        | 
| Klebsiella sp. D5A                                                        | 8719                                                                                                        | 
| Echinicola pacifica DSM 19836                                             | 8726                                                                                                        | 
| Flavobacteriaceae bacterium S85                                           | 8727                                                                                                        | 
| Dietzia cinnamea P4                                                       | 8728                                                                                                        | 
| Flexithrix dorotheae DSM 6795                                             | 8729                                                                                                        | 
| Gayadomonas joobiniege G7                                                 | 8730                                                                                                        | 
| Gilvimarinus chinensis DSM 19667                                          | 8731                                                                                                        | 
| Lewinella persica DSM 23188                                               | 8732                                                                                                        | 
| Rhodopirellula sp. SWK7                                                   | 8733                                                                                                        | 
| Cellulophaga geojensis KL-A                                               | 8735                                                                                                        | 
| Aquimarina latercula DSM 2041                                             | 8736                                                                                                        | 
| Saccharicrinis fermentans  DSM 9555                                       | 8737                                                                                                        | 
| Algibacter lectus JCM 19300                                               | 8738                                                                                                        | 
| Cellulophaga sp. E6                                                       | 8739                                                                                                        | 
| Pseudoalteromonas sp. PLSV                                                | 8740                                                                                                        | 
| Flammeovirga pacifica WPAGA1                                              | 8741                                                                                                        | 
| Flammeovirga sp. OC4                                                      | 8742                                                                                                        | 
| Gammaproteobacteria bacterium Q1                                          | 8743                                                                                                        | 
| Maribacter thermophilus HT7-2                                             | 8744                                                                                                        | 
| Flammeovirga sp. SJP92                                                    | 8745                                                                                                        | 
| Aquimarina sp. RZW4-3-2                                                   | 8746                                                                                                        | 
| Paraglaciecola sp.  S66                                                   | 8747                                                                                                        | 
| Cellulophaga baltica 18                                                   | 8748                                                                                                        | 
| Persicobacter sp. JZB09                                                   | 8757,8758,8759,8760,8761,8762,8763,8764,8749,8765,8750,8751,8752,8753,8754,8755,8756                        | 
| Lactococcus lactis subsp. lactis Dephy 1                                  | 8766                                                                                                        | 
| Alteromonas sp. ALT199                                                    | 8768                                                                                                        | 
| Catenovulum agarivorans DS-2                                              | 8769                                                                                                        | 
| Cellulophaga baltica 13                                                   | 8770                                                                                                        | 
| Cupriavidus basilensis OR16                                               | 8775                                                                                                        | 
| Cupriavidus sp. HMR-1                                                     | 8776                                                                                                        | 
| Cupriavidus sp. HPC(L)                                                    | 8777                                                                                                        | 
| Cupriavidus sp. UYPR2.512                                                 | 8778                                                                                                        | 
| Cupriavidus sp. WS                                                        | 8779                                                                                                        | 
| Cupriavidus sp. amp6                                                      | 8780                                                                                                        | 
| Bacillus siamensis KCTC 13613                                             | 8791                                                                                                        | 
| Bacillus pumilus ATCC 7061                                                | 8792                                                                                                        | 
| Bacillus sonorensis L12                                                   | 8793                                                                                                        | 
| [Clostridium] cf. saccharolyticum K10                                     | 8802                                                                                                        | 
| Clostridium perfringens SM101                                             | 8796,8804,8806,8807                                                                                         | 
| Clostridium saccharobutylicum DSM 13864                                   | 8803                                                                                                        | 
| Clostridium botulinum B1 Okra                                             | 8798,8809                                                                                                   | 
| Clostridium autoethanogenum DSM 10061                                     | 8800                                                                                                        | 
| Clostridium saccharoperbutylacetonicum N1-4(HMT)                          | 8797,8808                                                                                                   | 
| Clostridium botulinum A ATCC 19397                                        | 8801                                                                                                        | 
| Peptoclostridium difficile BI1                                            | 8810,8799,8805                                                                                              | 
| Arthrospira platensis YZ                                                  | 8914                                                                                                        | 
| Paraburkholderia mimosarum LMG 23256                                      | 8918                                                                                                        | 
| Sulfuricella denitrificans skB26                                          | 8962,8955                                                                                                   | 
| Halothiobacillus neapolitanus c2                                          | 8956                                                                                                        | 
| Thioalkalimicrobium cyclicum ALM1                                         | 8957                                                                                                        | 
| Thiocystis violascens DSM 198                                             | 8961                                                                                                        | 
| Thioalkalivibrio sp. K90mix                                               | 8958,8966                                                                                                   | 
| Thioalkalivibrio nitratireducens DSM 14787                                | 8960                                                                                                        | 
| Thiobacillus denitrificans ATCC 25259                                     | 8959                                                                                                        | 
| Thiomonas arsenitoxydans 3As                                              | 8963,8965                                                                                                   | 
| Thioflavicoccus mobilis 8321                                              | 8964,8967                                                                                                   | 
| Chlorobaculum parvum NCIB 8327                                            | 8970                                                                                                        | 
| Chlorobium chlorochromatii CaD3                                           | 8969                                                                                                        | 
| Advenella kashmirensis WT001                                              | 8976,8968                                                                                                   | 
| Chlorobium phaeobacteroides DSM 266                                       | 8971                                                                                                        | 
| Chlorobium phaeovibrioides DSM 265 NULL                                   | 8973                                                                                                        | 
| Chlorobium luteolum DSM 273                                               | 8974                                                                                                        | 
| Halorhodospira halophila SL1                                              | 8972                                                                                                        | 
| Sideroxydans lithotrophicus ES-1                                          | 8978                                                                                                        | 
| Prosthecochloris aestuarii DSM 271                                        | 8975,8979                                                                                                   | 
| Rhodomicrobium vannielii ATCC 17100                                       | 8977                                                                                                        | 
| Lactobacillus curvatus FBA2                                               | 8982                                                                                                        | 
| Lactobacillus sakei FBL1                                                  | 8983                                                                                                        | 
| Lactobacillus reuteri DSM 20016                                           | 8986                                                                                                        | 
| Lactobacillus reuteri SD2112                                              | 8984,8989,8991,8994,8999                                                                                    | 
| Lactobacillus reuteri TD1                                                 | 8988                                                                                                        | 
| Lactobacillus reuteri JCM 1112                                            | 8987                                                                                                        | 
| Lactobacillus reuteri I5007                                               | 8985,8990,8992,8995,9000,9001,9002                                                                          | 
| Lactobacillus iners DSM 13335                                             | 8993                                                                                                        | 
| Lactobacillus gasseri 224-1                                               | 8996                                                                                                        | 
| Lactobacillus jensenii 115-3-CHN                                          | 8997                                                                                                        | 
| Lactobacillus reuteri ATCC 53608                                          | 8998                                                                                                        | 
| Lactobacillus crispatus 2029                                              | 9003                                                                                                        | 
| Lactobacillus sanfranciscensis DSM 20451                                  | 9004                                                                                                        | 
| Lactobacillus fructivorans ATCC 27394                                     | 9005                                                                                                        | 
| Mycobacterium vaccae ATCC 25954                                           | 9033                                                                                                        | 
| Mycobacterium vaccae  NBRC 14118                                          | 9035                                                                                                        | 
| Mycobacterium austroafricanum DSM 44191                                   | 9036                                                                                                        | 
| Mycobacterium aurum NCTC 10437                                            | 9037                                                                                                        | 
| Mycobacterium chubuense DSM 44219                                         | 9038                                                                                                        | 
| Mycobacterium vaccae 95051                                                | 9040                                                                                                        | 
| Peptococcaceae bacterium RM NULL                                          | 9041                                                                                                        | 
| Aminobacter aminovorans KCTC 2477                                         | 9042,9043,9044,9045,9046                                                                                    | 
| Bacillus subtilis subsp. spizizenii TU-B-10                               | 9052                                                                                                        | 
| Lactococcus garvieae UNIUD074                                             | 9064                                                                                                        | 
| Lactococcus garvieae DCC43                                                | 9065                                                                                                        | 
| Lactococcus garvieae 8831                                                 | 9066                                                                                                        | 
| Lactococcus garvieae 21881                                                | 9067                                                                                                        | 
| Lactococcus garvieae TRF1                                                 | 9068                                                                                                        | 
| Nitrolancea hollandica Lb                                                 | 9080                                                                                                        | 
| Geobacter bemidjiensis Bem                                                | 9111                                                                                                        | 
| Geobacter daltonii FRC-32                                                 | 9112                                                                                                        | 
| Geobacter lovleyi SZ                                                      | 9113,9114                                                                                                   | 
| Geobacter metallireducens GS-15                                           | 9115,9116                                                                                                   | 
| Geobacter sp. M18                                                         | 9117                                                                                                        | 
| Geobacter sp. M21                                                         | 9118                                                                                                        | 
| Geobacter sulfurreducens KN400                                            | 9119                                                                                                        | 
| Geobacter uraniireducens Rf4                                              | 9120                                                                                                        | 
| Geobacter sulfurreducens PCA                                              | 9122                                                                                                        | 
| Paraburkholderia sprentiae WSM5005                                        | 9130                                                                                                        | 
| Paraburkholderia dilworthii WSM3556                                       | 9131                                                                                                        | 
| Roseovarius sp. 217                                                       | 9132                                                                                                        | 
| Oceanicola batsensis HTCC2597                                             | 9134                                                                                                        | 
| Oceanicola granulosus HTCC2516                                            | 9135                                                                                                        | 
| Oceanibulbus indolifex HEL-45                                             | 9136                                                                                                        | 
| Phaeobacter gallaeciensis 2.10                                            | 9137,9142,9145,9149                                                                                         | 
| Phaeobacter gallaeciensis DSM 26640                                       | 9139,9140,9144,9147,9148,9152,9153,9154                                                                     | 
| Phaeobacter inhibens DSM 17395                                            | 9146,9150,9138,9143                                                                                         | 
| Ruegeria pomeroyi DSS-3                                                   | 9141,9151                                                                                                   | 
| Silicibacter lacuscaerulensis ITI-1157                                    | 9182                                                                                                        | 
| Leisingera daeponensis DSM 23529                                          | 9183                                                                                                        | 
| Sediminimonas qiaohouensis DSM 21189                                      | 9184                                                                                                        | 
| Leisingera aquimarina DSM 24565                                           | 9185                                                                                                        | 
| Pseudophaeobacter arcticus DSM 23566                                      | 9186                                                                                                        | 
| Sedimentitalea nanhaiensis DSM 24252                                      | 9187                                                                                                        | 
| Leisingera caerulea DSM 24564                                             | 9188                                                                                                        | 
| Halanaerobium praevalens DSM 2228                                         | 9189                                                                                                        | 
| Yersinia aldovae 670-83                                                   | 9190                                                                                                        | 
| Lactobacillus curvatus WiKim52                                            | 9192                                                                                                        | 
| Acinetobacter guillouiae CIP 63.46                                        | 9205                                                                                                        | 
| Enterococcus durans ATCC 6056 ASWM                                        | 9206                                                                                                        | 
| Pseudoalteromonas piscicida S2724                                         | 9207                                                                                                        | 
| Pseudoalteromonas elyakovii ATCC 700519                                   | 9208                                                                                                        | 
| Pseudoalteromonas piscicida JCM 20779                                     | 9209                                                                                                        | 
| Staphylococcus pasteuri BAB3                                              | 9210                                                                                                        | 
| Pseudoalteromonas sp. BMB                                                 | 9211                                                                                                        | 
| Staphylococcus sp. AOAB                                                   | 9212                                                                                                        | 
| Hafnia alvei ATCC 13337                                                   | 9213                                                                                                        | 
| Photobacterium phosphoreum ATCC 11040                                     | 9214                                                                                                        | 
| Escherichia coli SCM-21                                                   | 9260                                                                                                        | 
| Propionibacterium acnes 266                                               | 9262                                                                                                        | 
| Propionibacterium acnes ATCC 11828                                        | 9263                                                                                                        | 
| Propionibacterium acnes HL096PA1                                          | 9264,9265                                                                                                   | 
| Propionibacterium acnes TypeIA2 P.acn17                                   | 9266                                                                                                        | 
| Propionibacterium acnes HL030PA1                                          | 9267                                                                                                        | 
| Propionibacterium acnes HL036PA1                                          | 9268                                                                                                        | 
| Propionibacterium acnes HL059PA1                                          | 9269                                                                                                        | 
| Propionibacterium acnes HL086PA1                                          | 9270                                                                                                        | 
| Propionibacterium acnes HL110PA3                                          | 9271                                                                                                        | 
| Propionibacterium acnes PRP-38                                            | 9272                                                                                                        | 
| Methanohalophilus mahii DSM 5219                                          | 9289                                                                                                        | 
| Olsenella uli DSM 7084                                                    | 9321                                                                                                        | 
| Echinicola vietnamensis DSM 17526                                         | 9322                                                                                                        | 
| Meiothermus silvanus DSM 9946 NULL                                        | 9323,9324,9325                                                                                              | 
| Thermobacillus composti KWC4                                              | 9326,9327                                                                                                   | 
| Frateuria aurantia DSM 6220                                               | 9328                                                                                                        | 
| Hirschia baltica ATCC 49814 NULL                                          | 9329,9330                                                                                                   | 
| Pseudomonas stutzeri RCH2                                                 | 9331,9332,9333,9334                                                                                         | 
| Coraliomargarita akajimensis DSM 45221                                    | 9335                                                                                                        | 
| Halovivax ruber XH-70                                                     | 9336                                                                                                        | 
| Natronobacterium gregoryi SP2                                             | 9337                                                                                                        | 
| Methanohalophilus sp T328-1                                               | 9338                                                                                                        | 
| Methanohalophilus sp DAL1                                                 | 9339                                                                                                        | 
| Methanohalophilus sp 2-GBenrich                                           | 9340                                                                                                        | 
| Methanohalobium evestigatum Z-7303                                        | 9341,9342                                                                                                   | 
| Natronococcus occultus SP4                                                | 9343,9344,9345                                                                                              | 
| Cellvibrio japonicus Ueda107                                              | 9414                                                                                                        | 
| Lactobacillus curvatus WiKim38                                            | 9465                                                                                                        | 
| Azospirillum brasilense Sp 7                                              | 9468,9469,9470,9471,9472,9473                                                                               | 
| Azospirillum humicireducens SgZ-5                                         | 9474                                                                                                        | 
| Azospirillum thiophilum BV-S                                              | 9478,9479,9480,9481,9482,9475,9476,9477                                                                     | 
| Lactobacillus plantarum WCFS1                                             | 9485,9486,9487,9488                                                                                         | 
| Lactococcus lactis subsp. cremoris TIFN5                                  | 9489                                                                                                        | 
| Lactococcus lactis subsp. cremoris TIFN7                                  | 9490                                                                                                        | 
| Lactococcus lactis subsp. lactis A12                                      | 9491                                                                                                        | 
| Lactococcus lactis subsp. lactis CNCM I-1631                              | 9492                                                                                                        | 
| Lactococcus lactis subsp. lactis bv. diacetylactis LD61                   | 9493                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum NC8 NULL                         | 9494                                                                                                        | 
| Lactococcus garvieae LG9                                                  | 9495                                                                                                        | 
| Mycobacterium tuberculosis DBS2                                           | 9496                                                                                                        | 
| Pseudomonas protegens CHA0                                                | 9497                                                                                                        | 
| Yersinia intermedia Y228                                                  | 9539                                                                                                        | 
| Lysinibacillus contaminans DSM 25560                                      | 9571                                                                                                        | 
| Lysinibacillus fusiformis M5                                              | 9572                                                                                                        | 
| Lysinibacillus macroides DSM 54                                           | 9573                                                                                                        | 
| Lysinibacillus pakistanensis JCM 18776                                    | 9574                                                                                                        | 
| Lysinibacillus parviboronicapiens JCM 18861 JCM 18861                     | 9575                                                                                                        | 
| Lysinibacillus sp. AR18-8 AR18-8                                          | 9576                                                                                                        | 
| Lysinibacillus sp. F5 F5                                                  | 9577                                                                                                        | 
| Lysinibacillus sp. FJAT-14745 FJAT-14745                                  | 9578                                                                                                        | 
| Lysinibacillus sp. ZYM-1 ZYM-1                                            | 9579                                                                                                        | 
| Lysinibacillus sphaericus 2362                                            | 9580                                                                                                        | 
| Lysinibacillus sphaericus B1-CDA                                          | 9581                                                                                                        | 
| Lysinibacillus sphaericus FSL M8-0337                                     | 9582                                                                                                        | 
| Lysinibacillus sphaericus III(3)7                                         | 9583,9586                                                                                                   | 
| Lysinibacillus sphaericus OT4b.25                                         | 9584,9587                                                                                                   | 
| Lysinibacillus sphaericus OT4b.49                                         | 9585                                                                                                        | 
| Curtobacterium ammoniigenes NBRC 101786                                   | 9589                                                                                                        | 
| Gryllotalpicola ginsengisoli DSM 22003                                    | 9590                                                                                                        | 
| Curtobacterium flaccumfaciens UCD-AKU                                     | 9591                                                                                                        | 
| Curtobacterium oceanosedimentum NS263                                     | 9592                                                                                                        | 
| Curtobacterium citreum NS330                                              | 9593                                                                                                        | 
| Curtobacterium luteum NS184                                               | 9594                                                                                                        | 
| Staphylococcus pasteuri 915_SPAS                                          | 9595                                                                                                        | 
| Propionibacterium freudenreichii ITG P23                                  | 9596                                                                                                        | 
| Lactococcus lactis Bpl1                                                   | 9597                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 456 PRJEB6445                   | 9598                                                                                                        | 
| Propionibacterium acnes 6609                                              | 9599                                                                                                        | 
| Propionibacterium acnes C1                                                | 9600                                                                                                        | 
| Propionibacterium acnes SK137                                             | 9601                                                                                                        | 
| Propionibacterium acnes TypeIA2 P.acn31                                   | 9602                                                                                                        | 
| Propionibacterium acnes TypeIA2 P.acn33                                   | 9603                                                                                                        | 
| Propionibacterium acnes HL001PA1                                          | 9604                                                                                                        | 
| Propionibacterium acnes HL002PA1                                          | 9605                                                                                                        | 
| Propionibacterium acnes HL002PA2                                          | 9606                                                                                                        | 
| Propionibacterium acnes HL002PA3                                          | 9607                                                                                                        | 
| Propionibacterium acnes HL005PA1                                          | 9608                                                                                                        | 
| Clostridium pasteurianum DSM 525                                          | 9609                                                                                                        | 
| Clostridium sporogenes ATCC 15579                                         | 9610                                                                                                        | 
| Clostridium saccharoperbutylacetonicum N1-4(HMT) ATCC 27021               | 9611                                                                                                        | 
| Clostridium sporogenes PA 3679                                            | 9612                                                                                                        | 
| Clostridium thermocellum DSM 2360                                         | 9613                                                                                                        | 
| Clostridium thermocellum JW20                                             | 9614                                                                                                        | 
| Roseburia inulinivorans DSM 16841                                         | 9615                                                                                                        | 
| Roseburia inulinivorans CAG:15 NULL                                       | 9616                                                                                                        | 
| Ruminiclostridium thermocellum AD2                                        | 9618                                                                                                        | 
| Clostridium pasteurianum NRRL B-598                                       | 9624                                                                                                        | 
| Microcystis aeruginosa NIES-98 NIES-98                                    | 9625                                                                                                        | 
| Propionibacterium acnes HL072PA2                                          | 9637                                                                                                        | 
| Propionibacterium acnes HL074PA1                                          | 9638                                                                                                        | 
| Propionibacterium acnes HL078PA1                                          | 9639                                                                                                        | 
| Propionibacterium acnes HL082PA1                                          | 9640                                                                                                        | 
| Propionibacterium acnes HL083PA1                                          | 9641                                                                                                        | 
| Propionibacterium acnes HL087PA1                                          | 9642                                                                                                        | 
| Propionibacterium acnes HL092PA1                                          | 9643                                                                                                        | 
| Propionibacterium acnes HL096PA3                                          | 9644                                                                                                        | 
| Propionibacterium acnes HL097PA1                                          | 9645                                                                                                        | 
| Propionibacterium acnes HL099PA1                                          | 9646                                                                                                        | 
| Propionibacterium acnes HL103PA1                                          | 9647                                                                                                        | 
| Propionibacterium acnes HL110PA2                                          | 9648                                                                                                        | 
| Propionibacterium acnes HL110PA4                                          | 9649                                                                                                        | 
| Propionibacterium acnes J139                                              | 9650                                                                                                        | 
| Propionibacterium acnes J165                                              | 9651                                                                                                        | 
| Propionibacterium acnes P6                                                | 9652                                                                                                        | 
| Propionibacterium acnes PA2                                               | 9653                                                                                                        | 
| Propionibacterium acnes SK182                                             | 9654                                                                                                        | 
| Propionibacterium acnes SK182B-JCVI                                       | 9655                                                                                                        | 
| Propionibacterium acnes SK187                                             | 9656                                                                                                        | 
| Escherichia coli NCTC86                                                   | 9657                                                                                                        | 
| Moraxella osloensis CCUG 350                                              | 9679,9680,9681,9682,9683                                                                                    | 
| Moraxella osloensis KMC41                                                 | 9684,9685,9686,9687                                                                                         | 
| Lactobacillus reuteri CRL 1098                                            | 9688                                                                                                        | 
| Lactobacillus reuteri 100-23                                              | 9689                                                                                                        | 
| Lactobacillus reuteri CF48-3A                                             | 9690                                                                                                        | 
| Lactobacillus reuteri lpuph                                               | 9691                                                                                                        | 
| Lactobacillus reuteri mlc3                                                | 9692                                                                                                        | 
| Lactobacillus reuteri MM2-3                                               | 9693                                                                                                        | 
| Lactobacillus reuteri MM4-1A                                              | 9694                                                                                                        | 
| Microcystis aeruginosa CACIAM 03                                          | 9695                                                                                                        | 
| Rhodococcus ruber P25                                                     | 9778                                                                                                        | 
| Propionibacterium freudenreichii subsp. freudenreichii DSM 20271          | 9796                                                                                                        | 
| Propionibacterium freudenreichii subsp. shermanii NULL                    | 9797                                                                                                        | 
| Propionibacterium freudenreichii subsp. freudenreichii ITG P20            | 9798                                                                                                        | 
| Propionibacterium freudenreichii subsp. freudenreichii NULL               | 9799                                                                                                        | 
| Propionibacterium freudenreichii ITG P1                                   | 9800                                                                                                        | 
| Propionibacterium freudenreichii ITG P14                                  | 9801                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 508                             | 9802                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 527                             | 9803                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 512                             | 9804                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 513                             | 9805                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 514                             | 9806                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 516                             | 9807                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 118                             | 9808                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 122                             | 9809                                                                                                        | 
| Propionibacterium freudenreichii ITG P18                                  | 9810                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 135                             | 9811                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 134                             | 9812                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 123                             | 9813                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 119                             | 9814                                                                                                        | 
| Propionibacterium freudenreichii CIRM-BIA 121                             | 9815                                                                                                        | 
| Flavobacterium psychrophilum 11754                                        | 9816                                                                                                        | 
| Flavobacterium psychrophilum 17830                                        | 9817                                                                                                        | 
| Flavobacterium psychrophilum Pullman                                      | 9818                                                                                                        | 
| Flavobacterium psychrophilum KTEN-1510                                    | 9819                                                                                                        | 
| Enterococcus mundtii QAUEM2808                                            | 9820                                                                                                        | 
| Sinorhizobium meliloti BO21CC                                             | 9821                                                                                                        | 
| Sinorhizobium meliloti AK58                                               | 9822                                                                                                        | 
| Clostridium bifermentans ATCC 19299                                       | 9831                                                                                                        | 
| Clostridium bifermentans ATCC 638                                         | 9832                                                                                                        | 
| Clostridium hathewayi CAG:224 NULL                                        | 9833                                                                                                        | 
| Clostridium carboxidivorans P7                                            | 9834                                                                                                        | 
| Clostridium carboxidivorans P7 PRJNA29495                                 | 9835                                                                                                        | 
| Clostridium cellulovorans 743B PRJNA52819                                 | 9836                                                                                                        | 
| Hungatella hathewayi 12489931                                             | 9837                                                                                                        | 
| Hungatella hathewayi DSM 13479                                            | 9838                                                                                                        | 
| Hungatella hathewayi WAL-18680                                            | 9839                                                                                                        | 
| Clostridium termitidis CT1112 CT1112                                      | 9840                                                                                                        | 
| Ruminococcus bromii L2-63                                                 | 9876                                                                                                        | 
| Ruminococcus champanellensis 18P13 = JCM 17042 18P13                      | 9877                                                                                                        | 
| Acidothermus cellulolyticus 11B 11B; ATCC 43068                           | 9878                                                                                                        | 
| [Clostridium] clariflavum DSM 19732                                       | 9879                                                                                                        | 
| Ruminococcus torques L2-14                                                | 9880                                                                                                        | 
| Acetivibrio cellulolyticus CD2                                            | 9881                                                                                                        | 
| Ruminococcus flavefaciens 17                                              | 9882                                                                                                        | 
| Clostridium papyrosolvens C7                                              | 9883                                                                                                        | 
| Propionibacterium acnes FZ1-2-0                                           | 9884                                                                                                        | 
| Propionibacterium acnes HL005PA2                                          | 9885                                                                                                        | 
| Propionibacterium acnes HL005PA3                                          | 9886                                                                                                        | 
| Propionibacterium acnes HL005PA4                                          | 9887                                                                                                        | 
| Propionibacterium acnes HL007PA1                                          | 9888                                                                                                        | 
| Propionibacterium acnes HL013PA1                                          | 9889                                                                                                        | 
| Propionibacterium acnes HL013PA2                                          | 9890                                                                                                        | 
| Propionibacterium acnes HL020PA1                                          | 9891                                                                                                        | 
| Propionibacterium acnes HL025PA1                                          | 9892                                                                                                        | 
| Propionibacterium acnes HL025PA2                                          | 9893                                                                                                        | 
| Clostridium nexile CAG:348 NULL                                           | 9894                                                                                                        | 
| Clostridium thermocellum BC1 NULL                                         | 9895                                                                                                        | 
| Clostridium tyrobutyricum DSM 2637 = ATCC 25755 = JCM 11008 DSM 2637      | 9896                                                                                                        | 
| Terrisporobacter glycolicus ATCC 14880  ATCC 14880                        | 9897                                                                                                        | 
| Tyzzerella nexilis DSM 1787                                               | 9898                                                                                                        | 
| Ruminiclostridium thermocellum YS                                         | 9899                                                                                                        | 
| Clostridium tyrobutyricum UC7086                                          | 9900                                                                                                        | 
| Clostridium tyrobutyricum DSM 2637                                        | 9901                                                                                                        | 
| Bradyrhizobiaceae bacterium  SG-6C                                        | 9917                                                                                                        | 
| Bradyrhizobium sp.  WSM2793                                               | 9918                                                                                                        | 
| Bradyrhizobium sp.  WSM1253                                               | 9919                                                                                                        | 
| Bradyrhizobium sp. WSM471                                                 | 9920                                                                                                        | 
| Bradyrhizobium sp.  YR681                                                 | 9921                                                                                                        | 
| Bradyrhizobium sp. DFCI-1 NULL                                            | 9922                                                                                                        | 
| Rhizobium leguminosarum bv. trifolii  SRDI565                             | 9923                                                                                                        | 
| Flavobacterium columnare 94-081                                           | 9926                                                                                                        | 
| Flavobacterium columnare C#2                                              | 9927                                                                                                        | 
| Flavobacterium columnare Pf1                                              | 9928                                                                                                        | 
| Flavobacterium columnare TC 1691                                          | 9929                                                                                                        | 
| Lysinibacillus sphaericus LMG 22257                                       | 9930                                                                                                        | 
| Lysinibacillus xylanilyticus SR-86                                        | 9931                                                                                                        | 
| Allobaculum stercoricanis DSM 13633                                       | 9957                                                                                                        | 
| Pseudoalteromonas undina DSM 6065 NCIMB 2128                              | 9961                                                                                                        | 
| Pseudoalteromonas sp.  PAMC 22718                                         | 9962                                                                                                        | 
| Pseudoalteromonas sp.  NW 4327                                            | 9963                                                                                                        | 
| Pseudoalteromonas ruthenica  CP76                                         | 9964                                                                                                        | 
| Pseudoalteromonas marina DSM 17587 mano4                                  | 9965                                                                                                        | 
| Pseudoalteromonas flavipulchra  JG1                                       | 9968                                                                                                        | 
| Pseudoalteromonas haloplanktis ANT/505                                    | 9969                                                                                                        | 
| Propionibacterium acidifaciens F0233                                      | 10030                                                                                                       | 
| Propionibacterium acnes HL027PA1                                          | 10031                                                                                                       | 
| Propionibacterium acnes HL030PA2                                          | 10032                                                                                                       | 
| Propionibacterium acnes HL036PA3                                          | 10033                                                                                                       | 
| Propionibacterium humerusii HL037PA3                                      | 10034                                                                                                       | 
| Propionibacterium acnes HL050PA2                                          | 10035                                                                                                       | 
| Propionibacterium acnes HL060PA1                                          | 10036                                                                                                       | 
| Propionibacterium acnes HL082PA2                                          | 10037                                                                                                       | 
| Desulfovibrio sp. J2                                                      | 10045                                                                                                       | 
| Lactobacillus acidipiscis KCTC 13900                                      | 10046                                                                                                       | 
| Parabacteroides distasonis ATCC 8503                                      | 10048                                                                                                       | 
| Parabacteroides johnsonii DSM 18315                                       | 10049                                                                                                       | 
| Parabacteroides merdae ATCC 43184                                         | 10050                                                                                                       | 
| Clostridium hiranonis DSM 13275                                           | 10069                                                                                                       | 
| Intestinibacter bartlettii DSM 16795                                      | 10070                                                                                                       | 
| Clostridium bartlettii  CAG 1329                                          | 10071                                                                                                       | 
| Clostridium celatum DSM 1785                                              | 10072                                                                                                       | 
| Clostridium citroniae WAL-17108                                           | 10073                                                                                                       | 
| Clostridium hylemonae DSM 15053                                           | 10074                                                                                                       | 
| Clostridium leptum DSM 753                                                | 10075                                                                                                       | 
| Clostridium leptum CAG 27                                                 | 10076                                                                                                       | 
| Clostridium tunisiense TJ                                                 | 10077                                                                                                       | 
| Propionibacterium acnes HL072PA1                                          | 10129                                                                                                       | 
| Propionibacterium acnes HL083PA2                                          | 10130                                                                                                       | 
| Propionibacterium acnes HL087PA2                                          | 10131                                                                                                       | 
| Propionibacterium acnes HL087PA3                                          | 10132                                                                                                       | 
| Propionibacterium acnes HL096PA2                                          | 10133                                                                                                       | 
| Propionibacterium acnes HL110PA1                                          | 10134                                                                                                       | 
| Cutibacterium avidum TM16                                                 | 10135                                                                                                       | 
| Cutibacterium granulosum DSM 20700                                        | 10136                                                                                                       | 
| Cutibacterium granulosum TM11                                             | 10137                                                                                                       | 
| Cutibacterium avidum ATCC 25577                                           | 10138                                                                                                       | 
| Cycloclasticus zancles 7-ME                                               | 10142,10144                                                                                                 | 
| Dichelobacter nodosus VCS1703A                                            | 10143                                                                                                       | 
| Spiribacter sp. UAH-SP71                                                  | 10147                                                                                                       | 
| Spiribacter salinus M19-40                                                | 10146                                                                                                       | 
| Oceanimonas sp. GK1                                                       | 10145,10148,10150                                                                                           | 
| Teredinibacter turnerae T7901                                             | 10149                                                                                                       | 
| Fangia hongkongensis FSC776  DSM 21703                                    | 10162                                                                                                       | 
| Arhodomonas aquaeolei DSM 8974                                            | 10163                                                                                                       | 
| Beggiatoa alba B18LD                                                      | 10164                                                                                                       | 
| Leucothrix mucor DSM 2157                                                 | 10165                                                                                                       | 
| Thiocapsa marina 5811                                                     | 10166                                                                                                       | 
| Thiorhodococcus drewsii AZ1                                               | 10167                                                                                                       | 
| Thiorhodospira sibirica ATCC 700588                                       | 10168                                                                                                       | 
| Thiorhodovibrio sp. 970                                                   | 10169                                                                                                       | 
| Thiothrix nivea DSM 5205                                                  | 10170                                                                                                       | 
| Pseudoalteromonas sp. BSi20429                                            | 10171                                                                                                       | 
| Pseudoalteromonas sp. BSi20311                                            | 10172                                                                                                       | 
| Pseudoalteromonas sp. BSi20439                                            | 10173                                                                                                       | 
| Pseudoalteromonas sp. BSi20480                                            | 10174                                                                                                       | 
| Pseudoalteromonas sp. BSi20495                                            | 10175                                                                                                       | 
| Pseudoalteromonas sp. BSi20652                                            | 10176                                                                                                       | 
| Pseudoalteromonas sp. NJ631                                               | 10177                                                                                                       | 
| Pseudomonas pseudoalcaligenes KF707  KF707                                | 10178                                                                                                       | 
| Pseudomonas pseudoalcaligenes CECT 5344 CECT5344                          | 10179                                                                                                       | 
| Nitrococcus mobilis Nb-231 public                                         | 10182                                                                                                       | 
| uncultured Thiohalocapsa sp. PB-PSB1 NULL                                 | 10183                                                                                                       | 
| Lamprocystis purpurea DSM 4197                                            | 10186                                                                                                       | 
| Cycloclasticus pugetii PS-1                                               | 10187                                                                                                       | 
| Rhodobacter sphaeroides KD131 KD131; KCTC 12085                           | 10188,10189,10190,10191                                                                                     | 
| Bilophila sp. 4_1_30                                                      | 10192                                                                                                       | 
| Bilophila wadsworthia 3_1_6                                               | 10193                                                                                                       | 
| Rhodobacter sphaeroides 2.4.1 NZ_AKBU                                     | 10194                                                                                                       | 
| Rhodobacter sphaeroides 2.4.1 NZ_AKVW                                     | 10195                                                                                                       | 
| Rhodobacter sphaeroides WS8N                                              | 10196                                                                                                       | 
| Silicibacter sp. TrichCH4B                                                | 10197                                                                                                       | 
| Acidiferrobacter thiooxydans ZJ                                           | 10215                                                                                                       | 
| Alteromonas sp. Mac1                                                      | 10216                                                                                                       | 
| Spongiibacter sp. IMCC21906                                               | 10217,10218                                                                                                 | 
| Arsukibacterium sp. MJ3                                                   | 10219                                                                                                       | 
| Candidatus Tenderia electrophaga NRL1                                     | 10220,10221                                                                                                 | 
| Marichromatium purpuratum 984 987                                         | 10222                                                                                                       | 
| Thiocapsa sp. KS1                                                         | 10223                                                                                                       | 
| Rheinheimera sp. EpRS3                                                    | 10224                                                                                                       | 
| Thiohalocapsa sp. ML1                                                     | 10225                                                                                                       | 
| Thiorhodococcus sp AK35                                                   | 10226                                                                                                       | 
| Rheinheimera salexigens KH87                                              | 10227                                                                                                       | 
| Acidihalobacter ferrooxidans V8                                           | 10228                                                                                                       | 
| Acidihalobacter prosperus F5                                              | 10229                                                                                                       | 
| Aquisalimonas asiatica CGMCC 1.6291                                       | 10230                                                                                                       | 
| Ectothiorhodosinus mongolicus M9                                          | 10231                                                                                                       | 
| Ectothiorhodospira sp. PHS-1                                              | 10232                                                                                                       | 
| Ectothiorhodospira haloalkaliphila ATCC 51935                             | 10233                                                                                                       | 
| Ectothiorhodospira mobilis DSM 4180                                       | 10234                                                                                                       | 
| Halofilum ochraceum XJ16                                                  | 10235                                                                                                       | 
| Halorhodospira halochloris A                                              | 10236                                                                                                       | 
| Thioalkalivibrio versutus D301                                            | 10237                                                                                                       | 
| Thiohalomonas denitrificans HLD2                                          | 10238                                                                                                       | 
| Thiohalospira halophila DSM 15071 HL3                                     | 10239                                                                                                       | 
| Halothiobacillus sp. LS2                                                  | 10240                                                                                                       | 
| Wenzhouxiangella marina KCTC 42284                                        | 10241                                                                                                       | 
| Woeseia oceani XK5                                                        | 10242                                                                                                       | 
| Gynuella sunshinyii YC6258                                                | 10243                                                                                                       | 
| Gilliamella apicola wkB1                                                  | 10244                                                                                                       | 
| Frischella perrara PEB0191                                                | 10245                                                                                                       | 
| Allofrancisella guangzhouensis 08HL01032                                  | 10246,10247                                                                                                 | 
| Hydrogenovibrio marinus DSM 11271                                         | 10248                                                                                                       | 
| Hydrogenovibrio marinus MH-110                                            | 10249                                                                                                       | 
| Piscirickettsia salmonis LF-89 = ATCC VR-1361                             | 10250,10251,10252,10253                                                                                     | 
| Sulfurivirga caldicuralii DSM 17737                                       | 10254                                                                                                       | 
| Thioalkalimicrobium aerophilum AL3                                        | 10255                                                                                                       | 
| Thiothrix lacustris DSM 21227                                             | 10256                                                                                                       | 
| Lokiarchaeum sp GC14_75                                                   | 10258                                                                                                       | 
| Candidatus Lokiarchaeota archaeon CR_4                                    | 10259                                                                                                       | 
| Candidatus Thorarchaeota archaeon SMTZ1-45                                | 10260                                                                                                       | 
| Candidatus Thorarchaeota archaeon SMTZ1-83                                | 10261                                                                                                       | 
| Candidatus Thorarchaeota archaeon AB_25                                   | 10262                                                                                                       | 
| Candidatus Odinarchaeota archaeon LCB_4                                   | 10263                                                                                                       | 
| Candidatus Heimdallarchaeota archaeon AB_125                              | 10264                                                                                                       | 
| Candidatus Heimdallarchaeota archaeon LC_2                                | 10265                                                                                                       | 
| Candidatus Heimdallarchaeota archaeon LC_3                                | 10266                                                                                                       | 
| Lactobacillus curvatus RI-406                                             | 10275                                                                                                       | 
| Lactobacillus curvatus RI-124                                             | 10276                                                                                                       | 
| Lactobacillus curvatus RI-198                                             | 10277                                                                                                       | 
| Lactobacillus curvatus RI-193                                             | 10278                                                                                                       | 
| Leptospira interrogans serovar Manilae UP-MMC-NIID LP                     | 10279,10280,10281                                                                                           | 
| Cupriavidus sp. UYMMa02A                                                  | 10289                                                                                                       | 
| Propionibacterium avidum 44067                                            | 10290                                                                                                       | 
| Propionibacterium acidipropionici ATCC 4875                               | 10291                                                                                                       | 
| Propionibacterium propionicum F0230a                                      | 10292                                                                                                       | 
| Propionibacterium acnes HL056PA1                                          | 10293                                                                                                       | 
| Propionibacterium acnes HL059PA2                                          | 10294                                                                                                       | 
| Propionibacterium acnes HL063PA2                                          | 10295                                                                                                       | 
| Propionibacterium acnes HL063PA1                                          | 10296                                                                                                       | 
| Propionibacterium humerusii P08                                           | 10297                                                                                                       | 
| Propionibacterium acnes HL067PA1                                          | 10298                                                                                                       | 
| delta proteobacterium MLMS-1                                              | 10315                                                                                                       | 
| Halobacillus halophilus DSM 2266                                          | 10317,10318,10319                                                                                           | 
| Halomicrobium mukohataei DSM 12286                                        | 10320,10321                                                                                                 | 
| halophilic archaeon DL31                                                  | 10323,10324,10322                                                                                           | 
| Lactobacillus sakei RI-394                                                | 10327                                                                                                       | 
| Lactobacillus sakei RI-403                                                | 10328                                                                                                       | 
| Lactobacillus sakei RI-410                                                | 10329                                                                                                       | 
| Lactobacillus sakei RI-409                                                | 10330                                                                                                       | 
| Lactobacillus sakei RI-412                                                | 10331                                                                                                       | 
| Lactobacillus sakei RI-404                                                | 10332                                                                                                       | 
| Tannerella forsythia ATCC 43037                                           | 10354                                                                                                       | 
| Alistipes finegoldii DSM 17242                                            | 10355                                                                                                       | 
| Alistipes shahii WAL 8301                                                 | 10356                                                                                                       | 
| Odoribacter splanchnicus DSM 20712 NULL                                   | 10357                                                                                                       | 
| Mucilaginibacter paludis DSM 18603                                        | 10358                                                                                                       | 

