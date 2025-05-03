<%-- 
    Document   : login
    Created on : May 4, 2025, 4:21:14 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Swift Login</title>
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/Login/styles.css">
</head>
<body>
  <div class="container">
      <img class="logo" src="../Images/logo.png">
    <div class="welcome-text">Welcome to Swift</div>
    
    <div class="login-form">
      <div class="form-group">
        <label for="username" class="form-label">Username</label>
        <input type="text" id="username" class="form-input">
      </div>
      
      <div class="form-group">
        <label for="password" class="form-label">Password</label>
        <input type="password" id="password" class="form-input">
      </div>
        <button class="login-button" onClick="window.location.href='Admin/admin_dashboard.jsp';">Log in</button>   
      <div class="login-info">
        Login as Admin, Cashier, or Supplier
      </div>
      <div class="forgot-info">
          <a href="#">Forgot Password</a>
      </div>
    </div>
  </div>
</body>
</html>
