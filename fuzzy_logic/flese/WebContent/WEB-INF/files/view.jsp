<%@page import="results.ResultsStoreHouse"%>
<%@page import="auxiliar.JspsUtils"%>
<%@page import="java.util.ArrayList"%>
<%@page import="constants.KUrls"%>
<%@page import="constants.KConstants"%>

<%
	String [] msgs = JspsUtils.getResultMessages(request);
%>
	<div class="fileViewTable">
<% 
if ((msgs != null) && (msgs.length > 0)) { 
	for (int i=0; i<msgs.length; i++) {
		out.println(msgs[i]);
	}
} else { 
	
	ResultsStoreHouse resultsStoreHouse =  JspsUtils.getResultsStoreHouse(request);	
	String [] fileContents = resultsStoreHouse.getfileContents();
	
	if (fileContents != null) {
		for (int i=0; i< fileContents.length; i++) {
%>
			<div class="fileViewTableRow">
				<div class="fileViewTableCell">
					<%= fileContents[i] %>
				</div>
			</div>
<%
		}
	}
}
%>

</div>






<!--  END -->
