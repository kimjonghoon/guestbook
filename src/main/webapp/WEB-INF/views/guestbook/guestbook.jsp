<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>

<%-- //[START imports]--%>
<%@ page import="net.java_school.guestbook.Greeting"%>
<%@ page import="net.java_school.guestbook.Guestbook"%>
<%@ page import="com.googlecode.objectify.Key"%>
<%@ page import="com.googlecode.objectify.ObjectifyService"%>
<%-- //[END imports]--%>

<%@ page import="java.util.List"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="security"%>

<html>
<head>
<link type="text/css" rel="stylesheet" href="/resources/stylesheets/main.css" />
<script type="text/javascript">
function del(key) {
	var check = confirm('Are you sure you want to delete this greeting?');
	if (check) {
		var form = document.getElementById("delForm");
		form.keyString.value = key;
		form.submit();
	}
}
</script>
</head>

<body>

<%
	String guestbookName = request.getParameter("guestbookName");
	if (guestbookName == null) {
		guestbookName = "default";
	}
	pageContext.setAttribute("guestbookName", guestbookName);
	UserService userService = UserServiceFactory.getUserService();
	User user = userService.getCurrentUser();
	if (user != null) {
		pageContext.setAttribute("user", user);
%>
	<p>
		Hello, ${fn:escapeXml(user.nickname)}! (You can <a href="/logout">sign out</a>.)
	</p>
<%
	} else {
%>
	<p>
		Hello! <a href="<%=userService.createLoginURL("/guestbook/?guestbookName=" + guestbookName)%>">Sign in</a> to include your name with greetings you post.
	</p>
<%
	}
%>
<%-- //[START datastore]--%>
<%
	// Create the correct Ancestor key
	Key<Guestbook> theBook = Key.create(Guestbook.class, guestbookName);

	// Run an ancestor query to ensure we see the most up-to-date
	// view of the Greetings belonging to the selected Guestbook.
	List<Greeting> greetings = ObjectifyService.ofy().load().type(Greeting.class) // We want only Greetings
			.ancestor(theBook) // Anyone in this book
			.order("-date") // Most recent first - date is indexed.
			.limit(5) // Only show 5 of them.
			.list();

	if (greetings.isEmpty()) {
%>
	<p>Guestbook '${fn:escapeXml(guestbookName)}' has no messages.</p>
<%
	} else {
%>
	<p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'.</p>
<%
	// Look at all of our greetings
		for (Greeting greeting : greetings) {
			pageContext.setAttribute("greeting_content", greeting.content);
			pageContext.setAttribute("keyString", greeting.getKey().toWebSafeString());
			String author;
			String author_id = null;
			if (greeting.author_email == null) {
				author = "An anonymous person";
			} else {
				author = greeting.author_email;
				author_id = greeting.author_id;
				if (user != null && user.getUserId().equals(author_id)) {
					author += " (You)";
				}
			}
			pageContext.setAttribute("greeting_user", author);
			pageContext.setAttribute("author_id", author_id);
%>
	<p>
		<b>${fn:escapeXml(greeting_user)}</b> wrote:
	</p>
	<blockquote>${fn:escapeXml(greeting_content)}</blockquote>
	<security:authorize access="isAuthenticated() and (#author_id == principal.userId or hasRole('ROLE_ADMIN'))">
		<blockquote><a href="javascript:del('${keyString }')">Del</a></blockquote>
	</security:authorize>
<%
	}
}
%>
	<form action="/guestbook/sign" method="post">
		<div>
			<textarea name="content" rows="3" cols="60"></textarea>
		</div>
		<div>
			<input type="submit" value="Post Greeting" />
		</div>
		<input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}" />
		<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
	</form>
	<%-- //[END datastore]--%>
	<form action="/guestbook" method="get">
		<div>
			<input type="text" name="guestbookName" value="${fn:escapeXml(guestbookName)}" />
		</div>
		<div>
			<input type="submit" value="Switch Guestbook" />
		</div>
	</form>
	<form id="delForm" action="/guestbook/del" method="post" style="display: none;">
		<input type="hidden" name="keyString" />
		<input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}" />
		<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
	</form>
</body>
</html>
<%-- //[END all]--%>