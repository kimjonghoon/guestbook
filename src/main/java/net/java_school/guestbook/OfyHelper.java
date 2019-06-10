package net.java_school.guestbook;

import com.googlecode.objectify.ObjectifyService;

import javax.servlet.annotation.WebListener;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextListener;
import javax.servlet.ServletContextEvent;

/**
 * OfyHelper, a ServletContextListener, is setup in web.xml to run before a JSP is run.  This is
 * required to let JSP's access Ofy.
 **/
@WebListener
public class OfyHelper implements ServletContextListener {
	public static void register() {
		ObjectifyService.register(Guestbook.class);
		ObjectifyService.register(Greeting.class);
	}

	public void contextInitialized(ServletContextEvent event) {
		ServletContext sc = event.getServletContext();
		sc.log("OfyHelper: Init");
		// This will be invoked as part of a warmup request, or the first user
		// request if no warmup request was invoked.
		register();
	}

	public void contextDestroyed(ServletContextEvent event) {
		// App Engine does not currently invoke this method.
	}
}
