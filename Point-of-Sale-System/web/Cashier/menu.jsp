<%-- 
    Document   : menu
    Created on : May 18, 2025, 8:55:46 PM
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
                    <a href="sales_reports.jsp" style="text-decoration: none; color: inherit;">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Sales</span>
                </li>
                <li class="menu-item">
                    <a href="sales_reports.jsp" style="text-decoration: none; color: inherit;">
                    <i class="fas fa-box"></i>
                    <span>Products</span>
                </li>
                <li class="menu-item">
                    <a href="sales_reports.jsp" style="text-decoration: none; color: inherit;">
                    <i class="fas fa-chart-bar"></i>
                    <span>Reports</span>
                </li>
                <li class="menu-item">
                    <a href="sales_reports.jsp" style="text-decoration: none; color: inherit;">
                    <i class="fas fa-warehouse"></i>
                    <span>Inventory</span>
                </li>
                <li class="menu-item">
                    <a href="sales_reports.jsp" style="text-decoration: none; color: inherit;">
                    <i class="fas fa-receipt"></i>
                    <span>Transactions</span>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/logoutAction" style="text-decoration: none; color: inherit;">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </li>
            </ul>
        </div>
    </body>
</html>
