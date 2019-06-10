<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="security"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Home</title>
</head>
<body>

<article>
<h1>Home</h1>
<ul>
	<li><a href="/guestbook">Guestbook</a></li>
	<security:authorize access="hasRole('ROLE_ADMIN')">
		<li><a href="/admin">Admin</a></li>
	</security:authorize>
</ul>
</article>

</body>
</html>