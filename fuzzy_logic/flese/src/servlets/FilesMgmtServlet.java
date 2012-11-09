package servlets;

import java.io.IOException;
import java.util.Iterator;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


import auxiliar.FileInfoClass;
import auxiliar.FilesMgmtClass;
import auxiliar.FoldersUtilsClass;
import auxiliar.LocalUserNameClass;
import auxiliar.ServletsAuxMethodsClass;


/**
 * Servlet implementation class SearchServlet
 */
@WebServlet("/FilesMgmtServlet")
public class FilesMgmtServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	final Log LOG = LogFactory.getLog(FilesMgmtServlet.class);
	private static FilesMgmtClass filesMgmtAux = null;
	
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		doGetAndDoPost("doGet", request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		doGetAndDoPost("doPost", request, response);
	}
	
	private void doGetAndDoPost(String doAction, HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		LOG.info("--- "+doAction+" invocation ---");
		try {
			if (filesMgmtAux == null) {
				ServletContext servletContext = getServletConfig().getServletContext();
				filesMgmtAux = new FilesMgmtClass(servletContext);
			}
			fileMgmtServlet(doAction, request, response);
		} catch (Exception e) {
			ServletsAuxMethodsClass.actionOnException(ServletsAuxMethodsClass.SocialAuthServletSignOut, e, request, response, LOG);
		}
		LOG.info("--- "+doAction+" end ---");
	}

	private void fileMgmtServlet(String doAction, HttpServletRequest request, HttpServletResponse response) throws Exception {
		// Tests if we have logged in.
		LocalUserNameClass localUserName = new LocalUserNameClass(request, response);
		
		String request_op = request.getParameter("op");
		LOG.info("op: " + request_op);
		if (request_op != null) {
			try {
				if ("upload".equals(request_op)) {
					filesMgmtAux.uploadFile(doAction, localUserName, request, response);
				}
				if ("download".equals(request_op)) {
					filesMgmtAux.downloadFile(doAction, localUserName, request, response);
				}
				if ("remove".equals(request_op)) {
					filesMgmtAux.removeFile(doAction, localUserName, request, response);
				}
				if ("view".equals(request_op)) {
					filesMgmtAux.viewFile(doAction, localUserName, request, response);
				}

				if ((! "upload".equals(request_op)) && (! ("download".equals(request_op))) &&
						(! ("remove".equals(request_op))) && (! ("view".equals(request_op)))) {
					LOG.info("Strange op in request. op: " + request_op);
				}
			} catch (Exception e) {
				ServletsAuxMethodsClass.actionOnException(ServletsAuxMethodsClass.FilesMgmtServlet, e, request, response, LOG);
			}
		}

		if ((request_op == null) || ((! ("download".equals(request_op))) && (! ("view".equals(request_op))))) {

			// Prepare the information we present in the jsp page.
			FoldersUtilsClass workingFolder = new FoldersUtilsClass();
			Iterator<FileInfoClass> filesIterator = null;
			if (workingFolder != null) {
				filesIterator = workingFolder.returnFilesIterator(localUserName.getLocalUserName());
			}
			request.setAttribute("filesIterator", filesIterator);

			// Forward to the jsp page.
			ServletsAuxMethodsClass.forward_to(ServletsAuxMethodsClass.FilesMgmtIndexPage, request, response, LOG);
		}

	}
}



