<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Fuzzy Search</title>
</head>
<body>
		<H1>Perform your query.</H1>

		<% if (request.getAttribute("msg1") != null) { %>
			<h1>MSG: <%=request.getAttribute("msg1") %>
			</h1>
		<% } %>
		
		<% if (request.getAttribute("msg2") != null) { %>
			<h1>MSG: <%=request.getAttribute("msg2") %>
			</h1>
		<% } %>

<!--
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><script>function envFlush(a){function b(c){for(var d in a)c[d]=a[d];}if(window.requireLazy){requireLazy(['Env'],b);}else{Env=window.Env||{};b(Env);}}
envFlush({"user":"1620895280","locale":"es_ES","method":"GET","svn_rev":608370,"tier":"","vip":"66.220.153.72","static_base":"https:\/\/s-static.ak.facebook.com\/","www_base":"http:\/\/www.facebook.com\/","rep_lag":2,"fb_dtsg":"AQD8MCzX","ajaxpipe_token":"AXgdTMlmlwwQA1Sq","lhsh":"tAQFs4eTP","tracking_domain":"https:\/\/pixel.facebook.com","retry_ajax_on_network_error":"1","fbid_emoticons":"1"});</script><script>envFlush({"eagleEyeConfig":{"seed":"0WKK","sessionStorage":true}});CavalryLogger=false;window._script_path = "DeveloperAppDetailsPageletController";</script><noscript> <meta http-equiv="refresh" content="0; URL=/apps/104311106384261/summary?_fb_noscript=1" /> </noscript>
<meta name="robots" content="noodp, noydir" /><meta name="referrer" content="default" id="meta_referrer" /><meta name="description" content="&#xa1;Bienvenido a Facebook en Espa&#xf1;ol (Espa&#xf1;a)! Facebook es una herramienta social que pone en contacto a personas con sus amigos y otras personas que trabajan, estudian y viven en su entorno. Facebook se emplea para estar en contacto con amigos, cargar un n&#xfa;mero ilimitado de fotos, compartir enlaces y v&#xed;deos, y saber m&#xe1;s sobre las personas conocidas." /><link rel="alternate" media="handheld" href="https://developers.facebook.com/apps/104311106384261/summary" /><title>Básica - Desarrolladores de Facebook</title><link rel="canonical" href="https://developers.facebook.com/apps/104311106384261/summary/" /><meta property="fb:app_id" content="113869198637480" /><meta property="og:title" content="B&#xe1;sica" /><meta property="og:type" content="website" /><meta property="og:url" content="https://developers.facebook.com/apps/104311106384261/summary" /><meta property="og:image" content="https://developers.facebook.com/attachment/platformlogo.jpg" /><meta property="og:site_name" content="Facebook Developers" />
    <link rel="stylesheet" href="https://s-static.ak.fbcdn.net/rsrc.php/v2/yn/r/onAV1-PV3Pg.css" />
    <link rel="stylesheet" href="https://s-static.ak.fbcdn.net/rsrc.php/v2/yX/r/aAAp834HQTp.css" />
    <link rel="stylesheet" href="https://s-static.ak.fbcdn.net/rsrc.php/v2/yx/r/9bfBibvqF1x.css" />

    <script src="https://s-static.ak.fbcdn.net/rsrc.php/v2/y5/r/Y4wWsHS3XhZ.js"></script>
  <script type="text/javascript">window.Bootloader && Bootloader.done(["NPGon"]);</script><script>new (require("ServerJS"))().handle({"require":[["lowerDomain"],["QuicklingPrelude"],["Primer"]]})</script></head><body class="ff4 Locale_es_ES"><div id="FB_HiddenContainer" style="position:absolute; top:-10000px; width:0px; height:0px;"></div><div class="-cx-PRIVATE-fbLayout__root"><div class="devsitePage"><div class="menu"><div class="content"><a class="logo topNavItem" href="/"><i class="img sp_990tmg sx_a67319"><u>Desarrolladores de Facebook</u></i></a><div class="search"><form method="get" action="/search"><span class="uiSearchInput"><span><input type="text" class="inputtext DOMControl_placeholder" maxlength="100" aria-label="Buscar" name="selection" placeholder="Search Facebook Developers" value="Search Facebook Developers" /><button type="submit" title="Search Facebook Developers"><span class="accessible_elem">Search Facebook Developers</span></button></span></span></form></div><a class="topNavItem" href="/docs/">Documentos</a><a class="topNavItem" href="/tools">Herramientas</a><a class="topNavItem" href="/support/">Soporte</a><a class="topNavItem" href="/blog/">Noticias</a><a class="topNavItem" href="https://developers.facebook.com/apps">Aplicaciones</a><ul class="account"><li class="tinyman"><a href="http://www.facebook.com/victorpablosceruelo"><img class="-cx-PRIVATE-uiSquareImage__root tinymanPhoto -cx-PRIVATE-uiSquareImage__large img" src="https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/48984_1620895280_7460296_q.jpg" alt="" /><span class="tinymanName">Victor</span></a></li><li id="accountNav"><a id="accountNavArrow" onclick="CSS.toggleClass(this.parentNode, &quot;togglerOpen&quot;);" href="#"><div class="menuPulldown"></div></a><ul class="nav"><a class="submenuNav" href="http://www.facebook.com/campaign/landing.php?placement=tad_dev&amp;campaign_id=264263327005748&amp;extra_1=auto">Publicidad</a><li><a class="submenuNav" href="https://developers.facebook.com/settings?tab=email">Configuración</a></li><li><form id="logout_form" method="post" action="https://www.facebook.com/logout.php" onsubmit="return Event.__inlineSubmit(this,event)"><input type="hidden" name="fb_dtsg" value="AQD8MCzX" autocomplete="off" /><input type="hidden" autocomplete="off" name="ref" value="ds" /><input type="hidden" autocomplete="off" name="h" value="AffCxZGwIj4a3YRN" /><label class="uiLinkButton submenuNav logoutButton"><input type="submit" value="Salir" /></label></form></li></ul></li></ul><div class="clear"></div></div></div><div class="body nav" id="DeveloperAppBody"><div class="content"><div><div id="toolbarContainer" class="hidden_elem"></div><div id="mainContainer"><div id="leftColContainer"><div id="leftCol"></div></div><div id="contentCol" class="clearfix"><div id="contentArea" role="main"><div class="developerAppDetailsLeft"><div id="developerAppNavigation" data-referrer="developerAppNavigation"></div></div><div class="developerAppDetailsRight"><div id="headerArea"><div><div id="developerAppHeader" data-referrer="developerAppHeader"></div></div><div></div></div><div id="developerAppDetailsContent" data-referrer="developerAppDetailsContent"></div></div></div><div id="bottomContent"></div></div></div></div></div></div><div class="footer"><div class="content"><div class="copyright"><div class="mrl"><div class="fsm fwn fcg"><span> Facebook © 2012</span> · <a rel="dialog" href="/ajax/intl/language_dialog.php?uri=https%3A%2F%2Fdevelopers.facebook.com%2Fapps%2F104311106384261%2Fsummary" title="Usa Facebook en otro idioma.">Español (España)</a></div></div></div><div class="links"><a href="http://www.facebook.com/FacebookDevelopers" accesskey="1" title="Acerca de">Acerca de</a><a href="http://www.facebook.com/campaign/landing.php?placement=pf_dev&amp;campaign_id=402047449186&amp;extra_1=auto" accesskey="2" title="Publicidad">Publicidad</a><a href="http://www.facebook.com/careers" accesskey="3" title="Careers">Careers</a><a href="http://developers.facebook.com/policy" accesskey="4" title="Normas de la plataforma">Normas de la plataforma</a><a href="http://www.facebook.com/policy.php" accesskey="5" title="Pol&#xed;tica de privacidad">Política de privacidad</a></div></div></div><div id="fb-root"></div><div id="fb-root"></div></div></div>
<script type="text/javascript">Bootloader.setResourceMap({"ZnUfY":{"type":"css","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yn\/r\/onAV1-PV3Pg.css"},"wijP2":{"type":"css","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yX\/r\/aAAp834HQTp.css"},"zO4BE":{"type":"css","permanent":1,"src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yx\/r\/9bfBibvqF1x.css"},"FVdSs":{"type":"css","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yX\/r\/I7PXXk_ZbEC.css"},"X\/Fq6":{"type":"css","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yM\/r\/BVUpc4p1Q3y.css"},"sT0qP":{"type":"css","permanent":1,"src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/ys\/r\/bUcQ81toXjU.css"},"VDymv":{"type":"css","permanent":1,"src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yv\/r\/D3KKXzCPXzc.css"}});Bootloader.setResourceMap({"dJJId":{"type":"js","src":"\/\/connect.facebook.net\/es_ES\/all.js"},"8gPM0":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/ye\/r\/-JeBvooAx6-.js"},"bS0QP":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yI\/r\/DEkb1KhiYGq.js"},"\/geEf":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yf\/r\/9qXljYWZZoC.js"},"ai925":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yq\/r\/CYAZMUDf1xO.js"},"CJBKn":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yB\/r\/x5XDkud1H_O.js"},"cNca2":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yT\/r\/7YVta2ViNbr.js"},"DGjNe":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yo\/r\/4soDYzSjtJM.js"},"1zqwA":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/ys\/r\/G1hmG6HUu0t.js"},"bwsMw":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yi\/r\/5VR2mwxDrFF.js"},"28ZbA":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/ya\/r\/GBtTEkiodA0.js"},"C5ony":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yP\/r\/Fwia1Dbb1Fn.js"},"qrs0z":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yn\/r\/hZOYSk4AV5R.js"},"DI7dA":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yo\/r\/fw9LG7EhhG5.js"},"sGDQW":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yV\/r\/v-RRIlT3ZXH.js"},"zyFOp":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/y-\/r\/0ptsa-67vx7.js"},"2ma5f":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yo\/r\/hCn6u3fXLtg.js"},"q1R25":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yZ\/r\/uVstu2bdKQl.js"},"H42Jh":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/y3\/r\/ppwOo4BAmlb.js"},"AtxWD":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yE\/r\/0jGJARW_TcI.js"},"Kz14F":{"type":"js","src":"https:\/\/s-static.ak.fbcdn.net\/rsrc.php\/v2\/yN\/r\/IkPGluO9j5W.js"}});
Bootloader.enableBootload({"ConfirmationDialog":{"resources":["8gPM0","bS0QP","ai925"],"module":true},"Dialog":{"resources":["8gPM0","bS0QP","zO4BE"],"module":true},"IframeShim":{"resources":["8gPM0","bS0QP","CJBKn"],"module":true},"ErrorSignal":{"resources":["8gPM0","bS0QP","cNca2"],"module":true},"DOM":{"resources":["8gPM0"],"module":true},"HTML":{"resources":["8gPM0"],"module":true},"event-extensions":{"resources":["8gPM0"],"module":true},"AsyncDialog":{"resources":["8gPM0","bS0QP","zO4BE"],"module":true},"FbdDialogProvider":{"resources":["DGjNe","8gPM0","1zqwA","bwsMw"],"module":true},"React":{"resources":["28ZbA","C5ony"],"module":true},"AsyncRequest":{"resources":["8gPM0","bS0QP"],"module":true},"PhotoSnowlift":{"resources":["8gPM0","bS0QP","zO4BE"],"module":true},"VaultBox":{"resources":["8gPM0","bS0QP","zO4BE","qrs0z","DI7dA","sGDQW","FVdSs"],"module":true},"SpotlightShareViewer":{"resources":["8gPM0","bS0QP","X\/Fq6","zyFOp"],"module":true},"PhotoTagger":{"resources":["8gPM0","bS0QP","zO4BE","DI7dA"],"module":true},"fb-photos-snowlift-css":{"resources":["sT0qP","zO4BE"]},"Live":{"resources":["8gPM0","bS0QP","1zqwA"],"module":true},"PhotoTagApproval":{"resources":["8gPM0","bS0QP","DI7dA"],"module":true},"PhotoTags":{"resources":["8gPM0","bS0QP","DI7dA"],"module":true},"TagTokenizer":{"resources":["8gPM0","bS0QP","DI7dA","zO4BE"],"module":true},"fb-photos-snowlift-fullscreen-css":{"resources":["VDymv"]},"PhotoPivot":{"resources":["8gPM0","bS0QP","zO4BE","2ma5f"],"module":true},"PhotosButtonTooltips":{"resources":["8gPM0","bS0QP","zO4BE","q1R25"],"module":true},"VideoRotate":{"resources":["8gPM0","bS0QP","H42Jh"],"module":true},"AsyncResponse":{"resources":["bS0QP"],"module":true},"PhotoInlineEditor":{"resources":["8gPM0","bS0QP","zO4BE","DI7dA","AtxWD"],"module":true},"Form":{"resources":["8gPM0","bS0QP"],"module":true},"DOMScroll":{"resources":["8gPM0","bS0QP"],"module":true},"Toggler":{"resources":["8gPM0","bS0QP","zO4BE"],"module":true},"Tooltip":{"resources":["8gPM0","bS0QP","zO4BE"],"module":true},"Input":{"resources":["8gPM0","bS0QP"],"module":true},"trackReferrer":{"resources":[],"module":true},"detect-broken-proxy-cache":{"resources":["8gPM0"]},"link-rel-preload":{"resources":["8gPM0"]},"legacy:dialog":{"resources":["8gPM0","bS0QP","zO4BE"]},"legacy:ajaxpipe":{"resources":["8gPM0","bS0QP","Kz14F"]},"legacy:async":{"resources":["8gPM0","bS0QP"]},"legacy:PhotoSnowlift":{"resources":["8gPM0","bS0QP","zO4BE","q1R25"]},"legacy:Toggler":{"resources":["8gPM0","bS0QP","zO4BE"]}});</script>
<script type="text/javascript">
Bootloader.configurePage(["ZnUfY","wijP2","zO4BE"]);
Bootloader.done(["jDr+c"]);


new (require("ServerJS"))().handle({"elements":[["m736770_1","logout_form",2]],"define":[["BanzaiConfig",[],{"MAX_SIZE":10000,"MAX_WAIT":60000,"gks":[]}]],"require":[["PlaceholderListener"],["PlaceholderOnsubmitFormListener"],["FlipDirectionOnKeypress"],["enforceMaxLength"],["UserActionHistory"],["userAction","setUATypeConfig",[],[{"uan":false,"uai":false,"uad":false,"uae":false}]],["ScriptPathState","setUserURISampleRate",[],[0.0002]],["userAction","setCustomSampleConfig",[],[{"uan":{"test":{"test":true}}}]],["DimensionTracking"],["InitialJSLoader","loadOnDOMContentReady",[],[["dJJId","8gPM0","bS0QP","\/geEf"]]]]});

onloadRegister_DEPRECATED(function (){window.intl_locale_rewrites = {"meta":{"\/_B\/":"([.,!?\\s]|^)","\/_E\/":"([.,!?\\s]|$)"},"patterns":{"\/_By \u0001([Ii]|[Hh]i[^e])\/":"$1e \u0001$2","\/_Bo \u0001([Oo]|[Hh]o)\/":"$1u \u0001$2","\/_\u0001([^\u0001]*)\u0001\/e":"mb_strtolower(\"\u0001$1\u0001\")","\/\\^\\x01([^\\x01])(?=[^\\x01]*\\x01)\/e":"mb_strtoupper(\"\u0001$1\")","\/_\u0001([^\u0001]*)\u0001\/":"javascript"}};});
onloadRegister_DEPRECATED(function (){SelectOnFocus.forCode()});
onloadRegister_DEPRECATED(function (){FB.init({"appId":113869198637480,"xfbml":true})});
onafterloadRegister_DEPRECATED(function (){Bootloader.loadComponents(["detect-broken-proxy-cache"], function(){ detect_broken_proxy_cache("1620895280", "c_user") });});
onafterloadRegister_DEPRECATED(function (){Bootloader.loadComponents(["link-rel-preload"], function(){ link_rel_preload() });});
</script>
<script>var bigPipe = new (require('BigPipe'))({"lid":0,"forceFinish":true});</script>

<script>bigPipe.onPageletArrive({"phase":0,"id":"first_response","is_last":true,"css":["ZnUfY","wijP2","zO4BE"],"js":["dJJId","8gPM0","bS0QP","\/geEf"]})</script>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

<script>bigPipe.onPageletArrive({"phase":1,"id":"developerAppNavigation","css":["ZnUfY"],"js":["8gPM0","bS0QP"],"content":{"developerAppNavigation":{"container_id":"ubeefx_1"}}})</script>

<script>bigPipe.onPageletArrive({"phase":1,"id":"developerAppHeader","css":["zO4BE"],"js":["8gPM0","bS0QP"],"content":{"developerAppHeader":{"container_id":"ubeefx_2"}}})</script>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

<code class="hidden_elem" id="ubeefx_57"><form class="mal developerAppDetailsForm" action="https://developers.facebook.com/apps/104311106384261/summary?save=1" method="post" novalidate="1" onsubmit="return Event.__inlineSubmit(this,event)" id="ubeefx_56"><input type="hidden" name="fb_dtsg" value="AQD8MCzX" autocomplete="off" /><div><div class="mbl pam developerAppSectionBanner uiBoxWhite"><table class="uiGrid developerAppSummaryBanner" cellspacing="0" cellpadding="0"><tbody><tr><td><div class="editLogoContainer" onmouseover="CSS.show(&quot;editLogoOverlay&quot;);" onmouseout="CSS.hide(&quot;editLogoOverlay&quot;);"><a class="logo_link" href="https://developers.facebook.com/ajax/image/upload/?app_id=104311106384261&amp;type=1" id="upload_logo_url" rel="dialog"><div class="appImageLogo"><img class="img" id="img_logo_url" src="https://s-static.ak.facebook.com/rsrc.php/v2/y_/r/9myDd8iyu0B.gif" alt="" /></div></a><div class="editLogoOverlay hidden_elem" id="editLogoOverlay"><a class="uiIconText editLogoIconLink" href="https://developers.facebook.com/ajax/image/upload/?app_id=104311106384261&amp;type=1" style="padding-left: 15px;" rel="dialog"><i class="img sp_14y7us sx_17d437" style="top: 2px;"></i> Edit </a></div></div></td><td><div><span class="fsxl fwb">fuzzy-search</span><div class="mts"><table class="uiGrid" cellspacing="0" cellpadding="0"><tbody><tr><td><span class="fwb">App ID: </span></td><td>104311106384261</td></tr><tr><td><span class="fwb">App Secret: </span></td><td><span><span class="mrs" id="application_secret">98f597f23568bc06e158fee939f2d80f</span>(<a rel="dialog" href="https://developers.facebook.com/ajax/developers/reset_secret_key.php?app_id=104311106384261">reiniciar</a>) 

</span></td></tr></tbody></table><span><div><a class="icon_link" href="https://developers.facebook.com/ajax/image/upload/?app_id=104311106384261&amp;type=2" id="upload_icon_url" rel="dialog"><img class="imgWrap img" id="img_icon_url" src="https://s-static.ak.facebook.com/rsrc.php/v2/yT/r/4QVMqOjUhcd.gif" alt="" /></a></div><div class="editIconLink"> (<a class="icon_link" href="https://developers.facebook.com/ajax/image/upload/?app_id=104311106384261&amp;type=2" id="upload_icon_url" rel="dialog">edit icon</a>) </div></span></div></div></td></tr></tbody></table></div><div><div class="uiHeader uiHeaderTopAndBottomBorder uiHeaderSection developerAppDetailsSectionHeader"><div class="clearfix uiHeaderTop"><div><h3 tabindex="0" class="uiHeaderTitle">Información básica</h3></div></div></div><table class="uiGrid developerAppDetailsFormGrid" cellspacing="0" cellpadding="0"><tbody><tr><td class="headerColumn"><div><span class="fwb">Display Name:</span><a class="mls uiHelpLink" data-hover="tooltip" title="The name of the app, using no more than 32 characters and no less than 3. Please make sure that your app name does not violate the trademark or other rights of a third party. Otherwise, we may be forced to remove your app." href="#"></a></div></td><td class="contentPane"><input type="text" class="inputtext pls" maxlength="32" name="name" value="fuzzy-search" id="ubeefx_8" /></td></tr></tbody></table><table class="uiGrid developerAppDetailsFormGrid" cellspacing="0" cellpadding="0"><tbody><tr><td class="headerColumn"><div><span class="fwb">Namespace:</span><a class="mls uiHelpLink" data-hover="tooltip" title="The app namespace is used for defining custom Open Graph actions and objects (e.g., namespace:action) and for the URL for Apps on Facebook (e.g., http://apps.facebook.com/namespace)" href="#"></a></div></td><td class="contentPane"><input type="text" class="inputtext pls" id="ubeefx_7" maxlength="20" name="short_app_name" value="fuzzy-search" /></td></tr></tbody></table><table class="uiGrid developerAppDetailsFormGrid" cellspacing="0" cellpadding="0"><tbody><tr><td class="headerColumn"><div><span class="fwb">Contact Email:</span><a class="mls uiHelpLink" data-hover="tooltip" title="Primary email used for important communication related to your app" href="#"></a></div></td><td class="contentPane"><input type="text" class="inputtext pls" id="ubeefx_10" name="contact" value="victorpablosceruelo&#064;gmail.com" /></td></tr></tbody></table>
-->

<table class="uiGrid developerAppDetailsFormGrid" cellspacing="0" cellpadding="0"><tbody><tr><td class="headerColumn">


<div><span class="fwb">App Domains:</span>
<a class="mls uiHelpLink" data-hover="tooltip" title="Enable auth on domain and subdomain(s) (e.g., &quot;example.com&quot; will enable *.example.com)" href="#"></a></div></td>
<td class="contentPane"><div class="clearfix uiTokenizer uiInlineTokenizer developerAppInlineTokenizer" onclick="$(&#039;ubeefx_11&#039;).focus();" id="ubeefx_13">
<div class="tokenarea" id="ubeefx_12">
<span class="uiToken removable">http://pabloscortes.mooo.com<input type="hidden" autocomplete="off" name="site_domains[]" value="http://pabloscortes.mooo.com" />
<input type="hidden" autocomplete="off" name="text_site_domains[]" value="http://pabloscortes.mooo.com" />
<a class="remove uiCloseButton uiCloseButtonSmall" href="#" role="button" aria-label="&#xbf;Eliminar http://pabloscortes.mooo.com?" title="Eliminar"></a></span>
</div><div class="uiTypeahead" id="ubeefx_14"><div class="wrap"><input type="hidden" autocomplete="off" class="hiddenInput" />
<div class="innerWrap"><input type="text" class="inputtext textInput" id="ubeefx_11" data-placeholder="Enter your site domains and press enter" autocomplete="off" aria-autocomplete="list" aria-expanded="false" aria-invalid="false" aria-owns="typeahead_list_ubeefx_14" role="textbox" spellcheck="false" />
</div></div></div></div></td></tr></tbody></table><input type="hidden" autocomplete="off" name="hidden_site_domain" id="hidden_site_domain_input" />
<table class="uiGrid developerAppDetailsFormGrid" cellspacing="0" cellpadding="0">
<tbody><tr><td class="headerColumn"><div><span class="fwb">Category:</span>



</body>
</html>