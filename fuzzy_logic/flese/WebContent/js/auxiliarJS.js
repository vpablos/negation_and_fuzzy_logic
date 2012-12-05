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
		   			console.log(data); //data returned
		   			console.log(textStatus); //success
		   			console.log(jqxhr.status); //200
		   			console.log('Load was performed.');
				});
	}
	
}

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
	   			
	   			var userInformationDiv = document.createElement('div');
	   			userInformationDiv.id = "userInformationDiv";
	   			userInformationDiv.className = "userInformationTable";
	   			parentDiv.appendChild(userInformationDiv);
	   			
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
			});
	
	return false;
}

function insertFilesList (parentDivId) {
	
	var parentDiv = document.getElementById(parentDivId);
	var filesListDiv = document.createElement('div');
	filesListDiv.id = "filesListDiv";
	parentDiv.appendChild(filesListDiv);
	filesListDiv.innerHTML = loadingImageHtml();
		
	$.getScript(urlMappingFor('FilesListRequest'), 
			function(data, textStatus, jqxhr) {
				filesListDiv.innerHTML = "";
	   			filesListDiv.className = "filesListTable"; 			
	   			var row = null;
	   			var cell = null;
	   			
	   			if ((filesList != null) && (filesList.length > 0)) {
	   				
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
	   			
	   				for (var i=0; i<filesList.length; i++) {
	   					
		   				row = document.createElement('div');
		   				row.className = "filesListTableRow";
		   				filesListDiv.appendChild(row);
		   			
		   				cell = document.createElement('div');
		   				cell.className = "filesListTableCell";
		   				cell.innerHTML = "<a href='#' title='view program file " + filesList[i].fileName + "' "+
		   								 "rel='" + urlMappingFor('FileViewRequest') + 
		   								 "&fileName="+filesList[i].fileName+"&fileOwner="+filesList[i].fileOwner + "'>" + 
		   								 filesList[i].fileName + "</a>";
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
	   				
	   				useRelAttributeToCreatePopUps();
	   			}
			});
}


function useRelAttributeToCreatePopUps() {
	   // Use the each() method to gain access to each elements attributes
	   $('a[rel]').each(function()
	   {
	      $(this).qtip(
	      {
	         content: {
	            // Set the text to an image HTML string with the correct src URL to the loading image you want to use
	            text: loadingImageHtml(),
	            // '<img class="throbber" src="/projects/qtip/images/throbber.gif" alt="Loading..." />',
	            url: $(this).attr('rel'), // Use the rel attribute of each element for the url to load
	            title: {
	               text: 'Showing contents of program file ' + $(this).text(), // Give the tooltip a title using each elements text
	               button: 'Close' // Show a close link in the title
	            }
	         },
	         position: {
	             corner: {
	                target: 'topRight',
	                tooltip: 'bottomLeft'
	             }
	         },
/*	         position: {
	            corner: {
	               target: 'bottomMiddle', // Position the tooltip above the link
	               tooltip: 'topMiddle'
	            },
	            adjust: {
	               screen: true // Keep the tooltip on-screen at all times
	            }
	         }, */
	         show: { 
	            when: 'click', 
	            solo: true // Only show one tooltip at a time
	         },
	         hide: 'unfocus',
	         style: {
	            tip: true, // Apply a speech bubble tip to the tooltip at the designated tooltip corner
	            border: {
	               width: 0,
	               radius: 4
	            },
	            name: 'light', // Use the default light style
	            // width: 570 // Set the tooltip width
	            width: '50%' // Set the tooltip width
	         }
	      });
	   });
}


function fileContentsPopUp(fileName) {
	
	return false;
}




