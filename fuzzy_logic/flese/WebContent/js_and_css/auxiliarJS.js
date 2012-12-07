/*!
 * programQuery Library v1
 * Author: Victor Pablos Ceruelo
 */

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

function loadingImageHtml() {
	return "<br /><img src=\"images/loading.gif\" width=\"200\" alt=\"loading\" title=\"loading\" />";
}

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

function fileInfo(fileName, fileOwner) {
	this.fileName = fileName;
	this.fileOwner = fileOwner;
}

function insertProgramFileSelection(parentDivId) {
	var parentDiv = document.getElementById(parentDivId);
	parentDiv.innerHTML = loadingImageHtml();
	
	$.getScript(urlMappingFor('FilesListRequest'), 
			function(data, textStatus, jqxhr) {
		parentDiv.innerHTML = "";
		
		var selectDatabaseDiv = document.createElement('div');
		selectDatabaseDiv.id = "selectDatabaseDiv";
		parentDiv.appendChild(selectDatabaseDiv);
		
		if ((filesList == null) || (filesList.length == 0)) {
			selectDatabaseDiv.innerHTML = "No databases. Please upload one via your user options.";
		}
		else {
			var html = "";
			html += "<select name='selectedDatabase' onchange='selectedProgramDatabaseChanged(this, \""+parentDivId+"\")' >";
			html += "<option id='----' name='----' title='----' value='----'>----</option>";
			for (var i=0; i<filesList.length; i++) {
				html += "<option id='" + filesList[i].fileName + "-owned-by-" + filesList[i].fileOwner + "' " +
						"name='" + filesList[i].fileName + "-owned-by-" + filesList[i].fileOwner + "' " +
						"title='" + filesList[i].fileName + "-owned-by-" + filesList[i].fileOwner + "' " +
						"value='" + filesList[i].fileName + "-owned-by-" + filesList[i].fileOwner + "'>" + 
						filesList[i].fileName + " ( owned by " + filesList[i].fileOwner + " ) " +
						"</option>";
			}
			html += "</select>";
			selectDatabaseDiv.innerHTML = html;
		}
	});
}

// Declare as global the variable containing the files list.
var filesList = null;

function cleanUpFilesList() {
	filesList = new Array();
}

function addToFilesList(index, fileName, fileOwner) {
	filesList[index] = new fileInfo(fileName, fileOwner);
}

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

var programIntrospection = new Array();

function cleanUpProgramIntrospection() {
	programIntrospection = null;
	programIntrospection = new Array();
}

function addToProgramIntrospection(index, predInfo) {
	programIntrospection[index] = predInfo;
}

function predInfo(predName, predArity, predType, predOtherInfo) {
	this.predName = predName;
	this.predArity = predArity;
	this.predType = predType;
	this.predOtherInfo = predOtherInfo;
}


function selectedProgramDatabaseChanged(comboBox, parentDivId) {
	// debug.info("parentDivId: " + parentDivId);
	var parentDiv = document.getElementById(parentDivId);
	
	var selectQueryDiv = document.getElementById('selectQueryDiv');
	if (selectQueryDiv == null) {
		selectQueryDiv = document.createElement('div');
		selectQueryDiv.id = 'selectQueryDiv';
		parentDiv.appendChild(selectQueryDiv);
	}

	selectQueryDiv.innerHTML = loadingImageHtml();
	
	var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;
	// alert("comboBoxValue: " + comboBoxValue);
	if ((comboBoxValue == null) || (comboBoxValue == "") || (comboBoxValue == "----")) {
		selectQueryDiv.innerHTML="Please choose a valid database to continue.";
	}
	else {
		var fileName = null;
		var fileOwner = null;
		var separation = "-owned-by-";
	
		i = comboBoxValue.indexOf(separation);
		if (i != -1) {
			fileName = comboBoxValue.substring(0, i);
			fileOwner = comboBoxValue.substring(i+separation.length);
		}
		else {
			fileName = '';
			fileOwner = '';
		}
		
		$.getScript(urlMappingFor('ProgramFileIntrospectionRequest') + "&fileName="+fileName+"&fileOwner="+fileOwner, 
				function(data, textStatus, jqxhr) {
					// debug.info("ProgramFileIntrospectionRequest done ... ");
		   			// alert("ProgramFileIntrospectionRequest done ... ");
		   			insertQuerySelection(parentDivId, selectQueryDiv.id, fileName, fileOwner);
				});
	}
	
}

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

function insertQuerySelection(parentDivId, selectQueryDivId, fileName, fileOwner) {
	// alert("Running insertQuerySelection ... ");
	var selectQueryDiv = document.getElementById(selectQueryDivId);
	selectQueryDiv.innerHTML = "";
	
	var chooseQueryStartTypeDivId = "chooseQueryStartTypeDiv";
	var queryLinesContainerDivId = "queryLinesContainerDiv";
	var queryLinesCounterFieldId = "queryLinesCounter";
	var html = "";
	html += "<form id='queryForm' action='"+ urlMappingFor('RunQueryRequest') + "&fileName="+fileName+"&fileOwner="+fileOwner + "' " +
			"method='POST' accept-charset='utf-8'>";
	html += "     <div id='queryStartContainer' class='queryStartTable'>";
	html += "          <div class='queryStartRow'>";
	html += "               <div class='queryStartCell'> ";
	html += "                    <h3>Your query: I'm looking for a </h3> ";
	html += "               </div>";
	html += "               <div class='queryStartCell' id='"+ chooseQueryStartTypeDivId +"'></div>";
	html += "          </div>";
	html += "     </div>";
    html += "     <input type='hidden' name='"+ queryLinesCounterFieldId +"' value='0' id='"+ queryLinesCounterFieldId +"'>";
    html += "     <div id='"+ queryLinesContainerDivId +"' class='queryLinesContainerTable'></div>";
	html += "     <INPUT type='submit' value='Execute Query' onclick='return testQueryValidity();'>";
	html += "</form>";

	selectQueryDiv.innerHTML = html;
	insertChooseQueryStartupType(chooseQueryStartTypeDivId, queryLinesContainerDivId, queryLinesCounterFieldId);
	
}

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

function insertChooseQueryStartupType(chooseQueryStartTypeDivId, queryLinesContainerDivId, queryLinesCounterFieldId) {
	var validTypesArray = new Array();
	var valid = false;
	for (var i=0; i<programIntrospection.length; i++) {
		valid = false;
		if (programIntrospection[i].predOtherInfo != '[]') {
			for (var j=0; j<programIntrospection[i].predOtherInfo.length; j++) {
				if (programIntrospection[i].predOtherInfo[j][0] == 'database') {
					valid = true;
				}
			}
		}
		
		if (valid) {
			var k=0;
			var found=false;
			while ((k < validTypesArray.length) && (! found)) {
				if (validTypesArray[k] == programIntrospection[i].predName)	found = true;
				else k++;
			}
			if (! found) {
				validTypesArray[validTypesArray.length] = programIntrospection[i].predName;
			}
		}
	}
	
	var html = "<select name=\'startupType' onchange=\"queryStartupTypeChanged(this, \'"+queryLinesContainerDivId+"\', \'"+queryLinesCounterFieldId+"\');\">";
	html += "<option name=\'----\' value=\'----\''>----</option>";
	for (var i=0; i<validTypesArray.length; i++) {
		html += "<option name=\'"+validTypesArray[i]+"\' value=\'"+validTypesArray[i]+"\''>"+validTypesArray[i]+"</option>";
	}
	html += "</select>";
	document.getElementById(chooseQueryStartTypeDivId).innerHTML = html;
}

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

function queryStartupTypeChanged(comboBox, queryLinesContainerDivId, queryLinesCounterFieldId) {
	var comboBoxValue = comboBox.options[comboBox.selectedIndex].value;
	debug.info("queryStartupTypeChanged: to " + comboBoxValue);
	
	resetQueryLinesCounterField(queryLinesCounterFieldId);
	var queryLinesContainerDiv = document.getElementById(queryLinesContainerDivId); 
	queryLinesDiv.innerHTML="";
	
	var row = null;
	var cell = null;
	var cellContents = null;
	var queryLinesTableId = "queryLinesTable";
	var queryLinesAggregatorTableId = "queryLinesAggregatorTable";
	
	row = document.createElement('div');
	row.className = "queryLinesContainerTableRow";
	queryLinesContainerDiv.appendChild(row);
	
	cell = document.createElement('div');
	cell.className = "queryLinesContainerTableCell";
	row.appendChild(cell);
	
	cellContents = document.createElement('div');
	cell.className = queryLinesTableId;
	cell.id = queryLinesTableId;
	cell.appendChild(cellContents);
	
	cell = document.createElement('div');
	cell.className = "queryLinesContainerTableCell";
	row.appendChild(cell);
	
	cellContents = document.createElement('div');
	cell.className = queryLinesAggregatorTableId;
	cell.id = queryLinesAggregatorTableId;
	cell.appendChild(cellContents);
	
	insertQueryLine(queryLinesTableId, queryLinesAggregatorTableId, comboBoxValue);
	// insertAggregatorTable(queryLinesTableId, queryLinesAggregatorTableId, comboBoxValue);
}

function resetQueryLinesCounterField(queryLinesCounterFieldId) {
	document.getElementById(queryLinesCounterFieldId).value = 0;
}

function incrementQueryLinesCounterField(queryLinesCounterFieldId) {
	document.getElementById(queryLinesCounterFieldId).value ++;
	return document.getElementById(queryLinesCounterFieldId).value;
}

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

function insertAggregatorTable(queryLinesTableId, queryLinesAggregatorTableId, comboBoxValue) {

	var queryLinesAggregatorTable = document.getElementById(queryLinesAggregatorTableId);
	var row = null;
	var cell = null;
	
	row = document.createElement('div');
	row.className = queryLinesAggregatorTableId + "Row";
	queryLinesAggregatorTable.appendChild(row);
	
	cell = document.createElement('div');
	cell.className = queryLinesAggregatorTableId + "Cell";
	row.appendChild(cell);
	
	cell.innerHTML= "<a href=\"\" onClick='return addQueryLineAndAggregatorChoose"+
					"(\""+queryLinesTableId+"\", \""+queryLinesAggregatorTableId+"\", \""+comboBoxValue+"\");' >" +
					"<img src=\"images/add.png\" width=\"20\" alt=\"Add more conditions to the query\" "+
					"title=\"Add more conditions to the query\" /></a>";
	
	return false;
}



/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------- */

userInformation = null;

function userInformationClass(fieldName, fieldValue) {
	this.fieldName = fieldName;
	this.fieldValue = fieldValue;
}

function cleanUpUserInformation () {
	userInformation = null;
	userInformation = new Array ();
}

function addToUserInformation(index, fieldName, fieldValue) {
	userInformation[index] = new userInformationClass(fieldName, fieldValue);
}

function insertUserOptions(parentDivId) {
	var parentDiv = document.getElementById(parentDivId);
	
	parentDiv.innerHTML = loadingImageHtml();
	
	$.getScript(urlMappingFor('UserOptionsRequest'), 
			function(data, textStatus, jqxhr) {
	   			parentDiv.innerHTML = "";
	   			
	   			var userInformationDiv = document.getElementById("userInformationDiv");
	   			if (userInformationDiv == null) {
	   				userInformationDiv = document.createElement('div');
	   				userInformationDiv.id = "userInformationDiv";
	   				userInformationDiv.className = "userInformationTable";
	   				parentDiv.appendChild(userInformationDiv);
	   			}
	   			userInformationDiv.innerHTML = "";
	   			
	   			var row = null;
	   			var cell = null;
	   			
	   			row = document.createElement('div');
	   			row.className = "userInformationTableRow";
	   			userInformationDiv.appendChild(row);
	   			
	   			cell = document.createElement('div');
	   			cell.className = "userInformationTableCell";
	   			cell.innerHTML = "Field Name";
	   			row.appendChild(cell);

	   			cell = document.createElement('div');
	   			cell.className = "userInformationTableCell";
	   			cell.innerHTML = "Value";
	   			row.appendChild(cell);

	   			for (var i=0; i<userInformation.length; i++) {
		   			row = document.createElement('div');
		   			row.className = "userInformationTableRow";
		   			userInformationDiv.appendChild(row);
		   			
		   			cell = document.createElement('div');
		   			cell.className = "userInformationTableCell";
		   			cell.innerHTML = userInformation[i].fieldName;
		   			row.appendChild(cell);

		   			cell = document.createElement('div');
		   			cell.className = "userInformationTableCell";
		   			cell.innerHTML = userInformation[i].fieldValue;;
		   			row.appendChild(cell);
	   			}
	   			
	   			insertFilesList(parentDivId);
	   			insertFileUploadFacility(parentDivId);
			});
	
	return false;
}

function insertFilesList (parentDivId) {
	
	var parentDiv = document.getElementById(parentDivId);
	var filesListDiv = document.getElementById('filesListDiv'); 
	if (filesListDiv == null) {
		filesListDiv = document.createElement('div');
		filesListDiv.id = "filesListDiv";
		parentDiv.appendChild(filesListDiv);
	}
	filesListDiv.innerHTML = loadingImageHtml();
	
	var fileViewContentsDiv = document.getElementById("fileViewContentsDiv");
	if (fileViewContentsDiv == null) {
		fileViewContentsDiv = document.createElement('div');
		fileViewContentsDiv.id = "fileViewContentsDiv";	 
		parentDiv.appendChild(fileViewContentsDiv);
	}
	fileViewContentsDiv.innerHTML = "";
		
	$.getScript(urlMappingFor('FilesListRequest'), 
			function(data, textStatus, jqxhr) {
				filesListDiv.innerHTML = "";
	   			filesListDiv.className = "filesListTable"; 			
	   			var row = null;
	   			var cell = null;
	   			
	   			var showHead = true;
	   			if ((filesList != null) && (filesList.length > 0)) {
	   				for (var i=0; i<filesList.length; i++) {
	   					if (filesList[i].fileOwner == localUserName) {
	   						if (showHead) {
	   							insertFilesListHead(filesListDiv.id);
	   							showHead = false;
	   						}
	   						
	   						row = document.createElement('div');
	   						row.className = "filesListTableRow";
	   						filesListDiv.appendChild(row);
		   			
	   						cell = document.createElement('div');
	   						cell.className = "filesListTableCell";
	   						cell.innerHTML = "<a href='#' title='view program file " + filesList[i].fileName + "' "+
		   								 	 "onclick='fileViewAction(" + i + ", \"" + fileViewContentsDiv.id + "\");' >" + 
		   								 	 filesList[i].fileName + "</a>";
	   						row.appendChild(cell);

	   						cell = document.createElement('div');
	   						cell.className = "filesListTableCell";
	   						cell.innerHTML = "<a href='#' title='remove program file " + filesList[i].fileName + "' "+
	   										 "onclick='removeFileAction(" + i + ", \"" + parentDivId + "\");' >" + 
	   										 "<img src='images/remove-file.gif' width='20em'>" + "</a>";
	   						row.appendChild(cell);

	   						cell = document.createElement('div');
	   						cell.className = "filesListTableCell";
		   					cell.innerHTML = "Personalizations";
		   					row.appendChild(cell);
	   					}
	   				}
	   			}
	   			
	   			if (showHead) {
	   				filesListDiv.innerHTML = "You do not owe any program file. Upload one by using the facility below.";
	   			}
			});
}

function insertFilesListHead(filesListDivId) {
	var filesListDiv = document.getElementById(filesListDivId);
	var row = null;
	var cell = null;
	
	row = document.createElement('div');
	row.className = "filesListTableRow";
	filesListDiv.appendChild(row);
		
	cell = document.createElement('div');
	cell.className = "filesListTableCell";
	cell.innerHTML = "Program File Name";
	row.appendChild(cell);

	cell = document.createElement('div');
	cell.className = "filesListTableCell";
	cell.innerHTML = "";
	row.appendChild(cell);

	cell = document.createElement('div');
	cell.className = "filesListTableCell";
	cell.innerHTML = "Personalizations";
	row.appendChild(cell);
}

function fileViewAction(index, fileViewContentsDivId) {
	// alert("fileViewContentsDivId: " + fileViewContentsDivId);
	var fileViewContentsDiv = document.getElementById(fileViewContentsDivId);
	
	$.get(urlMappingFor('FileViewRequest') + "&fileName="+filesList[index].fileName+"&fileOwner="+filesList[index].fileOwner, 
			function(data, textStatus, jqxhr) {
				fileViewContentsDiv.innerHTML = data;
				
			    $(function() {
			    	$(fileViewContentsDiv).dialog({
		                // add a close listener to prevent adding multiple divs to the document
		                close: function(event, ui) {
		                    // remove div with all data and events
		                    // dialog.remove();
		                    fileViewContentsDiv.innerHTML = "";
		                },
		                modal: true,
		                resizable: true, 
		                height: "auto", // 800,
		                width: "auto", // 800,
		                title: 'Contents of program file ' + filesList[index].fileName
		            });
			        // $( "#" + fileViewContentsDivId ).dialog();
			    });
			});
	
	//prevent the browser to follow the link
	return false;
}

function removeFileAction (index, parentDivId) {
	$.get(urlMappingFor('FileRemoveRequest') + "&fileName="+filesList[index].fileName+"&fileOwner="+filesList[index].fileOwner, 
			function(data, textStatus, jqxhr) {
				// Reload the screen.
				// alert("parentDivId: " + parentDivId);
				insertFilesList(parentDivId);
			});
}

function getIframeWindow(iframe_object) {
	  var doc = null;

	  if (iframe_object.contentWindow) return iframe_object.contentWindow;
	  if (iframe_object.window) return iframe_object.window;

	  if ((doc == null) && iframe_object.contentDocument) doc = iframe_object.contentDocument;
	  if ((doc == null) && iframe_object.document) doc = iframe_object.document;

	  if ((doc != null) && doc.defaultView) return doc.defaultView;
	  if ((doc != null) && doc.parentWindow) return doc.parentWindow;

	  return null;
	}

function notNullNorundefined(value) {
	return ((value != null) && (value != undefined));
}

function insertFileUploadFacility(parentDivId) {
	var parentDiv = document.getElementById(parentDivId);
	var fileUploadDiv = document.getElementById("fileUploadDiv");
	if (fileUploadDiv == null) {
		fileUploadDiv = document.createElement('div');
		fileUploadDiv.id = "fileUploadDiv";
		parentDiv.appendChild(fileUploadDiv);
	}
	
	var uploadFormId = "uploadForm";
	var uploadStatusDivId = "uploadStatus";
	var uploadFormTargetiFrameId = "uploadFormTargetiFrame";
	
	fileUploadDiv.innerHTML = "Upload Program files <br />" + 
							  "<FORM ID='"+uploadFormId+"' ENCTYPE='multipart/form-data' method='POST' accept-charset='UTF-8' "+
							  "target='" + uploadFormTargetiFrameId+ "' action='" + urlMappingFor('FileUploadRequest') + "' >" +
							  		"<INPUT TYPE='file' NAME='programFileToUpload' size='50' "+
							  		"onchange='uploadActionOnChange(\""+uploadFormId+"\", \""+uploadStatusDivId+"\");'>" +
							  "</FORM>" +
							  "<div id='"+uploadStatusDivId+"'></div>" +
							  "<iframe id='"+uploadFormTargetiFrameId+"' name='"+uploadFormTargetiFrameId+"' "+
							  "src='#' style='display:none;'></iframe>";
    	
	$('#' + uploadFormTargetiFrameId).load(function() {
		// document.getElementById('#' + submitiFrameId);
		var responseHtmlText = null;
		var iFrameWindow = getIframeWindow(this);
		if ((notNullNorundefined(iFrameWindow)) && (notNullNorundefined(iFrameWindow.document)) && (notNullNorundefined(iFrameWindow.document.body))) {
			responseHtmlText = iFrameWindow.document.body.innerHTML;
			// Do something with response text.
			if (notNullNorundefined(responseHtmlText)) {
				iFrameWindow.document.body.innerHTML="";
			}
			// Clear the content of the iframe.
			// this.contentDocument.location.href = '/images/loading.gif';
			// alert("responseText: " + responseHtmlText);
			document.getElementById(uploadStatusDivId).style.visibility = 'visible';
			document.getElementById(uploadStatusDivId).innerHTML = responseHtmlText;

			// Update the files list.
			insertFilesList (parentDivId);
		}
		  
	});	
}

function uploadActionOnChange(formId, uploadStatusDivId) {
	// alert("Upload Submit Action started ...");
	document.getElementById(uploadStatusDivId).style.visibility = 'visible';
	document.getElementById(uploadStatusDivId).innerHTML = loadingImageHtml();

	var form = document.getElementById(formId);
	form.submit();
}


/* ----------------------------------------------------------------------------------------------------------------------------*/
/* ----------------------------------------------------------------------------------------------------------------------------*/
/* ----------------------------------------------------------------------------------------------------------------------------*/

// EOF

/* ----------------------------------------------------------------------------------------------------------------------------*/
/* ----------------------------------------------------------------------------------------------------------------------------*/
/* ----------------------------------------------------------------------------------------------------------------------------*/


