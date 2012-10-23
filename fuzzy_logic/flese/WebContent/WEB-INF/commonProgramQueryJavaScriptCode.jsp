<script type="text/javascript">

	var queryLinesCounter = 0;
	var queryLinesCounterLimit = 100;
	var variablesCounter = 0;

	function convertTypeNameToVarName(inputString) {
		var firstCharacter = inputString[0];
		firstCharacter = firstCharacter.toUpperCase(); 
		var lastCharacters = inputString.substring(0, (inputString.length -1));
		return firstCharacter + lastCharacters; 
	}
	
	function addRfuzzyComputeOperator(queryLineGeneralId, rowId, foundPredInfo) {
		var index = 0;
		var predInfo = null;
		while (index<programIntrospectionArray.length && predInfo == null){
			if (programIntrospectionArray[index].predName == 'rfuzzy_compute_defined_operators') {
				predInfo = programIntrospectionArray[index];
			}
			else index++;
		}
		
		var row = document.getElementById(rowId);
		var cell = row.insertCell(-1);
		cell.id = queryLineGeneralId + ".rfuzzyComputeOperator";
		
		var rfuzzyComputeOperatorId = queryLineGeneralId + ".selectRfuzzyComputeOperator";
		html="<select name=\'" + rfuzzyComputeOperatorId + "\'>";;
		html += "<option name=\'----\' value=\'----\'>----</option>";
		
		var operators = predInfo.predOtherInfo;
		for (var i=0; i<operators.length; i++) {
			html+= "<option name=\'" + operators[i].predName + 
			"\' value=\'" + operators[i].predName + "\'>";
			html += operators[i].predName
			html += "</option>";
		}
		html += "</select>";
		cell.innerHTML = html;	
		
	}
	function addRfuzzyComputeArgument(queryLineGeneralId, rowId, foundPredInfo) {
		
	}

	
	function isQuantifierPredicate(programIntrospectionElement) {
		
		if ((programIntrospectionElement.predArity == 2) &&
			(programIntrospectionElement.predType != "-variable-")){
			var types = programIntrospectionElement.predType;
				return ((types[0] == "rfuzzy_predicate_type") &&
						(types[1] == "rfuzzy_truth_value_type"));
		}
		else return false;
	}
	
	function addQuantifier(queryLineGeneralId, rowId, quantifierIndex) {
		var row = document.getElementById(rowId);
		var cell = row.insertCell(0);
		cell.id = queryLineGeneralId + ".quantifier_" + quantifierIndex;
		var quantifierId = queryLineGeneralId + ".selectQuantifier_" + quantifierIndex;

		var html = "<select name=\'" + quantifierId + "\'>";
		html += "<option name=\'----\' value=\'----\'>----</option>";
		for (var i=0; i<programIntrospectionArray.length; i++){
			if (isQuantifierPredicate(programIntrospectionArray[i])) {
				if (((quantifierIndex == 0) && (programIntrospectionArray[i].predName == "fnot")) ||
						((quantifierIndex == 1) && (programIntrospectionArray[i].predName != "fnot"))) {
					html += "<option name=\'" + programIntrospectionArray[i].predName + 
								"\' value=\'" + programIntrospectionArray[i].predName + "\'>";
					if (programIntrospectionArray[i].predName == "fnot") html += "not";
					else html += programIntrospectionArray[i].predName;
					html += "</option>";
				}
			}
		}
		html += "</select>";
		cell.innerHTML = html;	
	}
	
	function changeInChooseRule(comboBox, queryLineGeneralId, rowId) {
		// var comboBox = document.getElementById('fuzzyRule[' + fuzzyRuleIndex + ']');
		var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;
		debug.info("changeInChooseRule: comboBoxValue: " + comboBoxValue);
		
		var foundPredInfo = null;
		var index = 0;
		debug.info("changeInChooseRule: searching ... ");
		while ((foundPredInfo == null) && (index < programIntrospectionArray.length)) {
			debug.info("programIntrospectionArray["+index+"]: " + programIntrospectionArray[index].predName);
			if (comboBoxValue == programIntrospectionArray[index].predName) {
				foundPredInfo = programIntrospectionArray[index];
				debug.info("changeInChooseRule: found");
			}
			else index++;
		}
		
		var row = document.getElementById(rowId);
		var cell = null;
		debug.info("row.cells.lenght = " + row.cells.length);
		if ((row.cells.length != 1) && (row.cells.length != 'undefined')) {	
			for (i=row.cells.length -1; i>=0; i--) {
				cell = row.cells[i];
				debug.info("row.cells["+i+"].id = " + row.cells[i].id);
				if (cell.id != (queryLineGeneralId + ".predicate")) {
					row.deleteCell(i);
					debug.info("row.cell removed");
				}
			}
		}
		
		if (foundPredInfo != null) {
			if (foundPredInfo.predType[foundPredInfo.predType.length -1] == 'rfuzzy_truth_value_type') {
				addQuantifier(queryLineGeneralId, rowId, 1)
				addQuantifier(queryLineGeneralId, rowId, 0)
			}
			else {
				addRfuzzyComputeOperator(queryLineGeneralId, rowId, foundPredInfo);
				addRfuzzyComputeArgument(queryLineGeneralId, rowId, foundPredInfo);
			}
		}
	}
	
	function startupTypeIsValid(startupType, predType) {
		return (predType[0] == startupType);
	}
	
	function addChooseRule(rowId, queryLineGeneralId, startupType) {
		
		var row = document.getElementById(rowId);
		var cell = row.insertCell(0);
		cell.id = queryLineGeneralId + ".predicate";
		
		var queryLineSelectPredicateId = queryLineGeneralId + ".selectPredicate";
		var html = "<select name=\'"+queryLineSelectPredicateId+"\'"+
					"onchange=\"changeInChooseRule(this, \'" + queryLineGeneralId + "\', \'"+rowId+"\');\">";
		html += "<option name=\'----\' value=\'----\''>----</option>";
		for (var i=0; i<programIntrospectionArray.length; i++){
			if (startupTypeIsValid(startupType, programIntrospectionArray[i].predType)) {
				html += "<option name=\'" + programIntrospectionArray[i].predName + 
							"\' value=\'" + programIntrospectionArray[i].predName + "\'>"+
							programIntrospectionArray[i].predName + "</option>";
			}
		}
		html += "</select>";
		
		cell.innerHTML = html;
	}
	
	function addQueryLine(queryLinesDivId, startupType) {
		if (queryLinesCounter == queryLinesCounterLimit) {
			alert("You have reached the limit of adding " + queryLinesCounter + " subqueries.");
		} else {
			var queryLineGeneralId = "queryLine[" + queryLinesCounter + "]";
			var queryLineDivContainerId = queryLineGeneralId+".divContainer"; 
			var queryLineDivContainer = document.createElement('div');
			queryLineDivContainer.id = queryLineDivContainerId;
			document.getElementById(queryLinesDivId).appendChild(queryLineDivContainer);
			
			var queryLineTableId = queryLineGeneralId + ".table";
			var queryLineTable = document.createElement('table');
			queryLineTable.id = queryLineTableId;
			document.getElementById(queryLineDivContainerId).appendChild(queryLineTable);
			
			rowId = queryLineGeneralId + ".row";
			var row = queryLineTable.insertRow(0);
			row.id = rowId;
						
			addChooseRule(rowId, queryLineGeneralId, startupType);
			
			queryLinesCounter++;
		}
	}
	
	function startupChange(comboBox, queryLinesDivId, queryTypeDivId) {
		var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;
		debug.info("comboBoxValue: " + comboBoxValue);
		queryLinesCounter=0;
		document.getElementById(queryLinesDivId).innerHTML="";
		
		addQueryLine(queryLinesDivId, comboBoxValue);
	}
	
	function fillQueryStartupValues(queryStartId) {
		var validTypesArray = new Array();
		var validTypesArrayCounter = 0;
		var valid = false;
		for (var i=0; i<programIntrospectionArray.length; i++) {
			valid = false;
			if (programIntrospectionArray[i].predOtherInfo != '[]') {
				for (var j=0; j<programIntrospectionArray[i].predOtherInfo.length; j++) {
					if (programIntrospectionArray[i].predOtherInfo[j] == 'database') {
						valid = true;
					}
				}
			}
			
			if (valid) {
				var k=0;
				var found=false;
				while ((k < validTypesArrayCounter) && (! found)) {
					if (validTypesArray[k] == programIntrospectionArray[i].predName)	found = true;
					else k++;
				}
				if (! found) {
					validTypesArray[validTypesArrayCounter] = programIntrospectionArray[i].predName;
					validTypesArrayCounter++;
				}
			}
		}
		
		var html = "<select name=\'startupType' onchange=\"startupChange(this, \'queryLines\', \'simpleOrAdvancedQuery\');\">";
		html += "<option name=\'----\' value=\'----\''>----</option>";
		for (var i=0; i<validTypesArrayCounter; i++) {
			html += "<option name=\'"+validTypesArray[i]+"\' value=\'"+validTypesArray[i]+"\''>"+validTypesArray[i]+"</option>";
		}
		html += "</select>";
		document.getElementById(queryStartId).innerHTML = html;
	}
	
</script>
