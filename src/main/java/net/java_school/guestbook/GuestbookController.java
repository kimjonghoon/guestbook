package net.java_school.guestbook;

import java.io.IOException;

import net.java_school.spring.security.GaeUserAuthentication;
import net.java_school.user.GaeUser;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import com.google.appengine.api.users.UserServiceFactory;
import com.googlecode.objectify.Key;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import static com.googlecode.objectify.ObjectifyService.ofy;

@Controller
public class GuestbookController {

	private GuestbookService guestbookService;

	public void setGuestbookService(GuestbookService guestbookService) {
		this.guestbookService = guestbookService;
	}

	@GetMapping("/")
	public String home() {
		return "index";
	}

	@GetMapping("/admin")
	public String adminHome() {
		return "admin/index";
	}

	@GetMapping("/403")
	public String error403() {
		return "403";
	}

	@GetMapping("/logout")
	public void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
		request.getSession().invalidate();
		String url = UserServiceFactory.getUserService().createLogoutURL("/guestbook");
		response.sendRedirect(url);
	}

	@GetMapping("/guestbook")
	public String guestbook(String guestbookName, Model model) {
		model.addAttribute("guestbookName", guestbookName);
		return "guestbook/guestbook";
	}

	@PostMapping("/guestbook/sign")
	public String sign(String guestbookName, String content, GaeUserAuthentication gaeUserAuthentication) {
		Greeting greeting = null;

		if (gaeUserAuthentication != null) {
			GaeUser gaeUser = (GaeUser) gaeUserAuthentication.getPrincipal();
			greeting = new Greeting(guestbookName, content, gaeUser.getUserId(), gaeUser.getEmail());
		} else {
			greeting = new Greeting(guestbookName, content);
		}

		guestbookService.sign(greeting);

		return "redirect:/guestbook/?guestbookName=" + guestbookName;
	}

	@PostMapping("/guestbook/del")
	public String del(String guestbookName, String keyString) {
		Key<Greeting> key = Key.create(keyString);
		Greeting greeting = ofy().load().key(key).now();
		guestbookService.del(greeting);
		return "redirect:/guestbook/?guestbookName=" + guestbookName;
	}
}