/*
 *
 * Copyright LABGeM 2015
 *
 * author: Jonathan MERCIER
 *
 * This software is a computer program whose purpose is to annotate a complete genome.
 *
 * This software is governed by the CeCILL  license under French law and
 * abiding by the rules of distribution of free software.  You can  use,
 * modify and/ or redistribute the software under the terms of the CeCILL
 * license as circulated by CEA, CNRS and INRIA at the following URL
 * "http://www.cecill.info".
 *
 * As a counterpart to the access to the source code and  rights to copy,
 * modify and redistribute granted by the license, users are provided only
 * with a limited warranty  and the software's author,  the holder of the
 * economic rights,  and the successive licensors  have only  limited
 * liability.
 *
 * In this respect, the user's attention is drawn to the risks associated
 * with loading,  using,  modifying and/or developing or reproducing the
 * software by the user in light of its specific status of free software,
 * that may mean  that it is complicated to manipulate,  and  that  also
 * therefore means  that it is reserved for developers  and  experienced
 * professionals having in-depth computer knowledge. Users are therefore
 * encouraged to load and test the software's suitability as regards their
 * requirements in conditions enabling the security of their systems and/or
 * data to be ensured and,  more generally, to use and operate it in the
 * same conditions as regards security.
 *
 * The fact that you are presently reading this means that you have had
 * knowledge of the CeCILL license and that you accept its terms.
 *
 */

package fr.cea.ig.grools.application;

import ch.qos.logback.classic.Logger;
import fr.cea.ig.genome_properties.model.ComponentEvidence;
import fr.cea.ig.grools.Integrator;
import fr.cea.ig.grools.Mode;
import fr.cea.ig.grools.Reasoner;
import fr.cea.ig.grools.Verbosity;
import fr.cea.ig.grools.drools.ReasonerImpl;
import fr.cea.ig.grools.fact.*;
import fr.cea.ig.grools.genome_properties.GenomePropertiesIntegrator;
import fr.cea.ig.grools.logic.TruthValue;
import fr.cea.ig.grools.obo.OboIntegrator;
import fr.cea.ig.grools.svg.GraphWriter;
import fr.cea.ig.io.model.obo.UPA;
import fr.cea.ig.io.parser.OboParser;
import lombok.NonNull;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVRecord;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Main
 */
public class Main {
    private final static Logger LOGGER  = (Logger) LoggerFactory.getLogger( Main.class );

    private static final String VERSION = "1.0.0";
    private static final String APPNAME = "grools-application";

    private static void showHelp( final Options options){
        final HelpFormatter formatter   = new HelpFormatter();
        formatter.printHelp( APPNAME +"[OPTION] csv_file outpur_dir", options );
        System.out.println();
        System.out.println("Note: Parameter unipathway  and genome-properties are mutually exclusive");
        System.out.println("Note: Parameter dispensable and specific are mutually exclusive");
    }

    private static void showVersion( final Options options){
        System.out.println(APPNAME +" version "+ VERSION);
    }

    private static CommandLine parseArgs( String[] args ){
        CommandLine cli = null;
        final Options       options     = new Options();

        options.addOption( "h", "help"              , false , "Display usage" );
        options.addOption( "v", "version"           , false , "Display application version");
        options.addOption( "f", "falsehood"         , false , "Non observed HMM matching to leaves prior-knowledge are considered as False (only with genome-properties)");
        options.addOption( "u", "unipathway"        , false , "use unipathway as graph of prior-knowledge");
        options.addOption( "g", "genome-properties" , false , "use genome-properties as graph of prior-knowledge");
        options.addOption( "i", "input"             , true  , "use a external file to make prior-knowledge graph");
        options.addOption( "d", "dispensable"       , false , "Enable the mode dispensable");
        options.addOption( "s", "specific"          , false , "Enable the mode specific");

        if (args.length < 1) {
            LOGGER.error( "Error: any parameter provided");
            System.out.println();
            showHelp( options );
            System.exit( 1 );
        }

        final CommandLineParser parser  = new DefaultParser();

        try {
            cli     = parser.parse( options, args );
            if( cli.hasOption( "help" ) ){
                showHelp( options );
                System.exit( 0 );
            }
            else if( cli.hasOption( "version" ) ){
                showVersion( options );
                System.exit( 0 );
            }
            else if( ! cli.hasOption( "unipathway" ) &&  ! cli.hasOption( "genome-properties" ) ){
                LOGGER.error( "Unipathway or genome-properties options need to be provided!" );
                showHelp( options );
                System.exit( 1 );
            }
            else if( cli.hasOption( "unipathway" ) &&  cli.hasOption( "genome-properties" ) ){
                LOGGER.error( "Unipathway and genome-properties options are mutually exclusive" );
                showHelp( options );
                System.exit( 1 );
            }
            else if( cli.hasOption( "dispensable" ) &&  cli.hasOption( "specific" ) ){
                LOGGER.error( "Dispensable and specific options are mutually exclusive" );
                showHelp( options );
                System.exit( 1 );
            }
            else if( cli.getArgs().length != 2 ){
                LOGGER.error( "A csv well formatted is expected!" );
                LOGGER.error( "A One output directory is expected!" );
                showHelp( options );
                System.exit( 1 );
            }
        } catch ( ParseException e ) {
            LOGGER.error( "Unexpected exception:" + e.getMessage() );
            System.out.println();
            showHelp( options );
        }
        return cli;
    }

    private static ObservationType observationTypeStrToObservationType( final String observationTypeStr ){
        ObservationType obsType = null;
        try {
            obsType = ObservationType.valueOf( observationTypeStr );
        }
        catch ( IllegalArgumentException e ) {
            LOGGER.error( "Error: the record " + observationTypeStr +" is not an accepted value" );
            LOGGER.error( "Accepted values: " + Arrays.stream(ObservationType.values())
                                                            .map(i -> i.toString())
                                                            .collect( Collectors.joining( ", ")) );
            System.exit( 1 );
        }
        return obsType;
    }

    private static TruthValue isPresentStrToTruthValue( final String isPresentStr ){
        TruthValue isPresent;

        switch ( isPresentStr ){
            case "t":
            case "T":
            case "True":
            case "TRUE":
            case "true":
                isPresent = TruthValue.t;
                break;
            case "f":
            case "F":
            case "False":
            case "FALSE":
            case "false":
                isPresent = TruthValue.f;
                break;
            default:
                isPresent = TruthValue.t;
        }
        return isPresent;
    }

    private static Set<PriorKnowledge> evidenceForToPriorKnowledge( final String evidenceFor, final String source, final Integrator integrator ){
        final Set<PriorKnowledge> pks = integrator.getPriorKnowledgeRelatedToObservationNamed( source, evidenceFor );
        if( pks == null || pks.size() == 0)
            LOGGER.warn( "Unknown prior-knowledge "+ evidenceFor);
        return pks;
    }

    private static Observation toObservation( final String name, final String label, final String source, final String description, TruthValue isPresent, final ObservationType type ){
        return ObservationImpl.builder()
                              .name( name )
                              .label( label )
                              .source( source )
                              .description( description )
                              .truthValue( isPresent )
                              .type( type )
                              .build();
    }

    private static void writeRecords(@NonNull final CSVPrinter csvPrinter, @NonNull final Concept concept){
        final List<Object> records = new ArrayList<>();
        records.add(concept.getName());
        records.add(concept.getLabel());
        records.add(concept.getSource());
        records.add(concept.getDescription());
        if( concept instanceof Observation){
            final Observation o = (Observation)concept;
            records.add( o.getType() );
            switch ( o.getType() ){
                case COMPUTATION:       records.add(o.getTruthValue() ) ; records.add("NA"); break;
                case ANNOTATION:        records.add(o.getTruthValue() ) ; records.add(o.getTruthValue()); break;
                case EXPERIMENTATION:   records.add("NA")               ; records.add(o.getTruthValue() );break;
                default:
                    LOGGER.warn("Unsupported observation type: "+o.getType());
            }
            records.add("NA");
        }
        else if( concept instanceof PriorKnowledge){
            final PriorKnowledge pk = (PriorKnowledge) concept;
            records.add( "PRIOR KNOWLEDGE" );
            records.add( pk.getPrediction() );
            records.add( pk.getExpectation() );
            records.add( pk.getConclusion() );
        }
        else
            LOGGER.warn("Unsupported type: " + concept.getClass() );
        try {
            csvPrinter.printRecord(records);
        } catch (IOException e) {
            LOGGER.error("while inserting records : \n" + concept);
            System.exit(1);
        }
    }

    public static void main( String[] args ) {
//        final Logger root = (Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
//        root.setLevel( Level.OFF );
        final Set<PriorKnowledge> observationRelatedTo  = new HashSet<>(  );
        final Set<PriorKnowledge> priorKnowledgeLeaves;

        final  CSVFormat format = CSVFormat.RFC4180
                .withDelimiter( ';' )
                .withRecordSeparator('\n')
                .withFirstRecordAsHeader();

        Integrator integrator = null;


        //args = new String[]{ "-f", "-g", "/home/jmercier/UP000000625.csv", "test_reporting1"}; // for debug purpose
        //args = new String[]{ "-u", "36.csv", "test_reporting2"}; // for debug purpose
        final CommandLine   cli     = parseArgs( args );
        Reader              in      = null;
        Iterable<CSVRecord> lines   = null;

        if( cli.getArgs().length != 2 ){
            LOGGER.error( APPNAME+" expect a CSV file and an output directory" );
            System.exit( 1 );
        }

        try {
            in = new FileReader( cli.getArgs()[ 0 ] );
        }
        catch( FileNotFoundException e){
            LOGGER.error( "CSV file "+ cli.getArgs()[ 0 ]+" not found!");
            System.exit( 1 );
        }

        try {
            File outDir = new File( cli.getArgs()[1]);
            if( ! outDir.exists() )
                outDir.mkdirs();
        }
        catch ( Exception e ){
            LOGGER.error( "Error while creating output directory: "+ cli.getArgs()[1] );
            LOGGER.error( e.getMessage() );
            System.exit( 1 );
        }

        try{
            lines = format.parse( in );
        }
        catch ( IOException e ){
            LOGGER.error( "Error while reading "+  cli.getArgs()[ 0 ]);
            LOGGER.error( e.getMessage() );
            System.exit( 1 );
        }

        Mode mode;

        if( cli.hasOption( "dispensable" ) ){
            mode = Mode.DISPENSABLE;
        }
        else if(cli.hasOption( "specific" ) ){
            mode = Mode.SPECIFIC;
        }
        else
            mode = Mode.NORMAL;


        LOGGER.info("Generating concept graph...");
        final Reasoner      grools  = new ReasonerImpl( mode, Verbosity.HIGHT );
        String input = null;
        if( cli.hasOption( "unipathway" ) ) {
            if( cli.hasOption( "input") )
                try {
                    integrator = new OboIntegrator( grools, new File(cli.getOptionValue("input") ), "user resources" );
                } catch (Exception e) {
                    LOGGER.error("Error while reading: "+cli.getOptionValue("input"));
                    System.exit(1);
                }
            else {
                try {
                    integrator = new OboIntegrator(grools);
                } catch (Exception e) {
                    LOGGER.error("Error while reading: internal obo file");
                    System.exit(1);
                }
            }
            input = "unipathway";
        }
        else if( cli.hasOption( "genome-properties" ) ){
            if( cli.hasOption( "input") )
                try {
                    integrator = new GenomePropertiesIntegrator( grools, new File(cli.getOptionValue("input") ) );
                } catch (Exception e) {
                    LOGGER.error("Error while reading: "+cli.getOptionValue("input"));
                    System.exit(1);
                }
            else {
                try {
                    integrator = new GenomePropertiesIntegrator(grools);
                } catch (Exception e) {
                    LOGGER.error("Error while reading: internal rdf file");
                    System.exit(1);
                }
            }
            input = "genome-properties";
        }
        else{
            // should not be possible, case tested in parseArgs
            LOGGER.error( "Any models was choosen [unipathway/genome-properties]!" );
            System.exit( 1 );
        }

        integrator.integration(  );
        // unipathway has inconsitent use of super pathway and isA terms. To avoid loops we remove super pathway terms.
        if( cli.hasOption( "unipathway" ) ) {
            final OboIntegrator oboIntegrator = (OboIntegrator)integrator;
            final OboParser     oboParser     = oboIntegrator.getOboParser();
            final List<UPA>     pathways      = oboParser.getPathways();
            final Set<PriorKnowledge> superpathways = pathways.stream()
                    .filter( upa  -> upa.getSuperPathway() != null )
                    .map( upa  -> upa.getSuperPathway().getIdLeft() )
                    .map( id   -> grools.getPriorKnowledge(id) )
                    .collect( Collectors.toSet() );
            grools.delete(superpathways);
        }

        LOGGER.info("Inserting observation...");

        for( final CSVRecord line : lines){
            final String                label       = line.get( "Label" );
            final ObservationType       obsType     = observationTypeStrToObservationType(line.get( "Type" ));
            final TruthValue            isPresent   = isPresentStrToTruthValue( line.get( "isPresent" ) );
            final String                source      = line.get( "Source" );
            final String                name        = line.get( "Name" );
            final String                description = line.get( "Description" );
            final Set<PriorKnowledge>   evidenceFor = evidenceForToPriorKnowledge( line.get( "EvidenceFor" ), source, integrator );

            if( evidenceFor != null ){
                for( final PriorKnowledge pk : evidenceFor ) {
                    final Observation o = toObservation( name, label, source, description, isPresent, obsType );
                    final Relation relation = new RelationImpl( o, pk );
                    grools.insert( o, relation );
                    observationRelatedTo.add( pk );
                }
            }
        }

        if( cli.hasOption( "falsehood" )) {
            if( ! cli.hasOption("genome-properties") ){
                LOGGER.error( "falsehood option can be used only with genome-properties option!" );
                System.exit( 1 );
            }
            priorKnowledgeLeaves = grools.getLeavesPriorKnowledges();
            priorKnowledgeLeaves.removeAll( observationRelatedTo );
            for ( final PriorKnowledge leaf : priorKnowledgeLeaves ) {
                final GenomePropertiesIntegrator gpi = (GenomePropertiesIntegrator) integrator;
                ComponentEvidence term = (ComponentEvidence) gpi.getRdfParser().getTerm(leaf.getLabel());
                if( term.getCategory().equals("HMM")) {
                    final Observation o = toObservation("No_" + leaf.getName(), leaf.getLabel(), input, leaf.getDescription(), TruthValue.f, ObservationType.COMPUTATION);
                    final Relation r = new RelationImpl(o, leaf);
                    grools.insert(o, r);
                }
            }
        }

        LOGGER.info("Reasoning...");
        grools.reasoning();

        LOGGER.info("Reporting...");
        List<PriorKnowledge> tops = null;
        if( cli.hasOption( "unipathway" ) ) {
            final OboIntegrator oboIntegrator = (OboIntegrator)integrator;
            final OboParser     oboParser     = oboIntegrator.getOboParser();
            final List<UPA>     pathways      = oboParser.getPathways();
            final Set<UPA>      isA           = pathways.stream()
                                                        .filter( upa  -> upa.getIsA() != null )
                                                        .map(upa -> upa.getIsA().stream().map(rel -> rel.getIdLeft()).collect(Collectors.toSet()))
                                                        .flatMap(Collection::stream)
                                                        .map( id   -> (UPA) oboParser.getTerm(id) )
                                                        .collect(Collectors.toSet());
            final Set<UPA>      others        = pathways.stream()
                                                        .filter( upa -> grools.getRelationsWithSource(grools.getPriorKnowledge(upa.getId())).isEmpty() )
                                                        .collect(Collectors.toSet());
            final List<PriorKnowledge> topsTMP = new ArrayList<>(isA.size() + others.size() );


            isA.stream()
               .map( upa -> grools.getPriorKnowledge(upa.getId()) )
               .collect( Collectors.toCollection(() -> topsTMP ) );
            others.stream()
                  .map( upa -> grools.getPriorKnowledge(upa.getId()) )
                  .collect( Collectors.toCollection(() -> topsTMP ) );
            tops = topsTMP;

        }
        else if( cli.hasOption( "genome-properties" ) )
            tops = grools.getTopsPriorKnowledges()
                         .stream()
                         .sorted( (a,b) -> a.getName().compareTo( b.getName() ) )
                         .collect(Collectors.toList());
        else{
            LOGGER.error( "Any models was choosen [unipathway/genome-properties]!" );
            System.exit( 1 );
        }

        GraphWriter graph = null;
        final Object[] header = {"Name", "Label", "Source", "Description", "Type", "Prediction", "Expectation", "Conclusion"};

        try {
            graph = new GraphWriter( cli.getArgs()[1] );
        } catch (Exception e) {
            LOGGER.error("while creating reporting into: "+cli.getArgs()[1]);
            System.exit(1);
        }
        for( final PriorKnowledge top : tops ) {
            Set<Relation> relations = grools.getSubGraph( top );
            try {
                graph.addGraph( top, relations );
            } catch (Exception e) {
                LOGGER.error("while creating reporting : " + top.getName());
                System.exit(1);
            }
            // write csv
            FileWriter fileWriter = null;
            CSVPrinter csvPrinter = null;
            final String     csvPath = Paths.get(cli.getArgs()[1],top.getName(),"result.csv").toString();
            try {
                fileWriter = new FileWriter( csvPath );
                csvPrinter = new CSVPrinter( fileWriter, format);
                csvPrinter.printRecord(header);

                for( final Relation relation : relations ){
                    writeRecords( csvPrinter, relation.getSource());
                    writeRecords( csvPrinter, relation.getTarget());
                }
                fileWriter.close();
                csvPrinter.close();
            } catch (IOException e) {
                LOGGER.error("while writing csv file : " + csvPath);
                System.exit(1);
            }
        }
        try {
            graph.close();
        } catch (IOException e) {
            LOGGER.error("Error while closing reporting : " + cli.getArgs()[1]);
            System.exit(1);
        }

    }
}
