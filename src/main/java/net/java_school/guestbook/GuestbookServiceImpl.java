package net.java_school.guestbook;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import com.googlecode.objectify.Key;
import static com.googlecode.objectify.ObjectifyService.ofy;//1.

@Service
public class GuestbookServiceImpl implements GuestbookService{
	public void sign(Greeting greeting) {
		ofy().save().entity(greeting).now();//1.
	}

	@PreAuthorize("isAuthenticated() and (#greeting.author_id == principal.userId or hasRole('ROLE_ADMIN'))")
	public void del(Greeting greeting) {
		Key<Greeting> key = greeting.getKey();
		ofy().delete().key(key).now();//1.
	}
}