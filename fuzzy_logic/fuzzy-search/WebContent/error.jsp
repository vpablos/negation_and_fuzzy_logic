<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>ERROR page</title>
</head>
<body>

<%@page import="java.util.*" %>

		<BR><h1>Parameters</h1><BR>
      <%
        for(Enumeration<String> e = request.getParameterNames(); e.hasMoreElements(); ){
                String paramName = (String) e.nextElement().toString();
                out.println("<br/><br/> " + "Parameter: " + paramName);
                
    			String[] values = request.getParameterValues(paramName);
    			for (int i=0; i<values.length; i++) {
    				out.println("<br/> " + values[i]);
//    				System.out.print(values[i]);
//    				System.out.print(", ");
    			}
        }
		%>
		<BR><BR><BR><BR><H1>Attributes</H1><BR>
      <%
        for(Enumeration<String> e = request.getAttributeNames(); e.hasMoreElements(); ){
                String attName = (String) e.nextElement().toString();
                out.println("<br/>" + attName);
        }
		%>
		
		<% if (request.getAttribute("msg") != null) { %>
			<h1>MSG: <%=request.getAttribute("msg") %>
			</h1>
		<% } %>

<br/><br/><br/><br/><H1>
<%@page import="socialAuth.AuxMethodsClass" %>
<a href="<%=AuxMethodsClass.getAppUrlFromRequest(request, null) %>/index.jsp">Go to starting page.</a>
</H1>
<BR/><BR/><BR/><BR/>
</body>
</html>