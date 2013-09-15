
<%@page import="prologConnector.PredicateInfo"%>
<%@page import="prologConnector.ProgramIntrospection"%>
<%@page import="results.ResultsStoreHouse"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="prologConnector.CiaoPrologTermInJava"%>
<%@page import="constants.KConstants"%>
<%@page import="auxiliar.JspsUtils"%>
<%@page import="constants.KUrls"%>
<%@page import="prologConnector.CiaoPrologQueryAnswer"%>
<%@page import="prologConnector.CiaoPrologProgramIntrospectionQuery"%>
<%@page import="storeHouse.RequestStoreHouse"%>

<%
	RequestStoreHouse requestStoreHouse = new RequestStoreHouse(request, false);
	ResultsStoreHouse resultsStoreHouse = JspsUtils.getResultsStoreHouse(request);
	ProgramIntrospection programIntrospection = resultsStoreHouse.getCiaoPrologProgramIntrospection();	
	PredicateInfo [] predicatesInfos = programIntrospection.getPredicatesInfosByMoreInfoKey(KConstants.MoreInfoTypes.database);
	String database = requestStoreHouse.getRequestParameter(KConstants.Request.databaseParam);
	String selectQueryAddLineUrl = KUrls.Queries.SelectQueryAddLine.getUrl(true) + programIntrospection.getProgramFileInfo().getInfoForUrls() + 
	"&" + KConstants.Request.databaseParam + "=" + database;
	String selectQueryAddAggrUrl = KUrls.Queries.SelectQueryAddAggr.getUrl(true) + programIntrospection.getProgramFileInfo().getInfoForUrls() + 
	"&" + KConstants.Request.databaseParam + "=" + database;
%>

	<div id="queryLinesContainerTableRow" class="queryLinesContainerTableRow">
		<div id="queryLinesContainerTableCell" class="queryLinesContainerTableCell">
			<div id="<%=KConstants.JspsDivs.queryLinesTableId %>" class="queryLinesTable">
			</div>
		</div>
		<div id="queryLinesContainerTableCell" class="queryLinesContainerTableCell">
			<div id="<%=KConstants.JspsDivs.queryLinesAggregatorTableId %>" class="queryLinesAggregatorTable">
			</div>
		</div>
		
	</div>

	<script type="text/javascript">
		selectQueryAddLine("<%=selectQueryAddLineUrl %>", "<%=selectQueryAddAggrUrl %>");
	</script>
