
<!-- beginning of commonBodyHead -->

<%@page import="auxiliar.ServletsAuxMethodsClass"%>
<%@page import="auxiliar.UrlMappingClass"%>
<script type="text/javascript">
	function urlMapping(nickName, url) {
		this.nickName = nickName;
		this.url = url;
	}
	var urlsMappings = new Array();
<%
	UrlMappingClass[] urlsMappings = ServletsAuxMethodsClass.urlsMappings();
	for (int i=0; i<urlsMappings.length; i++) {
		out.write("    urlsMappings["+i+"] = new urlMapping('" + urlsMappings[i].getKeyString() + "', '" + urlsMappings[i].getUrl() + "');\n");
	}
%>
	function urlMappingFor (nickName) {
		var found = false;
		var i = 0;
		while ((! found) && (i < urlsMappings.length)) {
			if (urlsMappings[i].nickName == nickName) {
				found = true;
				return urlsMappings[i].url;
			}
			else i++
		}
		return null;
	}
	
	function setupHref (aId, href) {
		var aLink = document.getElementById(aId);
		if (aLink != null) aLink.href = href;
	}
	
	function setupUserOptionsLink (aId) {
		var aLink = document.getElementById(aId);
		if (aLink != null) {
			aLink.onclick = function() { insertUserOptions('mainSection'); };
			aLink.href = "alcahueta";
		}
		
	}

<%
	String localUserName = null;
	if (request != null) {
		localUserName = (String) request.getAttribute("localUserName");
	}
	if (localUserName != null) {
		out.write("    var localUserName = '" + localUserName + "';\n");
	} 
	else {
		out.write("    var localUserName = null;\n");
	}
%>
	function setupBodyHeadLoggedDiv(mainSectionDivId) {
		var bodyHeadLoggedDiv = document.getElementById("bodyHeadLogged");
		if (localUserName == null) {
			bodyHeadLoggedDiv.innerHTML = "Not logged in";
		}
		else {
			bodyHeadLoggedDiv.innerHTML = "logged as <br /> " + localUserName + " <br> " + 
			"<a id='userOptions' title='user options' href='' onclick='return insertUserOptions(\'"+mainSectionDivId+"\');'>user options</a>";
		}
	}
	
	var msgsToTheUser = new Array();
	
	function addMsgToTheUser (msg) {
		msgsToTheUser[msgsToTheUser.length] = msg;
	}
	
	function showMsgsToTheUser () {
		var bodyToUserMsgsDiv = document.getElementById("bodyToUserMsgs");
		var html = "";
		if (msgsToTheUser.length != 0) {
			html += "<h3 class='bodyToUserMsgs'>Messages to the user:</h3>";
			html += "<ul class='bodyToUserMsgs'>";
			for (var i=0; i<msgsToTheUser.length; i++) {
				html += "<li class='bodyToUserMsgs'>";
				html += msgsToTheUser[i];
				html += "</li>";
			}
			html += "</ul>";
		}
		if (bodyToUserMsgsDiv != null) {
			bodyToUserMsgsDiv.innerHTML = html;
		}
		else {
			alert("bodyToUserMsgsDiv is null. Msgs will be shown in this way.")
			for (var i=0; i<msgsToTheUser.length; i++) {
				alert(msgsToTheUser[i]);
			}
		}
	}
	
<%
	if (request != null) {
		if (request.getAttribute("msgs") != null) {
			String [] msgs = (String []) request.getAttribute("msgs");
			for (int i=0; i<msgs.length; i++) {
				out.write("    addMsgToTheUser('"+msgs[i]+"');");
			}
			request.removeAttribute("msgs");
		}			
	}
	else {
		out.write("    addMsgToTheUser('ERROR: request is null.');");
	}
%>
	
</script>



<header>
	<div id="bodyHeadTable" class="bodyHeadTable">
		<div id="bodyHeadTitle" class="bodyHeadTable">
			FleSe : <span class="underline">Fle</span>xible 
			<span class="underline">Se</span>arches in Databases
		</div>
		<div id="bodyHeadLogged" class="bodyHeadTable"></div>
		<div id="bodyHeadLogout" class="bodyHeadTable"><a id="signOut" title="Sign out" href="">Sign out</a></div>
	</div>
</header>
<br />
<section id="bodyToUserMsgs" class="bodyToUserMsgs">
</section>
<br />

<script type="text/javascript">
	setupBodyHeadLoggedDiv('mainSection');
	setupHref ('signOut', urlMappingFor('SignOutRequest'));
	showMsgsToTheUser();
</script>

<!-- end of commonBodyHead -->


