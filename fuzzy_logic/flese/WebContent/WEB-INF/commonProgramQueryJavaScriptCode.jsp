<script type="text/javascript">

	var queryLinesCounter = 0;
	var queryLinesCounterLimit = 50;
	var fuzzyVarsCounter = 0;

	function chooseQuantifierCode(fuzzyRuleIndex, fuzzyRuleQuantifierIndex) {
		var html = "<select name=\'fuzzyRuleQuantifier[" + fuzzyRuleIndex + "][" + fuzzyRuleQuantifierIndex + "]\'>";
		html += "<option name=\'----\' value=\'----\'>----</option>";
		for (var i=0; i<programIntrospectionArray.length; i++){
			if (programIntrospectionArray[i].predClass == "quantifier") {
				if (((fuzzyRuleQuantifierIndex == 0) && (programIntrospectionArray[i].predName == "fnot")) ||
						((fuzzyRuleQuantifierIndex == 1) && (programIntrospectionArray[i].predName != "fnot"))) {
					html += "<option name=\'" + programIntrospectionArray[i].predName + 
								"\' value=\'" + programIntrospectionArray[i].predName + "\'>";
					if (programIntrospectionArray[i].predName == "fnot") html += "not";
					else html += programIntrospectionArray[i].predName;
					html += "</option>";
				}
			}
		}
		html += "</select>";
		return html;
	}
	
	function startupTypeIsValid(startupType, predType) {
		return (predType[0] == startupType);
	}
	
	function chooseRuleCode(fuzzyRuleIndex, startupType) {
		var html = "<select name=\'fuzzyRule[" + fuzzyRuleIndex + 
		           "]\' onchange=\"fuzzyRuleChange(this, " + fuzzyRuleIndex + ");\">";
		html += "<option name=\'----\' value=\'----\''>----</option>";
		for (var i=0; i<programIntrospectionArray.length; i++){
			if (((programIntrospectionArray[i].predClass == "crisp_rule") ||
					(programIntrospectionArray[i].predClass == "fuzzy_rule")) &&
					startupTypeIsValid(startupType, programIntrospectionArray[i].predType)) {
				html += "<option name=\'" + programIntrospectionArray[i].predName + 
							"\' value=\'" + programIntrospectionArray[i].predName + "\'>"+
							programIntrospectionArray[i].predName + "</option>";
			}
		}
		html += "</select>";
		return html;
	}
	function fuzzyRuleArgsCode(fuzzyRuleIndex) {
		return "<div class='ruleArgs'><div id=\'ruleArgs[" + fuzzyRuleIndex + "]\'></div></div>";
	}
	
	function addFuzzyRuleArgumentFields(fuzzyRuleIndex, fuzzyVarIndex) {
		debug.info("addFuzzyRuleArgumentFields: fuzzyRuleIndex:" + fuzzyRuleIndex + " fuzzyVarIndex:" + fuzzyVarIndex);
		var html = "";
		html += "<select name=\'fuzzyRuleArgument[" + fuzzyRuleIndex + "]["+ fuzzyVarIndex+"]\'" + 
				"onchange=\"fuzzyRuleArgumentChange(this, " + fuzzyRuleIndex + ", " + fuzzyVarIndex +");\">";
		for (var k=fuzzyVarIndex; k<fuzzyVarsCounter; k++){
			html += "<option name=\'var_" + k + "\' value=\'var_" + k + "\'>variable_"+ k + "</option>";
		}
		for (var k=0; k<fuzzyVarIndex; k++){
			html += "<option name=\'var_" + k + "\' value=\'var_" + k + "\'>variable_"+ k + "</option>";
		}
		html += "<option name=\'constant' value=\'constant\'>constant</option>";
		html += "</select>";
		html += "<div id=\'fuzzyRuleArgumentConstant[" + fuzzyRuleIndex + "]["+ fuzzyVarIndex+"]\'> </div>";
		return html;
	}
	function fuzzyRuleArgumentChange(comboBox, fuzzyRuleIndex, fuzzyVarIndex) {
		var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;
		var divName = "fuzzyRuleArgumentConstant[" + fuzzyRuleIndex + "]["+ fuzzyVarIndex+"]";
		if (comboBoxValue == "constant") {
			var html = "<input type=\'text\' name=\'fuzzyRuleArgumentConstant["+ fuzzyRuleIndex + "][" + fuzzyVarIndex + "]\'>";
			document.getElementById(divName).innerHTML = html;
		}
		else {
			document.getElementById(divName).innerHTML = "";
		}
	}
	
	function fuzzyRuleChange(comboBox, fuzzyRuleIndex) {
		// var elementId = "";
		var divName = "fuzzyRuleArgs[" + fuzzyRuleIndex + "]";
		debug.info("fuzzyRuleChange(comboBox, " + fuzzyRuleIndex + ") -> divName: " + divName);
		// var comboBox = document.getElementById('fuzzyRule[' + fuzzyRuleIndex + ']');
		var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;
		debug.info("comboBoxValue: " + comboBoxValue);
		
		var found = false;
		var i = 0;
		var predArity = 0;
		while ((! found) && (i < programIntrospectionArray.length)) {
			debug.info("programIntrospectionArray["+i+"]: " + programIntrospectionArray[i].predName);
			if (comboBoxValue == programIntrospectionArray[i].predName) {
				found = true;
				foundPredInfo = programIntrospectionArray[i];
			}
			i++;
		}
		
		// HERE !!!
		var fuzzyVarIndex = fuzzyVarsCounter;
		fuzzyVarsCounter += predArity;
		var html = "";
		while (fuzzyVarIndex < fuzzyVarsCounter) {
			if (fuzzyVarIndex +1 == fuzzyVarsCounter) html+= "result: ";
			html += addFuzzyRuleArgumentFields(fuzzyRuleIndex, fuzzyVarIndex);
			fuzzyVarIndex += 1;
		}
		document.getElementById(divName).innerHTML = html;
		document.getElementById('hiddenNumOfVariables').innerHTML = " " + 
					"<input type=\"hidden\" name=\"fuzzyVarsCounter\" id=\"fuzzyVarsCounter\" value=\""+ fuzzyVarsCounter + "\" />";
	}
	
	function addQueryLine(queryLinesDivId, startupType) {
		if (queryLinesCounter == queryLinesCounterLimit) {
			alert("You have reached the limit of adding " + queryLinesCounter + " subqueries.");
		} else {
			var newDiv = document.createElement('div');
			newDiv.id="queryLine_" + queryLinesCounter;
			newDiv.innerHTML = "<table id=\'queryLineTable_"+queryLinesCounter+"\'><tr><td>" +  
					chooseQuantifierCode(queryLinesCounter, 0) + "</td><td>" +
					chooseQuantifierCode(queryLinesCounter, 1) + "</td><td>" +
					chooseRuleCode(queryLinesCounter, startupType) + 
					fuzzyRuleArgsCode(queryLinesCounter) + "</td></tr></table>";
			
			document.getElementById(queryLinesDivId).appendChild(newDiv);
			// document.getElementById(queryLinesDivId).innerHTML += newDiv;
			queryLinesCounter++;
		}
	}
	
	function startupChange(comboBox, queryLinesDivId, queryTypeDivId) {
		var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;
		debug.info("comboBoxValue: " + comboBoxValue);
		
		document.getElementById(queryLinesDivId).innerHTML="";
		addQueryLine(queryLinesDivId, comboBoxValue);
	}
	
	function fillQueryStartupValues(queryStartId) {
		var validTypesArray = new Array();
		var validTypesArrayCounter = 0;
		for (var i=0; i<programIntrospectionArray.length; i++) {
			if (programIntrospectionArray[i].predType != '-variable-') {
				for (var j=0; j<programIntrospectionArray[i].predType.length; j++) {
					var k=0;
					var found=false;
					while ((k < validTypesArrayCounter) && (! found)) {
						if (validTypesArray[k] == programIntrospectionArray[i].predType[j])	found = true;
						else k++;
					}
					if (! found) {
						validTypesArray[validTypesArrayCounter] = programIntrospectionArray[i].predType[j];
						validTypesArrayCounter++;
					}
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
