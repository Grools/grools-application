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


| Organism name                                                   | Sequences ID list                                                                                           | 
|-----------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------| 
| Bacillus halodurans                                             | 1                                                                                                           | 
| Escherichia coli                                                | 6274,2                                                                                                      | 
| Yersinia pestis                                                 | 678679680681                                                                                                | 
| Mycobacterium tuberculosis                                      | 1745                                                                                                        | 
| Mycobacterium tuberculosis                                      | 354                                                                                                         | 
| Bacillus subtilis                                               | 843                                                                                                         | 
| Photorhabdus luminescens                                        | 10                                                                                                          | 
| Yersinia pestis                                                 | 682683                                                                                                      | 
| Sulfolobus solfataricus                                         | 14                                                                                                          | 
| Methanothermobacter thermautotrophicus                          | 15                                                                                                          | 
| Methanocaldococcus jannaschii                                   | 16,1742,1743                                                                                                | 
| Pyrococcus abyssi                                               | 17,1741                                                                                                     | 
| Chlamydia trachomatis                                           | 18                                                                                                          | 
| Chlamydophila pneumoniae                                        | 19                                                                                                          | 
| Synechocystis sp.                                               | 20,4487,4488,4489,4490                                                                                      | 
| Mycoplasma pneumoniae                                           | 1625                                                                                                        | 
| Neisseria meningitidis                                          | 24                                                                                                          | 
| Rickettsia prowazekii                                           | 25                                                                                                          | 
| Borrelia burgdorferi                                            | 2480,2481,26,2482,2467,2483,2468,2484,2469,2485,2470,2486,2471,2487,2472,2473,2474,2475,2476,2477,2478,2479 | 
| Thermotoga maritima                                             | 27                                                                                                          | 
| Pseudomonas aeruginosa                                          | 3745                                                                                                        | 
| Pseudoalteromonas haloplanktis                                  | 75,76                                                                                                       | 
| Salmonella enterica subsp. enterica                             | 32                                                                                                          | 
| Salmonella typhimurium                                          | 35,2496                                                                                                     | 
| Neisseria meningitidis                                          | 486                                                                                                         | 
| Acinetobacter baylyi                                            | 36                                                                                                          | 
| Kuenenia stuttgartiensis                                        | 256257258259260                                                                                             | 
| Neisseria gonorrhoeae                                           | 142                                                                                                         | 
| Aeropyrum pernix                                                | 41                                                                                                          | 
| Streptococcus pneumoniae                                        | 8591                                                                                                        | 
| Clostridium acetobutylicum                                      | 1744,44                                                                                                     | 
| Haemophilus influenzae                                          | 47                                                                                                          | 
| Vibrio cholerae                                                 | 387388                                                                                                      | 
| Xylella fastidiosa                                              | 49                                                                                                          | 
| Shigella flexneri 2a                                            | 50                                                                                                          | 
| Campylobacter jejuni subsp. jejuni                              | 52                                                                                                          | 
| Pseudomonas syringae pv. tomato                                 | 53                                                                                                          | 
| Ralstonia solanacearum                                          | 55215                                                                                                       | 
| Bacillus cereus                                                 | 56,68                                                                                                       | 
| Bacillus cereus                                                 | 58,67                                                                                                       | 
| Bacillus anthracis                                              | 59                                                                                                          | 
| Frankia alni                                                    | 284                                                                                                         | 
| Streptomyces coelicolor                                         | 397398399                                                                                                   | 
| Acinetobacter baumannii                                         | 231,232,62,70,71                                                                                            | 
| Bacillus anthracis                                              | 63,65,66                                                                                                    | 
| Pseudomonas entomophila                                         | 180                                                                                                         | 
| Acinetobacter baumannii                                         | 73,74,234,623                                                                                               | 
| Bacillus licheniformis                                          | 77                                                                                                          | 
| Xenorhabdus bovienii                                            | 248                                                                                                         | 
| Yersinia enterocolitica                                         | 666667                                                                                                      | 
| Bacillus thuringiensis serovar konkukian                        | 80                                                                                                          | 
| Desulfotalea psychrophila                                       | 81,82,83                                                                                                    | 
| Oceanobacillus iheyensis                                        | 84                                                                                                          | 
| Mycoplasma genitalium                                           | 85                                                                                                          | 
| Photorhabdus asymbiotica                                        | 1053,1054                                                                                                   | 
| Bordetella bronchiseptica                                       | 87                                                                                                          | 
| Bordetella parapertussis                                        | 88                                                                                                          | 
| Bordetella pertussis                                            | 89                                                                                                          | 
| Borrelia garinii                                                | 91,92,93                                                                                                    | 
| Treponema pallidum subsp. pallidum                              | 94                                                                                                          | 
| Treponema denticola                                             | 95                                                                                                          | 
| Leptospira interrogans serovar lai                              | 96,97                                                                                                       | 
| Leptospira interrogans serovar Copenhageni                      | 98,99                                                                                                       | 
| Corynebacterium glutamicum                                      | 9783                                                                                                        | 
| Leptospira biflexa serovar Patoc                                | 262324325                                                                                                   | 
| Escherichia coli                                                | 104105103                                                                                                   | 
| Escherichia coli                                                | 106                                                                                                         | 
| Buchnera aphidicola                                             | 107108109                                                                                                   | 
| Buchnera aphidicola                                             | 110                                                                                                         | 
| Buchnera aphidicola                                             | 111                                                                                                         | 
| Erwinia carotovora subsp. atroseptica                           | 113                                                                                                         | 
| Wigglesworthia glossinidia endosymbiont of Glossina brevipalpis | 545546                                                                                                      | 
| Burkholderia mallei                                             | 115116                                                                                                      | 
| Burkholderia pseudomallei                                       | 119120                                                                                                      | 
| Pyrococcus furiosus                                             | 121                                                                                                         | 
| Pyrococcus horikoshii                                           | 122                                                                                                         | 
| Thermoplasma volcanium                                          | 123                                                                                                         | 
| Vibrio vulnificus                                               | 124125                                                                                                      | 
| Herminiimonas arsenicoxydans                                    | 158                                                                                                         | 
| Psychrobacter arcticus                                          | 138                                                                                                         | 
| Neisseria meningitidis                                          | 566                                                                                                         | 
| Bradyrhizobium japonicum                                        | 149                                                                                                         | 
| Mesorhizobium loti                                              | 150151152                                                                                                   | 
| Sinorhizobium meliloti                                          | 153154155                                                                                                   | 
| Frankia sp.                                                     | 1122                                                                                                        | 
| Frankia sp.                                                     | 1121                                                                                                        | 
| Bradyrhizobium sp.                                              | 246                                                                                                         | 
| Bradyrhizobium sp.                                              | 252312                                                                                                      | 
| Salmonella enterica subsp. enterica serovar Choleraesuis        | 162163164                                                                                                   | 
| Bdellovibrio bacteriovorus                                      | 165                                                                                                         | 
| Rhizobium leguminosarum bv. viciae                              | 1.6616716816917E+020                                                                                        | 
| Rhodopseudomonas palustris                                      | 173174                                                                                                      | 
| Pseudomonas fluorescens                                         | 179                                                                                                         | 
| Pseudomonas syringae pv. syringae                               | 181                                                                                                         | 
| Helicobacter hepaticus                                          | 182                                                                                                         | 
| Helicobacter pylori                                             | 183                                                                                                         | 
| Helicobacter pylori                                             | 184                                                                                                         | 
| Campylobacter jejuni                                            | 185                                                                                                         | 
| Wolinella succinogenes                                          | 186                                                                                                         | 
| Escherichia coli                                                | 278279                                                                                                      | 
| Escherichia coli                                                | 556                                                                                                         | 
| Shigella sonnei                                                 | 190191                                                                                                      | 
| Candidatus Cloacamonas acidaminovorans                          | 192                                                                                                         | 
| Escherichia coli                                                | 275822                                                                                                      | 
| Escherichia coli                                                | 544                                                                                                         | 
| Escherichia coli                                                | 372373823                                                                                                   | 
| Escherichia coli                                                | 357462                                                                                                      | 
| Escherichia coli                                                | 202203                                                                                                      | 
| Ralstonia eutropha                                              | 209210211212                                                                                                | 
| Escherichia fergusonii                                          | 365366                                                                                                      | 
| Pseudomonas syringae pv. phaseolicola                           | 216217218                                                                                                   | 
| Shigella boydii                                                 | 219220                                                                                                      | 
| Shigella dysenteriae                                            | 222,2495,221                                                                                                | 
| Burkholderia sp.                                                | 225226227                                                                                                   | 
| Cupriavidus taiwanensis                                         | 280411560                                                                                                   | 
| Helicobacter pylori                                             | 561                                                                                                         | 
| Methylobacterium extorquens                                     | 240241242                                                                                                   | 
| Marinobacter hydrocarbonoclasticus                              | 329                                                                                                         | 
| Escherichia coli                                                | 244                                                                                                         | 
| Francisella tularensis subsp. tularensis                        | 247                                                                                                         | 
| Xenorhabdus nematophila                                         | 249273                                                                                                      | 
| Methylobacterium extorquens                                     | 415416417418419                                                                                             | 
| Escherichia coli                                                | 264265                                                                                                      | 
| Rhizobium etli                                                  | 8.52266267268269E+020                                                                                       | 
| Legionella pneumophila subsp. pneumophila                       | 276                                                                                                         | 
| Legionella pneumophila                                          | 281636                                                                                                      | 
| Coxiella burnetii                                               | 2490,2491                                                                                                   | 
| Rickettsia felis                                                | 283358359                                                                                                   | 
| Fusobacterium nucleatum subsp. nucleatum                        | 286                                                                                                         | 
| Cupriavidus metallidurans                                       | 290291539540                                                                                                | 
| Burkholderia cenocepacia                                        | 294295296                                                                                                   | 
| Burkholderia thailandensis                                      | 297298                                                                                                      | 
| Burkholderia xenovorans                                         | 299300301                                                                                                   | 
| Mycobacterium avium subsp. paratuberculosis                     | 302                                                                                                         | 
| Mycobacterium bovis                                             | 303                                                                                                         | 
| Mycobacterium sp.                                               | 305306                                                                                                      | 
| Helicobacter pylori                                             | 307308                                                                                                      | 
| Mycobacterium marinum                                           | 720721                                                                                                      | 
| Mycobacterium smegmatis                                         | 722                                                                                                         | 
| Helicobacter acinonychis                                        | 313314                                                                                                      | 
| Sulfurimonas denitrificans                                      | 315                                                                                                         | 
| Borrelia afzelii                                                | 316317318                                                                                                   | 
| Clostridium perfringens                                         | 319                                                                                                         | 
| Clostridium tetani                                              | 320321                                                                                                      | 
| Escherichia coli                                                | 322                                                                                                         | 
| Ralstonia eutropha                                              | 323335350                                                                                                   | 
| Thiomonas sp.                                                   | 327326                                                                                                      | 
| Burkholderia phymatum                                           | 599602603604                                                                                                | 
| Leptospira borgpetersenii serovar Hardjo-bovis                  | 344345                                                                                                      | 
| Leptospira borgpetersenii serovar Hardjo-bovis                  | 346347                                                                                                      | 
| Candidatus Nitrospira defluvii                                  | 364                                                                                                         | 
| Magnetospirillum magneticum                                     | 349                                                                                                         | 
| Escherichia coli                                                | 351                                                                                                         | 
| Rickettsia conorii                                              | 360                                                                                                         | 
| Rickettsia bellii                                               | 361                                                                                                         | 
| Rickettsia typhi                                                | 362                                                                                                         | 
| Nitrobacter hamburgensis                                        | 368369370367                                                                                                | 
| Nitrobacter winogradskyi                                        | 375                                                                                                         | 
| Nitrosomonas europaea                                           | 376                                                                                                         | 
| Nitrosomonas eutropha                                           | 378379380                                                                                                   | 
| Vibrio fischeri                                                 | 389390391                                                                                                   | 
| Vibrio parahaemolyticus                                         | 392393                                                                                                      | 
| Vibrio vulnificus                                               | 394395396                                                                                                   | 
| Photobacterium profundum                                        | 402403404                                                                                                   | 
| Vibrio tasmaniensis                                             | 405406                                                                                                      | 
| Bartonella bacilliformis                                        | 407                                                                                                         | 
| Bartonella henselae                                             | 408                                                                                                         | 
| Bartonella quintana                                             | 409                                                                                                         | 
| Streptococcus pneumoniae                                        | 412                                                                                                         | 
| Streptococcus pneumoniae                                        | 413                                                                                                         | 
| Alkalilimnicola ehrlichei                                       | 420                                                                                                         | 
| Pyrobaculum arsenaticum                                         | 421                                                                                                         | 
| Streptococcus agalactiae                                        | 422                                                                                                         | 
| Streptococcus agalactiae                                        | 423                                                                                                         | 
| Streptococcus agalactiae                                        | 424                                                                                                         | 
| Streptococcus mutans                                            | 425                                                                                                         | 
| Methylobacterium extorquens                                     | 702                                                                                                         | 
| Streptococcus pyogenes                                          | 428                                                                                                         | 
| Streptococcus pyogenes                                          | 429                                                                                                         | 
| Streptococcus pyogenes                                          | 430                                                                                                         | 
| Streptococcus pyogenes                                          | 431                                                                                                         | 
| Streptococcus pyogenes                                          | 432                                                                                                         | 
| Streptococcus pyogenes                                          | 433                                                                                                         | 
| Streptococcus pyogenes                                          | 434                                                                                                         | 
| Streptococcus sanguinis                                         | 435                                                                                                         | 
| Streptococcus thermophilus                                      | 436                                                                                                         | 
| Streptococcus thermophilus                                      | 437438439                                                                                                   | 
| Streptococcus thermophilus                                      | 440                                                                                                         | 
| Streptococcus suis                                              | 441                                                                                                         | 
| Streptococcus suis                                              | 442                                                                                                         | 
| Streptococcus pyogenes                                          | 443                                                                                                         | 
| Shigella flexneri 2a                                            | 444445                                                                                                      | 
| Nocardia cyriacigeorgica                                        | 3482                                                                                                        | 
| Methanosarcina acetivorans                                      | 447                                                                                                         | 
| Methanosarcina barkeri                                          | 448449                                                                                                      | 
| Methanosarcina mazei                                            | 450                                                                                                         | 
| Clostridium sticklandii                                         | 654                                                                                                         | 
| Azospirillum lipoferum                                          | 1024,1025,1026,1027,1028,1029,1033                                                                          | 
| Acinetobacter baumannii                                         | 459460461                                                                                                   | 
| Streptomyces cattleya                                           | 1349,1350                                                                                                   | 
| Neisseria meningitidis                                          | 465                                                                                                         | 
| Archaeoglobus fulgidus                                          | 466                                                                                                         | 
| Haloarcula marismortui                                          | 4.7446747546847E+026                                                                                        | 
| Corynebacterium glutamicum                                      | 476477                                                                                                      | 
| Halobacterium sp.                                               | 478479480                                                                                                   | 
| Haloquadratum walsbyi                                           | 481482                                                                                                      | 
| Hyperthermus butylicus                                          | 483                                                                                                         | 
| Metallosphaera sedula                                           | 484                                                                                                         | 
| Methanococcoides burtonii                                       | 485                                                                                                         | 
| Methanococcus maripaludis                                       | 487488                                                                                                      | 
| Methanococcus maripaludis                                       | 489                                                                                                         | 
| Methanocorpusculum labreanum                                    | 490                                                                                                         | 
| Methanobrevibacter smithii                                      | 491                                                                                                         | 
| Methanoculleus marisnigri                                       | 492                                                                                                         | 
| Methanopyrus kandleri                                           | 493                                                                                                         | 
| Methanosaeta thermophila                                        | 494                                                                                                         | 
| Methanosphaera stadtmanae                                       | 495                                                                                                         | 
| Methanospirillum hungatei                                       | 496                                                                                                         | 
| Nanoarchaeum equitans                                           | 497                                                                                                         | 
| Natronomonas pharaonis                                          | 498499500                                                                                                   | 
| Picrophilus torridus                                            | 501                                                                                                         | 
| Pyrobaculum aerophilum                                          | 502                                                                                                         | 
| Pyrobaculum calidifontis                                        | 503                                                                                                         | 
| Pyrobaculum islandicum                                          | 504                                                                                                         | 
| Staphylothermus marinus                                         | 505                                                                                                         | 
| Sulfolobus acidocaldarius                                       | 506                                                                                                         | 
| Sulfolobus tokodaii                                             | 507                                                                                                         | 
| Thermococcus kodakarensis                                       | 508                                                                                                         | 
| Thermofilum pendens                                             | 509510                                                                                                      | 
| Thermoplasma acidophilum                                        | 511                                                                                                         | 
| uncultured methanogenic archaeon                                | 512                                                                                                         | 
| Methanococcus aeolicus                                          | 513                                                                                                         | 
| Methanococcus maripaludis                                       | 514                                                                                                         | 
| Methanococcus vannielii                                         | 515                                                                                                         | 
| Nocardia farcinica                                              | 516517518                                                                                                   | 
| Buchnera aphidicola                                             | 521,1504                                                                                                    | 
| Baumannia cicadellinicola                                       | 522                                                                                                         | 
| Candidatus Blochmannia floridanus                               | 523                                                                                                         | 
| Candidatus Blochmannia pennsylvanicus                           | 524                                                                                                         | 
| Sodalis glossinidius                                            | 525526527528                                                                                                | 
| Wolbachia endosymbiont                                          | 529                                                                                                         | 
| Wolbachia pipientis                                             | 530                                                                                                         | 
| Candidatus Carsonella ruddii                                    | 531                                                                                                         | 
| Mycoplasma hyopneumoniae                                        | 532                                                                                                         | 
| Mycoplasma hyopneumoniae                                        | 533                                                                                                         | 
| Mycoplasma hyopneumoniae                                        | 534                                                                                                         | 
| Lawsonia intracellularis                                        | 535536537538                                                                                                | 
| Mycobacterium canettii                                          | 1701                                                                                                        | 
| Candidatus Methylomirabilis oxyfera                             | 913                                                                                                         | 
| Legionella pneumophila subsp. pneumophila                       | 845                                                                                                         | 
| Bacillus amyloliquefaciens                                      | 558                                                                                                         | 
| Escherichia coli                                                | 559                                                                                                         | 
| Methylobacterium sp.                                            | 699700701                                                                                                   | 
| Legionella pneumophila subsp. pneumophila                       | 751846                                                                                                      | 
| Janthinobacterium sp.                                           | 570                                                                                                         | 
| Escherichia coli                                                | 571                                                                                                         | 
| Shigella flexneri 5                                             | 572                                                                                                         | 
| Legionella hackeliae                                            | 2315,2316                                                                                                   | 
| Legionella micdadei                                             | 2317                                                                                                        | 
| Legionella-Like Amoebal Pathogens                               | 2319,2370,5013                                                                                              | 
| Azorhizobium caulinodans                                        | 583                                                                                                         | 
| Enterobacter sp.                                                | 584585                                                                                                      | 
| Serratia proteamaculans                                         | 586587                                                                                                      | 
| Methylobacterium radiotolerans                                  | 7.04984985986988E+026                                                                                       | 
| Carnoules 1                                                     | 591                                                                                                         | 
| Carnoules 2                                                     | 592                                                                                                         | 
| Carnoules 3                                                     | 593                                                                                                         | 
| Carnoules 4                                                     | 594                                                                                                         | 
| Carnoules 5                                                     | 595                                                                                                         | 
| Carnoules 6                                                     | 596                                                                                                         | 
| Carnoules 7                                                     | 597                                                                                                         | 
| Magnetococcus sp.                                               | 601                                                                                                         | 
| Rhodospirillum rubrum                                           | 605606                                                                                                      | 
| Rhodobacter sphaeroides                                         | 614615616                                                                                                   | 
| Rhodobacter sphaeroides                                         | 6.17618619620622E+017                                                                                       | 
| Legionella pneumophila                                          | 624625                                                                                                      | 
| Legionella pneumophila                                          | 875                                                                                                         | 
| Vibrio harveyi                                                  | 627628629                                                                                                   | 
| Mycobacterium canettii                                          | 1939                                                                                                        | 
| Mycobacterium canettii                                          | 1940                                                                                                        | 
| Agrobacterium tumefaciens                                       | 632633634635                                                                                                | 
| Bartonella tribocorum                                           | 638637                                                                                                      | 
| Orientia tsutsugamushi                                          | 640                                                                                                         | 
| Rickettsia massiliae                                            | 641642                                                                                                      | 
| Rickettsia rickettsii                                           | 643                                                                                                         | 
| Rickettsia rickettsii                                           | 644                                                                                                         | 
| Rickettsia akari                                                | 645                                                                                                         | 
| Rickettsia bellii                                               | 646                                                                                                         | 
| Rickettsia canadensis                                           | 647                                                                                                         | 
| Mycobacterium canettii                                          | 1700                                                                                                        | 
| Ralstonia solanacearum                                          | 1667,1668,1669                                                                                              | 
| Trichodesmium erythraeum                                        | 655                                                                                                         | 
| Nostoc sp.                                                      | 4485,4486,656,4481,4482,4483,4484                                                                           | 
| Anabaena variabilis                                             | 657,1966,1967,1968,1969                                                                                     | 
| Synechococcus elongatus                                         | 658                                                                                                         | 
| Synechococcus sp.                                               | 659                                                                                                         | 
| Synechococcus sp.                                               | 660                                                                                                         | 
| Thermosynechococcus elongatus                                   | 661                                                                                                         | 
| Prochlorococcus marinus                                         | 662                                                                                                         | 
| Prochlorococcus marinus                                         | 663                                                                                                         | 
| Microcystis aeruginosa                                          | 664                                                                                                         | 
| Oscillatoria sp.                                                | 1461                                                                                                        | 
| Yersinia pestis                                                 | 668669670                                                                                                   | 
| Yersinia pestis                                                 | 674675676677                                                                                                | 
| Yersinia pestis                                                 | 684685686                                                                                                   | 
| Yersinia pestis                                                 | 687688689                                                                                                   | 
| Yersinia pestis                                                 | 690                                                                                                         | 
| Yersinia pseudotuberculosis                                     | 691692693                                                                                                   | 
| Yersinia pseudotuberculosis                                     | 694695696                                                                                                   | 
| Yersinia pseudotuberculosis                                     | 697                                                                                                         | 
| Mycobacterium sp.                                               | 708                                                                                                         | 
| Mycobacterium sp.                                               | 709710711                                                                                                   | 
| Mycobacterium abscessus                                         | 712713                                                                                                      | 
| Mycobacterium avium                                             | 714                                                                                                         | 
| Mycobacterium bovis BCG                                         | 715                                                                                                         | 
| Mycobacterium gilvum                                            | 716717718719                                                                                                | 
| Mycobacterium tuberculosis                                      | 723                                                                                                         | 
| Neisseria lactamica                                             | 724725                                                                                                      | 
| Mycobacterium tuberculosis                                      | 726                                                                                                         | 
| Mycobacterium ulcerans                                          | 727                                                                                                         | 
| Mycobacterium vanbaalenii                                       | 728                                                                                                         | 
| Neisseria meningitidis                                          | 729                                                                                                         | 
| Candidatus Sulcia muelleri                                      | 730                                                                                                         | 
| Rhizobium sp.                                                   | 1514,1620,1621                                                                                              | 
| Ochrobactrum anthropi                                           | 7.3573673773874E+017                                                                                        | 
| Helicobacter pylori                                             | 741                                                                                                         | 
| Campylobacter fetus                                             | 742                                                                                                         | 
| Campylobacter hominis                                           | 743744                                                                                                      | 
| Stenotrophomonas maltophilia                                    | 745                                                                                                         | 
| Alkaliphilus oremlandii                                         | 747                                                                                                         | 
| Clostridium beijerinckii                                        | 748                                                                                                         | 
| Clostridium difficile                                           | 752754                                                                                                      | 
| Clostridium botulinum A                                         | 753                                                                                                         | 
| Clostridium kluyveri                                            | 755756                                                                                                      | 
| Clostridium novyi                                               | 757                                                                                                         | 
| Clostridium perfringens                                         | 758759                                                                                                      | 
| Staphylococcus aureus subsp. aureus                             | 760761                                                                                                      | 
| Clostridium phytofermentans                                     | 762                                                                                                         | 
| Listeria monocytogenes                                          | 763                                                                                                         | 
| Clostridium thermocellum                                        | 764                                                                                                         | 
| Ralstonia solanacearum                                          | 767                                                                                                         | 
| Marinobacter aquaeolei                                          | 772773774                                                                                                   | 
| Nostoc punctiforme                                              | 7.81782783784786E+017                                                                                       | 
| Agrobacterium vitis                                             | 7.86787788789791E+020                                                                                       | 
| Agrobacterium radiobacter                                       | 801793794795796                                                                                             | 
| Microcystis aeruginosa                                          | 800                                                                                                         | 
| Alkaliphilus metalliredigens                                    | 802                                                                                                         | 
| Ralstonia solanacearum                                          | 1165,1254,1255                                                                                              | 
| Agrobacterium tumefaciens                                       | 805                                                                                                         | 
| Azospirillum brasilense                                         | 811,812,1545,1546,1547,1548,1549                                                                            | 
| Xenorhabdus doucetiae                                           | 1936,1937                                                                                                   | 
| Xenorhabdus bovienii                                            | 1902,1903,1904                                                                                              | 
| Helicobacter pylori                                             | 817818                                                                                                      | 
| Vibrio nigripulchritudo                                         | 1610,1611,1718,1719                                                                                         | 
| Helicobacter pylori                                             | 829830                                                                                                      | 
| Thermodesulfovibrio yellowstonii                                | 831                                                                                                         | 
| Alcanivorax borkumensis                                         | 832                                                                                                         | 
| Neisseria gonorrhoeae                                           | 833834                                                                                                      | 
| Salinispora arenicola                                           | 835                                                                                                         | 
| Salinispora tropica                                             | 836                                                                                                         | 
| Delftia acidovorans                                             | 841                                                                                                         | 
| Bordetella petrii                                               | 842                                                                                                         | 
| Xenorhabdus poinarii                                            | 1907                                                                                                        | 
| Desulfotomaculum hydrothermale                                  | 2590                                                                                                        | 
| Methylobacterium nodulans                                       | 9.94993992995997E+023                                                                                       | 
| Burkholderia vietnamiensis                                      | 8.62855856857859E+023                                                                                       | 
| Microcystis sp.                                                 | 2203                                                                                                        | 
| Microcystis aeruginosa                                          | 2198                                                                                                        | 
| Microcystis aeruginosa                                          | 2197                                                                                                        | 
| Microcystis aeruginosa                                          | 2196                                                                                                        | 
| Microcystis aeruginosa                                          | 2199                                                                                                        | 
| Microcystis aeruginosa                                          | 2200                                                                                                        | 
| Microcystis aeruginosa                                          | 2201                                                                                                        | 
| Desulfotomaculum reducens                                       | 874                                                                                                         | 
| Escherichia coli                                                | 876                                                                                                         | 
| Escherichia coli                                                | 877                                                                                                         | 
| Escherichia coli                                                | 878                                                                                                         | 
| Escherichia coli                                                | 879                                                                                                         | 
| Escherichia coli                                                | 880                                                                                                         | 
| Escherichia coli                                                | 881                                                                                                         | 
| Escherichia coli                                                | 8.82883884885887E+020                                                                                       | 
| Escherichia coli                                                | 889                                                                                                         | 
| Escherichia coli                                                | 890909                                                                                                      | 
| Escherichia coli                                                | 891892893                                                                                                   | 
| Escherichia coli                                                | 894895896                                                                                                   | 
| Escherichia coli                                                | 8.97898899900902E+020                                                                                       | 
| Escherichia coli                                                | 904905906907908                                                                                             | 
| Ralstonia solanacearum                                          | 1630,1675                                                                                                   | 
| Geodermatophilus obscurus                                       | 1258                                                                                                        | 
| Oligotropha carboxidovorans                                     | 972                                                                                                         | 
| Azospirillum brasilense                                         | 2128,2545,2546,2124,2125,2127                                                                               | 
| Candidatus Glomeribacter gigasporarum                           | 6766                                                                                                        | 
| Candidatus Koribacter versatilis                                | 977                                                                                                         | 
| Lactobacillus fermentum                                         | 1004                                                                                                        | 
| Lactobacillus plantarum                                         | 1005,1006,1007,1008                                                                                         | 
| Lactobacillus salivarius                                        | 1012,1009,1010,1011                                                                                         | 
| Pediococcus pentosaceus                                         | 1013                                                                                                        | 
| Bartonella grahamii                                             | 1014,1015                                                                                                   | 
| Polynucleobacter necessarius subsp. necessarius                 | 1035                                                                                                        | 
| Polynucleobacter necessarius subsp. asymbioticus                | 1036                                                                                                        | 
| Neisseria meningitidis                                          | 1037                                                                                                        | 
| Blood disease bacterium                                         | 2259,2260                                                                                                   | 
| Acidithiobacillus ferrooxidans                                  | 1041                                                                                                        | 
| Methylococcus capsulatus                                        | 1043                                                                                                        | 
| Methylocella silvestris                                         | 1044                                                                                                        | 
| Methylobacillus flagellatus                                     | 1045                                                                                                        | 
| Ralstonia pickettii                                             | 1059,1060,1061                                                                                              | 
| Comamonas testosteroni                                          | 1062                                                                                                        | 
| Escherichia coli                                                | 1063                                                                                                        | 
| Moorella thermoacetica                                          | 1070                                                                                                        | 
| Carboxydothermus hydrogenoformans                               | 1071                                                                                                        | 
| Magnetospirillum gryphiswaldense                                | 1078,1124                                                                                                   | 
| Pseudomonas putida                                              | 1082                                                                                                        | 
| Pseudomonas putida                                              | 1083                                                                                                        | 
| Gloeobacter violaceus                                           | 1084                                                                                                        | 
| Synechococcus sp.                                               | 1085                                                                                                        | 
| Synechococcus sp.                                               | 1086                                                                                                        | 
| Cyanothece sp.                                                  | 1087,1088,1089,1090                                                                                         | 
| Cyanothece sp.                                                  | 1091,1092,1093,1094,1095,1096,1097                                                                          | 
| Synechococcus sp.                                               | 1101,1102,1103,1104,1098,1099,1100                                                                          | 
| Cyanothece sp.                                                  | 1105,1106,1107,1108,1109                                                                                    | 
| Acaryochloris marina                                            | 1117,1118,1119,1110,1111,1112,1113,1114,1115,1116                                                           | 
| Streptomyces griseus subsp. griseus                             | 1123                                                                                                        | 
| Brucella abortus                                                | 1125,1126                                                                                                   | 
| Brucella abortus bv 1                                           | 1127,1128                                                                                                   | 
| Brucella canis                                                  | 1129,1130                                                                                                   | 
| Brucella melitensis                                             | 1131,1132                                                                                                   | 
| Lactobacillus casei                                             | 1137,1138                                                                                                   | 
| Lactobacillus casei                                             | 1139                                                                                                        | 
| Lactobacillus rhamnosus                                         | 1140                                                                                                        | 
| Lactobacillus rhamnosus                                         | 1141,1142                                                                                                   | 
| Lactobacillus rhamnosus                                         | 1143,1144,1152                                                                                              | 
| Brucella melitensis biovar Abortus                              | 1145,1146                                                                                                   | 
| Arthrobacter aurescens TC1                                      | 1147,1148,1149                                                                                              | 
| Brucella melitensis bv 1                                        | 1150,1151                                                                                                   | 
| Arthrobacter chlorophenolicus                                   | 1155,1153,1154                                                                                              | 
| Arthrobacter sp.                                                | 1156,1157,1158,1159                                                                                         | 
| Micrococcus luteus                                              | 1160                                                                                                        | 
| Pseudomonas sp.                                                 | 1170                                                                                                        | 
| Candidatus Sulcia muelleri                                      | 1171                                                                                                        | 
| Candidatus Hamiltonella defensa                                 | 1172,1173                                                                                                   | 
| Tetrasphaera australiensis                                      | 2552                                                                                                        | 
| Candidatus Hodgkinia cicadicola                                 | 1483                                                                                                        | 
| Tetrasphaera elongata                                           | 2093                                                                                                        | 
| Tetrasphaera japonica                                           | 1540                                                                                                        | 
| Propionibacterium acnes                                         | 1184                                                                                                        | 
| Tropheryma whipplei                                             | 1185                                                                                                        | 
| Nocardioides sp.                                                | 1187,1186                                                                                                   | 
| Thiomonas intermedia                                            | 2433,2434,2435                                                                                              | 
| Ralstonia syzygii                                               | 2230,2231                                                                                                   | 
| Desulfovibrio magneticus                                        | 1191,1192,1193                                                                                              | 
| Xylanimonas cellulosilytica                                     | 1194,1195                                                                                                   | 
| Escherichia albertii                                            | 1197                                                                                                        | 
| Janibacter                                                      | 1198                                                                                                        | 
| Methylibium petroleiphilum                                      | 1199,1200                                                                                                   | 
| Aeromicrobium marinum                                           | 1201                                                                                                        | 
| Kribbella flavida                                               | 1202                                                                                                        | 
| Propionibacterium sp. oral taxon 191                            | 1203                                                                                                        | 
| Pseudomonas fluorescens                                         | 1204                                                                                                        | 
| Pseudomonas aeruginosa                                          | 1205                                                                                                        | 
| Pseudomonas aeruginosa                                          | 1209                                                                                                        | 
| Pseudomonas fluorescens                                         | 1210,1211                                                                                                   | 
| Brucella microti                                                | 1212,1213                                                                                                   | 
| Leptothrix cholodnii                                            | 1214                                                                                                        | 
| Brucella ovis                                                   | 1215,1216                                                                                                   | 
| Brucella suis                                                   | 1217,1218                                                                                                   | 
| Brucella suis                                                   | 1219,1220                                                                                                   | 
| Yersinia pseudotuberculosis                                     | 1221,1222                                                                                                   | 
| Yersinia pestis                                                 | 1226,1223,1224,1225                                                                                         | 
| Yersinia pestis                                                 | 1227,1228,1229,1230                                                                                         | 
| Yersinia pestis                                                 | 1231                                                                                                        | 
| Yersinia pestis                                                 | 1232                                                                                                        | 
| Yersinia pestis                                                 | 1233                                                                                                        | 
| Yersinia pestis                                                 | 1234,1235,1236                                                                                              | 
| Yersinia pestis                                                 | 1237                                                                                                        | 
| Yersinia pestis                                                 | 1238                                                                                                        | 
| Yersinia pestis                                                 | 1239                                                                                                        | 
| Yersinia pestis                                                 | 1240                                                                                                        | 
| Yersinia pestis                                                 | 1241                                                                                                        | 
| Yersinia pestis                                                 | 1242,1243                                                                                                   | 
| Yersinia pestis                                                 | 1244                                                                                                        | 
| Rhodococcus erythropolis                                        | 1288,1289,1290,1291                                                                                         | 
| Rhodococcus opacus                                              | 1292                                                                                                        | 
| Rhodococcus jostii                                              | 1293,1294,1295,1296                                                                                         | 
| Azospirillum sp.                                                | 1306,1307,1308,1309,1303,1304,1305                                                                          | 
| Cyanobacterium sp.                                              | 1317                                                                                                        | 
| Variovorax paradoxus                                            | 1318,1319                                                                                                   | 
| Thiomicrospira crunogena                                        | 1327                                                                                                        | 
| Francisella novicida                                            | 1328                                                                                                        | 
| Francisella tularensis                                          | 1329                                                                                                        | 
| Francisella tularensis subsp. holarctica                        | 1330                                                                                                        | 
| Francisella tularensis subsp. tularensis                        | 1333                                                                                                        | 
| Francisella tularensis subsp. tularensis                        | 1335                                                                                                        | 
| Magnetite-containing magnetic vibrio                            | 1336                                                                                                        | 
| Francisella tularensis subsp. holarctica                        | 1337                                                                                                        | 
| Francisella philomiragia subsp. philomiragia                    | 1339,1338                                                                                                   | 
| Candidatus Accumulibacter phosphatis clade IIA                  | 1342,1343,1344,1345                                                                                         | 
| Blattabacterium sp. Blattella germanica Bge                     | 1351                                                                                                        | 
| Blattabacterium sp. Periplaneta americana                       | 1352,1353                                                                                                   | 
| Wolbachia sp.                                                   | 1354                                                                                                        | 
| Wolbachia endosymbiont of Culex quinquefasciatus Pel            | 1355                                                                                                        | 
| Sinorhizobium sp.                                               | 1358                                                                                                        | 
| Sinorhizobium sp.                                               | 1359                                                                                                        | 
| Sinorhizobium sp.                                               | 1360                                                                                                        | 
| Sinorhizobium sp.                                               | 1361                                                                                                        | 
| Sinorhizobium sp.                                               | 1362                                                                                                        | 
| Sinorhizobium sp.                                               | 1363                                                                                                        | 
| Sinorhizobium sp.                                               | 1364                                                                                                        | 
| Sinorhizobium sp.                                               | 1365                                                                                                        | 
| Sinorhizobium sp.                                               | 1366                                                                                                        | 
| Sinorhizobium sp.                                               | 1367                                                                                                        | 
| Sinorhizobium sp.                                               | 1368                                                                                                        | 
| Sinorhizobium sp.                                               | 1369                                                                                                        | 
| Sinorhizobium sp.                                               | 1370                                                                                                        | 
| Sinorhizobium sp.                                               | 1371                                                                                                        | 
| Sinorhizobium sp.                                               | 1372                                                                                                        | 
| Sinorhizobium sp.                                               | 1373                                                                                                        | 
| Sinorhizobium sp.                                               | 1374                                                                                                        | 
| Sinorhizobium sp.                                               | 1375                                                                                                        | 
| Sinorhizobium sp.                                               | 1376                                                                                                        | 
| Sinorhizobium sp.                                               | 1377                                                                                                        | 
| Sinorhizobium sp.                                               | 1378                                                                                                        | 
| Sinorhizobium sp.                                               | 1379                                                                                                        | 
| Sinorhizobium sp.                                               | 1380                                                                                                        | 
| Sinorhizobium sp.                                               | 1381                                                                                                        | 
| Sinorhizobium sp.                                               | 1382                                                                                                        | 
| Sinorhizobium sp.                                               | 1383                                                                                                        | 
| Sinorhizobium sp.                                               | 1384                                                                                                        | 
| Sinorhizobium sp.                                               | 1385                                                                                                        | 
| Sinorhizobium sp.                                               | 1386                                                                                                        | 
| Sinorhizobium sp.                                               | 1387                                                                                                        | 
| Sinorhizobium sp.                                               | 1388                                                                                                        | 
| Sinorhizobium sp.                                               | 1389                                                                                                        | 
| Sinorhizobium sp.                                               | 1390                                                                                                        | 
| Sinorhizobium sp.                                               | 1391                                                                                                        | 
| Sinorhizobium sp.                                               | 1392                                                                                                        | 
| Sinorhizobium sp.                                               | 1393                                                                                                        | 
| Sinorhizobium sp.                                               | 1394                                                                                                        | 
| Sinorhizobium sp.                                               | 1395                                                                                                        | 
| Sinorhizobium sp.                                               | 1396                                                                                                        | 
| Sinorhizobium sp.                                               | 1397                                                                                                        | 
| Sinorhizobium sp.                                               | 1398                                                                                                        | 
| Sinorhizobium sp.                                               | 1399                                                                                                        | 
| Sinorhizobium sp.                                               | 1400                                                                                                        | 
| Sinorhizobium sp.                                               | 1401                                                                                                        | 
| Sinorhizobium sp.                                               | 1402                                                                                                        | 
| Sinorhizobium sp.                                               | 1403                                                                                                        | 
| Escherichia coli                                                | 1404                                                                                                        | 
| Cyanobium gracile                                               | 3513                                                                                                        | 
| Lactobacillus acidophilus                                       | 1410                                                                                                        | 
| Lactobacillus delbrueckii subsp. bulgaricus                     | 1411                                                                                                        | 
| Lactobacillus delbrueckii subsp. bulgaricus                     | 1412                                                                                                        | 
| Lactococcus lactis subsp. cremoris                              | 1413                                                                                                        | 
| Lactococcus lactis subsp. cremoris                              | 1415,1416,1417,1418,1419,1414                                                                               | 
| Bifidobacterium animalis subsp. lactis                          | 1420                                                                                                        | 
| Bifidobacterium animalis subsp. lactis                          | 1421                                                                                                        | 
| Bifidobacterium animalis subsp. lactis                          | 1422                                                                                                        | 
| Bifidobacterium longum                                          | 1423,1424                                                                                                   | 
| Lactococcus lactis subsp. lactis                                | 1425,1426                                                                                                   | 
| Bifidobacterium animalis subsp. lactis                          | 1427                                                                                                        | 
| Bifidobacterium bifidum                                         | 1428                                                                                                        | 
| Bifidobacterium breve                                           | 1429                                                                                                        | 
| Escherichia coli                                                | 1433,1434,1435,1432                                                                                         | 
| Escherichia coli                                                | 1436,1437                                                                                                   | 
| Escherichia coli                                                | 1438,1439,1440,1441,1442,1443                                                                               | 
| Acidaminococcus fermentans                                      | 1448                                                                                                        | 
| Lactobacillus plantarum                                         | 1449                                                                                                        | 
| Lactobacillus johnsonii                                         | 1450,1451,1452                                                                                              | 
| Lactobacillus johnsonii                                         | 1453                                                                                                        | 
| Thermus thermophilus                                            | 1454,1455,1456                                                                                              | 
| Burkholderia sp.                                                | 1476,1477,1478,1479                                                                                         | 
| Listeria monocytogenes                                          | 1480                                                                                                        | 
| Clostridium difficile                                           | 1481                                                                                                        | 
| Clostridium difficile                                           | 1482                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 1484                                                                                                        | 
| Lactobacillus paracasei subsp. paracasei                        | 1485                                                                                                        | 
| Methylosinus trichosporium                                      | 5870                                                                                                        | 
| Rhodospirillum centenum                                         | 1505                                                                                                        | 
| Desulfovibrio vulgaris                                          | 1507,1508                                                                                                   | 
| Desulfovibrio vulgaris                                          | 1509,1510                                                                                                   | 
| Desulfovibrio desulfuricans subsp. desulfuricans                | 1513                                                                                                        | 
| Ralstonia solanacearum                                          | 2364,2363                                                                                                   | 
| Dehalococcoides sp.                                             | 1519                                                                                                        | 
| Dehalococcoides sp.                                             | 1521                                                                                                        | 
| Dehalococcoides sp.                                             | 1522                                                                                                        | 
| Dehalococcoides ethenogenes                                     | 1523                                                                                                        | 
| Microcystis aeruginosa                                          | 2204                                                                                                        | 
| Tetrasphaera jenkinsii                                          | 1541                                                                                                        | 
| Jonesia denitrificans                                           | 1542                                                                                                        | 
| Sanguibacter keddieii                                           | 1544                                                                                                        | 
| Beutenbergia cavernae                                           | 1550                                                                                                        | 
| Clostridium ljungdahlii                                         | 1551                                                                                                        | 
| Sinorhizobium medicae                                           | 1552,1553,1554,1555                                                                                         | 
| Acinetobacter sp.                                               | 1561                                                                                                        | 
| Acinetobacter baumannii                                         | 1562,1563                                                                                                   | 
| Acinetobacter baumannii                                         | 1564                                                                                                        | 
| Acinetobacter baumannii                                         | 1565,1566,1567                                                                                              | 
| Acinetobacter baumannii                                         | 1571                                                                                                        | 
| Acinetobacter baumannii                                         | 1572                                                                                                        | 
| Acinetobacter baumannii                                         | 1573                                                                                                        | 
| Acinetobacter baumannii                                         | 1574                                                                                                        | 
| Acinetobacter baumannii                                         | 1575                                                                                                        | 
| Acinetobacter calcoaceticus                                     | 1576                                                                                                        | 
| Acinetobacter haemolyticus                                      | 1577                                                                                                        | 
| Acinetobacter johnsonii                                         | 1578                                                                                                        | 
| Acinetobacter junii                                             | 1579                                                                                                        | 
| Acinetobacter lwoffii                                           | 1580                                                                                                        | 
| Acinetobacter radioresistens                                    | 1581                                                                                                        | 
| Acinetobacter radioresistens                                    | 1582                                                                                                        | 
| Acinetobacter baumannii                                         | 1583                                                                                                        | 
| Acinetobacter baumannii                                         | 1584                                                                                                        | 
| Cyanothece sp.                                                  | 1585,1586,1587,1588                                                                                         | 
| Acinetobacter baumannii                                         | 1589                                                                                                        | 
| Acinetobacter sp.                                               | 1590                                                                                                        | 
| Acinetobacter sp.                                               | 1591                                                                                                        | 
| Acinetobacter sp.                                               | 1592                                                                                                        | 
| Cyanothece sp.                                                  | 2912,2913,2914,2915,2916,2917,2918                                                                          | 
| Clostridium cellulolyticum                                      | 1599                                                                                                        | 
| Gallionella capsiferriformans                                   | 1607                                                                                                        | 
| Xanthomonas campestris pv                                       | 1614                                                                                                        | 
| Mycoplasma hominis                                              | 1624                                                                                                        | 
| Mesorhizobium sp.                                               | 1632,1633                                                                                                   | 
| Mesorhizobium metallidurans                                     | 1634,1635                                                                                                   | 
| Rhizobium mesoamericanum                                        | 1639,1640,1641,1642,2301,1636,1637                                                                          | 
| Rhizobium leguminosarum bv trifolii                             | 1648,1649,1650,1651,1652,1653                                                                               | 
| Rhizobium leguminosarum bv trifolii                             | 1654,1655,1656,1657,1658                                                                                    | 
| Clostridium cellulovorans                                       | 1662                                                                                                        | 
| Clostridium saccharolyticum                                     | 1663                                                                                                        | 
| Amycolatopsis mediterranei                                      | 1664                                                                                                        | 
| Corynebacterium diphtheriae                                     | 1677                                                                                                        | 
| Gordonia bronchialis                                            | 1678,1679                                                                                                   | 
| Segniliparus rotundus                                           | 1680                                                                                                        | 
| Tsukamurella paurometabola                                      | 1681,1682                                                                                                   | 
| Methyloversatilis universalis                                   | 3944                                                                                                        | 
| Methylomonas methanica                                          | 4045                                                                                                        | 
| Candidatus Zinderia insecticola                                 | 1717                                                                                                        | 
| Candidatus Sulcia muelleri                                      | 1698                                                                                                        | 
| Cenarchaeum symbiosum                                           | 1703                                                                                                        | 
| Syntrophus aciditrophicus SB                                    | 1704                                                                                                        | 
| Syntrophomonas wolfei subsp. wolfei                             | 1705                                                                                                        | 
| Klebsiella pneumoniae                                           | 1706,1707,1708                                                                                              | 
| Klebsiella pneumoniae subsp. pneumoniae                         | 1709,1710,1711,1712,1713,1714                                                                               | 
| Klebsiella pneumoniae                                           | 1715,1716                                                                                                   | 
| Nitrososphaera viennensis                                       | 2920                                                                                                        | 
| Escherichia coli                                                | 1725,1726,1727,1728,1724                                                                                    | 
| Escherichia coli                                                | 1729,1730                                                                                                   | 
| Shewanella piezotolerans                                        | 1731                                                                                                        | 
| Desulfovibrio salexigens                                        | 1732                                                                                                        | 
| Desulfovibrio vulgaris                                          | 1733                                                                                                        | 
| Desulfovibrio aespoeensis                                       | 6968                                                                                                        | 
| Desulfovibrio desulfuricans subsp. desulfuricans                | 1735                                                                                                        | 
| Desulfovibrio piger                                             | 1736                                                                                                        | 
| Desulfovibrio sp.                                               | 1737,7100                                                                                                   | 
| Desulfovibrio fructosovorans                                    | 1738                                                                                                        | 
| Desulfovibrio sp.                                               | 1739                                                                                                        | 
| Shewanella violacea                                             | 1740                                                                                                        | 
| Opitutus terrae                                                 | 1746                                                                                                        | 
| Vibrio mimicus                                                  | 1747                                                                                                        | 
| Halomonas elongata                                              | 1860                                                                                                        | 
| Helicobacter pylori                                             | 1861,1862,2966                                                                                              | 
| Helicobacter pylori                                             | 1863,1864                                                                                                   | 
| Helicobacter pylori                                             | 1865                                                                                                        | 
| Aminobacterium colombiense                                      | 1866                                                                                                        | 
| Thermanaerovibrio acidaminovorans                               | 1867                                                                                                        | 
| Bacteroides fragilis                                            | 1869,1870                                                                                                   | 
| Bacteroides fragilis                                            | 1872,1871                                                                                                   | 
| Bacteroides thetaiotaomicron                                    | 1873,1874                                                                                                   | 
| Bacteroides vulgatus                                            | 1875                                                                                                        | 
| Bacteroides helcogenes                                          | 1876                                                                                                        | 
| Zunongwangia profunda                                           | 1877                                                                                                        | 
| Gramella forsetii                                               | 1878                                                                                                        | 
| Croceibacter atlanticus                                         | 1879                                                                                                        | 
| Flavobacterium johnsoniae                                       | 1880                                                                                                        | 
| Flavobacteriaceae bacterium                                     | 1882                                                                                                        | 
| Candidatus Nitrosotenuis uzonensis                              | 1883                                                                                                        | 
| Escherichia coli                                                | 1884                                                                                                        | 
| Escherichia coli                                                | 1885                                                                                                        | 
| Escherichia coli                                                | 1886                                                                                                        | 
| Escherichia coli                                                | 1887                                                                                                        | 
| Escherichia coli                                                | 1888                                                                                                        | 
| Escherichia coli                                                | 1889,1890                                                                                                   | 
| Escherichia coli                                                | 1891,1892                                                                                                   | 
| Escherichia coli                                                | 1893,1894                                                                                                   | 
| Escherichia coli                                                | 1895,1896                                                                                                   | 
| Burkholderia rhizoxinica                                        | 1905,1906,7188                                                                                              | 
| Aliivibrio salmonicida                                          | 1914,1915,1910,1911,1912,1913                                                                               | 
| Vibrio cholerae                                                 | 1916,1917                                                                                                   | 
| Vibrio cholerae                                                 | 1918,1919                                                                                                   | 
| Vibrio cholerae                                                 | 1920,1921                                                                                                   | 
| Vibrio fischeri                                                 | 1922,1923,1924                                                                                              | 
| Vibrio furnissii                                                | 1925,1926                                                                                                   | 
| Vibrio sp.                                                      | 1927,1928                                                                                                   | 
| Vibrio vulnificus                                               | 1930,1929                                                                                                   | 
| Sinorhizobium sp.                                               | 1941                                                                                                        | 
| Sinorhizobium sp.                                               | 1942                                                                                                        | 
| Agrobacterium sp.                                               | 1943,1944,1945                                                                                              | 
| Xenorhabdus nematophila                                         | 2627                                                                                                        | 
| Arthrospira platensis                                           | 1947                                                                                                        | 
| Archaeoglobus profundus                                         | 1948,1949                                                                                                   | 
| Micromonospora sp.                                              | 1952                                                                                                        | 
| Clostridium difficile MID11                                     | 2122                                                                                                        | 
| Caulobacter crescentus                                          | 1976                                                                                                        | 
| Chlamydia muridarum                                             | 1978                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhi               | 1980                                                                                                        | 
| Chlamydia muridarum Nigg                                        | 1981,1982                                                                                                   | 
| Chlamydia muridarum                                             | 1983                                                                                                        | 
| Chlamydia trachomatis                                           | 1984                                                                                                        | 
| Chlamydia trachomatis                                           | 1985                                                                                                        | 
| Chlamydia trachomatis A HAR-13                                  | 1986,1987                                                                                                   | 
| Chlamydophila abortus                                           | 1988                                                                                                        | 
| Chlamydophila caviae GPIC                                       | 1989,1990                                                                                                   | 
| Chlamydophila felis                                             | 1991,1992                                                                                                   | 
| Chlamydophila pneumoniae                                        | 1993                                                                                                        | 
| Chlamydophila pneumoniae                                        | 1994                                                                                                        | 
| Chlamydophila pneumoniae                                        | 1995                                                                                                        | 
| Candidatus Protochlamydia amoebophila                           | 1996                                                                                                        | 
| Waddlia chondrophila                                            | 1997,1998                                                                                                   | 
| Parachlamydia acanthamoebae                                     | 1999                                                                                                        | 
| Parachlamydia acanthamoebae                                     | 2000                                                                                                        | 
| Simkania negevensis                                             | 2001,2002                                                                                                   | 
| Candidatus Amoebophilus asiaticus                               | 2012                                                                                                        | 
| Candidatus Azobacteroides pseudotrichonymphae genomovar CFP2    | 2013,2014,2015,2016,2017                                                                                    | 
| Candidatus Sulcia muelleri                                      | 2018                                                                                                        | 
| Candidatus Sulcia muelleri                                      | 2019                                                                                                        | 
| Candidatus Microthrix parvicella                                | 2605                                                                                                        | 
| Methanosaeta concilii                                           | 2049,2048                                                                                                   | 
| Brachybacterium faecium                                         | 2051                                                                                                        | 
| Chitinophaga pinensis                                           | 2052                                                                                                        | 
| Pedobacter heparinus                                            | 2053                                                                                                        | 
| Dyadobacter fermentans                                          | 2054                                                                                                        | 
| Kytococcus sedentarius                                          | 2055                                                                                                        | 
| Spirosoma linguale                                              | 2056,2057,2058,2059,2060,2061,2062,2063,2064                                                                | 
| Escherichia coli                                                | 2065                                                                                                        | 
| Escherichia coli                                                | 2076,2077,2078,2079                                                                                         | 
| Roseobacter denitrificans                                       | 2067,2068,2069,2070,2071                                                                                    | 
| Neisseria cinerea                                               | 2072                                                                                                        | 
| Stigmatella aurantiaca                                          | 2073                                                                                                        | 
| Conexibacter woesei                                             | 2074                                                                                                        | 
| Capnocytophaga ochracea                                         | 2075                                                                                                        | 
| Pirellula staleyi                                               | 2080                                                                                                        | 
| Haloterrigena turkmenica                                        | 2083,2084,2085,2086,2087,2081,2082                                                                          | 
| Candidatus Nitrosoarchaeum limnia                               | 4671                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhimurium         | 2098,2099,2100,2101                                                                                         | 
| Methylacidiphilum fumariolicum                                  | 5365                                                                                                        | 
| Xenorhabdus szentirmaii                                         | 2115                                                                                                        | 
| Xenorhabdus cabanillasii                                        | 2134                                                                                                        | 
| Methylacidiphilum infernorum                                    | 2148                                                                                                        | 
| Mesorhizobium opportunistum                                     | 2154                                                                                                        | 
| Mesorhizobium ciceri biovar biserrulae                          | 2155,2156                                                                                                   | 
| Chelativorans sp.                                               | 2157,2158,2159,2160                                                                                         | 
| Nitrosospira multiformis                                        | 2162,2163,2164,2165                                                                                         | 
| Nitrosomonas sp.                                                | 2166,2167,2168                                                                                              | 
| Nitrosomonas sp.                                                | 2169                                                                                                        | 
| Nitrosococcus oceani                                            | 2178                                                                                                        | 
| Nitrosococcus oceani                                            | 2171,2172                                                                                                   | 
| Nitrosococcus watsonii                                          | 2173,2174,2175                                                                                              | 
| Nitrosococcus halophilus                                        | 2176,2177                                                                                                   | 
| Nitrosopumilus maritimus                                        | 2179                                                                                                        | 
| Nitrosopumilus sp.                                              | 2206                                                                                                        | 
| Agrobacterium tumefaciens                                       | 2208                                                                                                        | 
| Xanthomonas oryzae pv oryzae                                    | 2213                                                                                                        | 
| Xanthomonas oryzae pv oryzae                                    | 2214                                                                                                        | 
| Xanthomonas oryzae pv oryzae                                    | 2215                                                                                                        | 
| Xanthomonas axonopodis pv citrumelo                             | 2216                                                                                                        | 
| Xanthomonas oryzae pv. oryzicola                                | 2217                                                                                                        | 
| Xanthomonas campestris pv vesicatoria                           | 2218,2219,2220,2221,2222                                                                                    | 
| Xanthomonas fuscans subsp. aurantifolii                         | 2223                                                                                                        | 
| Xanthomonas axonopodis pv citri                                 | 2225,2226,2227                                                                                              | 
| Ralstonia solanacearum                                          | 2234,2235                                                                                                   | 
| Ralstonia solanacearum                                          | 2236,2237                                                                                                   | 
| Streptosporangium roseum                                        | 2244,2245                                                                                                   | 
| Catenulispora acidiphila                                        | 2247                                                                                                        | 
| Magnetospirillum gryphiswaldense                                | 2298                                                                                                        | 
| Verrucosispora maris                                            | 2250,2251                                                                                                   | 
| Deinococcus deserti                                             | 2262,2263,2264,2265                                                                                         | 
| Azospirillum amazonense                                         | 2261                                                                                                        | 
| Desulfobacterium autotrophicum                                  | 2290,2291                                                                                                   | 
| Desulfurivibrio alkaliphilus                                    | 2292                                                                                                        | 
| Thioalkalivibrio sulfidophilus                                  | 2293                                                                                                        | 
| Allochromatium vinosum                                          | 2295,2296,2297                                                                                              | 
| Nitrobacter sp.                                                 | 2300                                                                                                        | 
| Nitrosotalea devanaterra                                        | 5376                                                                                                        | 
| Delta proteobacterium                                           | 2327                                                                                                        | 
| Clostridium difficile MID12                                     | 2341                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 2348                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 2349,2350                                                                                                   | 
| Staphylococcus aureus subsp. aureus                             | 2351                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 2352,2353,2354                                                                                              | 
| Mesorhizobium australicum                                       | 2374                                                                                                        | 
| Mesorhizobium amorphae                                          | 2375                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3429,2653,2654                                                                                              | 
| Xanthomonas citri pv. citri                                     | 2380,2381,3430                                                                                              | 
| Arthrobacter phenanthrenivorans                                 | 2386,2387,2388                                                                                              | 
| Stenotrophomonas maltophilia                                    | 2389                                                                                                        | 
| Stenotrophomonas sp.                                            | 2391                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum                        | 2392,2393                                                                                                   | 
| Lactobacillus plantarum subsp. plantarum                        | 2394                                                                                                        | 
| Thermosediminibacter oceani                                     | 2395                                                                                                        | 
| Thermincola potens                                              | 2396                                                                                                        | 
| Klebsiella variicola                                            | 2398                                                                                                        | 
| Agrobacterium tumefaciens                                       | 2400                                                                                                        | 
| Cupriavidus necator                                             | 2402,2403,2404,2401                                                                                         | 
| Stenotrophomonas maltophilia                                    | 2390                                                                                                        | 
| Agrobacterium tumefaciens                                       | 2440                                                                                                        | 
| Tepidanaerobacter sp.                                           | 2441                                                                                                        | 
| Desulfosporosinus orientis                                      | 2504                                                                                                        | 
| Syntrophobacter fumaroxidans                                    | 2443                                                                                                        | 
| Pelotomaculum thermopropionicum                                 | 2444                                                                                                        | 
| Dehalogenimonas lykanthroporepellens                            | 2445                                                                                                        | 
| Ignicoccus hospitalis                                           | 2446                                                                                                        | 
| Thermomicrobium roseum                                          | 2447,2448                                                                                                   | 
| Thermoanaerobacter sp.                                          | 2449                                                                                                        | 
| Chloroflexus aurantiacus                                        | 2450                                                                                                        | 
| Candidatus Pelagibacter ubique                                  | 2451                                                                                                        | 
| Mycobacterium canettii                                          | 2453                                                                                                        | 
| Candidatus Korarchaeum cryptofilum OPF8                         | 2454                                                                                                        | 
| Aquifex aeolicus                                                | 2455,2456                                                                                                   | 
| Salinibacter ruber DSM 13855                                    | 2457,2458                                                                                                   | 
| Prochlorococcus marinus subsp. marinus CCMP1375                 | 2459                                                                                                        | 
| Deinococcus radiodurans                                         | 2460,2461,2462,2463                                                                                         | 
| Dictyoglomus turgidum                                           | 2464                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 2465                                                                                                        | 
| Mycoplasma mycoides subsp. mycoides SC                          | 2466                                                                                                        | 
| Mesoplasma florum L1                                            | 2488                                                                                                        | 
| Xanthomonas campestris pv campestris                            | 2489                                                                                                        | 
| Clostridium botulinum A                                         | 2492,2493                                                                                                   | 
| Leptospira interrogans serovar Manilae                          | 5570                                                                                                        | 
| Enterococcus faecalis                                           | 2499,2500,2501,2502                                                                                         | 
| Lactobacillus helveticus                                        | 2505                                                                                                        | 
| Lactobacillus helveticus                                        | 2506                                                                                                        | 
| Lactobacillus helveticus                                        | 2507                                                                                                        | 
| Thermosipho africanus                                           | 2516                                                                                                        | 
| Thermosipho melanesiensis                                       | 2517                                                                                                        | 
| Fervidobacterium nodosum                                        | 2518                                                                                                        | 
| Fervidobacterium pennivorans                                    | 2519                                                                                                        | 
| Thermotoga thermarum                                            | 2520                                                                                                        | 
| Thermotoga naphthophila                                         | 2521                                                                                                        | 
| Thermotoga petrophila                                           | 2522                                                                                                        | 
| Thermotoga lettingae                                            | 2523                                                                                                        | 
| Thermotoga neapolitana                                          | 2524                                                                                                        | 
| Thermotoga sp.                                                  | 2525                                                                                                        | 
| Kosmotoga olearia                                               | 2526                                                                                                        | 
| Marinitoga piezophila                                           | 2527,2528                                                                                                   | 
| Petrotoga mobilis                                               | 2529                                                                                                        | 
| Lactobacillus rhamnosus                                         | 2539                                                                                                        | 
| Lactobacillus rhamnosus                                         | 2540                                                                                                        | 
| Lactobacillus rhamnosus                                         | 2541                                                                                                        | 
| Lactobacillus rhamnosus                                         | 2542                                                                                                        | 
| Lactobacillus rhamnosus                                         | 2543                                                                                                        | 
| Desulfosporosinus youngiae                                      | 2551                                                                                                        | 
| Desulfitobacterium hafniense                                    | 3786                                                                                                        | 
| Desulfitobacterium hafniense                                    | 3791                                                                                                        | 
| Desulfosporosinus sp.                                           | 2556                                                                                                        | 
| Burkholderia phytofirmans                                       | 2564,2565,2563                                                                                              | 
| Burkholderia gladioli                                           | 2566,2567,2568,2569,2570,2571                                                                               | 
| Burkholderia ambifaria                                          | 2576,2577,2578,2579                                                                                         | 
| Thermococcus barophilus                                         | 2583,2582                                                                                                   | 
| Thermococcus sp.                                                | 2584                                                                                                        | 
| Thermococcus gammatolerans EJ3                                  | 2585                                                                                                        | 
| Thermococcus onnurineus                                         | 2586                                                                                                        | 
| Thermococcus sibiricus                                          | 2587                                                                                                        | 
| Thermococcus sp.                                                | 2588                                                                                                        | 
| Thermococcus litoralis                                          | 2589                                                                                                        | 
| Listeria monocytogenes                                          | 2596                                                                                                        | 
| Listeria monocytogenes                                          | 2597                                                                                                        | 
| Listeria monocytogenes                                          | 2598                                                                                                        | 
| Listeria monocytogenes                                          | 2599                                                                                                        | 
| Listeria monocytogenes                                          | 2600                                                                                                        | 
| Listeria monocytogenes                                          | 2601                                                                                                        | 
| Listeria seeligeri serovar 1/2b                                 | 2602                                                                                                        | 
| Listeria innocua                                                | 2603,2604                                                                                                   | 
| Listeria welshimeri serovar 6b                                  | 2607                                                                                                        | 
| Listeria ivanovii                                               | 2608                                                                                                        | 
| Listeria marthii                                                | 2609                                                                                                        | 
| Listeria monocytogenes                                          | 2610                                                                                                        | 
| Listeria monocytogenes                                          | 2611                                                                                                        | 
| Listeria monocytogenes                                          | 2612                                                                                                        | 
| Listeria monocytogenes                                          | 2613                                                                                                        | 
| Listeria monocytogenes                                          | 2615                                                                                                        | 
| Listeria monocytogenes                                          | 2616                                                                                                        | 
| Listeria monocytogenes                                          | 2617                                                                                                        | 
| Listeria monocytogenes                                          | 2618                                                                                                        | 
| Listeria monocytogenes                                          | 2619                                                                                                        | 
| Listeria monocytogenes                                          | 2620                                                                                                        | 
| Listeria monocytogenes                                          | 2621                                                                                                        | 
| Listeria grayi                                                  | 2622                                                                                                        | 
| Listeria monocytogenes                                          | 2623                                                                                                        | 
| Listeria monocytogenes                                          | 2624                                                                                                        | 
| Listeria monocytogenes serotype 1-2a                            | 2625                                                                                                        | 
| Listeria monocytogenes serotype 4b                              | 2626                                                                                                        | 
| Bradyrhizobium sp.                                              | 2655                                                                                                        | 
| Klebsiella oxytoca                                              | 2659                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Agona               | 2663,2664                                                                                                   | 
| Salmonella enterica subsp. enterica serovar Paratyphi           | 2665                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Enteritidis         | 2666                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Heidelberg          | 2667,2668,2669                                                                                              | 
| Salmonella enterica subsp. enterica serovar Paratyphi C         | 2670,2671                                                                                                   | 
| Salmonella enterica subsp. enterica serovar Schwarzengrund      | 2673,2674,2675                                                                                              | 
| Salmonella enterica subsp. arizonae serovar 62:z4,z23:--        | 2676                                                                                                        | 
| Salmonella bongori                                              | 2677                                                                                                        | 
| Candidatus Saccharimonas aalborgensis                           | 2689                                                                                                        | 
| TM7.2                                                           | 2690                                                                                                        | 
| TM7.3                                                           | 2691                                                                                                        | 
| TM7.4                                                           | 2692                                                                                                        | 
| Candidatus Competibacter denitrificans                          | 2693,2694                                                                                                   | 
| Candidatus Contendobacter odensis                               | 2695                                                                                                        | 
| Candidatus Hamiltonella defensa                                 | 2696                                                                                                        | 
| Cyanobium sp.                                                   | 2697                                                                                                        | 
| Synechococcus elongatus                                         | 2698,2699                                                                                                   | 
| Synechococcus sp.                                               | 2700                                                                                                        | 
| Synechococcus sp.                                               | 2702                                                                                                        | 
| Synechococcus sp.                                               | 2703                                                                                                        | 
| Synechococcus sp.                                               | 2704                                                                                                        | 
| Prochlorococcus marinus subsp. pastoris CCMP1986                | 2705                                                                                                        | 
| Lyngbya sp.                                                     | 2706                                                                                                        | 
| Prochlorococcus marinus                                         | 2710                                                                                                        | 
| Prochlorococcus marinus                                         | 2711                                                                                                        | 
| Prochlorococcus marinus                                         | 2712                                                                                                        | 
| Prochlorococcus marinus                                         | 2713                                                                                                        | 
| Prochlorococcus marinus                                         | 2714                                                                                                        | 
| Prochlorococcus marinus                                         | 2716                                                                                                        | 
| Prochlorococcus marinus                                         | 2717                                                                                                        | 
| Mycobacterium africanum                                         | 2718                                                                                                        | 
| Prochlorococcus marinus                                         | 2719                                                                                                        | 
| Prochlorococcus marinus                                         | 2720                                                                                                        | 
| Synechococcus sp.                                               | 2721                                                                                                        | 
| Synechococcus sp.                                               | 2722                                                                                                        | 
| Synechococcus sp.                                               | 2723                                                                                                        | 
| Synechococcus sp.                                               | 2724                                                                                                        | 
| Synechococcus sp.                                               | 2725                                                                                                        | 
| Synechococcus sp.                                               | 2726                                                                                                        | 
| Synechococcus sp.                                               | 2727                                                                                                        | 
| Synechococcus sp.                                               | 2728                                                                                                        | 
| Mycobacterium canettii                                          | 2729                                                                                                        | 
| Mycobacterium canettii                                          | 2731                                                                                                        | 
| Mycobacterium canettii                                          | 2732                                                                                                        | 
| Mycobacterium canettii                                          | 2733                                                                                                        | 
| Synechococcus sp.                                               | 2734                                                                                                        | 
| Rubrivivax gelatinosus                                          | 2737                                                                                                        | 
| Rubrivivax benzoatilyticus                                      | 2740                                                                                                        | 
| Thermobifida fusca                                              | 2750                                                                                                        | 
| Nocardiopsis dassonvillei subsp. dassonvillei                   | 2751,2752                                                                                                   | 
| Xenorhabdus bovienii                                            | 3523                                                                                                        | 
| Xenorhabdus bovienii                                            | 3524                                                                                                        | 
| Xenorhabdus bovienii                                            | 3525                                                                                                        | 
| Xenorhabdus bovienii                                            | 3526                                                                                                        | 
| Xenorhabdus bovienii                                            | 3535                                                                                                        | 
| Xenorhabdus bovienii                                            | 3527                                                                                                        | 
| Xenorhabdus bovienii                                            | 3528                                                                                                        | 
| Xenorhabdus bovienii                                            | 3529                                                                                                        | 
| Xenorhabdus bovienii                                            | 3531                                                                                                        | 
| Francisella tularensis subsp. holarctica                        | 2766                                                                                                        | 
| Caldicellulosiruptor saccharolyticus                            | 2771                                                                                                        | 
| Klebsiella pneumoniae                                           | 2779,2778                                                                                                   | 
| Klebsiella pneumoniae subsp. pneumoniae                         | 2780,2781,2782,2783,2784,2785,2786                                                                          | 
| Enterobacter cloacae                                            | 2787                                                                                                        | 
| Klebsiella pneumoniae                                           | 2788,4630                                                                                                   | 
| Klebsiella oxytoca                                              | 2789                                                                                                        | 
| Listeria monocytogenes                                          | 2802                                                                                                        | 
| Listeria monocytogenes                                          | 2803                                                                                                        | 
| Listeria monocytogenes                                          | 2804,2805                                                                                                   | 
| Listeria monocytogenes serotype                                 | 2806                                                                                                        | 
| Listeria monocytogenes                                          | 2807                                                                                                        | 
| Listeria monocytogenes                                          | 2808                                                                                                        | 
| Listeria monocytogenes                                          | 2809                                                                                                        | 
| Listeria innocua                                                | 2810                                                                                                        | 
| Listeria innocua                                                | 2811                                                                                                        | 
| Listeria innocua                                                | 2812                                                                                                        | 
| Listeria seeligeri                                              | 2813                                                                                                        | 
| Listeria seeligeri                                              | 2814                                                                                                        | 
| Mesotoga prima                                                  | 2850,2851                                                                                                   | 
| Candidatus Nitrososphaera gargensis                             | 2853                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 2873                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 2874                                                                                                        | 
| Staphylococcus aureus                                           | 2875                                                                                                        | 
| Mycobacterium chubuense                                         | 2877,2878,2876                                                                                              | 
| Mycobacterium rhodesiae                                         | 2879                                                                                                        | 
| Mycobacterium sp.                                               | 2880                                                                                                        | 
| Mycobacterium mageritense                                       | 2881                                                                                                        | 
| Mycobacterium sp.                                               | 2895                                                                                                        | 
| Mycobacterium gilvum                                            | 2896,2897,2898                                                                                              | 
| Mycobacterium abscessus subsp. bolletii                         | 2899                                                                                                        | 
| Clostridium phage phiC2                                         | 2900                                                                                                        | 
| Clostridium phage phiCD27                                       | 2901                                                                                                        | 
| Clostridium phage phiCD38-2                                     | 2902                                                                                                        | 
| Clostridium phage phiCD119                                      | 2903                                                                                                        | 
| Clostridium phage phiCD6356                                     | 2904                                                                                                        | 
| Chlorobium tepidum                                              | 2905                                                                                                        | 
| Micromonospora aurantiaca                                       | 2909                                                                                                        | 
| Mycobacterium phlei                                             | 2910                                                                                                        | 
| Mycobacterium thermoresistibile                                 | 2911                                                                                                        | 
| Kitasatospora setae                                             | 2936                                                                                                        | 
| Streptomyces scabiei                                            | 2937                                                                                                        | 
| Streptomyces bingchenggensis                                    | 2938                                                                                                        | 
| Streptomyces sp.                                                | 2939                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhimurium         | 2940,2941                                                                                                   | 
| Xanthomonas citri pv. citri                                     | 3419                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3428                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3413                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3420                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3779                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3398                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3400                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3401                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3405                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3414                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3417                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3396                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3397                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3402                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3403                                                                                                        | 
| Xanthomonas citri pv. citri                                     | 3406                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 3011                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 3016,3017,3018,3019                                                                                         | 
| Staphylococcus aureus subsp. aureus                             | 3020,3021,3022                                                                                              | 
| Staphylococcus aureus subsp. aureus                             | 3023,3024                                                                                                   | 
| Staphylococcus aureus subsp. aureus                             | 3027,3028,3029,3030                                                                                         | 
| Staphylococcus aureus subsp. aureus                             | 3036                                                                                                        | 
| Desulfovibrio magneticus                                        | 3177                                                                                                        | 
| Rhizobium sp.                                                   | 3473,3475,3916                                                                                              | 
| Acidithiobacillus ferrivorans                                   | 3201                                                                                                        | 
| Acidithiobacillus caldus                                        | 3202,3203,3204,3205,3206                                                                                    | 
| Acidithiobacillus thiooxidans                                   | 3207                                                                                                        | 
| Acidithiobacillus caldus                                        | 3208                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 3209                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 3210,3211                                                                                                   | 
| Bacillus amyloliquefaciens                                      | 3212                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 3213                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 3214                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum                     | 3215                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum                     | 3216                                                                                                        | 
| Clostridium difficile MID13                                     | 3220                                                                                                        | 
| Listeria monocytogenes                                          | 3221,3222                                                                                                   | 
| Listeria monocytogenes                                          | 3223,3224                                                                                                   | 
| Listeria monocytogenes                                          | 3225                                                                                                        | 
| Listeria monocytogenes                                          | 3226                                                                                                        | 
| Listeria monocytogenes                                          | 3227                                                                                                        | 
| Listeria monocytogenes                                          | 3228                                                                                                        | 
| Listeria monocytogenes                                          | 3229                                                                                                        | 
| Listeria monocytogenes                                          | 3230                                                                                                        | 
| Listeria monocytogenes                                          | 3231                                                                                                        | 
| Listeria monocytogenes serotype 7                               | 3232,3233                                                                                                   | 
| Bacillus sp.                                                    | 3240                                                                                                        | 
| Bacillus sp.                                                    | 3241                                                                                                        | 
| Clostridium acidurici                                           | 3243,3244                                                                                                   | 
| Listeria monocytogenes                                          | 3245                                                                                                        | 
| Streptomyces hygroscopicus subsp. jinggangensis                 | 3247,3248,3249                                                                                              | 
| Roseovarius nubinhibens                                         | 3250                                                                                                        | 
| Streptococcus sanguinis                                         | 3252                                                                                                        | 
| Anabaena sp.                                                    | 3273,3274,3275,3276,3277                                                                                    | 
| Leptospira borgpetersenii                                       | 3278                                                                                                        | 
| Leptospira licerasiae serovar Varillal                          | 3279                                                                                                        | 
| Listeria monocytogenes serotype 4b                              | 3284                                                                                                        | 
| Acidithiobacillus ferrooxidans                                  | 3338                                                                                                        | 
| Halomonas sp.                                                   | 3339                                                                                                        | 
| Halomonas sp.                                                   | 3340                                                                                                        | 
| Halomonas sp.                                                   | 3341                                                                                                        | 
| Staphylococcus haemolyticus                                     | 3342,3343,3344,3345                                                                                         | 
| Staphylococcus saprophyticus subsp. saprophyticus               | 3346,3347,3348                                                                                              | 
| Staphylococcus epidermidis                                      | 3349,3350                                                                                                   | 
| Staphylococcus capitis                                          | 3351                                                                                                        | 
| Staphylococcus capitis                                          | 3352                                                                                                        | 
| Staphylococcus epidermidis                                      | 3355,3356,3357,3358,3359,3353,3354                                                                          | 
| Staphylococcus lugdunensis                                      | 3360                                                                                                        | 
| Staphylococcus lugdunensis                                      | 3361                                                                                                        | 
| Staphylococcus carnosus subsp. carnosus                         | 3363                                                                                                        | 
| Staphylococcus pseudintermedius                                 | 3364                                                                                                        | 
| Staphylococcus aureus                                           | 3365                                                                                                        | 
| Burkholderia glumae                                             | 3382,3383,3384,3385,3386,3387                                                                               | 
| Burkholderia sp.                                                | 3388,3389                                                                                                   | 
| Burkholderia phenoliruptrix                                     | 3390,3391,3392                                                                                              | 
| Halomonas sp.                                                   | 3393,3394                                                                                                   | 
| Actinobacillus pleuropneumoniae serovar 3                       | 3426                                                                                                        | 
| Actinobacillus pleuropneumoniae serovar 5b                      | 3427                                                                                                        | 
| Xanthomonas citri pv. bilvae                                    | 3438                                                                                                        | 
| Actinobacillus suis                                             | 3439                                                                                                        | 
| Bordetella bronchiseptica                                       | 3440                                                                                                        | 
| Bordetella bronchiseptica                                       | 3441                                                                                                        | 
| Haemophilus parasuis                                            | 3442                                                                                                        | 
| Mycoplasma hyopneumoniae                                        | 3455                                                                                                        | 
| Mycoplasma hyorhinis                                            | 3456                                                                                                        | 
| Mycoplasma hyorhinis                                            | 3457                                                                                                        | 
| Streptococcus agalactiae                                        | 3458                                                                                                        | 
| Pasteurella multocida subsp. multocida                          | 3461                                                                                                        | 
| Pasteurella multocida subsp. multocida                          | 3462,3463                                                                                                   | 
| Streptococcus suis                                              | 3464                                                                                                        | 
| Streptococcus suis                                              | 3466                                                                                                        | 
| Streptococcus suis                                              | 3467                                                                                                        | 
| Streptococcus suis                                              | 3468                                                                                                        | 
| Methylophaga aminisulfidivorans                                 | 3469                                                                                                        | 
| Methylobacterium sp.                                            | 3470                                                                                                        | 
| Methylobacterium extorquens                                     | 3471                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3472                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3476                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3477                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3478                                                                                                        | 
| Nocardia brasiliensis ATCC 700358                               | 3483                                                                                                        | 
| Stenotrophomonas maltophilia                                    | 3504                                                                                                        | 
| Thermacetogenium phaeum                                         | 3522                                                                                                        | 
| Acetobacterium woodii                                           | 3530                                                                                                        | 
| Stenotrophomonas maltophilia                                    | 3536                                                                                                        | 
| Stenotrophomonas maltophilia                                    | 3537                                                                                                        | 
| Streptococcus sanguinis                                         | 3538                                                                                                        | 
| Streptococcus sanguinis                                         | 3539                                                                                                        | 
| Streptococcus sanguinis                                         | 3540                                                                                                        | 
| Streptococcus sanguinis                                         | 3541                                                                                                        | 
| Streptococcus sanguinis                                         | 3542                                                                                                        | 
| Streptococcus sanguinis                                         | 3543                                                                                                        | 
| Streptococcus sanguinis                                         | 3544                                                                                                        | 
| Streptococcus sanguinis                                         | 3545                                                                                                        | 
| Streptococcus sanguinis                                         | 3546                                                                                                        | 
| Streptococcus sanguinis                                         | 3547                                                                                                        | 
| Streptococcus sanguinis                                         | 3548                                                                                                        | 
| Streptococcus sanguinis                                         | 3549                                                                                                        | 
| Streptococcus sanguinis                                         | 3550                                                                                                        | 
| Streptococcus sanguinis                                         | 3551                                                                                                        | 
| Streptococcus sanguinis                                         | 3552                                                                                                        | 
| Streptococcus sanguinis                                         | 3553                                                                                                        | 
| Streptococcus sanguinis                                         | 3554                                                                                                        | 
| Streptococcus sanguinis                                         | 3555                                                                                                        | 
| Streptococcus sanguinis                                         | 3556                                                                                                        | 
| Streptococcus sanguinis                                         | 3557                                                                                                        | 
| Streptococcus sanguinis                                         | 3558                                                                                                        | 
| Leptospira santarosai serovar Shermani                          | 3559                                                                                                        | 
| Leptospira borgpetersenii serovar Mini                          | 3560                                                                                                        | 
| Listeria monocytogenes                                          | 3561                                                                                                        | 
| Halomonas boliviensis                                           | 3562                                                                                                        | 
| Halomonas sp.                                                   | 3563                                                                                                        | 
| Arthrospira platensis                                           | 3564                                                                                                        | 
| Methylocystis parvus                                            | 3565                                                                                                        | 
| Methylophaga thiooxydans                                        | 3566                                                                                                        | 
| Methylococcus capsulatus                                        | 3567                                                                                                        | 
| Methylobacterium sp.                                            | 3568                                                                                                        | 
| Methylobacterium sp.                                            | 3569                                                                                                        | 
| Methanobrevibacter sp.                                          | 3570                                                                                                        | 
| Cupriavidus sp.                                                 | 3573                                                                                                        | 
| Niastella koreensis                                             | 3637                                                                                                        | 
| Methylocystis sp.                                               | 3668                                                                                                        | 
| Beijerinckia indica subsp. indica                               | 3669,3670,3671                                                                                              | 
| Desulfomonile tiedjei                                           | 3673,3672                                                                                                   | 
| Stenotrophomonas maltophilia                                    | 3686                                                                                                        | 
| Stenotrophomonas maltophilia                                    | 3687                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3746                                                                                                        | 
| Escherichia coli                                                | 3749                                                                                                        | 
| Aeromonas hydrophila subsp. hydrophila                          | 3754                                                                                                        | 
| Aeromonas salmonicida subsp. salmonicida                        | 3755,3756,3757,3758,3759,3760                                                                               | 
| Aeromonas veronii                                               | 3762                                                                                                        | 
| Citrobacter koseri                                              | 3765,3763,3764                                                                                              | 
| Citrobacter rodentium                                           | 3766,3767,3768,3769                                                                                         | 
| Serratia plymuthica                                             | 3770                                                                                                        | 
| Serratia marcescens                                             | 3771                                                                                                        | 
| Serratia symbiotica                                             | 3772                                                                                                        | 
| Desulfovibrio africanus                                         | 3773                                                                                                        | 
| Desulfovibrio desulfuricans                                     | 3774                                                                                                        | 
| Desulfovibrio vulgaris                                          | 3775,3776                                                                                                   | 
| Anaeromyxobacter dehalogenans                                   | 3777                                                                                                        | 
| Anaeromyxobacter dehalogenans                                   | 3780                                                                                                        | 
| Desulfitobacterium dehalogenans                                 | 3783                                                                                                        | 
| Desulfitobacterium dichloroeliminans                            | 3784                                                                                                        | 
| Anaeromyxobacter sp.                                            | 3792                                                                                                        | 
| Anaeromyxobacter sp.                                            | 3794                                                                                                        | 
| Dehalococcoides mccartyi                                        | 3795                                                                                                        | 
| Dehalococcoides mccartyi                                        | 3796                                                                                                        | 
| Dehalobacter sp.                                                | 3797                                                                                                        | 
| Dehalobacter sp.                                                | 3798                                                                                                        | 
| Citrobacter freundii                                            | 3799                                                                                                        | 
| Citrobacter freundii ATCC 8090                                  | 3800                                                                                                        | 
| Citrobacter freundii                                            | 3801                                                                                                        | 
| Citrobacter sp.                                                 | 3802                                                                                                        | 
| Citrobacter sp.                                                 | 3803                                                                                                        | 
| Gordonia malaquae                                               | 3804                                                                                                        | 
| Pseudomonas sp.                                                 | 3805                                                                                                        | 
| Burkholderia sp.                                                | 3806                                                                                                        | 
| Gordonia effusa                                                 | 3807                                                                                                        | 
| Vibrio brasiliensis                                             | 3808                                                                                                        | 
| Rickettsiella grylli                                            | 3809                                                                                                        | 
| Diplorickettsia massiliensis                                    | 3810                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3811                                                                                                        | 
| Micavibrio aeruginosavorus                                      | 3812                                                                                                        | 
| Candidatus Nitrosoarchaeum koreensis                            | 3815                                                                                                        | 
| Candidatus Nitrosoarchaeum limnia                               | 3816                                                                                                        | 
| Candidatus Nitrosopumilus salaria                               | 3817                                                                                                        | 
| Burkholderia kururiensis                                        | 3818                                                                                                        | 
| Burkholderia gladioli                                           | 3819                                                                                                        | 
| Burkholderia glumae                                             | 3820                                                                                                        | 
| Burkholderia glumae                                             | 3821                                                                                                        | 
| Burkholderia glumae                                             | 3822                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3823                                                                                                        | 
| Pseudomonas aeruginosa                                          | 3824                                                                                                        | 
| Austwickia chelonae                                             | 3825                                                                                                        | 
| Amycolatopsis azurea                                            | 3826                                                                                                        | 
| Methanoculleus bourgensis MS2                                   | 3827                                                                                                        | 
| Amycolatopsis decaplanina                                       | 3828                                                                                                        | 
| Dehalococcoides sp.                                             | 3832                                                                                                        | 
| Sinorhizobium sp.                                               | 3833                                                                                                        | 
| Burkholderia terrae                                             | 3837                                                                                                        | 
| Providencia stuartii                                            | 3860                                                                                                        | 
| Sphingobium sp.                                                 | 3869,3870                                                                                                   | 
| Sphingobium indicum                                             | 3879                                                                                                        | 
| Serratia plymuthica                                             | 3880,3881                                                                                                   | 
| Serratia marcescens                                             | 3882,3883                                                                                                   | 
| Serratia symbiotica                                             | 3884                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 3885,3886                                                                                                   | 
| Bacillus amyloliquefaciens subsp. plantarum                     | 3887                                                                                                        | 
| Thauera sp.                                                     | 3888,3889                                                                                                   | 
| Thauera aminoaromatica                                          | 3890                                                                                                        | 
| Thauera terpenica                                               | 3891                                                                                                        | 
| Thauera selenatis AX                                            | 3892                                                                                                        | 
| Methanomassiliicoccus luminyensis                               | 3893                                                                                                        | 
| Agrobacterium albertimagni                                      | 3894                                                                                                        | 
| Agrobacterium tumefaciens                                       | 3895                                                                                                        | 
| Rhizobium sp. PDO1-076                                          | 3896                                                                                                        | 
| Magnetospirillum sp.                                            | 3918                                                                                                        | 
| Methylobacterium sp.                                            | 3925                                                                                                        | 
| Hyphomicrobium sp.                                              | 3926                                                                                                        | 
| Methylobacterium mesophilicum                                   | 3927                                                                                                        | 
| Hyphomicrobium denitrificans                                    | 3928                                                                                                        | 
| Enterobacter cloacae subsp. dissolvens                          | 3929                                                                                                        | 
| Enterobacter cloacae subsp. cloacae                             | 3930,3931,3932                                                                                              | 
| Enterobacter sp.                                                | 3933,3934                                                                                                   | 
| Enterobacter cloacae subsp. cloacae                             | 3935                                                                                                        | 
| Enterobacter lignolyticus                                       | 3936                                                                                                        | 
| Enterobacter cloacae subsp. dissolvens                          | 3937                                                                                                        | 
| Enterobacter sp.                                                | 3938                                                                                                        | 
| Enterobacter cloacae subsp. cloacae                             | 3939                                                                                                        | 
| Methyloversatilis sp.                                           | 3940                                                                                                        | 
| Methylobacter sp.                                               | 3941                                                                                                        | 
| Methylobacter sp.                                               | 3942                                                                                                        | 
| Methylopila sp.                                                 | 3943                                                                                                        | 
| Agrobacterium sp.                                               | 3958                                                                                                        | 
| Agrobacterium radiobacter                                       | 3961                                                                                                        | 
| Rhodococcus ruber                                               | 3966                                                                                                        | 
| Carnobacterium maltaromaticum                                   | 3969                                                                                                        | 
| Carnobacterium sp.                                              | 3970                                                                                                        | 
| Carnobacterium sp.                                              | 3971,3972                                                                                                   | 
| Acinetobacter sp.                                               | 3980                                                                                                        | 
| Candidatus Nitrosopumilus koreensis                             | 3998                                                                                                        | 
| Candidatus Nitrosopumilus sp.                                   | 3999                                                                                                        | 
| Stenotrophomonas maltophilia                                    | 4002                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4004,4005,4006                                                                                              | 
| Campylobacter jejuni subsp. jejuni                              | 4007                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4008                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4009                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4010                                                                                                        | 
| Methylomonas sp.                                                | 4019                                                                                                        | 
| Methylophaga lonarensis                                         | 4020                                                                                                        | 
| Methylotenera sp.                                               | 4025                                                                                                        | 
| Methylotenera sp.                                               | 4026                                                                                                        | 
| Methylotenera versatilis                                        | 4027                                                                                                        | 
| Methylotenera mobilis                                           | 4028                                                                                                        | 
| Methylophaga sp.                                                | 4033                                                                                                        | 
| Methylophaga sp.                                                | 4034,4035                                                                                                   | 
| Methylotenera versatilis                                        | 4036                                                                                                        | 
| Methylovorus glucosetrophus                                     | 4037,4038,4039                                                                                              | 
| Methylovorus sp.                                                | 4040                                                                                                        | 
| Candidatus Methanomethylophilus alvus                           | 4041                                                                                                        | 
| Methanomethylovorans hollandica                                 | 4042,4043                                                                                                   | 
| Rhizobium tropici                                               | 4065,4066,4067,4068                                                                                         | 
| Herbaspirillum seropedicae                                      | 4099                                                                                                        | 
| Bacteroides xylanisolvens                                       | 4108                                                                                                        | 
| Candidatus Microthrix parvicella                                | 4113                                                                                                        | 
| Bacteroides xylanisolvens                                       | 4116                                                                                                        | 
| Bacteroides ovatus                                              | 4117                                                                                                        | 
| Bacteroides ovatus                                              | 4118                                                                                                        | 
| Acinetobacter baumannii                                         | 4122,4120,4121                                                                                              | 
| Campylobacter jejuni subsp. jejuni                              | 4124,4125                                                                                                   | 
| Campylobacter jejuni                                            | 4126                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4127,4128                                                                                                   | 
| Campylobacter jejuni subsp. jejuni IA3902                       | 4129,4130                                                                                                   | 
| Campylobacter jejuni subsp. jejuni                              | 4131                                                                                                        | 
| Leptospira borgpetersenii                                       | 4140                                                                                                        | 
| Leptospira borgpetersenii serovar Mini                          | 4141                                                                                                        | 
| Leptospira borgpetersenii serovar Castellonis                   | 4142                                                                                                        | 
| Leptospira kirschneri                                           | 4143                                                                                                        | 
| Leptospira kirschneri                                           | 4144                                                                                                        | 
| Salmonella enterica subsp. enterica serovar Typhimurium         | 4164,4165                                                                                                   | 
| Campylobacter jejuni subsp. doylei                              | 4168                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4169                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4170                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4171                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4172                                                                                                        | 
| Pseudomonas stutzeri                                            | 4177                                                                                                        | 
| uncultured archaeon                                             | 4188                                                                                                        | 
| Mucispirillum schaedleri                                        | 4189                                                                                                        | 
| Mycoplasma capricolum subsp. capricolum                         | 4192                                                                                                        | 
| Mycoplasma leachii                                              | 4193                                                                                                        | 
| Mycoplasma mycoides subsp. capri LC                             | 4194,4195                                                                                                   | 
| Mycoplasma mycoides subsp. mycoides SC                          | 4196                                                                                                        | 
| Mycoplasma putrefaciens                                         | 4197                                                                                                        | 
| Halomonas titanicae                                             | 4212                                                                                                        | 
| Mycoplasma agalactiae                                           | 4213                                                                                                        | 
| Mycoplasma bovis                                                | 4214                                                                                                        | 
| Mycoplasma fermentans                                           | 4215                                                                                                        | 
| Mycoplasma haemocanis                                           | 4216                                                                                                        | 
| Mycoplasma pneumoniae                                           | 4217                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 4219                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum                     | 4220,4221                                                                                                   | 
| Corynebacterium striatum                                        | 4223                                                                                                        | 
| Pedobacter saltans                                              | 4224                                                                                                        | 
| Caulobacter segnis                                              | 4225                                                                                                        | 
| Deinococcus maricopensis                                        | 4226                                                                                                        | 
| Roseobacter litoralis                                           | 4227,4228,4229,4230                                                                                         | 
| Photobacterium angustum                                         | 4247                                                                                                        | 
| Photobacterium damselae subsp. damselae                         | 4248                                                                                                        | 
| Photobacterium profundum                                        | 4492                                                                                                        | 
| Photobacterium sp.                                              | 4250                                                                                                        | 
| Photobacterium sp.                                              | 4251                                                                                                        | 
| Photobacterium leiognathi subsp. mandapamensis                  | 4252                                                                                                        | 
| Elusimicrobium minutum                                          | 4253                                                                                                        | 
| uncultured Termite group 1 bacterium phylotype Rs-D17           | 4254,4256,4258,4260                                                                                         | 
| Dysgonomonas gadei                                              | 4291                                                                                                        | 
| Dysgonomonas mossii                                             | 4292                                                                                                        | 
| Dysgonomonas mossii                                             | 4293                                                                                                        | 
| Enterobacteria phage P1                                         | 4294                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4299                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4300                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4301                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4302                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4303                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4304                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4305                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4306                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4307,4308                                                                                                   | 
| Campylobacter jejuni subsp. jejuni                              | 4309                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4310                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4311                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4312                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4313                                                                                                        | 
| Campylobacter jejuni                                            | 4314                                                                                                        | 
| Streptomyces clavuligerus                                       | 4322                                                                                                        | 
| Helicobacter pylori                                             | 4335                                                                                                        | 
| Helicobacter pylori                                             | 4336                                                                                                        | 
| Helicobacter pylori                                             | 4337                                                                                                        | 
| Helicobacter pylori                                             | 4338                                                                                                        | 
| Pseudomonas chlororaphis subsp. chlororaphis                    | 4347                                                                                                        | 
| Pseudomonas fluorescens                                         | 4348,4368                                                                                                   | 
| Pseudomonas chlororaphis subsp. aureofaciens                    | 4349                                                                                                        | 
| Pseudomonas chlororaphis                                        | 4350                                                                                                        | 
| Pseudomonas fluorescens                                         | 4351                                                                                                        | 
| Pseudomonas fluorescens                                         | 4352,4353                                                                                                   | 
| Pseudomonas fluorescens                                         | 4354                                                                                                        | 
| Pseudomonas fluorescens                                         | 4355                                                                                                        | 
| Pseudomonas fluorescens                                         | 4356                                                                                                        | 
| Pseudomonas fluorescens                                         | 4357                                                                                                        | 
| Pseudomonas fluorescens                                         | 4358                                                                                                        | 
| Pseudomonas fluorescens                                         | 4359                                                                                                        | 
| Pseudomonas fluorescens                                         | 4360                                                                                                        | 
| Pseudomonas fluorescens                                         | 4361                                                                                                        | 
| Pseudomonas fluorescens                                         | 4362                                                                                                        | 
| Pseudomonas fluorescens                                         | 4363                                                                                                        | 
| Pseudomonas fluorescens                                         | 4364                                                                                                        | 
| Pseudomonas fluorescens                                         | 4365                                                                                                        | 
| Pseudomonas fluorescens                                         | 4366                                                                                                        | 
| Pseudomonas fluorescens                                         | 4367                                                                                                        | 
| Helicobacter pylori                                             | 4371                                                                                                        | 
| Helicobacter pylori                                             | 4372,4373                                                                                                   | 
| Helicobacter pylori                                             | 4374                                                                                                        | 
| Helicobacter pylori                                             | 4375,4376                                                                                                   | 
| Helicobacter pylori                                             | 4377                                                                                                        | 
| Helicobacter pylori                                             | 4378                                                                                                        | 
| Helicobacter pylori                                             | 4379                                                                                                        | 
| Helicobacter pylori                                             | 4380,4381                                                                                                   | 
| Helicobacter pylori                                             | 4382                                                                                                        | 
| Helicobacter pylori                                             | 4383                                                                                                        | 
| Helicobacter pylori                                             | 4384                                                                                                        | 
| Helicobacter pylori                                             | 4385,4386                                                                                                   | 
| Helicobacter pylori                                             | 4387,4388                                                                                                   | 
| Helicobacter pylori                                             | 4389                                                                                                        | 
| Helicobacter pylori                                             | 4390,4391                                                                                                   | 
| Helicobacter pylori SNT49                                       | 4392,4393                                                                                                   | 
| Helicobacter pylori                                             | 4394                                                                                                        | 
| Helicobacter pylori                                             | 4395                                                                                                        | 
| Thauera linaloolentis                                           | 4403                                                                                                        | 
| Thauera phenylacetica                                           | 4404                                                                                                        | 
| Thauera sp.                                                     | 4405                                                                                                        | 
| Thauera sp.                                                     | 4406                                                                                                        | 
| Thauera sp.                                                     | 4407                                                                                                        | 
| Helicobacter pylori                                             | 4414                                                                                                        | 
| Helicobacter pylori                                             | 4415                                                                                                        | 
| Helicobacter pylori                                             | 4416                                                                                                        | 
| Helicobacter pylori                                             | 4417,4418,4419                                                                                              | 
| Helicobacter pylori                                             | 4420,4421,4422                                                                                              | 
| Helicobacter pylori                                             | 4423                                                                                                        | 
| Helicobacter pylori                                             | 4425,4424                                                                                                   | 
| Helicobacter pylori                                             | 4426                                                                                                        | 
| Helicobacter pylori                                             | 4427,4428                                                                                                   | 
| Helicobacter pylori                                             | 4429,4430                                                                                                   | 
| Helicobacter pylori                                             | 4431                                                                                                        | 
| Helicobacter pylori                                             | 4432,4433                                                                                                   | 
| Helicobacter pylori                                             | 4434,4435                                                                                                   | 
| Marinobacter santoriniensis                                     | 4436                                                                                                        | 
| Novosphingobium aromaticivorans                                 | 4437,4438,4439                                                                                              | 
| Sphingopyxis alaskensis                                         | 4441,4440                                                                                                   | 
| Sphingopyxis baekryungensis                                     | 4442                                                                                                        | 
| Sphingopyxis sp.                                                | 4443                                                                                                        | 
| Novosphingobium pentaromativorans                               | 4444                                                                                                        | 
| Bacillus selenitireducens                                       | 4450                                                                                                        | 
| Shewanella sp.                                                  | 4451,4452                                                                                                   | 
| Achromobacter arsenitoxydans                                    | 4453                                                                                                        | 
| Methanotorris igneus                                            | 4456                                                                                                        | 
| Methanococcus voltae                                            | 4457                                                                                                        | 
| Methanococcus maripaludis                                       | 4458                                                                                                        | 
| Methanococcus maripaludis                                       | 4459                                                                                                        | 
| Methanocaldococcus fervens                                      | 4460,4461                                                                                                   | 
| Desulfotomaculum alcoholivorax                                  | 4478                                                                                                        | 
| Desulfurispora thermophila                                      | 4479                                                                                                        | 
| Acidiphilium multivorum                                         | 4498,4499,4501,4503,4504,4505,4506,4507,4508                                                                | 
| Thermus scotoductus                                             | 4500,4502                                                                                                   | 
| Starkeya novella                                                | 4509                                                                                                        | 
| Xanthobacter autotrophicus                                      | 4510,4511                                                                                                   | 
| Chlorobium phaeobacteroides                                     | 4512                                                                                                        | 
| Chlorobium limicola                                             | 4513                                                                                                        | 
| Burkholderia multivorans                                        | 4514,4515,4516,4517                                                                                         | 
| Achromobacter piechaudii                                        | 4518                                                                                                        | 
| Alcaligenes faecalis subsp. faecalis                            | 4519                                                                                                        | 
| Nitrosopumilus sp.                                              | 4520                                                                                                        | 
| Methylophilus sp.                                               | 4521                                                                                                        | 
| Methyloglobulus morosus                                         | 4522                                                                                                        | 
| Methylobacterium sp.                                            | 4523                                                                                                        | 
| Methylobacterium sp.                                            | 4524                                                                                                        | 
| Methylophilus sp.                                               | 4525                                                                                                        | 
| Methylobacterium sp.                                            | 4526                                                                                                        | 
| Methylohalobius crimeensis                                      | 4527                                                                                                        | 
| Hyphomicrobium nitrativorans                                    | 4528                                                                                                        | 
| Brucella suis                                                   | 4529,4530                                                                                                   | 
| Brucella pinnipedialis                                          | 4531,4532                                                                                                   | 
| Brucella melitensis                                             | 4533,4534                                                                                                   | 
| Brucella melitensis                                             | 4535,4536                                                                                                   | 
| Brucella melitensis                                             | 4537,4538                                                                                                   | 
| Brucella canis HSK                                              | 4539,4540                                                                                                   | 
| Brucella abortus                                                | 4541,4542                                                                                                   | 
| Paenibacillus polymyxa                                          | 4553,4554                                                                                                   | 
| Natronomonas moolapensis                                        | 4555                                                                                                        | 
| Halobacterium salinarum R1                                      | 4556,4557,4558,4559,4560                                                                                    | 
| Caldisphaera lagunensis                                         | 4561                                                                                                        | 
| Acholeplasma laidlawii                                          | 4562                                                                                                        | 
| Mesoplasma florum                                               | 4563                                                                                                        | 
| Mycoplasma mobile                                               | 4564                                                                                                        | 
| Spiroplasma apis                                                | 4565                                                                                                        | 
| Spiroplasma chrysopicola                                        | 4566                                                                                                        | 
| Spiroplasma syrphidicola                                        | 4567                                                                                                        | 
| Spiroplasma diminutum                                           | 4568                                                                                                        | 
| Spiroplasma taiwanense                                          | 4569,4570                                                                                                   | 
| Verrucomicrobium spinosum                                       | 4571                                                                                                        | 
| Variovorax sp.                                                  | 4572                                                                                                        | 
| Nitrosopumilus sp.                                              | 4573                                                                                                        | 
| Pseudaminobacter salicylatoxidans                               | 4574                                                                                                        | 
| Verrucomicrobiae bacterium                                      | 4575                                                                                                        | 
| Aminomonas paucivorans                                          | 4576                                                                                                        | 
| Variovorax paradoxus                                            | 4577                                                                                                        | 
| Methylophilus methylotrophus DSM 46235 =                        | 4578                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4606                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 4607                                                                                                        | 
| Lactococcus garvieae                                            | 4609                                                                                                        | 
| Lactococcus raffinolactis                                       | 4610                                                                                                        | 
| Enterobacter cloacae                                            | 4611                                                                                                        | 
| Klebsiella pneumoniae                                           | 4626,4627                                                                                                   | 
| Chromobacterium violaceum                                       | 4631                                                                                                        | 
| Lactobacillus sakei subsp. sakei                                | 4632                                                                                                        | 
| Leuconostoc gelidum                                             | 4633                                                                                                        | 
| Macrococcus caseolyticus                                        | 4634,4635,4636,4637,4638,4639,4640,4641,4642                                                                | 
| Rothia mucilaginosa                                             | 4643                                                                                                        | 
| Serratia liquefaciens                                           | 4644,4645                                                                                                   | 
| Acinetobacter lwoffii                                           | 4646                                                                                                        | 
| Acinetobacter lwoffii                                           | 4647                                                                                                        | 
| Pseudomonas fragi                                               | 4648                                                                                                        | 
| Pseudomonas fragi                                               | 4649                                                                                                        | 
| Moraxella catarrhalis                                           | 4650                                                                                                        | 
| Shewanella putrefaciens                                         | 4651                                                                                                        | 
| Shewanella putrefaciens                                         | 4652                                                                                                        | 
| Lactobacillus curvatus                                          | 4653                                                                                                        | 
| Hafnia alvei                                                    | 4668                                                                                                        | 
| Candidatus Hamiltonella symbiont of Bemisia tabaci              | 4687                                                                                                        | 
| Wolbachia pipientis                                             | 4689                                                                                                        | 
| Chromohalobacter salexigens                                     | 4690                                                                                                        | 
| Streptococcus agalactiae                                        | 4711                                                                                                        | 
| Streptococcus agalactiae                                        | 4712                                                                                                        | 
| Vibrio cholerae                                                 | 4727                                                                                                        | 
| Saccharothrix espanaensis                                       | 4730                                                                                                        | 
| Fluoribacter dumoffii                                           | 4731                                                                                                        | 
| Streptomyces albulus                                            | 4732                                                                                                        | 
| Streptomyces sviceus                                            | 4733                                                                                                        | 
| Legionella longbeachae                                          | 4734                                                                                                        | 
| Candidatus Odyssella thessalonicensis                           | 4735                                                                                                        | 
| Streptomyces somaliensis                                        | 4736                                                                                                        | 
| Parabacteroides sp.                                             | 4737                                                                                                        | 
| Moorea producens                                                | 4738                                                                                                        | 
| Saccharopolyspora spinosa                                       | 4739                                                                                                        | 
| Marinomonas mediterranea                                        | 4744                                                                                                        | 
| Micavibrio aeruginosavorus                                      | 4745                                                                                                        | 
| Sphingobium japonicum                                           | 4746                                                                                                        | 
| Pseudomonas putida                                              | 4747                                                                                                        | 
| Akkermansia muciniphila                                         | 4748                                                                                                        | 
| Akkermansia muciniphila                                         | 4749                                                                                                        | 
| Akkermansia sp.                                                 | 4750                                                                                                        | 
| Cedecea davisae                                                 | 4751                                                                                                        | 
| Sphingobium japonicum                                           | 4767,4768,4769,4770,4771                                                                                    | 
| Streptomyces sp.                                                | 4772                                                                                                        | 
| Pyrococcus yayanosii                                            | 4773                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 4781                                                                                                        | 
| Carnobacterium sp.                                              | 4782,4783,4784,4785,4786,4787                                                                               | 
| Clostridium lentocellum                                         | 4788                                                                                                        | 
| Desulfovibrio gigas DSM 1382 =                                  | 4789,4790                                                                                                   | 
| Burkholderia graminis                                           | 4792                                                                                                        | 
| Candidatus Burkholderia kirkii                                  | 4793                                                                                                        | 
| Burkholderia pyrrocinia                                         | 4794                                                                                                        | 
| Burkholderia sp.                                                | 4795                                                                                                        | 
| Burkholderia sp.                                                | 4796                                                                                                        | 
| Burkholderia sp.                                                | 4797                                                                                                        | 
| Burkholderia bryophila                                          | 4798                                                                                                        | 
| Burkholderia vietnamiensis                                      | 4799                                                                                                        | 
| Streptomyces violaceusniger                                     | 4800,4801,4802                                                                                              | 
| Nonomuraea coxensis                                             | 4803                                                                                                        | 
| Pantoea sp.                                                     | 4804                                                                                                        | 
| Pantoea sp.                                                     | 4805                                                                                                        | 
| Pantoea agglomerans                                             | 4806                                                                                                        | 
| Pantoea agglomerans                                             | 4807                                                                                                        | 
| Pantoea agglomerans                                             | 4808                                                                                                        | 
| Pantoea ananatis                                                | 4809                                                                                                        | 
| Pantoea ananatis                                                | 4810                                                                                                        | 
| Pantoea dispersa                                                | 4811                                                                                                        | 
| Neisseria gonorrhoeae                                           | 4813                                                                                                        | 
| Microcystis aeruginosa                                          | 4814                                                                                                        | 
| Microcystis aeruginosa                                          | 4815                                                                                                        | 
| Microcystis aeruginosa                                          | 4816                                                                                                        | 
| Pleomorphomonas koreensis                                       | 4817                                                                                                        | 
| Pleomorphomonas oryzae                                          | 4818                                                                                                        | 
| Klebsiella pneumoniae subsp. pneumoniae                         | 4826,4827,4828,4829,4830,4831,4832                                                                          | 
| Aeromonas hydrophila                                            | 4835                                                                                                        | 
| Aeromonas dhakensis                                             | 4836                                                                                                        | 
| Aeromonas hydrophila                                            | 4837                                                                                                        | 
| Magnetospirillum magneticum                                     | 4838                                                                                                        | 
| Rhodospirillum rubrum                                           | 4839                                                                                                        | 
| Shinella zoogloeoides                                           | 4844                                                                                                        | 
| Rhizobium sp.                                                   | 4845                                                                                                        | 
| Rhizobium lupini                                                | 4846                                                                                                        | 
| Rhizobium phaseoli                                              | 4847                                                                                                        | 
| Rhizobium giardinii bv. giardinii                               | 4848                                                                                                        | 
| Rhizobium gallicum bv. gallicum                                 | 4849                                                                                                        | 
| Rhizobium grahamii                                              | 4850                                                                                                        | 
| Rhizobium freirei                                               | 4851                                                                                                        | 
| Rhizobium mongolense                                            | 4852                                                                                                        | 
| Agrobacterium tumefaciens                                       | 4853                                                                                                        | 
| Agrobacterium tumefaciens                                       | 4854                                                                                                        | 
| Agrobacterium rhizogenes                                        | 4855                                                                                                        | 
| Agrobacterium tumefaciens                                       | 4856                                                                                                        | 
| Rhizobium leguminosarum bv. phaseoli                            | 4862                                                                                                        | 
| Agrobacterium sp.                                               | 4863                                                                                                        | 
| Raoultella ornithinolytica                                      | 4864                                                                                                        | 
| Klebsiella pneumoniae subsp. pneumoniae                         | 4878                                                                                                        | 
| Pandoraea sp.                                                   | 4881                                                                                                        | 
| Porphyromonas gingivalis                                        | 4882                                                                                                        | 
| Porphyromonas gingivalis                                        | 4883                                                                                                        | 
| Porphyromonas gingivalis                                        | 4884                                                                                                        | 
| Acinetobacter baumannii                                         | 4885,4886,4887                                                                                              | 
| Desulfococcus multivorans                                       | 4896                                                                                                        | 
| Rhodococcus erythropolis                                        | 4916,4917                                                                                                   | 
| Rhodococcus pyridinivorans                                      | 4918,4919,4920                                                                                              | 
| Rhodococcus equi                                                | 4921                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4923                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4924                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4925                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4926                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4927                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4928                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4929                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4930                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4931                                                                                                        | 
| Mycobacterium tuberculosis                                      | 4932                                                                                                        | 
| Rahnella sp.                                                    | 4935,4936,4937                                                                                              | 
| Candidatus Regiella insecticola                                 | 4938                                                                                                        | 
| Candidatus Regiella insecticola                                 | 4939                                                                                                        | 
| Sporomusa ovata                                                 | 4940                                                                                                        | 
| Neisseria gonorrhoeae                                           | 4942                                                                                                        | 
| Dickeya dadantii                                                | 4949                                                                                                        | 
| Dickeya dadantii                                                | 4950                                                                                                        | 
| Dickeya zeae                                                    | 4951                                                                                                        | 
| Dickeya dadantii                                                | 4952                                                                                                        | 
| Bradyrhizobium oligotrophicum                                   | 4953                                                                                                        | 
| Bradyrhizobium elkanii                                          | 4954                                                                                                        | 
| Bradyrhizobium japonicum                                        | 4955                                                                                                        | 
| Capnocytophaga canimorsus                                       | 4965                                                                                                        | 
| Paenibacillus elgii                                             | 4966                                                                                                        | 
| Acidianus hospitalis                                            | 4967                                                                                                        | 
| Haloferax volcanii                                              | 4968,4969,4970,4971,4973                                                                                    | 
| Halorhabdus utahensis                                           | 4972                                                                                                        | 
| Metallosphaera cuprina                                          | 4974                                                                                                        | 
| Methanoregula boonei                                            | 4975                                                                                                        | 
| Methanothermobacter marburgensis                                | 4976,4977                                                                                                   | 
| Pyrococcus sp.                                                  | 4978                                                                                                        | 
| Sulfolobus islandicus                                           | 4979                                                                                                        | 
| Vulcanisaeta moutnovskia                                        | 4980                                                                                                        | 
| Natrinema pellirubrum                                           | 4982,4983,4981                                                                                              | 
| Paenibacillus terrae                                            | 4985                                                                                                        | 
| Paenibacillus sp.                                               | 4986                                                                                                        | 
| Paenibacillus sp.                                               | 4987                                                                                                        | 
| Paenibacillus polymyxa                                          | 4988                                                                                                        | 
| Paenibacillus polymyxa                                          | 4989,4990                                                                                                   | 
| Paenibacillus polymyxa                                          | 4991                                                                                                        | 
| Caulobacter crescentus                                          | 4999                                                                                                        | 
| Caulobacter sp.                                                 | 5003,5004,5005                                                                                              | 
| Caulobacter crescentus                                          | 5006                                                                                                        | 
| Bacillus anthracis                                              | 5010                                                                                                        | 
| Mycoplasma capricolum subsp. capripneumoniae                    | 5039                                                                                                        | 
| Mycoplasma ovipneumoniae                                        | 5040                                                                                                        | 
| Mycoplasma agalactiae                                           | 5041                                                                                                        | 
| Mycoplasma mycoides subsp. capri                                | 5042                                                                                                        | 
| Mycoplasma alkalescens                                          | 5043                                                                                                        | 
| Mycoplasma arginini                                             | 5044                                                                                                        | 
| Mycoplasma bovigenitalium                                       | 5045                                                                                                        | 
| Mycoplasma auris                                                | 5046                                                                                                        | 
| Mycoplasma yeatsii                                              | 5047                                                                                                        | 
| Mycoplasma synoviae ATCC 25204                                  | 5048                                                                                                        | 
| Mycoplasma agalactiae                                           | 5049                                                                                                        | 
| Mycoplasma bovis                                                | 5050                                                                                                        | 
| Mycoplasma conjunctivae                                         | 5051                                                                                                        | 
| Mycoplasma crocodyli                                            | 5052                                                                                                        | 
| Mycoplasma cynos                                                | 5053                                                                                                        | 
| Mycoplasma haemofelis                                           | 5054                                                                                                        | 
| Mycoplasma leachii                                              | 5055                                                                                                        | 
| Mycoplasma putrefaciens                                         | 5056                                                                                                        | 
| Mycoplasma synoviae                                             | 5057                                                                                                        | 
| Mycoplasma wenyonii                                             | 5058                                                                                                        | 
| Aster yellows witches-broom phytoplasma AYWB                    | 5079,5080,5081,5082,5083                                                                                    | 
| Candidatus Phytoplasma australiense                             | 5084                                                                                                        | 
| Candidatus Phytoplasma mali                                     | 5085                                                                                                        | 
| Onion yellows phytoplasma OY-M                                  | 5086                                                                                                        | 
| Strawberry lethal yellows phytoplasma (CPA)                     | 5087                                                                                                        | 
| Candidatus Phytoplasma solani                                   | 5088                                                                                                        | 
| Serratia fonticola                                              | 5103                                                                                                        | 
| Serratia fonticola                                              | 5104                                                                                                        | 
| Serratia plymuthica                                             | 5105                                                                                                        | 
| Azospirillum brasilense                                         | 5157                                                                                                        | 
| Azospirillum halopraeferens                                     | 5158                                                                                                        | 
| Azospirillum irakense                                           | 5159                                                                                                        | 
| Azospirillum brasilense                                         | 5173,5174,5175,5170,5171,5172                                                                               | 
| Pelosinus fermentans                                            | 5176                                                                                                        | 
| Pelosinus fermentans                                            | 5177                                                                                                        | 
| Pelosinus fermentans                                            | 5178                                                                                                        | 
| Pelosinus fermentans DSM 17108                                  | 5179                                                                                                        | 
| Pelosinus sp.                                                   | 5180                                                                                                        | 
| Pelosinus fermentans                                            | 5181                                                                                                        | 
| Pelosinus fermentans                                            | 5182                                                                                                        | 
| Rhizobium sullae                                                | 5221                                                                                                        | 
| Pyrococcus sp.                                                  | 5229                                                                                                        | 
| Thermococcus sp.                                                | 5230                                                                                                        | 
| Thermococcus barophilus                                         | 5231,5232                                                                                                   | 
| Bacteroides reticulotermitis                                    | 5243                                                                                                        | 
| Bifidobacterium bifidum                                         | 5245                                                                                                        | 
| Bifidobacterium breve                                           | 5246                                                                                                        | 
| Alteromonas macleodii                                           | 5249                                                                                                        | 
| Alteromonas macleodii                                           | 5250                                                                                                        | 
| Alteromonas macleodii                                           | 5251,5252                                                                                                   | 
| Alteromonas macleodii                                           | 5253                                                                                                        | 
| Alteromonas macleodii                                           | 5254                                                                                                        | 
| Alteromonas macleodii                                           | 5255,5256                                                                                                   | 
| Alteromonas macleodii                                           | 5258,5257                                                                                                   | 
| Pseudoalteromonas atlantica                                     | 5259                                                                                                        | 
| Pseudoalteromonas sp.                                           | 5260,5261                                                                                                   | 
| Alteromonas macleodii                                           | 5282,5283                                                                                                   | 
| Alteromonas macleodii                                           | 5284                                                                                                        | 
| Alteromonas macleodii                                           | 5285                                                                                                        | 
| Alteromonas macleodii                                           | 5286                                                                                                        | 
| Alteromonas macleodii                                           | 5287                                                                                                        | 
| Alteromonas macleodii                                           | 5288,5289                                                                                                   | 
| Alteromonas sp.                                                 | 5290                                                                                                        | 
| Glaciecola psychrophila                                         | 5291                                                                                                        | 
| Marinobacter adhaerens                                          | 5294,5292,5293                                                                                              | 
| Oscillatoria formosa                                            | 5296                                                                                                        | 
| Thermoanaerobacter tengcongensis MB4                            | 5301                                                                                                        | 
| Escherichia sp.                                                 | 5304                                                                                                        | 
| Escherichia sp.                                                 | 5305                                                                                                        | 
| Candidatus Nitrososphaera evergladensis                         | 5306                                                                                                        | 
| Pseudoalteromonas luteoviolacea                                 | 5313                                                                                                        | 
| Pseudoalteromonas luteoviolacea                                 | 5314                                                                                                        | 
| Myxococcus stipitatus                                           | 5317                                                                                                        | 
| Myxococcus fulvus                                               | 5318                                                                                                        | 
| Myxococcus xanthus                                              | 5319                                                                                                        | 
| Brevibacillus agri                                              | 5325                                                                                                        | 
| Brevibacillus panacihumi                                        | 5326                                                                                                        | 
| Brevibacillus massiliensis                                      | 5327                                                                                                        | 
| Brevibacillus brevis                                            | 5328                                                                                                        | 
| Brevibacillus laterosporus                                      | 5329                                                                                                        | 
| Clostridium butyricum                                           | 5342                                                                                                        | 
| Clostridium butyricum                                           | 5343                                                                                                        | 
| Clostridium butyricum                                           | 5344                                                                                                        | 
| Clostridium butyricum E4                                        | 5345                                                                                                        | 
| Clostridium beijerinckii                                        | 5346                                                                                                        | 
| candidate division SR1 bacterium                                | 5353                                                                                                        | 
| Lactobacillus salivarius                                        | 5359                                                                                                        | 
| Lactobacillus salivarius                                        | 5360                                                                                                        | 
| Lactobacillus salivarius                                        | 5361                                                                                                        | 
| Lactobacillus salivarius                                        | 5362                                                                                                        | 
| Leptospira interrogans serovar Icterohaemorrhagiae              | 5364                                                                                                        | 
| Citrobacter amalonaticus                                        | 5377                                                                                                        | 
| Treponema pedis                                                 | 5381                                                                                                        | 
| Treponema medium                                                | 5382                                                                                                        | 
| Treponema vincentii                                             | 5383                                                                                                        | 
| Burkholderia cenocepacia                                        | 5388                                                                                                        | 
| Burkholderia cenocepacia                                        | 5389                                                                                                        | 
| Burkholderia cenocepacia BC7                                    | 5390                                                                                                        | 
| Burkholderia cenocepacia                                        | 5394,5395,5392,5393                                                                                         | 
| Shewanella benthica                                             | 5397                                                                                                        | 
| Moritella dasanensis                                            | 5398                                                                                                        | 
| Moritella marina                                                | 5399                                                                                                        | 
| Moritella marina ATCC 15381                                     | 5400                                                                                                        | 
| Moritella sp.                                                   | 5401                                                                                                        | 
| Mannheimia haemolytica                                          | 5411                                                                                                        | 
| Mannheimia haemolytica                                          | 5412                                                                                                        | 
| Mannheimia haemolytica                                          | 5413                                                                                                        | 
| Mannheimia haemolytica                                          | 5414                                                                                                        | 
| Mannheimia haemolytica                                          | 5415                                                                                                        | 
| Mannheimia haemolytica                                          | 5416                                                                                                        | 
| Mannheimia haemolytica                                          | 5417                                                                                                        | 
| Acidovorax avenae subsp. avenae                                 | 5420                                                                                                        | 
| Acidovorax citrulli                                             | 5421                                                                                                        | 
| Acidovorax ebreus                                               | 5422                                                                                                        | 
| Acidovorax sp.                                                  | 5423,5424,5425                                                                                              | 
| Acidovorax sp.                                                  | 5426                                                                                                        | 
| Verminephrobacter eiseniae                                      | 5427,5428                                                                                                   | 
| Leptospirillum ferriphilum                                      | 5449                                                                                                        | 
| Thermus sp. RL                                                  | 5520                                                                                                        | 
| Staphylococcus equorum subsp. equorum                           | 5560                                                                                                        | 
| Corynebacterium casei                                           | 5561                                                                                                        | 
| Brevibacterium linens                                           | 5562                                                                                                        | 
| Arthrobacter arilaitensis                                       | 5564,5565,5563                                                                                              | 
| Sulfolobus solfataricus                                         | 5572                                                                                                        | 
| Caldivirga maquilingensis                                       | 5573                                                                                                        | 
| Vulcanisaeta distributa                                         | 5574                                                                                                        | 
| Staphylococcus aureus subsp. aureus                             | 5622,5623,5624                                                                                              | 
| Staphylococcus aureus                                           | 5625,5626                                                                                                   | 
| Staphylococcus aureus subsp. aureus                             | 5627,5628,5629                                                                                              | 
| Staphylococcus aureus subsp. aureus                             | 5630,5631                                                                                                   | 
| Deinococcus geothermalis                                        | 5657,5658,5659                                                                                              | 
| Deinococcus gobiensis                                           | 5660,5661,5662,5663,5664,5665,5666                                                                          | 
| Deinococcus peraridilitoris                                     | 5669,5667,5668                                                                                              | 
| Deinococcus proteolyticus                                       | 5670,5671,5672,5673,5674                                                                                    | 
| Photorhabdus temperata subsp. temperata                         | 5692                                                                                                        | 
| Photorhabdus temperata                                          | 5693                                                                                                        | 
| Alteromonadales bacterium                                       | 5694                                                                                                        | 
| Vibrio alginolyticus                                            | 5695                                                                                                        | 
| Vibrio campbellii                                               | 5696                                                                                                        | 
| Vibrio alginolyticus                                            | 5697                                                                                                        | 
| Shewanella oneidensis                                           | 5701,5702                                                                                                   | 
| Vibrio orientalis                                               | 5732                                                                                                        | 
| Providencia rettgeri                                            | 5769                                                                                                        | 
| Providencia rettgeri                                            | 5770                                                                                                        | 
| Staphylococcus saprophyticus subsp. saprophyticus               | 5778                                                                                                        | 
| Carnobacterium maltaromaticum DSM 20342                         | 5781                                                                                                        | 
| Clostridium tetanomorphum                                       | 5782                                                                                                        | 
| Escherichia coli                                                | 5794                                                                                                        | 
| Escherichia coli                                                | 5795                                                                                                        | 
| Escherichia coli                                                | 5796                                                                                                        | 
| Brucella abortus bv. 3                                          | 5811                                                                                                        | 
| Brucella ceti                                                   | 5812                                                                                                        | 
| Brucella melitensis bv. 1                                       | 5813                                                                                                        | 
| Brucella neotomae                                               | 5814                                                                                                        | 
| Brucella pinnipedialis                                          | 5815                                                                                                        | 
| Brucella pinnipedialis                                          | 5816                                                                                                        | 
| Brucella sp.                                                    | 5817                                                                                                        | 
| Brucella suis bv. 5                                             | 5818                                                                                                        | 
| Psychromonas ossibalaenae ATCC BAA-1528                         | 5824                                                                                                        | 
| Clostridium sp.                                                 | 5826                                                                                                        | 
| Eubacterium plexicaudatum                                       | 5827                                                                                                        | 
| Clostridium sp.                                                 | 5828                                                                                                        | 
| Firmicutes bacterium                                            | 5829                                                                                                        | 
| Lactobacillus murinus                                           | 5830                                                                                                        | 
| Lactobacillus sp.                                               | 5831                                                                                                        | 
| Parabacteroides sp.                                             | 5832                                                                                                        | 
| Nitrospina gracilis                                             | 5837                                                                                                        | 
| Burkholderia cepacia                                            | 5838                                                                                                        | 
| Methylobacterium sp.                                            | 5852                                                                                                        | 
| Methylobacterium sp.                                            | 5853                                                                                                        | 
| Aminobacter sp.                                                 | 5854                                                                                                        | 
| Methylocystis sp.                                               | 5855                                                                                                        | 
| Methylobacterium sp.                                            | 5856                                                                                                        | 
| Methylobacter sp.                                               | 5857                                                                                                        | 
| Methylosinus sp.                                                | 5858                                                                                                        | 
| Methylacidiphilum kamchatkense                                  | 5859                                                                                                        | 
| Methylobacterium sp.                                            | 5860                                                                                                        | 
| Methylomonas denitrificans                                      | 5861                                                                                                        | 
| Methylobacterium sp.                                            | 5862                                                                                                        | 
| Methylococcaceae bacterium                                      | 5863                                                                                                        | 
| Methylocapsa aurea                                              | 5864                                                                                                        | 
| Methylobacterium sp.                                            | 5865                                                                                                        | 
| Lactobacillus brevis ATCC 14869 = DSM 20054                     | 5915                                                                                                        | 
| Lactobacillus brevis subsp. gravesensis                         | 5916                                                                                                        | 
| Candidatus Nitrosocosmicus exaquare                             | 5917                                                                                                        | 
| Leuconostoc gasicomitatum                                       | 9220                                                                                                        | 
| Leuconostoc carnosum                                            | 9221,9222,9223,9224,9225                                                                                    | 
| Leuconostoc citreum                                             | 9218,9219,9215,9216,9217                                                                                    | 
| Leuconostoc kimchii                                             | 9226,9227,9228,9229,9230,9231                                                                               | 
| Leuconostoc mesenteroides subsp. mesenteroides                  | 9235,9236                                                                                                   | 
| Leuconostoc mesenteroides subsp. mesenteroides                  | 9237,9238,9239,9240,9241,9242                                                                               | 
| Serratia plymuthica S13                                         | 5957                                                                                                        | 
| Serratia sp.                                                    | 5958                                                                                                        | 
| Serratia sp.                                                    | 5959                                                                                                        | 
| Serratia sp.                                                    | 5960                                                                                                        | 
| Serratia sp.                                                    | 5961                                                                                                        | 
| Pseudomonas extremaustralis 14-3 substr.                        | 5971                                                                                                        | 
| Pseudomonas psychrophila                                        | 5972                                                                                                        | 
| Pseudomonas psychrotolerans                                     | 5973                                                                                                        | 
| Xanthomonas gardneri                                            | 5974                                                                                                        | 
| Xanthomonas hortorum pv. carotae                                | 5975                                                                                                        | 
| Xanthomonas oryzae                                              | 5976                                                                                                        | 
| Xanthomonas oryzae                                              | 5977                                                                                                        | 
| Xanthomonas translucens                                         | 5978                                                                                                        | 
| Xanthomonas translucens pv. graminis                            | 5979                                                                                                        | 
| Xanthomonas translucens pv. translucens                         | 5980                                                                                                        | 
| Halorubrum lacusprofundi                                        | 5983,5981,5982                                                                                              | 
| Haloquadratum walsbyi C23                                       | 5984,5985,5986,5987                                                                                         | 
| Weissella koreensis                                             | 5994,5995                                                                                                   | 
| Weissella koreensis                                             | 5996                                                                                                        | 
| Weissella halotolerans                                          | 5997                                                                                                        | 
| Weissella paramesenteroides                                     | 5998                                                                                                        | 
| Weissella confusa                                               | 5999                                                                                                        | 
| Weissella ceti                                                  | 6000                                                                                                        | 
| Weissella cibaria                                               | 6001                                                                                                        | 
| Pseudomonas aeruginosa                                          | 6006                                                                                                        | 
| Rhodopirellula baltica                                          | 6009                                                                                                        | 
| Enterococcus mundtii QU 25                                      | 6013,6014,6015,6016,6011,6012                                                                               | 
| Enterococcus hirae                                              | 6017,6018                                                                                                   | 
| Enterococcus avium                                              | 6019                                                                                                        | 
| Enterococcus durans                                             | 6020                                                                                                        | 
| Cellulophaga algicola                                           | 6030                                                                                                        | 
| Cellulophaga baltica                                            | 6040                                                                                                        | 
| Cellulophaga lytica                                             | 6041                                                                                                        | 
| Lactococcus piscium                                             | 6042,6043,6044                                                                                              | 
| Brochothrix campestris                                          | 6045                                                                                                        | 
| Brochothrix thermosphacta DSM 20171                             | 6046                                                                                                        | 
| Brochothrix thermosphacta                                       | 6047                                                                                                        | 
| Burkholderia vietnamiensis                                      | 6049,6050,6051,6048                                                                                         | 
| Microbacterium testaceum                                        | 6055                                                                                                        | 
| Rhodobacter sphaeroides 2.4.1                                   | 6074,6068,6069,6070,6071,6072,6073                                                                          | 
| Halogeometricum borinquense DSM 11551                           | 6075,6076,6077,6078,6079,6080                                                                               | 
| Rhodobacter capsulatus                                          | 6081,6082                                                                                                   | 
| Actinosynnema mirum                                             | 6083                                                                                                        | 
| Kineococcus radiotolerans SRS30216 = ATCC BAA-149               | 6084,6085,6086                                                                                              | 
| Slackia heliotrinireducens                                      | 6087                                                                                                        | 
| Stackebrandtia nassauensis                                      | 6088                                                                                                        | 
| Cellulomonas flavigena                                          | 6089                                                                                                        | 
| Cyanothece sp.                                                  | 6090,6091,6092,6093,6094,6095                                                                               | 
| Sphaerochaeta globosa                                           | 6097                                                                                                        | 
| Spirochaeta smaragdinae                                         | 6098                                                                                                        | 
| Treponema caldaria                                              | 6099                                                                                                        | 
| Sphaerochaeta pleomorpha                                        | 6115                                                                                                        | 
| Formosa agariphila                                              | 6130                                                                                                        | 
| Arthrospira sp.                                                 | 6131                                                                                                        | 
| Staphylococcus capitis                                          | 6150                                                                                                        | 
| Staphylococcus epidermidis                                      | 6151                                                                                                        | 
| Staphylococcus epidermidis                                      | 6152                                                                                                        | 
| Staphylococcus epidermidis                                      | 6153                                                                                                        | 
| Staphylococcus epidermidis                                      | 6154                                                                                                        | 
| Staphylococcus epidermidis                                      | 6155                                                                                                        | 
| Staphylococcus capitis                                          | 6156                                                                                                        | 
| Staphylococcus caprae                                           | 6157                                                                                                        | 
| Leptospira kirschneri                                           | 6177                                                                                                        | 
| Leptospira kirschneri                                           | 6178                                                                                                        | 
| Leptospira kirschneri                                           | 6179                                                                                                        | 
| Leptospira kirschneri                                           | 6180                                                                                                        | 
| Leptospira kirschneri                                           | 6181                                                                                                        | 
| Leptospira kirschneri                                           | 6182                                                                                                        | 
| Klebsiella oxytoca                                              | 6248,6249,6250                                                                                              | 
| Klebsiella pneumoniae JM45                                      | 6251,6252,6253                                                                                              | 
| Klebsiella pneumoniae subsp. pneumoniae                         | 6254                                                                                                        | 
| Frankia sp.                                                     | 6263                                                                                                        | 
| Frankia sp.                                                     | 6264                                                                                                        | 
| Frankia sp.                                                     | 6265                                                                                                        | 
| Frankia sp.                                                     | 6266                                                                                                        | 
| Frankia sp.                                                     | 6267                                                                                                        | 
| Frankia sp.                                                     | 6268                                                                                                        | 
| Frankia sp.                                                     | 6269                                                                                                        | 
| Frankia sp.                                                     | 6270                                                                                                        | 
| Frankia sp.                                                     | 6271                                                                                                        | 
| Frankia sp.                                                     | 6272                                                                                                        | 
| Sporomusa sp.                                                   | 6273                                                                                                        | 
| Burkholderia sp.                                                | 6377,6378,6379,6380,6381,6376                                                                               | 
| Burkholderia sp.                                                | 6382,6383,6384,6385,6386                                                                                    | 
| Fusobacterium gonidiaformans                                    | 6395                                                                                                        | 
| Fusobacterium mortiferum                                        | 6396                                                                                                        | 
| Fusobacterium necrophorum subsp. funduliforme                   | 6397                                                                                                        | 
| Fusobacterium nucleatum                                         | 6398                                                                                                        | 
| Fusobacterium nucleatum subsp. vincentii                        | 6399                                                                                                        | 
| Fusobacterium periodonticum                                     | 6400                                                                                                        | 
| Fusobacterium russii ATCC 25533                                 | 6401                                                                                                        | 
| Fusobacterium sp. CAG:649                                       | 6402                                                                                                        | 
| Fusobacterium ulcerans                                          | 6403                                                                                                        | 
| Fusobacterium varium                                            | 6404                                                                                                        | 
| Klebsiella pneumoniae                                           | 6433                                                                                                        | 
| Klebsiella pneumoniae                                           | 6434                                                                                                        | 
| Klebsiella pneumoniae                                           | 6435                                                                                                        | 
| Klebsiella pneumoniae                                           | 6436                                                                                                        | 
| Klebsiella pneumoniae                                           | 6437                                                                                                        | 
| Klebsiella pneumoniae                                           | 6438                                                                                                        | 
| Lactobacillus fermentum                                         | 6444                                                                                                        | 
| Lactobacillus fermentum                                         | 6445                                                                                                        | 
| Lactobacillus fermentum                                         | 6446                                                                                                        | 
| Candidatus Methanomassiliicoccus intestinalis Issoire-Mx1       | 6472                                                                                                        | 
| Thermoplasmatales archaeon                                      | 6473                                                                                                        | 
| Nitrosotenuis aquariensis                                       | 7525                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 6493                                                                                                        | 
| Bacillus amyloliquefaciens                                      | 6494                                                                                                        | 
| Bacillus amyloliquefaciens subsp. amyloliquefaciens             | 6495                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum                     | 6496                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum                     | 6497                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum                     | 6498                                                                                                        | 
| Bacillus amyloliquefaciens subsp. plantarum UCMB5033            | 6499                                                                                                        | 
| Paenibacillus dendritiformis                                    | 6625                                                                                                        | 
| Rahnella aquatilis                                              | 6632,6633,6634,6635                                                                                         | 
| Citrobacter youngae                                             | 6636                                                                                                        | 
| Enterobacter mori                                               | 6637                                                                                                        | 
| Leuconostoc citreum                                             | 6638                                                                                                        | 
| Enterococcus durans                                             | 6639                                                                                                        | 
| Lactobacillus malefermentans                                    | 6640                                                                                                        | 
| Enterococcus malodoratus                                        | 6654                                                                                                        | 
| Aerococcus viridans                                             | 6655                                                                                                        | 
| Agrobacterium tumefaciens                                       | 6670                                                                                                        | 
| Agrobacterium tumefaciens                                       | 6671                                                                                                        | 
| Agrobacterium tumefaciens                                       | 6672                                                                                                        | 
| Agrobacterium sp.                                               | 6673                                                                                                        | 
| Rhizobium rubi                                                  | 6674                                                                                                        | 
| Agrobacterium tumefaciens                                       | 6675                                                                                                        | 
| Rhizobium larrymoorei                                           | 6676                                                                                                        | 
| Agrobacterium tumefaciens                                       | 8679,8680                                                                                                   | 
| Agrobacterium tumefaciens                                       | 6678                                                                                                        | 
| Agrobacterium sp.                                               | 6679                                                                                                        | 
| Rhizobium sp.                                                   | 6680                                                                                                        | 
| Agrobacterium sp.                                               | 6681                                                                                                        | 
| Rhizobium nepotum                                               | 6682                                                                                                        | 
| Rhizobium sp.                                                   | 6683                                                                                                        | 
| Agrobacterium tumefaciens                                       | 6684                                                                                                        | 
| Rhizobium sp.                                                   | 6685                                                                                                        | 
| Agrobacterium sp.                                               | 6686                                                                                                        | 
| Agrobacterium sp.                                               | 6687                                                                                                        | 
| Agrobacterium tumefaciens                                       | 6688,6689,6690,6691                                                                                         | 
| Agrobacterium tumefaciens                                       | 6693,6694,6695,6692                                                                                         | 
| Carnobacterium gallinarum DSM 4847                              | 6697                                                                                                        | 
| Flavobacterium branchiophilum                                   | 6767,6768                                                                                                   | 
| Flavobacterium indicum                                          | 6769                                                                                                        | 
| Edwardsiella ictaluri                                           | 6770                                                                                                        | 
| Edwardsiella tarda                                              | 6771,6772                                                                                                   | 
| Edwardsiella tarda                                              | 6773,6774                                                                                                   | 
| Edwardsiella piscicida                                          | 6775                                                                                                        | 
| Klebsiella quasipneumoniae subsp. quasipneumoniae               | 6796                                                                                                        | 
| Hassallia byssoidea                                             | 6797                                                                                                        | 
| Escherichia coli                                                | 6799,6800                                                                                                   | 
| Escherichia coli                                                | 6801                                                                                                        | 
| Escherichia coli                                                | 6805,6806,6807,6802,6803,6804                                                                               | 
| Escherichia coli                                                | 6812                                                                                                        | 
| Citrobacter amalonaticus                                        | 6818                                                                                                        | 
| Citrobacter amalonaticus                                        | 6819                                                                                                        | 
| Citrobacter amalonaticus                                        | 6820,6821                                                                                                   | 
| Pseudomonas syringae                                            | 6844                                                                                                        | 
| Campylobacter lari RM2100                                       | 6845,6846                                                                                                   | 
| Campylobacter jejuni subsp. jejuni                              | 6850                                                                                                        | 
| Campylobacter concisus                                          | 6851,6852,6853                                                                                              | 
| Campylobacter curvus                                            | 6854                                                                                                        | 
| Campylobacter coli                                              | 6855                                                                                                        | 
| Campylobacter jejuni subsp. jejuni                              | 6856                                                                                                        | 
| delta proteobacterium BABL1                                     | 6857                                                                                                        | 
| Acidobacterium capsulatum                                       | 6858                                                                                                        | 
| Candidatus Chloracidobacterium thermophilum                     | 6860,6859                                                                                                   | 
| Candidatus Solibacter usitatus                                  | 6861                                                                                                        | 
| Granulicella mallensis                                          | 6862                                                                                                        | 
| Granulicella tundricola                                         | 6863,6864,6865,6866,6867,6868                                                                               | 
| Terriglobus roseus                                              | 6869                                                                                                        | 
| Terriglobus saanensis                                           | 6870                                                                                                        | 
| Acidobacteriaceae bacterium                                     | 6871                                                                                                        | 
| Acidobacteriaceae bacterium                                     | 6872                                                                                                        | 
| Acidobacteriaceae bacterium                                     | 6873                                                                                                        | 
| Gemmatimonas aurantiaca T-27                                    | 6875                                                                                                        | 
| Rhodopseudomonas palustris                                      | 6882                                                                                                        | 
| Sinorhizobium fredii                                            | 6884,6885,6887,6888,6890,6891,6892,6894,6896,6897                                                           | 
| Sinorhizobium fredii                                            | 6904,6905,6906,6907,6908,6909,6910,6911,6912,6913,6914,6898,6915,6899,6916,6900,6901,6902,6903              | 
| Sinorhizobium fredii                                            | 6917,6918,6919                                                                                              | 
| Ilyobacter polytropus                                           | 6943,6944,6945                                                                                              | 
| Pseudoalteromonas agarivorans                                   | 6946                                                                                                        | 
| Pseudoalteromonas arctica                                       | 9967                                                                                                        | 
| Pseudoalteromonas haloplanktis                                  | 6948                                                                                                        | 
| Pseudoalteromonas piscicida                                     | 6949                                                                                                        | 
| Pseudoalteromonas spongiae                                      | 9966                                                                                                        | 
| Pseudoalteromonas tunicata                                      | 6951                                                                                                        | 
| Pseudoalteromonas undina                                        | 6952                                                                                                        | 
| Pseudoalteromonas citrea DSM 8771                               | 6953                                                                                                        | 
| Pseudoalteromonas rubra DSM 6842                                | 6954                                                                                                        | 
| Desulfovibrio piezophilus                                       | 6958                                                                                                        | 
| Desulfovibrio africanus                                         | 6959                                                                                                        | 
| Desulfovibrio longus                                            | 6960                                                                                                        | 
| Desulfovibrio oxyclinae                                         | 6961                                                                                                        | 
| Desulfovibrio inopinatus                                        | 6966                                                                                                        | 
| Desulfovibrio putealis                                          | 6967                                                                                                        | 
| Microcystis aeruginosa                                          | 6969,7801                                                                                                   | 
| Photorhabdus luminescens                                        | 6978                                                                                                        | 
| Photorhabdus temperata subsp. khanii                            | 6979                                                                                                        | 
| Photorhabdus temperata subsp. temperata                         | 6980                                                                                                        | 
| Photorhabdus temperata subsp. thracensis                        | 6981                                                                                                        | 
| Xanthomonas sacchari                                            | 6983                                                                                                        | 
| Microcystis aeruginosa PCC                                      | 7007                                                                                                        | 
| Microcystis aeruginosa PCC                                      | 7008                                                                                                        | 
| Leptolyngbya sp.                                                | 7020                                                                                                        | 
| Vibrio sp.                                                      | 7021                                                                                                        | 
| Vibrio sp.                                                      | 7022                                                                                                        | 
| Vibrio sp.                                                      | 7023                                                                                                        | 
| Vibrio sp.                                                      | 7024                                                                                                        | 
| Vibrio sp.                                                      | 7025                                                                                                        | 
| Candidatus Caldiarchaeum subterraneum                           | 7039                                                                                                        | 
| Cytophaga hutchinsonii                                          | 7051                                                                                                        | 
| Leptospira interrogans                                          | 7052                                                                                                        | 
| Leptospira interrogans                                          | 7053                                                                                                        | 
| Leptospira interrogans                                          | 7054                                                                                                        | 
| Microcystis panniformis                                         | 7057                                                                                                        | 
| Bacillus anthracis                                              | 7059,7060,7058                                                                                              | 
| Bacillus anthracis                                              | 7061,7062,7063                                                                                              | 
| Bacillus anthracis                                              | 7064                                                                                                        | 
| Bacillus atrophaeus                                             | 7065                                                                                                        | 
| Bacillus cellulosilyticus                                       | 7066                                                                                                        | 
| Bacillus cereus                                                 | 7067,7068                                                                                                   | 
| Bacillus cereus                                                 | 7071,7072,7073,7069,7070                                                                                    | 
| Bacillus cereus                                                 | 7074,7075,7076,7077                                                                                         | 
| Bacillus cereus                                                 | 7078                                                                                                        | 
| Bacillus cereus                                                 | 7079,7080,7081,7082,7083,7084                                                                               | 
| Lactobacillus helveticus                                        | 7087                                                                                                        | 
| Lactobacillus helveticus                                        | 7088,7089                                                                                                   | 
| Lactobacillus helveticus                                        | 7090                                                                                                        | 
| Desulfovibrio hydrothermalis                                    | 7091,7093                                                                                                   | 
| Desulfovibrio desulfuricans subsp. aestuarii DSM 17919 =        | 7095                                                                                                        | 
| Desulfovibrio desulfuricans subsp. desulfuricans                | 7096                                                                                                        | 
| Desulfovibrio alkalitolerans                                    | 7097                                                                                                        | 
| Desulfovibrio sp.                                               | 7098                                                                                                        | 
| Desulfovibrio sp.                                               | 7099                                                                                                        | 
| Microcystis aeruginosa                                          | 7102                                                                                                        | 
| Celeribacter indicus                                            | 7103,7104,7105,7106,7107,7108                                                                               | 
| Nitrosomonas cryotolerans                                       | 7109                                                                                                        | 
| Bacillus cereus                                                 | 7111,7112,7113                                                                                              | 
| Bacillus cereus                                                 | 7114,7115,7116                                                                                              | 
| Bacillus cereus biovar anthracis                                | 7117,7118,7119,7120                                                                                         | 
| Bacillus clausii                                                | 7121                                                                                                        | 
| Bacillus cytotoxicus                                            | 7122,7123                                                                                                   | 
| Bacillus megaterium                                             | 7124                                                                                                        | 
| Bacillus megaterium                                             | 7125,7126,7127,7128,7129,7130,7131,7132                                                                     | 
| Bacillus pseudofirmus                                           | 7135,7133,7134                                                                                              | 
| Bacillus pumilus                                                | 7136                                                                                                        | 
| Bacillus subtilis subsp. natto                                  | 7137,7138                                                                                                   | 
| Bacillus subtilis subsp. spizizenii                             | 7150                                                                                                        | 
| Bacillus thuringiensis                                          | 7151,7152                                                                                                   | 
| Bacillus thuringiensis                                          | 7154,7153                                                                                                   | 
| Bacillus weihenstephanensis                                     | 7156,7157,7158,7159,7155                                                                                    | 
| Burkholderia ambifaria                                          | 7160,7161,7162,7163                                                                                         | 
| Burkholderia cenocepacia                                        | 7164,7165,7166,7167                                                                                         | 
| Burkholderia cenocepacia                                        | 7168,7169,7170                                                                                              | 
| Burkholderia cepacia                                            | 7171,7172                                                                                                   | 
| Burkholderia mallei                                             | 7173,7174                                                                                                   | 
| Burkholderia mallei                                             | 7175,7176                                                                                                   | 
| Burkholderia mallei                                             | 7177,7178                                                                                                   | 
| Burkholderia pseudomallei                                       | 7179,7180                                                                                                   | 
| Burkholderia pseudomallei                                       | 7181,7182                                                                                                   | 
| Burkholderia pseudomallei                                       | 7183,7184                                                                                                   | 
| Burkholderia pseudomallei                                       | 7185,7186                                                                                                   | 
| Burkholderia pseudomallei                                       | 7187                                                                                                        | 
| Burkholderia pseudomallei                                       | 7189,7190                                                                                                   | 
| Burkholderia sp.                                                | 7191,7192                                                                                                   | 
| Burkholderia sp.                                                | 7193,7194,7195,7196                                                                                         | 
| Burkholderia pseudomallei                                       | 7198,7197                                                                                                   | 
| Burkholderia thailandensis                                      | 7199,7200                                                                                                   | 
| Burkholderia pseudomallei                                       | 7203                                                                                                        | 
| Burkholderia pseudomallei                                       | 7205                                                                                                        | 
| Flavobacterium rivuli                                           | 7221                                                                                                        | 
| Flavobacterium columnare                                        | 9932                                                                                                        | 
| Burkholderia lata                                               | 7223                                                                                                        | 
| Burkholderia lata                                               | 7224                                                                                                        | 
| Burkholderia pseudomallei                                       | 7225,7226                                                                                                   | 
| Burkholderia pseudomallei                                       | 7227,7229                                                                                                   | 
| Burkholderia pseudomallei                                       | 7228,7230                                                                                                   | 
| Burkholderia pseudomallei                                       | 7231,7233                                                                                                   | 
| Burkholderia pseudomallei                                       | 7232,7234                                                                                                   | 
| Burkholderia thailandensis                                      | 7235,7237                                                                                                   | 
| Burkholderia thailandensis                                      | 7236,7238                                                                                                   | 
| Kyrpidia tusciae                                                | 7239                                                                                                        | 
| Burkholderia multivorans                                        | 7240,7241,7242,7243                                                                                         | 
| Burkholderia pseudomallei                                       | 7244,7245                                                                                                   | 
| Methylobacterium sp.                                            | 7255                                                                                                        | 
| Methylobacterium sp.                                            | 7256                                                                                                        | 
| Methylobacterium sp.                                            | 7257                                                                                                        | 
| Sphingomonas sp.                                                | 7258                                                                                                        | 
| Methylobacterium sp.                                            | 7259                                                                                                        | 
| Methylobacterium sp.                                            | 7260                                                                                                        | 
| Methylobacterium sp.                                            | 7261                                                                                                        | 
| Methylobacterium sp.                                            | 7262                                                                                                        | 
| Methylobacterium sp.                                            | 7263                                                                                                        | 
| Methylobacterium sp.                                            | 7264                                                                                                        | 
| Methylobacterium sp.                                            | 7265                                                                                                        | 
| Devosia sp.                                                     | 7266                                                                                                        | 
| Methylobacterium sp.                                            | 7267                                                                                                        | 
| Methylobacterium sp.                                            | 7268                                                                                                        | 
| Methylobacterium sp.                                            | 7269                                                                                                        | 
| Methylobacterium sp.                                            | 7270                                                                                                        | 
| Devosia sp.                                                     | 7271                                                                                                        | 
| Methylobacterium sp.                                            | 7272                                                                                                        | 
| Methylobacterium sp.                                            | 7273                                                                                                        | 
| Methylobacterium sp.                                            | 7274                                                                                                        | 
| Methylobacterium sp.                                            | 7275                                                                                                        | 
| Methylobacterium sp.                                            | 7276                                                                                                        | 
| Methylobacterium sp.                                            | 7277                                                                                                        | 
| Methylobacterium sp.                                            | 7278                                                                                                        | 
| Methylobacterium sp.                                            | 7279                                                                                                        | 
| Methylobacterium sp.                                            | 7280                                                                                                        | 
| Methylobacterium sp.                                            | 7281                                                                                                        | 
| Aminobacter sp.                                                 | 7282                                                                                                        | 
| Devosia sp.                                                     | 7283                                                                                                        | 
| Bosea sp.                                                       | 7284                                                                                                        | 
| Devosia sp.                                                     | 7285                                                                                                        | 
| Devosia sp.                                                     | 7286                                                                                                        | 
| Devosia sp.                                                     | 7287                                                                                                        | 
| Bosea sp.                                                       | 7288                                                                                                        | 
| Mycobacterium smegmatis                                         | 7289                                                                                                        | 
| Mycobacterium tuberculosis                                      | 7290                                                                                                        | 
| Lactobacillus plantarum                                         | 7301,7291,7292,7293,7294,7295,7296,7297,7298,7299,7300                                                      | 
| Lactobacillus plantarum                                         | 7302,7303,7304,7305                                                                                         | 
| Devosia sp.                                                     | 7306                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum                        | 7307,7308,7309,7310,7311,7312,7313                                                                          | 
| Lactococcus lactis subsp. cremoris                              | 7318,7314,7315,7316,7317                                                                                    | 
| Lactococcus lactis subsp. cremoris                              | 7319                                                                                                        | 
| Lactococcus lactis subsp. cremoris                              | 7320                                                                                                        | 
| Lactococcus lactis subsp. cremoris                              | 7321,7322,7323,7324,7325,7326,7327,7328,7329                                                                | 
| Lactococcus lactis subsp. lactis                                | 7334,7335,7330,7331,7332,7333                                                                               | 
| Lactococcus lactis subsp. lactis                                | 7336                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 7337,7338                                                                                                   | 
| Photorhabdus luminescens                                        | 7339                                                                                                        | 
| Photorhabdus luminescens subsp. laumondii                       | 7340                                                                                                        | 
| Photorhabdus luminescens                                        | 7341                                                                                                        | 
| Photorhabdus asymbiotica subsp. australis                       | 7342                                                                                                        | 
| Photorhabdus luminescens                                        | 7343                                                                                                        | 
| Photorhabdus luminescens subsp. luminescens                     | 7344                                                                                                        | 
| Photorhabdus luminescens                                        | 7345                                                                                                        | 
| Photorhabdus heterorhabditis                                    | 7346                                                                                                        | 
| Xenorhabdus nematophila                                         | 7347                                                                                                        | 
| Xenorhabdus sp.                                                 | 7348                                                                                                        | 
| Xenorhabdus griffiniae                                          | 7349                                                                                                        | 
| Xenorhabdus khoisanae                                           | 7350                                                                                                        | 
| Xenorhabdus sp.                                                 | 7351                                                                                                        | 
| Fibrobacter succinogenes subsp. succinogenes                    | 7352                                                                                                        | 
| Fibrobacter succinogenes subsp. succinogenes                    | 7353                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7354,7355                                                                                                   | 
| Lysinibacillus fusiformis                                       | 7356                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7357                                                                                                        | 
| Desulfobacter postgatei                                         | 7360                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 7374                                                                                                        | 
| Lactococcus lactis                                              | 7375                                                                                                        | 
| Lactobacillus plantarum                                         | 7376                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum                        | 7377                                                                                                        | 
| Lactobacillus plantarum                                         | 7378                                                                                                        | 
| Lactobacillus plantarum                                         | 7379                                                                                                        | 
| Propionibacterium freudenreichii subsp. shermanii CIRM-BIA1     | 7380                                                                                                        | 
| Desulfotomaculum acetoxidans                                    | 7381                                                                                                        | 
| Desulfotomaculum carboxydivorans                                | 7382                                                                                                        | 
| Desulfotomaculum gibsoniae                                      | 7383                                                                                                        | 
| Desulfotomaculum kuznetsovii                                    | 7384                                                                                                        | 
| Desulfotomaculum ruminis                                        | 7385                                                                                                        | 
| Desulfotomaculum hydrothermale                                  | 7386                                                                                                        | 
| Cobetia marina                                                  | 7389                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 7390                                                                                                        | 
| Lactococcus lactis subsp. lactis bv. diacetylactis              | 7391                                                                                                        | 
| Lactobacillus plantarum                                         | 7392                                                                                                        | 
| Lactobacillus plantarum                                         | 7393                                                                                                        | 
| Lactococcus lactis subsp. cremoris                              | 7394                                                                                                        | 
| Lactococcus lactis subsp. cremoris                              | 7395                                                                                                        | 
| Lactococcus lactis subsp. lactis bv. diacetylactis str.         | 7396                                                                                                        | 
| Lactobacillus plantarum                                         | 7397                                                                                                        | 
| Lactobacillus plantarum                                         | 7398                                                                                                        | 
| Burkholderia gladioli                                           | 7424,7425,7426,7427,7428                                                                                    | 
| Limnohabitans sp.                                               | 7450                                                                                                        | 
| Limnohabitans sp.                                               | 7451                                                                                                        | 
| Desulfurococcus fermentans                                      | 7457                                                                                                        | 
| Desulfosporosinus acidiphilus                                   | 7460,7461,7462                                                                                              | 
| Desulfosporosinus meridiei                                      | 7463                                                                                                        | 
| Bacteriovorax marinus                                           | 7464,7465                                                                                                   | 
| Bdellovibrio exovorus                                           | 7466                                                                                                        | 
| Desulfarculus baarsii                                           | 7467                                                                                                        | 
| Desulfatibacillum alkenivorans                                  | 7468                                                                                                        | 
| Desulfobacula toluolica                                         | 7469                                                                                                        | 
| Desulfobulbus propionicus                                       | 7470                                                                                                        | 
| Desulfocapsa sulfexigens                                        | 7471,7472                                                                                                   | 
| Desulfococcus oleovorans                                        | 7473                                                                                                        | 
| Desulfohalobium retbaense                                       | 7474,7475                                                                                                   | 
| Desulfomicrobium baculatum                                      | 7476                                                                                                        | 
| Candidatus Endolissoclinum faulkneri                            | 7514                                                                                                        | 
| Haliangium ochraceum                                            | 7515                                                                                                        | 
| Pelobacter carbinolicus                                         | 7516                                                                                                        | 
| Rhodospirillum photometricum                                    | 7517                                                                                                        | 
| Sorangium cellulosum So ce56                                    | 7518                                                                                                        | 
| Pseudomonas fluorescens                                         | 7519                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 7521,7520                                                                                                   | 
| Lactococcus lactis subsp. cremoris                              | 7522                                                                                                        | 
| Lactobacillus plantarum                                         | 7523                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 7524                                                                                                        | 
| Lactobacillus plantarum                                         | 7526                                                                                                        | 
| Tistrella mobilis                                               | 7533,7534,7535,7536,7537                                                                                    | 
| Desulfotignum balticum                                          | 7538                                                                                                        | 
| Niveispirillum irakense                                         | 7539                                                                                                        | 
| Desulforegula conservatrix                                      | 7540                                                                                                        | 
| Thalassobaculum salexigens                                      | 7541                                                                                                        | 
| Skermanella stibiiresistens                                     | 7542                                                                                                        | 
| Desulfatitalea tepidiphila                                      | 7543                                                                                                        | 
| Desulfovibrio cf. magneticus                                    | 7544                                                                                                        | 
| Fodinicurvata fenggangensis                                     | 7545                                                                                                        | 
| Desulfurella acetivorans                                        | 7546,7547                                                                                                   | 
| Geoalkalibacter subterraneus                                    | 7549,7548                                                                                                   | 
| Thalassospira xiamenensis  = DSM 17429                          | 7550,7551                                                                                                   | 
| Caenispirillum salinarum                                        | 7552                                                                                                        | 
| Desulfospira joergensenii                                       | 7553                                                                                                        | 
| Desulfotignum phosphitoxidans                                   | 7554                                                                                                        | 
| Fodinicurvata sediminis                                         | 7555                                                                                                        | 
| Novispirillum itersonii subsp. itersonii                        | 7556                                                                                                        | 
| Oceanibaculum indicum                                           | 7557                                                                                                        | 
| Phaeospirillum molischianum                                     | 7558                                                                                                        | 
| Thalassospira lucentensis QMT2 =                                | 7559                                                                                                        | 
| Phaeospirillum fulvum                                           | 7560                                                                                                        | 
| Clostridium ultunense                                           | 7600                                                                                                        | 
| Candidatus Desulforudis audaxviator                             | 7612                                                                                                        | 
| Syntrophobotulus glycolicus                                     | 7613                                                                                                        | 
| Dehalobacter sp.                                                | 7614                                                                                                        | 
| Dehalobacter sp.                                                | 7615                                                                                                        | 
| Dehalobacter sp.                                                | 7616                                                                                                        | 
| Desulfitobacterium hafniense                                    | 7617                                                                                                        | 
| Desulfitobacterium hafniense                                    | 7618                                                                                                        | 
| Desulfitobacterium hafniense                                    | 7619                                                                                                        | 
| Desulfitobacterium sp.                                          | 7620                                                                                                        | 
| Magnetospirillum sp. XM-1                                       | 7621,7622                                                                                                   | 
| Arthrobacter crystallopoietes                                   | 7623                                                                                                        | 
| Arthrobacter gangotriensis                                      | 7624                                                                                                        | 
| Arthrobacter globiformis                                        | 7625                                                                                                        | 
| Arthrobacter sp.                                                | 7626                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7630                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7631                                                                                                        | 
| Lysinibacillus fusiformis                                       | 7632                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7633                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7634                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7635                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7636                                                                                                        | 
| Lysinibacillus sphaericus                                       | 7637                                                                                                        | 
| Lysinibacillus sp.                                              | 7638                                                                                                        | 
| Lysinibacillus manganicus                                       | 7639                                                                                                        | 
| Lysinibacillus sinduriensis                                     | 7640                                                                                                        | 
| Lysinibacillus odysseyi                                         | 7641                                                                                                        | 
| Lysinibacillus massiliensis                                     | 7642                                                                                                        | 
| Lysinibacillus boronitolerans JCM 21713                         | 7643                                                                                                        | 
| Lysinibacillus fusiformis                                       | 7644                                                                                                        | 
| Lysinibacillus sp.                                              | 7645                                                                                                        | 
| Lysinibacillus sp.                                              | 7646                                                                                                        | 
| Lysinibacillus xylanilyticus                                    | 7647                                                                                                        | 
| Lysinibacillus varians                                          | 7648                                                                                                        | 
| Lysinibacillus fusiformis                                       | 7649,7650                                                                                                   | 
| Ralstonia solanacearum                                          | 7677,7678                                                                                                   | 
| Burkholderia sp.                                                | 7823,7824,7825,7826,7827,7828                                                                               | 
| Hoeflea phototrophica                                           | 7831                                                                                                        | 
| Hoeflea sp.                                                     | 7832                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7833,7834,7835                                                                                              | 
| Mycobacterium abscessus subsp. bolletii                         | 7837                                                                                                        | 
| Mycobacterium kansasii                                          | 7838,7839                                                                                                   | 
| Mycobacterium liflandii                                         | 7841,7842                                                                                                   | 
| Mycobacterium smegmatis                                         | 7843,7844,7845,7846                                                                                         | 
| Pseudomonas aeruginosa                                          | 7848                                                                                                        | 
| Mycobacterium yongonense                                        | 7849,7851,7852                                                                                              | 
| Mycobacterium abscessus                                         | 7853                                                                                                        | 
| Mycobacterium abscessus                                         | 7855                                                                                                        | 
| Mycobacterium abscessus                                         | 7857                                                                                                        | 
| Mycobacterium abscessus                                         | 7859                                                                                                        | 
| Mycobacterium abscessus                                         | 7861                                                                                                        | 
| Mycobacterium abscessus                                         | 7864                                                                                                        | 
| Mycobacterium abscessus                                         | 7866                                                                                                        | 
| Mycobacterium abscessus                                         | 7868                                                                                                        | 
| Mycobacterium abscessus                                         | 7870                                                                                                        | 
| Mycobacterium abscessus                                         | 7872                                                                                                        | 
| Mycobacterium abscessus                                         | 7874                                                                                                        | 
| Mycobacterium abscessus                                         | 7875                                                                                                        | 
| Mycobacterium abscessus                                         | 7877                                                                                                        | 
| Mycobacterium abscessus                                         | 7879                                                                                                        | 
| Mycobacterium abscessus                                         | 7881                                                                                                        | 
| Mycobacterium abscessus                                         | 7883                                                                                                        | 
| Mycobacterium abscessus                                         | 7884                                                                                                        | 
| Mycobacterium abscessus                                         | 7886                                                                                                        | 
| Mycobacterium abscessus                                         | 7888                                                                                                        | 
| Mycobacterium abscessus                                         | 7890                                                                                                        | 
| Mycobacterium abscessus                                         | 7891                                                                                                        | 
| Mycobacterium abscessus                                         | 7893                                                                                                        | 
| Mycobacterium abscessus                                         | 7895                                                                                                        | 
| Mycobacterium abscessus                                         | 7897                                                                                                        | 
| Mycobacterium abscessus                                         | 7898                                                                                                        | 
| Mycobacterium abscessus                                         | 7899                                                                                                        | 
| Mycobacterium abscessus                                         | 7900                                                                                                        | 
| Mycobacterium abscessus                                         | 7901                                                                                                        | 
| Mycobacterium abscessus                                         | 7902                                                                                                        | 
| Mycobacterium abscessus                                         | 7903                                                                                                        | 
| Mycobacterium abscessus                                         | 7904                                                                                                        | 
| Mycobacterium abscessus                                         | 7905                                                                                                        | 
| Mycobacterium abscessus                                         | 7906                                                                                                        | 
| Mycobacterium abscessus                                         | 7907                                                                                                        | 
| Mycobacterium abscessus                                         | 7908                                                                                                        | 
| Mycobacterium abscessus                                         | 7909                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7910                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7911                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7913                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7914                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7916                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7917                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7919                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7920                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7922                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7923                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7925                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii                         | 7926                                                                                                        | 
| Mycobacterium abscessus subsp. bolletii CCUG 48898 = JCM 15300  | 7928                                                                                                        | 
| Mycobacterium fortuitum subsp. fortuitum                        | 7929                                                                                                        | 
| Mycobacterium avium                                             | 7931                                                                                                        | 
| Mycobacterium avium                                             | 7933                                                                                                        | 
| Mycobacterium avium                                             | 7934                                                                                                        | 
| Mycobacterium avium subsp. avium                                | 7936                                                                                                        | 
| Mycobacterium avium subsp. avium                                | 7938                                                                                                        | 
| Mycobacterium avium subsp. avium                                | 7939                                                                                                        | 
| Mycobacterium avium subsp. avium                                | 7941                                                                                                        | 
| Mycobacterium avium subsp. hominissuis                          | 7942                                                                                                        | 
| Mycobacterium avium subsp. hominissuis                          | 7944                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7946                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7947                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7949                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7951                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7952                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7954                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7955                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7957                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7958                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7960                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7961                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7963                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7965                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7966                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7968                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7969                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7971                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7972                                                                                                        | 
| Mycobacterium avium subsp. paratuberculosis                     | 7974                                                                                                        | 
| Mycobacterium avium subsp. silvaticum                           | 7975                                                                                                        | 
| Vibrio alginolyticus                                            | 7977,7978                                                                                                   | 
| Vibrio sp.                                                      | 7979,7980                                                                                                   | 
| Vibrio halioticoli                                              | 7982                                                                                                        | 
| Vibrio harveyi                                                  | 7983                                                                                                        | 
| Vibrio harveyi                                                  | 7985                                                                                                        | 
| Vibrio harveyi                                                  | 7987                                                                                                        | 
| Vibrio harveyi                                                  | 7988                                                                                                        | 
| Sinorhizobium meliloti                                          | 7991,7992,7993,7994,7990                                                                                    | 
| Sinorhizobium meliloti                                          | 7996,7997,7998                                                                                              | 
| Sinorhizobium meliloti                                          | 7999,8000,8001,8002,8003                                                                                    | 
| Sinorhizobium meliloti                                          | 8005,8006,8007                                                                                              | 
| Sinorhizobium meliloti                                          | 8009,8010,8012,8008                                                                                         | 
| Sinorhizobium meliloti                                          | 8013,8014,8015                                                                                              | 
| Mycobacterium indicus pranii MTCC 9506                          | 8017                                                                                                        | 
| Mycobacterium colombiense                                       | 8020                                                                                                        | 
| Cellulophaga lytica                                             | 8033                                                                                                        | 
| Mycobacterium avium subsp. hominissuis                          | 8034,8035                                                                                                   | 
| Mycobacterium haemophilum DSM 44634                             | 8036                                                                                                        | 
| Mycobacterium immunogenum                                       | 8037                                                                                                        | 
| Mycobacterium immunogenum                                       | 8038                                                                                                        | 
| Mycobacterium immunogenum                                       | 8039                                                                                                        | 
| Mycobacterium immunogenum                                       | 8040                                                                                                        | 
| Fructobacillus fructosus                                        | 8050                                                                                                        | 
| Shewanella decolorationis                                       | 8073                                                                                                        | 
| Magnetospirillum magnetotacticum                                | 8076                                                                                                        | 
| Curtobacterium sp.                                              | 8082                                                                                                        | 
| Streptomyces sp.                                                | 8083                                                                                                        | 
| Acetobacter pasteurianus                                        | 8087,8088,8089,8090,8091,8092,8093                                                                          | 
| Brucella ceti                                                   | 8094,8095                                                                                                   | 
| Methylobacterium populi                                         | 8097,8098,8096                                                                                              | 
| Parvibaculum lavamentivorans                                    | 8099                                                                                                        | 
| Rickettsia rickettsii                                           | 8100                                                                                                        | 
| Sphingomonas wittichii                                          | 8101,8102,8103                                                                                              | 
| Terasakiella pusilla                                            | 8130                                                                                                        | 
| Martelella endophytica                                          | 8131                                                                                                        | 
| Pseudovibrio sp.                                                | 8163,8164                                                                                                   | 
| Staphylococcus warneri                                          | 8165,8166,8167,8168,8169,8170,8171,8172,8173                                                                | 
| Staphylococcus pasteuri                                         | 8174                                                                                                        | 
| Streptomyces lividans                                           | 8175                                                                                                        | 
| Streptomyces coelicoflavus                                      | 8176                                                                                                        | 
| Lactococcus garvieae                                            | 8178                                                                                                        | 
| Lactococcus garvieae                                            | 8179                                                                                                        | 
| Lactococcus garvieae                                            | 8180                                                                                                        | 
| Lactococcus garvieae                                            | 8181                                                                                                        | 
| Lactococcus garvieae                                            | 8182                                                                                                        | 
| Lactobacillus plantarum                                         | 8183                                                                                                        | 
| Lactobacillus plantarum                                         | 8184                                                                                                        | 
| Lactobacillus plantarum                                         | 8185                                                                                                        | 
| Lactobacillus plantarum                                         | 8186                                                                                                        | 
| Lactobacillus brevis                                            | 8187,8188,8189,8190,8191,8192,8193,8194,8195,8196                                                           | 
| Escherichia coli                                                | 8197                                                                                                        | 
| Elizabethkingia anophelis                                       | 8228                                                                                                        | 
| Steroidobacter denitrificans                                    | 8261                                                                                                        | 
| Citrobacter amalonaticus                                        | 8277,8278                                                                                                   | 
| Citrobacter amalonaticus                                        | 8279                                                                                                        | 
| Citrobacter amalonaticus                                        | 8280                                                                                                        | 
| Citrobacter amalonaticus                                        | 8281                                                                                                        | 
| Citrobacter amalonaticus                                        | 8282                                                                                                        | 
| Citrobacter amalonaticus                                        | 8283                                                                                                        | 
| Clostridium acetobutylicum                                      | 8284,8285,8286                                                                                              | 
| Clostridium acetobutylicum                                      | 8287,8288                                                                                                   | 
| Clostridium kluyveri                                            | 8289,8290                                                                                                   | 
| Clostridium pasteurianum                                        | 8291,8292                                                                                                   | 
| Escherichia coli O25b:H4-ST131                                  | 8335,8336,8337                                                                                              | 
| Achromobacter piechaudii                                        | 8339                                                                                                        | 
| Achromobacter xylosoxidans                                      | 8340                                                                                                        | 
| Leptospirillum ferriphilum                                      | 8343                                                                                                        | 
| Klebsiella pneumoniae                                           | 8360,8361,8362,8363                                                                                         | 
| Klebsiella pneumoniae                                           | 8364,8365,8366,8367,8368,8369                                                                               | 
| Microcystis aeruginosa                                          | 8372                                                                                                        | 
| Treponema azotonutricium                                        | 8407                                                                                                        | 
| Acidobacteriaceae bacterium TAA166                              | 8408                                                                                                        | 
| Serratia marcescens                                             | 8409                                                                                                        | 
| Synechococcus sp.                                               | 8426,8427,8428,8429,8430,8431                                                                               | 
| Synechocystis sp.                                               | 8434,8435,8432,8433                                                                                         | 
| Tolypothrix sp. PCC 7601                                        | 8436                                                                                                        | 
| Micromonospora sp.                                              | 8437                                                                                                        | 
| Streptomyces aurantiacus                                        | 8438                                                                                                        | 
| Streptomyces auratus                                            | 8439                                                                                                        | 
| Streptomyces griseus                                            | 8440                                                                                                        | 
| Streptomyces pristinaespiralis                                  | 8441                                                                                                        | 
| Streptomyces roseochromogenes subsp. oscitans                   | 8442                                                                                                        | 
| Streptomyces viridochromogenes                                  | 8443                                                                                                        | 
| Streptomyces viridochromogenes                                  | 8444                                                                                                        | 
| Nocardioides sp.                                                | 8445                                                                                                        | 
| Nocardioides sp.                                                | 8446                                                                                                        | 
| Streptomyces afghaniensis                                       | 8447                                                                                                        | 
| Streptomyces bottropensis                                       | 8448                                                                                                        | 
| Streptomyces chartreusis                                        | 8449                                                                                                        | 
| Streptomyces ghanaensis                                         | 8450                                                                                                        | 
| Streptomyces ipomoeae                                           | 8451                                                                                                        | 
| Streptomyces mobaraensis NBRC 13819 =                           | 8452                                                                                                        | 
| Streptomyces rimosus subsp. rimosus                             | 8453                                                                                                        | 
| Streptomyces scabrisporus                                       | 8454                                                                                                        | 
| Streptomyces sp.                                                | 8455                                                                                                        | 
| Streptomyces tsukubaensis                                       | 8456                                                                                                        | 
| Streptomyces acidiscabies                                       | 8457                                                                                                        | 
| Streptomyces albus                                              | 8458                                                                                                        | 
| Streptomyces canus                                              | 8459                                                                                                        | 
| Streptomyces gancidicus                                         | 8460                                                                                                        | 
| Streptomyces sp.                                                | 8461                                                                                                        | 
| Streptomyces sp.                                                | 8462                                                                                                        | 
| Streptomyces sp.                                                | 8463                                                                                                        | 
| Streptomyces sp.                                                | 8464                                                                                                        | 
| Streptomyces sp.                                                | 8465                                                                                                        | 
| Streptomyces sp.                                                | 8466                                                                                                        | 
| Streptomyces sp.                                                | 8467                                                                                                        | 
| Streptomyces sp.                                                | 8468                                                                                                        | 
| Streptomyces sp.                                                | 8469                                                                                                        | 
| Streptomyces sp.                                                | 8470                                                                                                        | 
| Streptomyces sp.                                                | 8471                                                                                                        | 
| Streptomyces sp.                                                | 8472                                                                                                        | 
| Streptomyces sp.                                                | 8473                                                                                                        | 
| Streptomyces sp.                                                | 8474                                                                                                        | 
| Streptomyces sp.                                                | 8475                                                                                                        | 
| Streptomyces sp.                                                | 8476                                                                                                        | 
| Streptomyces sp.                                                | 8477                                                                                                        | 
| Streptomyces sp.                                                | 8478                                                                                                        | 
| Streptomyces sp.                                                | 8479                                                                                                        | 
| Streptomyces sp.                                                | 8480                                                                                                        | 
| Streptomyces clavuligerus                                       | 8481                                                                                                        | 
| Streptomyces clavuligerus                                       | 8482                                                                                                        | 
| Streptomyces griseoaurantiacus                                  | 8484                                                                                                        | 
| Streptomyces griseoflavus                                       | 8485                                                                                                        | 
| Streptomyces himastatinicus                                     | 8486                                                                                                        | 
| Streptomyces lividans                                           | 8487                                                                                                        | 
| Streptomyces niveus                                             | 8488                                                                                                        | 
| Streptomyces prunicolor                                         | 8489                                                                                                        | 
| Streptomyces purpureus                                          | 8490                                                                                                        | 
| Streptomyces roseosporus                                        | 8491                                                                                                        | 
| Streptomyces roseosporus                                        | 8492                                                                                                        | 
| Burkholderia gladioli                                           | 8493                                                                                                        | 
| Methylophilales bacterium                                       | 8496                                                                                                        | 
| beta proteobacterium                                            | 8497                                                                                                        | 
| Pseudomonas aeruginosa N002                                     | 8514                                                                                                        | 
| Streptomyces avermitilis                                        | 8527,8528                                                                                                   | 
| Streptomyces cattleya NRRL 8057 = DSM 46488                     | 8529,8530                                                                                                   | 
| Streptomyces collinus                                           | 8531,8532,8533                                                                                              | 
| Streptomyces davawensis                                         | 8535,8534                                                                                                   | 
| Streptomyces fulvissimus                                        | 8536                                                                                                        | 
| Streptomyces hygroscopicus subsp. jinggangensis TL01            | 8537,8538,8539                                                                                              | 
| Streptomyces rapamycinicus                                      | 8540                                                                                                        | 
| Streptomyces venezuelae                                         | 8541                                                                                                        | 
| Nocardiopsis alba                                               | 8544                                                                                                        | 
| Streptomyces albus                                              | 8545                                                                                                        | 
| Streptomyces sp.                                                | 8546                                                                                                        | 
| Streptomyces sp.                                                | 8547                                                                                                        | 
| Streptomyces sp.                                                | 8548                                                                                                        | 
| Streptomyces sp.                                                | 8549                                                                                                        | 
| Streptomyces sp.                                                | 8550                                                                                                        | 
| Streptomyces sp.                                                | 8552                                                                                                        | 
| Streptomyces sp.                                                | 8553                                                                                                        | 
| Streptomyces sp.                                                | 8554                                                                                                        | 
| Streptomyces bottropensis                                       | 8555                                                                                                        | 
| Polaribacter sp.                                                | 8556                                                                                                        | 
| Rhizobium etli                                                  | 8557,8558,8559,8560                                                                                         | 
| Rhizobium etli bv. mimosae                                      | 8562,8563,8564,8565,8566,8567,8561                                                                          | 
| Rickettsia rickettsii                                           | 8568                                                                                                        | 
| Streptomyces cattleya NRRL 8057 =                               | 8569,8570                                                                                                   | 
| Streptomyces pratensis                                          | 8571,8572,8573                                                                                              | 
| Streptomyces sp.                                                | 8574,8575                                                                                                   | 
| [Eubacterium] siraeum                                           | 8576                                                                                                        | 
| Streptococcus pneumoniae                                        | 8577                                                                                                        | 
| Streptococcus pneumoniae SPN034156                              | 8578                                                                                                        | 
| Streptococcus pneumoniae SPN034183                              | 8579                                                                                                        | 
| Streptococcus pneumoniae SPN994038                              | 8580                                                                                                        | 
| Streptococcus pneumoniae SPN994039                              | 8582                                                                                                        | 
| Streptococcus pneumoniae SPNA45                                 | 8583                                                                                                        | 
| Streptococcus pseudopneumoniae                                  | 8584,8585                                                                                                   | 
| Streptococcus pyogenes                                          | 8587                                                                                                        | 
| Streptococcus pyogenes                                          | 8588                                                                                                        | 
| Lysinibacillus parviboronicapiens                               | 8662                                                                                                        | 
| Agrobacterium arsenijevicii                                     | 8676                                                                                                        | 
| Agrobacterium vitis                                             | 8677                                                                                                        | 
| Agrobacterium sp.                                               | 8678                                                                                                        | 
| Bifidobacterium longum subsp. longum                            | 8681                                                                                                        | 
| Leptolinea tardivitalis                                         | 8684                                                                                                        | 
| bacterium endosymbiont of Mortierella elongata FMR23-6          | 8699                                                                                                        | 
| Actinoplanes friuliensis                                        | 8701                                                                                                        | 
| Actinoplanes missouriensis                                      | 8702                                                                                                        | 
| Actinoplanes sp.                                                | 8703                                                                                                        | 
| Actinoplanes sp.                                                | 8704                                                                                                        | 
| Amycolatopsis mediterranei                                      | 8705                                                                                                        | 
| Amycolatopsis mediterranei                                      | 8706                                                                                                        | 
| Amycolatopsis orientalis                                        | 8707,8708                                                                                                   | 
| Amycolatopsis mediterranei                                      | 8709                                                                                                        | 
| Magnetospirillum moscoviense                                    | 8710                                                                                                        | 
| Magnetospirillum marisnigri                                     | 8711                                                                                                        | 
| Epulopiscium sp.                                                | 8715                                                                                                        | 
| Klebsiella sp.                                                  | 8719                                                                                                        | 
| Echinicola pacifica                                             | 8726                                                                                                        | 
| Flavobacteriaceae bacterium                                     | 8727                                                                                                        | 
| Dietzia cinnamea                                                | 8728                                                                                                        | 
| Flexithrix dorotheae                                            | 8729                                                                                                        | 
| Gayadomonas joobiniege                                          | 8730                                                                                                        | 
| Gilvimarinus chinensis                                          | 8731                                                                                                        | 
| Lewinella persica                                               | 8732                                                                                                        | 
| Rhodopirellula sp.                                              | 8733                                                                                                        | 
| Cellulophaga geojensis                                          | 8735                                                                                                        | 
| Aquimarina latercula                                            | 8736                                                                                                        | 
| Saccharicrinis fermentans                                       | 8737                                                                                                        | 
| Algibacter lectus                                               | 8738                                                                                                        | 
| Cellulophaga sp.                                                | 8739                                                                                                        | 
| Pseudoalteromonas sp.                                           | 8740                                                                                                        | 
| Flammeovirga pacifica                                           | 8741                                                                                                        | 
| Flammeovirga sp.                                                | 8742                                                                                                        | 
| Gammaproteobacteria bacterium                                   | 8743                                                                                                        | 
| Maribacter thermophilus                                         | 8744                                                                                                        | 
| Flammeovirga sp.                                                | 8745                                                                                                        | 
| Aquimarina sp.                                                  | 8746                                                                                                        | 
| Paraglaciecola sp.                                              | 8747                                                                                                        | 
| Cellulophaga baltica                                            | 8748                                                                                                        | 
| Persicobacter sp.                                               | 8757,8758,8759,8760,8761,8762,8763,8764,8749,8765,8750,8751,8752,8753,8754,8755,8756                        | 
| Lactococcus lactis subsp. lactis                                | 8766                                                                                                        | 
| Alteromonas sp.                                                 | 8768                                                                                                        | 
| Catenovulum agarivorans                                         | 8769                                                                                                        | 
| Cellulophaga baltica                                            | 8770                                                                                                        | 
| Cupriavidus basilensis                                          | 8775                                                                                                        | 
| Cupriavidus sp.                                                 | 8776                                                                                                        | 
| Cupriavidus sp.                                                 | 8777                                                                                                        | 
| Cupriavidus sp.                                                 | 8778                                                                                                        | 
| Cupriavidus sp.                                                 | 8779                                                                                                        | 
| Cupriavidus sp.                                                 | 8780                                                                                                        | 
| Bacillus siamensis                                              | 8791                                                                                                        | 
| Bacillus pumilus                                                | 8792                                                                                                        | 
| Bacillus sonorensis                                             | 8793                                                                                                        | 
| [Clostridium] cf. saccharolyticum                               | 8802                                                                                                        | 
| Clostridium perfringens                                         | 8796,8804,8806,8807                                                                                         | 
| Clostridium saccharobutylicum                                   | 8803                                                                                                        | 
| Clostridium botulinum B1                                        | 8798,8809                                                                                                   | 
| Clostridium autoethanogenum                                     | 8800                                                                                                        | 
| Clostridium saccharoperbutylacetonicum                          | 8797,8808                                                                                                   | 
| Clostridium botulinum A                                         | 8801                                                                                                        | 
| Peptoclostridium difficile                                      | 8810,8799,8805                                                                                              | 
| Arthrospira platensis                                           | 8914                                                                                                        | 
| Paraburkholderia mimosarum                                      | 8918                                                                                                        | 
| Sulfuricella denitrificans                                      | 8962,8955                                                                                                   | 
| Halothiobacillus neapolitanus                                   | 8956                                                                                                        | 
| Thioalkalimicrobium cyclicum                                    | 8957                                                                                                        | 
| Thiocystis violascens                                           | 8961                                                                                                        | 
| Thioalkalivibrio sp.                                            | 8958,8966                                                                                                   | 
| Thioalkalivibrio nitratireducens                                | 8960                                                                                                        | 
| Thiobacillus denitrificans                                      | 8959                                                                                                        | 
| Thiomonas arsenitoxydans                                        | 8963,8965                                                                                                   | 
| Thioflavicoccus mobilis                                         | 8964,8967                                                                                                   | 
| Chlorobaculum parvum                                            | 8970                                                                                                        | 
| Chlorobium chlorochromatii                                      | 8969                                                                                                        | 
| Advenella kashmirensis                                          | 8976,8968                                                                                                   | 
| Chlorobium phaeobacteroides                                     | 8971                                                                                                        | 
| Chlorobium phaeovibrioides DSM 265                              | 8973                                                                                                        | 
| Chlorobium luteolum                                             | 8974                                                                                                        | 
| Halorhodospira halophila                                        | 8972                                                                                                        | 
| Sideroxydans lithotrophicus                                     | 8978                                                                                                        | 
| Prosthecochloris aestuarii                                      | 8975,8979                                                                                                   | 
| Rhodomicrobium vannielii                                        | 8977                                                                                                        | 
| Lactobacillus curvatus                                          | 8982                                                                                                        | 
| Lactobacillus sakei                                             | 8983                                                                                                        | 
| Lactobacillus reuteri                                           | 8986                                                                                                        | 
| Lactobacillus reuteri                                           | 8984,8989,8991,8994,8999                                                                                    | 
| Lactobacillus reuteri                                           | 8988                                                                                                        | 
| Lactobacillus reuteri                                           | 8987                                                                                                        | 
| Lactobacillus reuteri                                           | 8985,8990,8992,8995,9000,9001,9002                                                                          | 
| Lactobacillus iners                                             | 8993                                                                                                        | 
| Lactobacillus gasseri                                           | 8996                                                                                                        | 
| Lactobacillus jensenii                                          | 8997                                                                                                        | 
| Lactobacillus reuteri                                           | 8998                                                                                                        | 
| Lactobacillus crispatus                                         | 9003                                                                                                        | 
| Lactobacillus sanfranciscensis                                  | 9004                                                                                                        | 
| Lactobacillus fructivorans                                      | 9005                                                                                                        | 
| Mycobacterium vaccae                                            | 9033                                                                                                        | 
| Mycobacterium vaccae                                            | 9035                                                                                                        | 
| Mycobacterium austroafricanum                                   | 9036                                                                                                        | 
| Mycobacterium aurum                                             | 9037                                                                                                        | 
| Mycobacterium chubuense                                         | 9038                                                                                                        | 
| Mycobacterium vaccae                                            | 9040                                                                                                        | 
| Peptococcaceae bacterium RM                                     | 9041                                                                                                        | 
| Aminobacter aminovorans                                         | 9042,9043,9044,9045,9046                                                                                    | 
| Bacillus subtilis subsp. spizizenii                             | 9052                                                                                                        | 
| Lactococcus garvieae                                            | 9064                                                                                                        | 
| Lactococcus garvieae                                            | 9065                                                                                                        | 
| Lactococcus garvieae                                            | 9066                                                                                                        | 
| Lactococcus garvieae                                            | 9067                                                                                                        | 
| Lactococcus garvieae                                            | 9068                                                                                                        | 
| Nitrolancea hollandica                                          | 9080                                                                                                        | 
| Geobacter bemidjiensis                                          | 9111                                                                                                        | 
| Geobacter daltonii                                              | 9112                                                                                                        | 
| Geobacter lovleyi                                               | 9113,9114                                                                                                   | 
| Geobacter metallireducens                                       | 9115,9116                                                                                                   | 
| Geobacter sp.                                                   | 9117                                                                                                        | 
| Geobacter sp.                                                   | 9118                                                                                                        | 
| Geobacter sulfurreducens                                        | 9119                                                                                                        | 
| Geobacter uraniireducens                                        | 9120                                                                                                        | 
| Geobacter sulfurreducens                                        | 9122                                                                                                        | 
| Paraburkholderia sprentiae                                      | 9130                                                                                                        | 
| Paraburkholderia dilworthii                                     | 9131                                                                                                        | 
| Roseovarius sp.                                                 | 9132                                                                                                        | 
| Oceanicola batsensis                                            | 9134                                                                                                        | 
| Oceanicola granulosus                                           | 9135                                                                                                        | 
| Oceanibulbus indolifex                                          | 9136                                                                                                        | 
| Phaeobacter gallaeciensis                                       | 9137,9142,9145,9149                                                                                         | 
| Phaeobacter gallaeciensis                                       | 9139,9140,9144,9147,9148,9152,9153,9154                                                                     | 
| Phaeobacter inhibens                                            | 9146,9150,9138,9143                                                                                         | 
| Ruegeria pomeroyi                                               | 9141,9151                                                                                                   | 
| Silicibacter lacuscaerulensis                                   | 9182                                                                                                        | 
| Leisingera daeponensis                                          | 9183                                                                                                        | 
| Sediminimonas qiaohouensis                                      | 9184                                                                                                        | 
| Leisingera aquimarina                                           | 9185                                                                                                        | 
| Pseudophaeobacter arcticus                                      | 9186                                                                                                        | 
| Sedimentitalea nanhaiensis                                      | 9187                                                                                                        | 
| Leisingera caerulea                                             | 9188                                                                                                        | 
| Halanaerobium praevalens                                        | 9189                                                                                                        | 
| Yersinia aldovae                                                | 9190                                                                                                        | 
| Lactobacillus curvatus                                          | 9192                                                                                                        | 
| Acinetobacter guillouiae                                        | 9205                                                                                                        | 
| Enterococcus durans                                             | 9206                                                                                                        | 
| Pseudoalteromonas piscicida                                     | 9207                                                                                                        | 
| Pseudoalteromonas elyakovii                                     | 9208                                                                                                        | 
| Pseudoalteromonas piscicida                                     | 9209                                                                                                        | 
| Staphylococcus pasteuri                                         | 9210                                                                                                        | 
| Pseudoalteromonas sp.                                           | 9211                                                                                                        | 
| Staphylococcus sp.                                              | 9212                                                                                                        | 
| Hafnia alvei                                                    | 9213                                                                                                        | 
| Photobacterium phosphoreum                                      | 9214                                                                                                        | 
| Escherichia coli                                                | 9260                                                                                                        | 
| Propionibacterium acnes                                         | 9262                                                                                                        | 
| Propionibacterium acnes                                         | 9263                                                                                                        | 
| Propionibacterium acnes                                         | 9264,9265                                                                                                   | 
| Propionibacterium acnes TypeIA2                                 | 9266                                                                                                        | 
| Propionibacterium acnes                                         | 9267                                                                                                        | 
| Propionibacterium acnes                                         | 9268                                                                                                        | 
| Propionibacterium acnes                                         | 9269                                                                                                        | 
| Propionibacterium acnes                                         | 9270                                                                                                        | 
| Propionibacterium acnes                                         | 9271                                                                                                        | 
| Propionibacterium acnes                                         | 9272                                                                                                        | 
| Methanohalophilus mahii                                         | 9289                                                                                                        | 
| Olsenella uli                                                   | 9321                                                                                                        | 
| Echinicola vietnamensis                                         | 9322                                                                                                        | 
| Meiothermus silvanus DSM 9946                                   | 9323,9324,9325                                                                                              | 
| Thermobacillus composti                                         | 9326,9327                                                                                                   | 
| Frateuria aurantia                                              | 9328                                                                                                        | 
| Hirschia baltica ATCC 49814                                     | 9329,9330                                                                                                   | 
| Pseudomonas stutzeri                                            | 9331,9332,9333,9334                                                                                         | 
| Coraliomargarita akajimensis                                    | 9335                                                                                                        | 
| Halovivax ruber                                                 | 9336                                                                                                        | 
| Natronobacterium gregoryi                                       | 9337                                                                                                        | 
| Methanohalophilus sp                                            | 9338                                                                                                        | 
| Methanohalophilus sp                                            | 9339                                                                                                        | 
| Methanohalophilus sp                                            | 9340                                                                                                        | 
| Methanohalobium evestigatum                                     | 9341,9342                                                                                                   | 
| Natronococcus occultus                                          | 9343,9344,9345                                                                                              | 
| Cellvibrio japonicus                                            | 9414                                                                                                        | 
| Lactobacillus curvatus                                          | 9465                                                                                                        | 
| Azospirillum brasilense                                         | 9468,9469,9470,9471,9472,9473                                                                               | 
| Azospirillum humicireducens                                     | 9474                                                                                                        | 
| Azospirillum thiophilum                                         | 9478,9479,9480,9481,9482,9475,9476,9477                                                                     | 
| Lactobacillus plantarum                                         | 9485,9486,9487,9488                                                                                         | 
| Lactococcus lactis subsp. cremoris                              | 9489                                                                                                        | 
| Lactococcus lactis subsp. cremoris                              | 9490                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 9491                                                                                                        | 
| Lactococcus lactis subsp. lactis                                | 9492                                                                                                        | 
| Lactococcus lactis subsp. lactis bv. diacetylactis              | 9493                                                                                                        | 
| Lactobacillus plantarum subsp. plantarum NC8                    | 9494                                                                                                        | 
| Lactococcus garvieae                                            | 9495                                                                                                        | 
| Mycobacterium tuberculosis                                      | 9496                                                                                                        | 
| Pseudomonas protegens                                           | 9497                                                                                                        | 
| Yersinia intermedia                                             | 9539                                                                                                        | 
| Lysinibacillus contaminans                                      | 9571                                                                                                        | 
| Lysinibacillus fusiformis                                       | 9572                                                                                                        | 
| Lysinibacillus macroides                                        | 9573                                                                                                        | 
| Lysinibacillus pakistanensis                                    | 9574                                                                                                        | 
| Lysinibacillus parviboronicapiens JCM 18861                     | 9575                                                                                                        | 
| Lysinibacillus sp. AR18-8                                       | 9576                                                                                                        | 
| Lysinibacillus sp. F5                                           | 9577                                                                                                        | 
| Lysinibacillus sp. FJAT-14745                                   | 9578                                                                                                        | 
| Lysinibacillus sp. ZYM-1                                        | 9579                                                                                                        | 
| Lysinibacillus sphaericus                                       | 9580                                                                                                        | 
| Lysinibacillus sphaericus                                       | 9581                                                                                                        | 
| Lysinibacillus sphaericus                                       | 9582                                                                                                        | 
| Lysinibacillus sphaericus                                       | 9583,9586                                                                                                   | 
| Lysinibacillus sphaericus                                       | 9584,9587                                                                                                   | 
| Lysinibacillus sphaericus                                       | 9585                                                                                                        | 
| Curtobacterium ammoniigenes                                     | 9589                                                                                                        | 
| Gryllotalpicola ginsengisoli                                    | 9590                                                                                                        | 
| Curtobacterium flaccumfaciens                                   | 9591                                                                                                        | 
| Curtobacterium oceanosedimentum                                 | 9592                                                                                                        | 
| Curtobacterium citreum                                          | 9593                                                                                                        | 
| Curtobacterium luteum                                           | 9594                                                                                                        | 
| Staphylococcus pasteuri                                         | 9595                                                                                                        | 
| Propionibacterium freudenreichii                                | 9596                                                                                                        | 
| Lactococcus lactis                                              | 9597                                                                                                        | 
| Propionibacterium freudenreichii                                | 9598                                                                                                        | 
| Propionibacterium acnes                                         | 9599                                                                                                        | 
| Propionibacterium acnes                                         | 9600                                                                                                        | 
| Propionibacterium acnes                                         | 9601                                                                                                        | 
| Propionibacterium acnes TypeIA2                                 | 9602                                                                                                        | 
| Propionibacterium acnes TypeIA2                                 | 9603                                                                                                        | 
| Propionibacterium acnes                                         | 9604                                                                                                        | 
| Propionibacterium acnes                                         | 9605                                                                                                        | 
| Propionibacterium acnes                                         | 9606                                                                                                        | 
| Propionibacterium acnes                                         | 9607                                                                                                        | 
| Propionibacterium acnes                                         | 9608                                                                                                        | 
| Clostridium pasteurianum                                        | 9609                                                                                                        | 
| Clostridium sporogenes                                          | 9610                                                                                                        | 
| Clostridium saccharoperbutylacetonicum N1-4(HMT)                | 9611                                                                                                        | 
| Clostridium sporogenes                                          | 9612                                                                                                        | 
| Clostridium thermocellum                                        | 9613                                                                                                        | 
| Clostridium thermocellum                                        | 9614                                                                                                        | 
| Roseburia inulinivorans                                         | 9615                                                                                                        | 
| Roseburia inulinivorans CAG:15                                  | 9616                                                                                                        | 
| Ruminiclostridium thermocellum                                  | 9618                                                                                                        | 
| Clostridium pasteurianum                                        | 9624                                                                                                        | 
| Microcystis aeruginosa NIES-98                                  | 9625                                                                                                        | 
| Propionibacterium acnes                                         | 9637                                                                                                        | 
| Propionibacterium acnes                                         | 9638                                                                                                        | 
| Propionibacterium acnes                                         | 9639                                                                                                        | 
| Propionibacterium acnes                                         | 9640                                                                                                        | 
| Propionibacterium acnes                                         | 9641                                                                                                        | 
| Propionibacterium acnes                                         | 9642                                                                                                        | 
| Propionibacterium acnes                                         | 9643                                                                                                        | 
| Propionibacterium acnes                                         | 9644                                                                                                        | 
| Propionibacterium acnes                                         | 9645                                                                                                        | 
| Propionibacterium acnes                                         | 9646                                                                                                        | 
| Propionibacterium acnes                                         | 9647                                                                                                        | 
| Propionibacterium acnes                                         | 9648                                                                                                        | 
| Propionibacterium acnes                                         | 9649                                                                                                        | 
| Propionibacterium acnes                                         | 9650                                                                                                        | 
| Propionibacterium acnes                                         | 9651                                                                                                        | 
| Propionibacterium acnes                                         | 9652                                                                                                        | 
| Propionibacterium acnes                                         | 9653                                                                                                        | 
| Propionibacterium acnes                                         | 9654                                                                                                        | 
| Propionibacterium acnes                                         | 9655                                                                                                        | 
| Propionibacterium acnes                                         | 9656                                                                                                        | 
| Escherichia coli                                                | 9657                                                                                                        | 
| Moraxella osloensis                                             | 9679,9680,9681,9682,9683                                                                                    | 
| Moraxella osloensis                                             | 9684,9685,9686,9687                                                                                         | 
| Lactobacillus reuteri                                           | 9688                                                                                                        | 
| Lactobacillus reuteri                                           | 9689                                                                                                        | 
| Lactobacillus reuteri                                           | 9690                                                                                                        | 
| Lactobacillus reuteri                                           | 9691                                                                                                        | 
| Lactobacillus reuteri                                           | 9692                                                                                                        | 
| Lactobacillus reuteri                                           | 9693                                                                                                        | 
| Lactobacillus reuteri                                           | 9694                                                                                                        | 
| Microcystis aeruginosa                                          | 9695                                                                                                        | 
| Rhodococcus ruber                                               | 9778                                                                                                        | 
| Propionibacterium freudenreichii subsp. freudenreichii          | 9796                                                                                                        | 
| Propionibacterium freudenreichii subsp. shermanii               | 9797                                                                                                        | 
| Propionibacterium freudenreichii subsp. freudenreichii          | 9798                                                                                                        | 
| Propionibacterium freudenreichii subsp. freudenreichii          | 9799                                                                                                        | 
| Propionibacterium freudenreichii                                | 9800                                                                                                        | 
| Propionibacterium freudenreichii                                | 9801                                                                                                        | 
| Propionibacterium freudenreichii                                | 9802                                                                                                        | 
| Propionibacterium freudenreichii                                | 9803                                                                                                        | 
| Propionibacterium freudenreichii                                | 9804                                                                                                        | 
| Propionibacterium freudenreichii                                | 9805                                                                                                        | 
| Propionibacterium freudenreichii                                | 9806                                                                                                        | 
| Propionibacterium freudenreichii                                | 9807                                                                                                        | 
| Propionibacterium freudenreichii                                | 9808                                                                                                        | 
| Propionibacterium freudenreichii                                | 9809                                                                                                        | 
| Propionibacterium freudenreichii                                | 9810                                                                                                        | 
| Propionibacterium freudenreichii                                | 9811                                                                                                        | 
| Propionibacterium freudenreichii                                | 9812                                                                                                        | 
| Propionibacterium freudenreichii                                | 9813                                                                                                        | 
| Propionibacterium freudenreichii                                | 9814                                                                                                        | 
| Propionibacterium freudenreichii                                | 9815                                                                                                        | 
| Flavobacterium psychrophilum                                    | 9816                                                                                                        | 
| Flavobacterium psychrophilum                                    | 9817                                                                                                        | 
| Flavobacterium psychrophilum                                    | 9818                                                                                                        | 
| Flavobacterium psychrophilum                                    | 9819                                                                                                        | 
| Enterococcus mundtii                                            | 9820                                                                                                        | 
| Sinorhizobium meliloti                                          | 9821                                                                                                        | 
| Sinorhizobium meliloti                                          | 9822                                                                                                        | 
| Clostridium bifermentans                                        | 9831                                                                                                        | 
| Clostridium bifermentans                                        | 9832                                                                                                        | 
| Clostridium hathewayi CAG:224                                   | 9833                                                                                                        | 
| Clostridium carboxidivorans                                     | 9834                                                                                                        | 
| Clostridium carboxidivorans                                     | 9835                                                                                                        | 
| Clostridium cellulovorans                                       | 9836                                                                                                        | 
| Hungatella hathewayi                                            | 9837                                                                                                        | 
| Hungatella hathewayi                                            | 9838                                                                                                        | 
| Hungatella hathewayi                                            | 9839                                                                                                        | 
| Clostridium termitidis CT1112                                   | 9840                                                                                                        | 
| Ruminococcus bromii                                             | 9876                                                                                                        | 
| Ruminococcus champanellensis 18P13 = JCM 17042                  | 9877                                                                                                        | 
| Acidothermus cellulolyticus 11B                                 | 9878                                                                                                        | 
| [Clostridium] clariflavum                                       | 9879                                                                                                        | 
| Ruminococcus torques                                            | 9880                                                                                                        | 
| Acetivibrio cellulolyticus                                      | 9881                                                                                                        | 
| Ruminococcus flavefaciens                                       | 9882                                                                                                        | 
| Clostridium papyrosolvens                                       | 9883                                                                                                        | 
| Propionibacterium acnes                                         | 9884                                                                                                        | 
| Propionibacterium acnes                                         | 9885                                                                                                        | 
| Propionibacterium acnes                                         | 9886                                                                                                        | 
| Propionibacterium acnes                                         | 9887                                                                                                        | 
| Propionibacterium acnes                                         | 9888                                                                                                        | 
| Propionibacterium acnes                                         | 9889                                                                                                        | 
| Propionibacterium acnes                                         | 9890                                                                                                        | 
| Propionibacterium acnes                                         | 9891                                                                                                        | 
| Propionibacterium acnes                                         | 9892                                                                                                        | 
| Propionibacterium acnes                                         | 9893                                                                                                        | 
| Clostridium nexile CAG:348                                      | 9894                                                                                                        | 
| Clostridium thermocellum BC1                                    | 9895                                                                                                        | 
| Clostridium tyrobutyricum DSM 2637 = ATCC 25755 = JCM 11008     | 9896                                                                                                        | 
| Terrisporobacter glycolicus ATCC 14880                          | 9897                                                                                                        | 
| Tyzzerella nexilis                                              | 9898                                                                                                        | 
| Ruminiclostridium thermocellum                                  | 9899                                                                                                        | 
| Clostridium tyrobutyricum                                       | 9900                                                                                                        | 
| Clostridium tyrobutyricum                                       | 9901                                                                                                        | 
| Bradyrhizobiaceae bacterium                                     | 9917                                                                                                        | 
| Bradyrhizobium sp.                                              | 9918                                                                                                        | 
| Bradyrhizobium sp.                                              | 9919                                                                                                        | 
| Bradyrhizobium sp.                                              | 9920                                                                                                        | 
| Bradyrhizobium sp.                                              | 9921                                                                                                        | 
| Bradyrhizobium sp. DFCI-1                                       | 9922                                                                                                        | 
| Rhizobium leguminosarum bv. trifolii                            | 9923                                                                                                        | 
| Flavobacterium columnare                                        | 9926                                                                                                        | 
| Flavobacterium columnare                                        | 9927                                                                                                        | 
| Flavobacterium columnare                                        | 9928                                                                                                        | 
| Flavobacterium columnare                                        | 9929                                                                                                        | 
| Lysinibacillus sphaericus                                       | 9930                                                                                                        | 
| Lysinibacillus xylanilyticus                                    | 9931                                                                                                        | 
| Allobaculum stercoricanis                                       | 9957                                                                                                        | 
| Pseudoalteromonas undina DSM 6065                               | 9961                                                                                                        | 
| Pseudoalteromonas sp.                                           | 9962                                                                                                        | 
| Pseudoalteromonas sp.                                           | 9963                                                                                                        | 
| Pseudoalteromonas ruthenica                                     | 9964                                                                                                        | 
| Pseudoalteromonas marina DSM 17587                              | 9965                                                                                                        | 
| Pseudoalteromonas flavipulchra                                  | 9968                                                                                                        | 
| Pseudoalteromonas haloplanktis                                  | 9969                                                                                                        | 
| Propionibacterium acidifaciens                                  | 10030                                                                                                       | 
| Propionibacterium acnes                                         | 10031                                                                                                       | 
| Propionibacterium acnes                                         | 10032                                                                                                       | 
| Propionibacterium acnes                                         | 10033                                                                                                       | 
| Propionibacterium humerusii                                     | 10034                                                                                                       | 
| Propionibacterium acnes                                         | 10035                                                                                                       | 
| Propionibacterium acnes                                         | 10036                                                                                                       | 
| Propionibacterium acnes                                         | 10037                                                                                                       | 
| Desulfovibrio sp.                                               | 10045                                                                                                       | 
| Lactobacillus acidipiscis                                       | 10046                                                                                                       | 
| Parabacteroides distasonis                                      | 10048                                                                                                       | 
| Parabacteroides johnsonii                                       | 10049                                                                                                       | 
| Parabacteroides merdae                                          | 10050                                                                                                       | 
| Clostridium hiranonis                                           | 10069                                                                                                       | 
| Intestinibacter bartlettii                                      | 10070                                                                                                       | 
| Clostridium bartlettii                                          | 10071                                                                                                       | 
| Clostridium celatum                                             | 10072                                                                                                       | 
| Clostridium citroniae                                           | 10073                                                                                                       | 
| Clostridium hylemonae                                           | 10074                                                                                                       | 
| Clostridium leptum                                              | 10075                                                                                                       | 
| Clostridium leptum                                              | 10076                                                                                                       | 
| Clostridium tunisiense                                          | 10077                                                                                                       | 
| Propionibacterium acnes                                         | 10129                                                                                                       | 
| Propionibacterium acnes                                         | 10130                                                                                                       | 
| Propionibacterium acnes                                         | 10131                                                                                                       | 
| Propionibacterium acnes                                         | 10132                                                                                                       | 
| Propionibacterium acnes                                         | 10133                                                                                                       | 
| Propionibacterium acnes                                         | 10134                                                                                                       | 
| Cutibacterium avidum                                            | 10135                                                                                                       | 
| Cutibacterium granulosum                                        | 10136                                                                                                       | 
| Cutibacterium granulosum                                        | 10137                                                                                                       | 
| Cutibacterium avidum                                            | 10138                                                                                                       | 
| Cycloclasticus zancles                                          | 10142,10144                                                                                                 | 
| Dichelobacter nodosus                                           | 10143                                                                                                       | 
| Spiribacter sp.                                                 | 10147                                                                                                       | 
| Spiribacter salinus                                             | 10146                                                                                                       | 
| Oceanimonas sp.                                                 | 10145,10148,10150                                                                                           | 
| Teredinibacter turnerae                                         | 10149                                                                                                       | 
| Fangia hongkongensis FSC776                                     | 10162                                                                                                       | 
| Arhodomonas aquaeolei                                           | 10163                                                                                                       | 
| Beggiatoa alba                                                  | 10164                                                                                                       | 
| Leucothrix mucor                                                | 10165                                                                                                       | 
| Thiocapsa marina                                                | 10166                                                                                                       | 
| Thiorhodococcus drewsii                                         | 10167                                                                                                       | 
| Thiorhodospira sibirica                                         | 10168                                                                                                       | 
| Thiorhodovibrio sp.                                             | 10169                                                                                                       | 
| Thiothrix nivea                                                 | 10170                                                                                                       | 
| Pseudoalteromonas sp.                                           | 10171                                                                                                       | 
| Pseudoalteromonas sp.                                           | 10172                                                                                                       | 
| Pseudoalteromonas sp.                                           | 10173                                                                                                       | 
| Pseudoalteromonas sp.                                           | 10174                                                                                                       | 
| Pseudoalteromonas sp.                                           | 10175                                                                                                       | 
| Pseudoalteromonas sp.                                           | 10176                                                                                                       | 
| Pseudoalteromonas sp.                                           | 10177                                                                                                       | 
| Pseudomonas pseudoalcaligenes KF707                             | 10178                                                                                                       | 
| Pseudomonas pseudoalcaligenes CECT 5344                         | 10179                                                                                                       | 
| Nitrococcus mobilis                                             | 10182                                                                                                       | 
| uncultured Thiohalocapsa sp. PB-PSB1                            | 10183                                                                                                       | 
| Lamprocystis purpurea                                           | 10186                                                                                                       | 
| Cycloclasticus pugetii                                          | 10187                                                                                                       | 
| Rhodobacter sphaeroides KD131                                   | 10188,10189,10190,10191                                                                                     | 
| Bilophila sp.                                                   | 10192                                                                                                       | 
| Bilophila wadsworthia                                           | 10193                                                                                                       | 
| Rhodobacter sphaeroides                                         | 10194                                                                                                       | 
| Rhodobacter sphaeroides                                         | 10195                                                                                                       | 
| Rhodobacter sphaeroides                                         | 10196                                                                                                       | 
| Silicibacter sp.                                                | 10197                                                                                                       | 
| Acidiferrobacter thiooxydans                                    | 10215                                                                                                       | 
| Alteromonas sp.                                                 | 10216                                                                                                       | 
| Spongiibacter sp.                                               | 10217,10218                                                                                                 | 
| Arsukibacterium sp.                                             | 10219                                                                                                       | 
| Candidatus Tenderia electrophaga                                | 10220,10221                                                                                                 | 
| Marichromatium purpuratum 984                                   | 10222                                                                                                       | 
| Thiocapsa sp.                                                   | 10223                                                                                                       | 
| Rheinheimera sp.                                                | 10224                                                                                                       | 
| Thiohalocapsa sp.                                               | 10225                                                                                                       | 
| Thiorhodococcus sp                                              | 10226                                                                                                       | 
| Rheinheimera salexigens                                         | 10227                                                                                                       | 
| Acidihalobacter ferrooxidans                                    | 10228                                                                                                       | 
| Acidihalobacter prosperus                                       | 10229                                                                                                       | 
| Aquisalimonas asiatica                                          | 10230                                                                                                       | 
| Ectothiorhodosinus mongolicus                                   | 10231                                                                                                       | 
| Ectothiorhodospira sp.                                          | 10232                                                                                                       | 
| Ectothiorhodospira haloalkaliphila                              | 10233                                                                                                       | 
| Ectothiorhodospira mobilis                                      | 10234                                                                                                       | 
| Halofilum ochraceum                                             | 10235                                                                                                       | 
| Halorhodospira halochloris                                      | 10236                                                                                                       | 
| Thioalkalivibrio versutus                                       | 10237                                                                                                       | 
| Thiohalomonas denitrificans                                     | 10238                                                                                                       | 
| Thiohalospira halophila                                         | 10239                                                                                                       | 
| Halothiobacillus sp.                                            | 10240                                                                                                       | 
| Wenzhouxiangella marina                                         | 10241                                                                                                       | 
| Woeseia oceani                                                  | 10242                                                                                                       | 
| Gynuella sunshinyii                                             | 10243                                                                                                       | 
| Gilliamella apicola                                             | 10244                                                                                                       | 
| Frischella perrara                                              | 10245                                                                                                       | 
| Allofrancisella guangzhouensis                                  | 10246,10247                                                                                                 | 
| Hydrogenovibrio marinus                                         | 10248                                                                                                       | 
| Hydrogenovibrio marinus                                         | 10249                                                                                                       | 
| Piscirickettsia salmonis LF-89 =                                | 10250,10251,10252,10253                                                                                     | 
| Sulfurivirga caldicuralii                                       | 10254                                                                                                       | 
| Thioalkalimicrobium aerophilum                                  | 10255                                                                                                       | 
| Thiothrix lacustris                                             | 10256                                                                                                       | 
| Lokiarchaeum sp                                                 | 10258                                                                                                       | 
| Candidatus Lokiarchaeota archaeon                               | 10259                                                                                                       | 
| Candidatus Thorarchaeota archaeon                               | 10260                                                                                                       | 
| Candidatus Thorarchaeota archaeon                               | 10261                                                                                                       | 
| Candidatus Thorarchaeota archaeon                               | 10262                                                                                                       | 
| Candidatus Odinarchaeota archaeon                               | 10263                                                                                                       | 
| Candidatus Heimdallarchaeota archaeon                           | 10264                                                                                                       | 
| Candidatus Heimdallarchaeota archaeon                           | 10265                                                                                                       | 
| Candidatus Heimdallarchaeota archaeon                           | 10266                                                                                                       | 
| Lactobacillus curvatus                                          | 10275                                                                                                       | 
| Lactobacillus curvatus                                          | 10276                                                                                                       | 
| Lactobacillus curvatus                                          | 10277                                                                                                       | 
| Lactobacillus curvatus                                          | 10278                                                                                                       | 
| Leptospira interrogans serovar Manilae                          | 10279,10280,10281                                                                                           | 
| Cupriavidus sp.                                                 | 10289                                                                                                       | 
| Propionibacterium avidum                                        | 10290                                                                                                       | 
| Propionibacterium acidipropionici                               | 10291                                                                                                       | 
| Propionibacterium propionicum                                   | 10292                                                                                                       | 
| Propionibacterium acnes                                         | 10293                                                                                                       | 
| Propionibacterium acnes                                         | 10294                                                                                                       | 
| Propionibacterium acnes                                         | 10295                                                                                                       | 
| Propionibacterium acnes                                         | 10296                                                                                                       | 
| Propionibacterium humerusii                                     | 10297                                                                                                       | 
| Propionibacterium acnes                                         | 10298                                                                                                       | 
| delta proteobacterium                                           | 10315                                                                                                       | 
| Halobacillus halophilus                                         | 10317,10318,10319                                                                                           | 
| Halomicrobium mukohataei                                        | 10320,10321                                                                                                 | 
| halophilic archaeon                                             | 10323,10324,10322                                                                                           | 
| Lactobacillus sakei                                             | 10327                                                                                                       | 
| Lactobacillus sakei                                             | 10328                                                                                                       | 
| Lactobacillus sakei                                             | 10329                                                                                                       | 
| Lactobacillus sakei                                             | 10330                                                                                                       | 
| Lactobacillus sakei                                             | 10331                                                                                                       | 
| Lactobacillus sakei                                             | 10332                                                                                                       | 
| Tannerella forsythia                                            | 10354                                                                                                       | 
| Alistipes finegoldii                                            | 10355                                                                                                       | 
| Alistipes shahii                                                | 10356                                                                                                       | 
| Odoribacter splanchnicus DSM 20712                              | 10357                                                                                                       | 
| Mucilaginibacter paludis                                        | 10358                                                                                                       | 

