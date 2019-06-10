package net.java_school.guestbook;

import org.springframework.stereotype.Service;

@Service
public interface GuestbookService {
	public void sign(Greeting greeting);
	public void del(Greeting greeting);
}