<%-- 
    Document   : menu
    Created on : May 16, 2025, 9:26:41 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
              <ul class="menu">
        <li class="menu-item active">
          <a href="admin_dashboard.jsp" style="text-decoration: none; color: inherit;">
          <i>📊</i> Dashboard
          </a>
        </li>
        <li class="menu-item">
           <a href="user_management.jsp" style="text-decoration: none; color: inherit;">
          <i>👤</i> User Management
        </li>
        <li class="menu-item">
          <a href="products.jsp" style="text-decoration: none; color: inherit;">
            <i>📦</i> Products
          </a>
        </li>

        <li class="menu-item">
            <a href="suppliers.jsp" style="text-decoration: none; color: inherit;">
          <i>🏭</i> Suppliers
        </li>
        <li class="menu-item">
            <a href="sales_reports.jsp" style="text-decoration: none; color: inherit;">
          <i>📈</i> Sales Reports
        </li>
        <li class="menu-item">
            <a href="inventory.jsp" style="text-decoration: none; color: inherit;">
          <i>📋</i> Inventory
        </li>      
        <li class="menu-item">
            <a href="${pageContext.request.contextPath}/logoutAction" style="text-decoration: none; color: inherit;">
          <i>↩️️</i><a>Logout</a>
        </li>        
      </ul>
    </body>
</html>
