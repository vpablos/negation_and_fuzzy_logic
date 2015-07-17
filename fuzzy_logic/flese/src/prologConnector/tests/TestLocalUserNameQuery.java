package prologConnector.tests;

import CiaoJava.PLAtom;
import CiaoJava.PLString;
import CiaoJava.PLStructure;
import CiaoJava.PLTerm;
import CiaoJava.PLVariable;
import auxiliar.LocalUserInfo;
import filesAndPaths.FilesAndPathsException;
import filesAndPaths.ProgramFileInfo;
import prologConnector.CiaoPrologConnectorException;
import prologConnector.CiaoPrologTestingQuery;
import prologConnector.PlConnectionEnvelope;
import prologConnector.PlConnectionEnvelopeException;

public class TestLocalUserNameQuery {

	public static class KCtes {

		public static String programOwner = "appAdm";
		public static String programFileName1 = "db_shopping.pl";
		public static String programFileName2 = "test_username.pl";

		public static String assertLocalUserNamePredicate = "assertLocalUserName";
		public static String retrieveLocalUserNamePredicate = "localUserName";

	}

	public static void main(String[] args) throws Exception {
		LocalUserInfo localUserInfo = LocalUserInfo.getFakeLocalUserInfo("victorpablosceruelo_at_gmail.com");

		// test1(localUserInfo);
		test2(localUserInfo);

		System.exit(0);

	}

	private static void test1(LocalUserInfo localUserInfo)
			throws CiaoPrologConnectorException, FilesAndPathsException, PlConnectionEnvelopeException {
		ProgramFileInfo pfi = new ProgramFileInfo(KCtes.programOwner, KCtes.programFileName1);
		// To fill in with values.
		PLStructure query = null;
		PLVariable[] variables = null;
		String[] variablesNames = null;

		variables = new PLVariable[5];
		variables[0] = new PLVariable(); // UserName
		variables[1] = new PLVariable(); // Xtmp
		variables[2] = new PLVariable(); // Vtmp
		variables[3] = new PLVariable(); // Cond
		variables[4] = new PLVariable(); // V

		variablesNames = new String[] { "UserName", "Xtmp", "Vtmp", "Cond", "V" };

		String localUserName = localUserInfo.getLocalUserName();
		PLTerm[] argsAssert = new PLTerm[] { new PLAtom("'" + localUserName + "'") };
		PLStructure queryAssert = new PLStructure(KCtes.assertLocalUserNamePredicate, argsAssert);

		PLTerm[] argsRetrieve = new PLTerm[] { variables[0] };
		PLStructure queryRetrieve = new PLStructure(KCtes.retrieveLocalUserNamePredicate, argsRetrieve);

		PLTerm[] args_expensive = { variables[1], variables[2] };
		PLStructure query_expensive = new PLStructure("expensive", args_expensive);

		PLTerm[] args_rfuzzy_var_truth_value = { variables[2], variables[3], variables[4] };
		PLStructure query_dump_constraints = new PLStructure("rfuzzy_var_truth_value", args_rfuzzy_var_truth_value);

		PLTerm[] args_conjunction1 = { queryAssert, queryRetrieve };
		PLStructure conjunction1 = new PLStructure(",", args_conjunction1);

		PLTerm[] args_conjunction2 = { query_expensive, query_dump_constraints };
		PLStructure conjunction2 = new PLStructure(",", args_conjunction2);

		PLTerm[] args_conjunction3 = { conjunction1, conjunction2 };
		PLStructure conjunction3 = new PLStructure(",", args_conjunction3);

		query = conjunction3;

		// Now the real stuff.
		CiaoPrologTestingQuery ciaoQuery = CiaoPrologTestingQuery.getInstance(pfi);
		ciaoQuery.overrideRealQuery(query, variables, variablesNames);
		PlConnectionEnvelope plConnectionEnvelope = new PlConnectionEnvelope();
		plConnectionEnvelope.runPrologQuery(ciaoQuery, localUserInfo);
	}

	private static void test2(LocalUserInfo localUserInfo)
			throws CiaoPrologConnectorException, FilesAndPathsException, PlConnectionEnvelopeException {
		ProgramFileInfo pfi = new ProgramFileInfo(KCtes.programOwner, KCtes.programFileName2);
		// To fill in with values.
		PLStructure query = null;
		PLVariable[] variables = null;
		String[] variablesNames = null;

		variables = new PLVariable[2];
		variables[0] = new PLVariable(); //
		variables[1] = new PLVariable(); //

		variablesNames = new String[] { "UserName", "Result" };

		String localUserName = localUserInfo.getLocalUserName();
		PLTerm[] argsAssert = new PLTerm[] { new PLString("'" + localUserName + "'") };
		PLStructure queryAssert = new PLStructure(KCtes.assertLocalUserNamePredicate, argsAssert);

		PLTerm[] argsRetrieve = new PLTerm[] { variables[0] };
		PLStructure queryRetrieve = new PLStructure(KCtes.retrieveLocalUserNamePredicate, argsRetrieve);

		PLTerm[] args_test = { variables[1] };
		PLStructure query_test = new PLStructure("test", args_test);

		PLTerm[] args_conjunction1 = { queryAssert, queryRetrieve };
		PLStructure conjunction1 = new PLStructure(",", args_conjunction1);

		PLTerm[] args_conjunction2 = { conjunction1, query_test };
		PLStructure conjunction2 = new PLStructure(",", args_conjunction2);

		query = conjunction2;

		// Now the real stuff.
		CiaoPrologTestingQuery ciaoQuery = CiaoPrologTestingQuery.getInstance(pfi);
		ciaoQuery.overrideRealQuery(query, variables, variablesNames);
		PlConnectionEnvelope plConnectionEnvelope = new PlConnectionEnvelope();
		plConnectionEnvelope.runPrologQuery(ciaoQuery, localUserInfo);
	}

}
