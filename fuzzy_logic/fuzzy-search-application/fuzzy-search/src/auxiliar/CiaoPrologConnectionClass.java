package auxiliar;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import CiaoJava.*;

public class CiaoPrologConnectionClass {

	final static private Log LOG = LogFactory.getLog(CiaoPrologConnectionClass.class);
	static private FoldersUtilsClass FoldersUtilsObject = null;
	final static private long maximumLong = 9223372036854775807L;
	
	// This one can not be shared between different processes.
	private PLConnection currentPlConnection = null;
	private String currentDatabase = null;
	private String currentDatabaseOwner = null;
	private Iterator<CiaoPrologProgramElementInfoClass> loadedProgramInfoIterator = null;
	
	public CiaoPrologConnectionClass() throws PLException, IOException, FoldersUtilsClassException {
		LOG.info("CiaoPrologConnectionClass: Connecting to Ciao Prolog server (plServer) ...");
		if (FoldersUtilsObject == null) {
			FoldersUtilsObject = new FoldersUtilsClass();
		}
		
		String [] argv = new String[1];
		argv[0] = FoldersUtilsObject.getPlServerPath();
		if (currentPlConnection == null) {
			currentPlConnection = new PLConnection(argv);
		}
		LOG.info("CiaoPrologConnectionClass: Connected to Ciao Prolog server (plServer). Initializing local objects.");

		// changeCiaoPrologWorkingFolder("");
		LOG.info("CiaoPrologConnectionClass: Connected to Ciao Prolog server (plServer). Initialized local objects.");
	}
	
	/**
	 * Changes the Ciao Prolog Working Folder 
	 * 
	 * @param     dataBaseOwner It is the owner of the new database, which coincides with the folder that contains the database.
	 * @exception FoldersUtilsClassException if the folder can not be created
	 * @exception PLException
	 * @exception IOException
	 * @exception LocalUserNameFixesClassException if the owner string is empty or null
	 */
	private void changeCiaoPrologWorkingFolder(String dataBaseOwner) 
			throws FoldersUtilsClassException, PLException, IOException, LocalUserNameFixesClassException {
		// Log info
		LOG.info("changeCiaoPrologWorkingFolder: folder selected: " + dataBaseOwner);
		
		if ((dataBaseOwner == null) || ("".equals(dataBaseOwner))){
			LOG.info("changeCiaoPrologWorkingFolder: dataBaseOwner is null or empty.");
			throw new FoldersUtilsClassException("changeCiaoPrologWorkingFolder: dataBaseOwner is null or empty.");
		}
		
		if ((! FoldersUtilsObject.folderExists(dataBaseOwner, true))) {
			LOG.info("changeCiaoPrologWorkingFolder: dataBaseOwner is an invalid folder.");
			throw new FoldersUtilsClassException("changeCiaoPrologWorkingFolder: newWorkingFolder is an invalid folder.");
		}
		
		// Adequate the value of dataBaseOwner (it was relative until here).
		dataBaseOwner = FoldersUtilsObject.getprogramsPath() + dataBaseOwner;
		
		// Change it only if necessary.
		if ((currentDatabaseOwner == null) || (! currentDatabaseOwner.equals(dataBaseOwner))) { 
			
				// Change working folder.
				PLVariable var1 = new PLVariable();
				PLStructure query = new PLStructure("working_directory",
						new PLTerm[]{var1, new PLAtom(dataBaseOwner)}); 
				
				ArrayList<PLTerm> queryAnswers = performDatabaseQuery(query, null);
				Iterator<PLTerm> queryAnswersIterator = queryAnswers.iterator();
				while (queryAnswersIterator.hasNext()) {
					PLTerm inputAnswer = queryAnswersIterator.next();
					LOG.info("changeCiaoPrologWorkingFolder: queryAnswer: " + inputAnswer.toString());	
				}
				
				currentDatabaseOwner = dataBaseOwner;
				
				LOG.info("changeCiaoPrologWorkingFolder: var1 value: " + var1.toString());
				LOG.info("changeCiaoPrologWorkingFolder: changed current working folder to " + currentDatabaseOwner);
		}
		else {
			LOG.info("changeCiaoPrologWorkingFolder: not changing current working folder. " + 
					 "Current working folder: " + currentDatabaseOwner);
		}
		
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public void databaseIntrospectionQuery(String owner, String database) 
			throws PLException, IOException, FoldersUtilsClassException, LocalUserNameFixesClassException {
		LOG.info("databaseIntrospectionQuery: owner: "+owner+" database: "+database);
		changeCiaoPrologWorkingFolder(owner);
		
		ArrayList<CiaoPrologProgramElementInfoClass> loadedProgramInfo = new ArrayList<CiaoPrologProgramElementInfoClass>();
		// rfuzzy_introspection(T, PN, PA).
		PLVariable predicateType = new PLVariable();
		PLVariable predicateName = new PLVariable();
		PLVariable predicateArity = new PLVariable();
		PLTerm[] args = {predicateType, predicateName, predicateArity};
		PLStructure query = new PLStructure("rfuzzy_introspection", args); 
		
		ArrayList<PLTerm> queryAnswers = performDatabaseQuery(query, database);
		Iterator<PLTerm> queryAnswersIterator = queryAnswers.iterator();
		while (queryAnswersIterator.hasNext()) {
			PLTerm inputAnswer = queryAnswersIterator.next();
			LOG.info("changeCiaoPrologWorkingFolder: queryAnswer: " + inputAnswer.toString());
			
			CiaoPrologProgramElementInfoClass answer = new CiaoPrologProgramElementInfoClass();
			answer.setPredicateType(predicateType.toString());
			answer.setPredicateName(predicateName.toString());
			answer.setPredicateArity(predicateArity.toString());
			answer.log_info();
			loadedProgramInfo.add(answer);
		}
		loadedProgramInfoIterator = loadedProgramInfo.iterator();
	}
	
	private ArrayList<PLTerm> performDatabaseQuery(PLStructure query, String database) throws PLException, IOException {
		return performDatabaseQueryAux(query, database, maximumLong, maximumLong);
	}
	
	
	private ArrayList<PLTerm> performDatabaseQueryAux(PLStructure query, String database, long maxNumAnswers, long maxNumberOfTries) 
			throws PLException, IOException {
		
		ArrayList<PLTerm> queryAnswers = new ArrayList<PLTerm>();
		
		if (query != null) {
			PLGoal currentGoal = null;
			long answersCounter = 0;

			LOG.info("runQuery: executing query: " + query.toString() + " .... ");
			if (currentPlConnection == null) throw new PLException("runQuery: plConnection is null.");
			currentGoal = new PLGoal(currentPlConnection, query); 
			if ((database != null) && (! "".equals(database)))
					currentGoal.useModule(database);
			currentGoal.query();

			LOG.info("performDatabaseQueryAux: getting answers ...");
			PLTerm currentQueryAnswer;
			long timesCounter;
			
			do { // Get all the answers you can.
				currentQueryAnswer = null;
				timesCounter = 0;
				// Save the current answer.
				answersCounter ++;
				LOG.info("performDatabaseQueryAux: getting answer number: "  + answersCounter);
				do { // Get the current answer.
					currentQueryAnswer = currentGoal.nextSolution();
					timesCounter++;
				} while ((currentQueryAnswer == null) && (currentGoal.isStillRunning()) && (timesCounter < maxNumberOfTries));

				if (timesCounter >= maxNumberOfTries){
					LOG.info("performDatabaseQueryAux: reached maxNumberOfTries: " + timesCounter + " >= " + maxNumberOfTries);
				}
				
				if (currentQueryAnswer != null) {
					LOG.info("performDatabaseQueryAux: goal: " + currentGoal.toString() + " answer: " + currentQueryAnswer.toString());
					// queryAnswers.add(currentGoal);
				}
				else {
					LOG.info("performDatabaseQueryAux: answer obtained: null ");
				}
				
			} while ((currentQueryAnswer != null) && (answersCounter < maxNumAnswers));
			
			LOG.info("performDatabaseQueryAux: terminating goal execution ...");
			if (currentGoal != null) {
				try {
					currentGoal.terminate();
				} catch (Exception e) {
					e.printStackTrace();
				} 
				currentGoal = null;
				answersCounter=-1; // Notify that there is no currentGoal.
			}
		}
		
		LOG.info("performDatabaseQueryAux: end.");
		return queryAnswers;
	}


	
	public Iterator<CiaoPrologProgramElementInfoClass> getProgramInfoIterator() {
		return loadedProgramInfoIterator;
	}
	
	public String getCurrentDatabase () { return currentDatabase; }
	public String getCurrentDatabaseOwner () { return currentDatabaseOwner; }
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * Destroys the current connection to the Ciao Prolog server, so it should dye. 
	 */
	public void connectionTermination() {
		if (currentPlConnection != null) {
			try {
				currentPlConnection.stop();
			} catch (Exception e) {
				e.printStackTrace();
			} 
			currentPlConnection = null;
		}
	}

}
