#!/usr/bin/env python3
import csv
import argparse
import re
import sys
from os.path import isfile

# Calling the 'checkInstallation' function checks if Python is >= 2.7 and < 3
requiredVersion = (3,5)
compounds = { "PM01": "carbon", "PM02" : "carbon", "PM03" : "nitrogen", "PM04" : "sulfur" }
ids       = {}


def check_installation(rv):
    current_version = sys.version_info
    if current_version[0] == rv[0] and current_version[1] >= rv[1]:
        pass
    else:
        sys.stderr.write( "{} - Error: Your Python interpreter must be {}.{} or greater (within major version {})\n".format(sys.argv[0], rv[0], rv[1], rv[0]) )
        sys.exit(-1)
    return 0

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def parse_commandline():
    parser = argparse.ArgumentParser()
    parser.add_argument( "MAPPER", type=argparse.FileType('r'), help='is a tabulated file: "Plate" "Position" "Property name" "Property id" "Description"' )
    parser.add_argument( "OUTPUT", type=argparse.FileType('w'), help='is a file path to store well formatted expectation' )
    parser.add_argument( "BIOLOGS", type=argparse.FileType('r'), nargs='+', help='is a list of tabulated file formated as: "Plate" "Position" "Observation"' )
    return parser.parse_args()


def load_mapper( mapper_file ):
    # Plate position nrj_source prior_knowledge_id description
    mapper = {}
    with mapper_file as f:
        for row in csv.reader( f, delimiter='\t', quotechar='"' ):
            if len(row) == 5 :
                # warn if position row x plate appear twice only latest stored values is kept
                mapper[ row[0].strip() + "_" + row[1].strip() ] = ( row[2].strip(), row[3].strip(), row[4].strip() ) # [ nrj_source, prior-knowledge id, description ]
    return mapper


def write_expectation( out, biolog, mapper ):
    name                = ""
    name_id             = ""
    evidence            = ""
    obs_type            = "EXPERIMENTATION"
    obs_source_suffix   = "BIOLOG experimentation: "
    obs_source          = ""
    label               = ""
    description         = ""
    counter             = 0
    reader              = None
    experiment_date     = ""
    name                = ""
    priorknowledge      = ""
    obs_source          = ""
    name_id             = ""
    plate               = ""
    with biolog as file_input:
        reader          = csv.DictReader( file_input, delimiter='\t', quotechar='"')
        matcher         = re.search('.*_([0-9]{6}).*\..*$', biolog.name)
        if matcher is None:
            experiment_date = "unknown"
        else:
            experiment_date = matcher.group(1)
        for row in reader:
            plate           = row["Plate_Type"]
            name            = plate + "_" + row["Well"]
            obs_source      = obs_source_suffix + experiment_date
            if name in mapper:
                priorknowledge  = mapper[ name ] # [ nrj_source, prior-knowledge id, description ]
                if name in ids:
                    counter = ids[ name ]
                    ids[ name ] += 1
                else:
                    ids[ name ] = 1
                name_id     = name + "_" + str(ids[ name ])
                description = priorknowledge[2] + " as " + compounds[ plate ] + " source."
                if row["Discretized"] == "TRUE":
                    out.write( '"{0}";"{1}";"{2}";"T";"{3}";"{4}";"Growth with {5} as {6} source"\n'.format( name_id, priorknowledge[1], obs_type, obs_source, priorknowledge[2], priorknowledge[0], compounds[plate] ) )
                elif row["Discretized"] == "FALSE":
                    out.write( '"{0}";"{1}";"{2}";"F";"{3}";"{4}";"No growth with {5} as {6} source"\n'.format( name_id, priorknowledge[1], obs_type, obs_source, priorknowledge[2], priorknowledge[0], compounds[plate] ) )
                elif row["Discretized"] == "NA":
                    out.write( '"{0}";"{1}";"{2}";"T";"{3}";"{4}";"Growth with {5} as {6} source"\n'.format( name_id, priorknowledge[1], obs_type, obs_source, priorknowledge[2], priorknowledge[0], compounds[plate] ) )
                    ids[ name ] += 1
                    name_id = name + "_" + str(ids[ name ])
                    out.write( '"{0}";"{1}";"{2}";"F";"{3}";"{4}";"No growth with {5} as {6} source"\n'.format( name_id, priorknowledge[1], obs_type, obs_source, priorknowledge[2], priorknowledge[0], compounds[plate] ) )
                else:
                    eprint( "Error: biolog file is badly formatted. Unknown observation: " + row["Discretized"] )
                    sys.exit(1)


def main():
    check_installation(requiredVersion)
    args   = parse_commandline()
    mapper = load_mapper( args.MAPPER )

    with args.OUTPUT as out:
        out.write( '"Name";"EvidenceFor";"Type";"isPresent";"Source";"Label";"Description"\n' )
        for biolog in args.BIOLOGS:
            if not isfile( biolog.name ):
                eprint( "Error File " + biolog + " do not exists " )
                sys.exit(1)
            write_expectation( out, biolog, mapper)


if __name__ == "__main__":
    main()

sys.exit(0)
