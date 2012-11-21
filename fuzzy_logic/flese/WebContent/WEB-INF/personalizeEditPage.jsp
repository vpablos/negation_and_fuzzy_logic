<jsp:include page="commonHtmlHead.jsp" />

<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="auxiliar.ServletsAuxMethodsClass"%>

<jsp:include page="commonPersonalization.jsp" />

<body>
    <div id="bodyContainer">
    	<jsp:include page="commonBodyHead.jsp" />
    	<h3><a title="Back to the program files menu" href="<%=ServletsAuxMethodsClass.getFullPathForUriNickName(ServletsAuxMethodsClass.FilesMgmtServlet, request, null) %>">Program Files Menu</a> &gt;
    		<a title="Back to personalize program file <%= (String) request.getAttribute("fileName") %>" href="<%=ServletsAuxMethodsClass.getFullPathForUriNickName(ServletsAuxMethodsClass.PersonalizeServlet, request, null) %>?fileName=<%= (String) request.getAttribute("fileName") %>&fileOwner=<%= (String) request.getAttribute("fileOwner") %>">Personalize program file <%= (String) request.getAttribute("fileName") %></a> &gt; 
			Personalize fuzzification <%= (String) request.getAttribute("fuzzification") %>
    	</h3>
    	<div class="tableWithBorderWidth50">
			<div class="tableHeadWithOutBorderWidth100">
					Information about the fuzzification chosen
			</div>

			<div class="tableRowWithBorderWidth100">
				<div class="tableCellWithBorderWidth50">Program file name</div>
				<div class="tableCellWithBorderWidth50"><%= (String) request.getAttribute("fileName") %></div>
			</div>
			<div class="tableRowWithBorderWidth100">
				<div class="tableCellWithBorderWidth50">Owner</div>
				<div class="tableCellWithBorderWidth50"><%= (String) request.getAttribute("fileOwner") %></div>
			</div>
			<div class="tableRowWithBorderWidth100">
				<div class="tableCellWithBorderWidth50">Fuzzification</div>
				<div class="tableCellWithBorderWidth50" id="predDefined"></div>
			</div>
			<div class="tableRowWithBorderWidth100">
				<div class="tableCellWithBorderWidth50">Depends on the values of</div>
				<div class="tableCellWithBorderWidth50" id="predNecessary"></div>
			</div>			
		</div>
    	
		<br />
		<br />
		<div id="personalizationTableDiv"></div>
		<br />
		<br />
		My personalized fuzzification
		<div id="myPersonalizationTableDiv">You have not defined your personalization for this fuzzification yet.</div>
		<br />
		<br />		
    	<h3><a title="Back to the program files menu" href="<%=ServletsAuxMethodsClass.getFullPathForUriNickName(ServletsAuxMethodsClass.FilesMgmtServlet, request, null) %>">Program Files Menu</a> &gt;
    		<a title="Back to personalize program file <%= (String) request.getAttribute("fileName") %>" href="<%=ServletsAuxMethodsClass.getFullPathForUriNickName(ServletsAuxMethodsClass.PersonalizeServlet, request, null) %>?fileName=<%= (String) request.getAttribute("fileName") %>&fileOwner=<%= (String) request.getAttribute("fileOwner") %>">Personalize program file <%= (String) request.getAttribute("fileName") %></a> &gt; 
			Personalize fuzzification <%= (String) request.getAttribute("fuzzification") %>
    	</h3>
    	<br /><br />
	</div>
	<script type="text/javascript">

		var myPersonalizedFunction = new Array();
		
		function createPersonalizationTable() {
			var divContainer = document.getElementById("myPersonalizationTableDiv");
			divContainer.innerHTML = ""; // clean up !!!
			
			var table = document.createElement('div');
			table.id = "myPersonalizationTable";
			table.className = "personalizationTable";
			divContainer.appendChild(table);

			var row = document.createElement('div');
			row.className = "personalizationTableRow";
			table.appendChild(row);
			
			var cell = document.createElement('div');
			row.appendChild(cell);
			// cell.className = "personalizationTable";
			// cell.innerHTML=personalizePredInfo[i][2];
			cell.className = "personalizationTableCell3";
			cell.id = 'chartDiv_' + i;
			// cell.innerHTML=personalizePredInfo[i][2];

			// drawChart(cell.id, i);
			// Cannot use i here !!!
		}
		function updateFunctionTable() {
			
		}
		
		function updateFunctionGraphic() {
			
		}
		
		function copyFunctionValues(index) {
			newFunctionValues = personalizePredInfo[index][3];
			for (var i=0; i<newFunctionValues.length; i++) {
				myPersonalizedFunction[i] = new Array();
				for (var j=0; j<newFunctionValues[i].length; j++) {
					if (j>1) {
						alert("Function is not well defined. Extra information will be discarded.")
					}
					else {
						myPersonalizedFunction[i][j] = newFunctionValues[i][j];
					}
				}
			}
			updateFunctionTable();
			updateFunctionGraphic();
		}
		
		function copyFunction(index) {
			var functionOwner = personalizePredInfo[index][2];
			var confirmationText="";
			if (functionOwner == '') {
				confirmationText = "predefined function";
			}
			else {
				confirmationText = "function defined by " + functionOwner;
			}
			if (confirm("Do you want to take the " + confirmationText + " as your personalized function for the fuzzification " + personalizePredInfo[index][0])) {
				copyFunctionValues(index);
			}
			return false;
		}
	
	
		var personalizeServletEditAction = "<%=ServletsAuxMethodsClass.getFullPathForUriNickName(ServletsAuxMethodsClass.PersonalizeServletEditAction, request, null) %>";
		var fileName = "<%= (String) request.getAttribute("fileName") %>";
		var fileOwner = "<%= (String) request.getAttribute("fileOwner") %>";
		var myPersonalization = null;
		
		if (personalizePredInfo.length > 0) {
			var divContainer = document.getElementById("personalizationTableDiv");
			var table = document.createElement('div');
			table.id = "personalizationTable";
			table.className = "personalizationTable";
			divContainer.appendChild(table);

			/*
			var row = document.createElement('div');
			row.className = "personalizationTableRow";
			table.appendChild(row);
			
			var cell = null;
			cell = document.createElement('div');
			cell.className = "personalizationTableCell3";
			cell.innerHTML = "function applied";
			row.appendChild(cell);
			*/

			for (var i=0; i<personalizePredInfo.length; i++) {
				row = document.createElement('div');
				row.className = "personalizationTableRow";
				table.appendChild(row);
				
				if (personalizePredInfo[i].length >= 3) {
					for (var j=0; j<personalizePredInfo[i][2].length; j++) {
						if (personalizePredInfo[i][j][0] == fileOwner) {
							myPersonalization = j;
						}
					}
					
					cell = document.createElement('div');
					cell.className = "personalizationTableCell3";
					cell.id = "functionGraphic_" + i;
					row.appendChild(cell);
					// cell.innerHTML=personalizePredInfo[i][2];
					drawChart(cell.id, i);
						
					document.getElementById("predDefined").innerHTML = personalizePredInfo[i][0];
					document.getElementById("predNecessary").innerHTML = personalizePredInfo[i][1];
						
				}
			}
		}
		
		// "<a title='take this function as my function' href='' onclick='return copyFunction("+i+")'><img src='images/copy.png'></img></a>";
	</script>
</body>
</html>