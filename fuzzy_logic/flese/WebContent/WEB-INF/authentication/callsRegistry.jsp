<%@page import="results.ResultsStoreHouse"%>
<%@page import="storeHouse.RequestStoreHouse"%>
<%@page import="constants.KConstants"%>
<%@page import="java.util.ArrayList"%>
<%@page import="auxiliar.JspsUtils"%>
<%@page import="constants.KUrls"%>

<%
	RequestStoreHouse requestStoreHouse = JspsUtils.getRequestStoreHouse(request);
	// SessionStoreHouse sessionStoreHouse = JspsUtils.getSessionStoreHouse(requestStoreHouse);
	ResultsStoreHouse resultsStoreHouse = JspsUtils.getResultsStoreHouse(requestStoreHouse);
	String registry = resultsStoreHouse.getRegistryEntries();
%>

<%	if (! JspsUtils.isAjax(requestStoreHouse)) { %>
<jsp:include page='../commonHtmlBody.jsp' />
<% } %>

<h3>FleSe User Session Registry</h3>

<table id='registry' class='registryTable'>
</table>

<script type="text/javascript">
	writeHtmlInContainer('registry', '<%=registry%>', false);
</script>
