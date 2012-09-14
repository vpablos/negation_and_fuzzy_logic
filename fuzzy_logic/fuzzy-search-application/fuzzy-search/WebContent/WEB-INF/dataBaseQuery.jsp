<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Fuzzy Search App</title>
</head>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Iterator"%>
<%@page import="auxiliar.CiaoPrologConnectionClass"%>
<%@page import="auxiliar.DataBaseInfoClass"%>

<% CiaoPrologConnectionClass connection = (CiaoPrologConnectionClass) session.getAttribute("connection"); %>

<!-- 
<script src="/fuzzy-search/addQueryLine.js" language="Javascript" type="text/javascript"></script>
 -->
 
<%  Iterator<String []> loadedProgramQuantifiersIterator = connection.getLoadedProgramQuantifiersIterator(); %>
<%  Iterator<String []> loadedProgramCrispPredicatesIterator = connection.getLoadedProgramCrispPredicatesIterator(); %>
<%  Iterator<String []> loadedProgramFuzzyRulesIterator = connection.getLoadedProgramFuzzyRulesIterator(); %>

<script language="javascript">
	function predInfo(predName, predArity) {
		this.predName = predName;
		this.predArity = predArity;
	}
	
	var quantifiersArray = new Array();
	<%
		int counter = 0;
		if (loadedProgramQuantifiersIterator != null) {
			String [] quantifierInfo;
			while (loadedProgramQuantifiersIterator.hasNext()) {
				quantifierInfo = loadedProgramQuantifiersIterator.next();
				%>
				quantifiersArray[<%=counter%>] = new predInfo("<%=quantifierInfo[1]%>", <%=quantifierInfo[2]%>);
				<%
				counter++;
			}
		}
	%>
		
	var fuzzyRulesArray = new Array();
	<%
		counter = 0;
		if (loadedProgramFuzzyRulesIterator != null) {
			String [] fuzzyRuleInfo;
			while (loadedProgramFuzzyRulesIterator.hasNext()) {
				fuzzyRuleInfo = loadedProgramFuzzyRulesIterator.next();
				%>
				fuzzyRulesArray[<%=counter%>] = new predInfo("<%=fuzzyRuleInfo[1]%>", <%=fuzzyRuleInfo[2]%>);
				<%
				counter++;
			}
		}
	%>

	var counter = 1;
	var limit = 50;

	function chooseQuantifierCode(counter, index) {
		var html = "<select name=\"quantifiers[" + counter + "][" + index + "]\">";
		for (var i=0; i<quantifiersArray.length; i++){
			html += "<option name=\"" + quantifiersArray[i].predName + 
						"\" value=\"" + quantifiersArray[i].predName + "\">"+
						quantifiersArray[i].predName + "</option>"
		}
		html += "</select>";
		return html;
	}
	function chooseFuzzyRuleCode(counter) {
		var html = "<select name=\"fuzzyRule[" + counter + 
		           "]\" onchange=\"fuzzyRuleChange('dynamicArgs[" + counter + "]', " + counter + ");\">";
		for (var i=0; i<fuzzyRulesArray.length; i++){
			html += "<option name=\"" + fuzzyRulesArray[i].predName + 
						"\" value=\"" + fuzzyRulesArray[i].predName + "\">"+
						fuzzyRulesArray[i].predName + "</option>"
		}
		html += "</select>";
		return html;
	}
	function fuzzyRuleArgsCode(counter) {
		var html = "<div id=\"dynamicArgs[" + counter + "]\"> </div>";
		return html;
	}
	
	function addFuzzyRuleArgumentBox(index) {
		html = "teto_" + j + " ";
	}
	
	function fuzzyRuleChange(divName, counter) {
		var comboBox = document.getElementById("fuzzyRule[" + counter + "]");
		var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;

		var found = false;
		var i = 0;
		while ((! found) && (i < fuzzyRulesArray.length)) {
			if (comboBoxValue == fuzzyRulesArray[i]) {
				found = true;
				var predArity = fuzzyRulesArray[i].predArity;
			}
			i++;
		}
		
		var html = "";
		for (var j=0; j<predArity; j++){
			html += addFuzzyRuleArgumentBox(j);
		}
		document.getElementById(divName).innerHTML = html;
	}
	
	function addQueryLine(divName) {
		if (counter == limit) {
			alert("You have reached the limit of adding " + counter + " subqueries.");
		} else {
			var newdiv = document.createElement('div');
			newdiv.innerHTML = chooseQuantifierCode(quantifiersArray, counter, 0) + 
					chooseQuantifierCode(counter, 1) +
					chooseFuzzyRuleCode(counter) + 
					fuzzyRuleArgsCode(counter);
			
			document.getElementById(divName).appendChild(newdiv);
			counter++;
		}
	}
</script>

<!--   <body onload=""> -->
<body>
	<h1>Fuzzy search application</h1>
		<h2><a href="DatabasesMenu">Back to the databases menu</a>. <a href="SocialAuthServlet?mode=signout">Signout</a>.</h2>
		<jsp:include page="showErrors.jsp" />
		<h2>Perform your query to the database <%=connection.getCurrentDatabase() %> 
			property of <%=connection.getCurrentDatabaseOwner() %></h2>

		
<form method="POST">
     <div id="dynamicInput">
          
     </div>
     <script type="text/javascript" language="JavaScript">
     addQueryLine('dynamicInput', quantifiersArray, fuzzyRulesArray);
	 </script>
     <input type="button" value="Add another text input" onClick="addQueryLine('dynamicInput', quantifiersArray, fuzzyRulesArray);">
</form>
		<h2>Available predicates at database: </h2>

		

</body>
</html>