
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
	CiaoPrologQueryAnswer [] queryAnswers = resultsStoreHouse.getCiaoPrologQueryAnswers();	
	ArrayList<String> arrayList = new ArrayList<String>(); 
			
	for (int i=0; i<queryAnswers.length; i++) { 
		CiaoPrologQueryAnswer queryAnswer = queryAnswers[i];
		CiaoPrologTermInJava predInfo = queryAnswer.getCiaoPrologQueryVariableAnswer(KConstants.ProgramIntrospectionFields.predicateMoreInfo);
		CiaoPrologTermInJava predName = queryAnswer.getCiaoPrologQueryVariableAnswer(KConstants.ProgramIntrospectionFields.predicateName);
		HashMap<String, String> hashMap = predInfo.toHashMap();
		boolean isDatabase = (hashMap.get("database") != null);
		if (isDatabase) {
			arrayList.add(predName.toString());
		}
	}
%>


<!-- <form id='queryForm' action='' method='POST' accept-charset='utf-8'>  -->
<!-- 
// action='"+ urlMappingFor('RunQueryRequest') + "&fileName="+fileName+"&fileOwner="+fileOwner + "' ";
// target='" + runQueryTargetiFrameId+ "'>";
 -->
	<div id='queryStartContainer' class='queryStartContainerTable'>
	     <div class='queryStartContainerTableRow'>
	          <div class='queryStartContainerTableCell1'>Your query: I'm looking for a </div>
	          <div class='queryStartContainerTableCell2' id='chooseQueryStartTypeContainerId'>
					<select name="chooseQueryStartType" id="chooseQueryStartType" onchange='selectedQueryStartTypeChanged(this, "queryLinesContainer");' >
						<%=JspsUtils.comboBoxDefaultValue() %>
<%
	for (int i=0; i<arrayList.size(); i++) {
		String value = arrayList.get(i);
%>	
						<option id='<%=value %>' title='<%=value %>' value='<%=value %>'><%=value %></option>
<%
	}
%>					</select>
	          </div>
		 </div>
	</div>

	<!-- Initialize the query lines counter -->	          
	<input type="hidden" name="queryLinesCounterFieldId" value="0" id="queryLinesCounterFieldId">
              
	<div id='queryLinesContainer' class='queryLinesContainerTable'>
	</div>
    
	<div class='searchOrPersonalizeTable'>
		 <div class='searchOrPersonalizeTableRow'>
			  <div class='searchOrPersonalizeTableCell'>
					<input type='submit' value='Search' onclick='return runQueryAfterSoftTests("parentDivId", "runQueryDivId", "chooseQueryStartTypeId", "queryLinesCounterFieldId", "fileName", "fileOwner");' >
			  </div>
			  <div class='searchOrPersonalizeTableCell'>&nbsp; or &nbsp;
			  </div>
			  <div class='searchOrPersonalizeTableCell'>
					<INPUT type='submit' value='Personalize Program File' onclick='return personalizeProgramFile(fileName, fileOwner, basic);'>
			  </div>
		</div>
	</div>
	<!--  </form><br />  -->

	<script type="text/javascript">
		loadAjaxIn('mainSecDiv', "<%=KUrls.Queries.AddLineToQuery.getUrl(true) %>");		
	</script>
