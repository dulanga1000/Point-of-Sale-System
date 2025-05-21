<%-- 
    Document   : login
    Created on : May 16, 2025, 9:31:18 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Swift Login</title>
    <%-- Assuming styles.css is in webapp/Login/styles.css --%>
    <%-- If login.jsp is also in webapp/Login/, then href="styles.css" is fine --%>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/Login/styles.css">
    <style>
        .error-message {
            color: #D8000C; /* Red color for errors */
            background-color: #FFD2D2; /* Light red background */
            border: 1px solid #D8000C;
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 4px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <%-- Assuming Images folder is at webapp/Images/logo.png --%>
        <img class="logo" src="${pageContext.request.contextPath}/Images/logo.png" alt="Swift Logo">
        <div class="welcome-text">Welcome to Swift</div>

        <%-- Display login error message if any --%>
        <%
            String loginError = (String) request.getAttribute("loginError");
            if (loginError != null && !loginError.isEmpty()) {
        %>
            <div class="error-message">
                <%= loginError %>
            </div>
        <%
            }
        %>
        <%-- Clear session error if it was set by a redirect (less common for login errors) --%>
        <%
            String sessionError = (String) session.getAttribute("loginError");
            if (sessionError != null) {
        %>
             <div class="error-message">
                <%= sessionError %>
            </div>
        <%
            session.removeAttribute("loginError");
            }
        %>


        <form class="login-form" method="POST" action="${pageContext.request.contextPath}/loginAction">
            <div class="form-group">
                <label for="usernameOrEmail" class="form-label">Username or Email</label>
                <%-- Added name attribute, changed id for clarity --%>
                <input type="text" id="usernameOrEmail" name="usernameOrEmail" class="form-input" required>
            </div>

            <div class="form-group">
                <label for="password" class="form-label">Password</label>
                <input type="password" id="password" name="password" class="form-input" required>
            </div>
            <button type="submit" class="login-button">Log in</button>
            <div class="login-info">
                Login as Admin or Cashier
            </div>
        </form>
    </div>
</body>
</html>

