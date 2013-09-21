package servlets;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import managers.AuthManager;
import managers.InterfaceManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import storeHouse.RequestStoreHouse;
import storeHouse.RequestStoreHouseException;
import storeHouse.RequestStoreHouseSessionException;
import auxiliar.NextStep;
import constants.KConstants;
import constants.KUrls;

/**
 * Servlet implementation class
 */
// @WebServlet(KConstants.servletName)
@WebServlet("/Servlet")
public class Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	final Log LOG = LogFactory.getLog(Servlet.class);

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGetAndDoPostProtected("doGet", request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGetAndDoPostProtected("doPost", request, response);
	}

	private void doGetAndDoPostProtected(String doMethod, HttpServletRequest request, HttpServletResponse response) {
		String requestUrl = request.getRequestURL().toString();
		LOG.info(formatMsg("url: " + requestUrl));
		try {
			doGetAndDoPost("doPost", request, response);
		} catch (ServletException e) {
			LOG.error("doGetAndDoPostProtected: ServletException EXCEPTION");
			e.printStackTrace();
			
		} catch (IOException e) {
			LOG.error("doGetAndDoPostProtected: IOException EXCEPTION");
			e.printStackTrace();
		}
	}
	
	private String formatMsg(String msg) {
		String line = "------------------------------------------------------------\n";
		return "\n" + line + msg + "\n" + line;
	}
	
	private void doGetAndDoPost(String doMethod, HttpServletRequest request, HttpServletResponse response) throws ServletException,
			IOException {

		String managerName = request.getParameter(KConstants.Request.managerParam);
		LOG.info(formatMsg("STARTS Servlet. doAction: " + doMethod + " manager: " + (managerName != null ? managerName : "")));

		InterfaceManager managerObject = getManager(managerName);
		NextStep nextStep = processRequest(managerObject, doMethod, request, response);

		if (nextStep != null) {
			try {
				nextStep.takeAction(request, response);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		LOG.info(formatMsg("ENDS Servlet. doAction: " + doMethod + " manager: " + (managerName != null ? managerName : "")));
	}

	private NextStep processRequest(InterfaceManager managerObject, String doMethod, HttpServletRequest request,
			HttpServletResponse response) {

		if (managerObject == null) {
			return new NextStep(KConstants.NextStep.forward_to, KUrls.Pages.Exception, "");
		}

		// Create the session if the manager needs it.
		boolean createSessionIfNull = managerObject.createSessionIfNull();
		ServletContext servletContext = getServletConfig().getServletContext();
		RequestStoreHouse requestStoreHouse;
		try {
			try {
				requestStoreHouse = new RequestStoreHouse(request, createSessionIfNull);
			} catch (RequestStoreHouseSessionException e) {
				e.printStackTrace();
				return new NextStep(KConstants.NextStep.forward_to, KUrls.Pages.NullSession, "");
			}
			requestStoreHouse.setResponse(response);
			requestStoreHouse.setServletContext(servletContext);
			requestStoreHouse.setDoMethod(doMethod);
		} catch (RequestStoreHouseException e) {
			e.printStackTrace();
			return managerObject.getExceptionPage();
		}

		// By-pass parameters to the manager.
		managerObject.setSessionStoreHouse(requestStoreHouse);
		
		// Dispatch the query.
		return managerObject.processRequest();
	}

	@SuppressWarnings("unchecked")
	private InterfaceManager getManager(String managerName) {
		@SuppressWarnings("rawtypes")
		Class managerClass = null;
		InterfaceManager managerObject = null;

		if (managerName != null) {
			String managerClassFullName = KConstants.Managers.managersPackage + "." + managerName + KConstants.Managers.managerSuffix;
			try {
				managerClass = Class.forName(managerClassFullName);
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
				managerClass = null;
			}
		}

		if (managerClass == null) {
			managerClass = AuthManager.class;
		}

		try {
			managerObject = (InterfaceManager) (managerClass.getConstructor(new Class[0])).newInstance(new Object[0]);
		} catch (InstantiationException e) {
			managerObject = null;
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			managerObject = null;
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			managerObject = null;
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			managerObject = null;
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			managerObject = null;
			e.printStackTrace();
		} catch (SecurityException e) {
			managerObject = null;
			e.printStackTrace();
		}
		return managerObject;
	}
}

/* --- */
