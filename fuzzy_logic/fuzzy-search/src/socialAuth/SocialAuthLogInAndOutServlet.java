
package socialAuth;

// import java.io.IOException;
import java.io.InputStream;
//import java.io.PrintWriter;
//import java.util.ArrayList;
//import java.util.Enumeration;
//import java.util.List;
//import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


import socialAuth.SocialAuthConfig;
import socialAuth.SocialAuthManager;
import socialAuth.AuthForm;
// import socialAuth.exception.SocialAuthException;
// import socialAuth.util.SocialAuthUtil;

// Do not use struts !!!
// import org.apache.struts.action.Action;
// import org.apache.struts.action.ActionForm;
// import org.apache.struts.action.ActionForward;
// import org.apache.struts.action.ActionMapping;
// import org.apache.struts.util.RequestUtils;


/**
 * 
 * It redirects the browser to an appropriate URL which will be used for
 * authentication with the provider that has been set by clicking the icon. It
 * creates an instance of the requested provider from AuthProviderFactory and
 * calls the getLoginRedirectURL() method to find the URL which the user should
 * be redirect to.
 * 
 * @author tarunn@brickred.com
 * 
 */
// public class SocialAuthenticationAction extends Action {

@WebServlet("/SocialAuthLogInAndOutServlet")
public class SocialAuthLogInAndOutServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	final Log LOG = LogFactory.getLog(SocialAuthLogInAndOutServlet.class);

	/**
	 * creates a instance of the requested provider from AuthProviderFactory and
	 * calls the getLoginRedirectURL() method to find the URL which the user
	 * should be redirect to.
	 * 
	 * @param mapping
	 *            the action mapping
	 * @param form
	 *            the action form
	 * @param request
	 *            the http servlet request
	 * @param response
	 *            tc the http servlet response
	 * @return ActionForward where the action should flow
	 * @throws Exception
	 *             if an error occurs
	 */

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, java.io.IOException {
			LOG.info("doGet invocation. Calling doPost");
			doPost(request, response);
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, java.io.IOException {
		
		
		try {
			socialAuthentication(request, response);
		} catch (Exception e) {
			System.out.print("Exception thrown: ");
			System.out.print(e);
			e.printStackTrace();
			
		}
	}
		
	private void socialAuthentication(HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		HttpSession session = request.getSession(true);
		String appUrl = AuxMethodsClass.getAppUrlFromRequest(request, LOG);
		String newUrl = appUrl + "/index-authentication.jsp";
		
		LOG.info("socialAuthentication entered");
		AuxMethodsClass.log_request_parameters(request, LOG);
		
		// Get the value of the parameter; the name is case-sensitive
		String request_id = request.getParameter("id");
		String request_mode = request.getParameter("mode");
	    if ((request_id != null) && (! "".equals(request_id)) &&
	    	(request_mode != null) && (! "".equals(request_mode))	) { 
	        // (request_id == null) :: The request parameter was not present in the query string.
	        // e.g. http://hostname.com?a=b
	        // ("".equals(request_id)) The request parameter was present in the query string but has no value.
	        // e.g. http://hostname.com?param=&a=b

	    	if ("signin".equals(request_mode)) {
	    		newUrl = socialAuthenticationLogIn(appUrl, request_mode, request_id, session, response);
	    		
	    	    // Go to the newUrl
	    	    if (newUrl != null) {
	    	    	LOG.info(newUrl);
	    	    	response.sendRedirect( newUrl );
	    	    	// ActionForward fwd = new ActionForward("openAuthUrl", url, true);
	    	    	// return fwd;
	    	    	return;
	    	    }
	    	    else {
	    	    	LOG.info("ERROR: newUrl is null !!! ");
	    	    }
	    	}
	    	else {
	    		if ("signout".equals(request_mode)) {
	    			socialAuthenticationLogOut(appUrl, request_mode, request_id, session, response);
	    			AuxMethodsClass.goToAppIndex(request, response, LOG);
	    			return;
	    		}
	    	}
	    }

		LOG.info("ERROR: Last line in doPost !!!");
		AuxMethodsClass.goToAuthenticationLogout(request, response, LOG);
		// return mapping.findForward("failure");
	}
		
	private String socialAuthenticationLogIn(String appUrl, String request_mode, String request_id,
			HttpSession session, HttpServletResponse response) throws Exception {
		// AuthForm authForm = (AuthForm) form;
		AuthForm authForm = null;
		String newUrl = "";

		if ("signin".equals(request_mode)) {
			authForm = new AuthForm();
			authForm.setId(request_id);
			InputStream in = SocialAuthLogInAndOutServlet.class.getClassLoader()
					.getResourceAsStream("oauth_consumer.properties");
			SocialAuthConfig conf = SocialAuthConfig.getDefault();
			conf.load(in);
			authForm.setSocialAuthManager(new SocialAuthManager());
			authForm.getSocialAuthManager().setSocialAuthConfig(conf);

			session.setAttribute("authForm", authForm);
			LOG.info("Redirecting to open authentication service for "+request_id);
			// String returnToUrl = RequestUtils.absoluteURL(request, "/socialAuthenticationServlet").toString();
			String returnToUrl = appUrl + "/SocialAuthLoggedInServlet";  
			newUrl = authForm.getSocialAuthManager().getAuthenticationUrl(request_id, returnToUrl);
		}
		// if (newUrl != null) {
		return newUrl;
		// }


	}
	
	private void socialAuthenticationLogOut(String appUrl, String request_mode, String request_id,
			HttpSession session, HttpServletResponse response) {
		
		AuthForm authForm = null;
		if ("signout".equals(request_mode)) {
			authForm = (AuthForm) session.getAttribute("authForm");
			if ((authForm != null) && 
				(authForm.getSocialAuthManager() != null)) {
				authForm.getSocialAuthManager().disconnectProvider(authForm.getId());
			    // String urlWithSessionID = response.encodeRedirectURL(aDestinationPage.toString());
			    // response.sendRedirect( urlWithSessionID );
				// return mapping.findForward("home");
				// url = RequestUtils.absoluteURL(request, "/").toString();
			}
			session.invalidate();
		}
		
	}
	
	/**
	 * Displays the user profile and contacts for the given provider.
	 * 
	 * @param mapping
	 *            the action mapping
	 * @param form
	 *            the action form
	 * @param request
	 *            the http servlet request
	 * @param response
	 *            the http servlet response
	 * @return ActionForward where the action should flow
	 * @throws IOException 
	 * @throws Exception
	 *             if an error occurs
	 */

	
/*	private ActionForward execute(final ActionMapping mapping,
			final ActionForm form, final HttpServletRequest request,
			final HttpServletResponse response) throws Exception {

		AuthForm authForm = (AuthForm) form;


		String id = authForm.getId();
		SocialAuthManager manager;
		if (authForm.getSocialAuthManager() != null) {
			manager = authForm.getSocialAuthManager();
			if ("signout".equals(request.getParameter("mode"))) {
				manager.disconnectProvider(id);
				return mapping.findForward("home");
			}
		} else {
			InputStream in = SocialAuthenticationAction.class.getClassLoader()
					.getResourceAsStream("oauth_consumer.properties");
			SocialAuthConfig conf = SocialAuthConfig.getDefault();
			conf.load(in);
			manager = new SocialAuthManager();
			manager.setSocialAuthConfig(conf);
			authForm.setSocialAuthManager(manager);
		}

		String returnToUrl = RequestUtils.absoluteURL(request,
				"/socialAuthSuccessAction.do").toString();
		String url = manager.getAuthenticationUrl(id, returnToUrl);
		LOG.info("Redirecting to: " + url);
		if (url != null) {
			ActionForward fwd = new ActionForward("openAuthUrl", url, true);
			return fwd;
		}
		return mapping.findForward("failure");
	}
*/

}

