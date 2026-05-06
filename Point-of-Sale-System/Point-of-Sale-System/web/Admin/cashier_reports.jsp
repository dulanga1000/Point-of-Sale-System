<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.Year" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Database connection details
    String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database";
    String DB_USER = "root";
    String DB_PASSWORD = "";

    // Date handling
    LocalDate today = LocalDate.now();
    String startDateStr = request.getParameter("startDate");
    String endDateStr = request.getParameter("endDate");

    LocalDate startDate = (startDateStr != null && !startDateStr.isEmpty()) ? LocalDate.parse(startDateStr) : today;
    LocalDate endDate = (endDateStr != null && !endDateStr.isEmpty()) ? LocalDate.parse(endDateStr) : today;

    Locale sriLankaLocale = new Locale("en", "LK");
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(sriLankaLocale);
    currencyFormatter.setCurrency(java.util.Currency.getInstance("LKR"));
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Performance Reports - Swift POS</title>
    <link rel="Stylesheet" href="styles.css"> <%-- Ensure styles.css is present --%>
    <style>
       
        .main-content { flex-grow: 1; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; background-color: #fff; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .page-title { margin: 0; font-size: 24px; color: #333; }
        .user-profile { display: flex; align-items: center; }
        .user-profile img { width: 40px; height: 40px; border-radius: 50%; margin-right: 10px; object-fit: cover;}
        .user-profile h4 { margin: 0; font-size: 14px; color: #555; }
        
        .filter-form { background-color: #fff; padding: 15px; margin-bottom: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); display: flex; gap: 15px; align-items: center; flex-wrap: wrap; }
        .filter-form label { font-weight: bold; margin-right: 5px; }
        .filter-form input[type="date"] { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
        .filter-form button { padding: 8px 15px; background-color: var(--primary, #4A90E2); color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .filter-form button:hover { background-color: #357abd; }

        .report-table-container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; font-size: 14px; margin-top: 15px;}
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid #eee; }
        th { background-color: #f8f9fa; font-weight: 600; color: #333; }
        td.currency { text-align: right; }
        td.number { text-align: center; }
        .status { padding: 4px 10px; border-radius: 15px; font-size: 12px; font-weight: 500; display: inline-block; }
        .status.active { background-color: #d4edda; color: #155724; } /* Green */
        .status.break { background-color: #fff3cd; color: #856404; } /* Yellow */
        .status.inactive { background-color: #f8d7da; color: #721c24; } /* Red */
        .no-data { text-align: center; padding: 20px; color: #777; }

        .footer { text-align: center; padding: 20px; margin-top: 20px; font-size: 14px; color: #777; border-top: 1px solid #eee; }
        .mobile-top-bar { display: none; }
        :root { --primary: #4A90E2; }
         @media (max-width: 768px) {
            .dashboard { flex-direction: column; }
            .sidebar { width: 100%; min-height: auto; position: fixed; top: 0; left: -100%; transition: left 0.3s; z-index: 1000; background-color: #333; }
            .sidebar.active { left: 0; }
            .main-content { margin-left: 0; padding-top: 60px; }
            .mobile-top-bar { display: flex; justify-content: space-between; align-items: center; background-color: #fff; padding: 10px 15px; position: fixed; top: 0; left: 0; width: 100%; z-index: 1001; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .mobile-logo img { height: 30px; }
            .mobile-logo h2 { font-size: 18px; margin-left: 8px; }
            .mobile-nav-toggle { background: none; border: none; font-size: 24px; cursor: pointer; }
            .header { flex-direction: column; align-items: flex-start; }
            .user-profile { margin-top:10px; }
            .filter-form { flex-direction: column; align-items: stretch; }
            .filter-form div { display: flex; flex-direction: column; margin-bottom:10px;}
            .filter-form label { margin-bottom: 5px; }
        }
    </style>
</head>
<body>
    <div class="mobile-top-bar">
        <div class="mobile-logo" style="display:flex; align-items:center;">
            <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
            <h2>Swift</h2>
        </div>
        <button class="mobile-nav-toggle" id="mobileNavToggle">☰</button>
    </div>

    <div class="dashboard">
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
                <h2>Swift</h2>
            </div>
            <jsp:include page="menu.jsp" />
        </div>

        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Cashier Performance Reports</h1>
                 <div class="user-profile">
                    <%
                        String adminProfileImg = "Images/default-profile.png"; 
                        String adminFirstName = "Admin";
                        Connection headerConn = null;
                        PreparedStatement headerPstmt = null;
                        ResultSet headerRs = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            headerConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                            headerPstmt = headerConn.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'Admin' LIMIT 1");
                            headerRs = headerPstmt.executeQuery();
                            if (headerRs.next()) {
                                adminFirstName = headerRs.getString("first_name") != null ? headerRs.getString("first_name") : "Admin";
                                String fetchedPath = headerRs.getString("profile_image_path");
                                if (fetchedPath != null && !fetchedPath.trim().isEmpty() && 
                                    !fetchedPath.toLowerCase().endsWith("uploads\\profile_images\\") && 
                                    !fetchedPath.toLowerCase().endsWith("uploads/profile_images/")) {
                                    adminProfileImg = fetchedPath.replace("\\", "/");
                                }
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace(); 
                        } finally {
                            if (headerRs != null) try { headerRs.close(); } catch (SQLException e) { /* log */ }
                            if (headerPstmt != null) try { headerPstmt.close(); } catch (SQLException e) { /* log */ }
                            if (headerConn != null) try { headerConn.close(); } catch (SQLException e) { /* log */ }
                        }
                    %>
                    <img src="${pageContext.request.contextPath}/<%= adminProfileImg %>" alt="Admin Profile" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Images/default-profile.png';">
                    <div><h4><%= adminFirstName %></h4></div>
                </div>
            </div>

            <form method="get" action="cashier_reports.jsp" class="filter-form">
                <div>
                    <label for="startDate">Start Date:</label>
                    <input type="date" id="startDate" name="startDate" value="<%= startDate.toString() %>" required>
                </div>
                <div>
                    <label for="endDate">End Date:</label>
                    <input type="date" id="endDate" name="endDate" value="<%= endDate.toString() %>" required>
                </div>
                <button type="submit">View Report</button>
            </form>

            <div class="report-table-container">
                <h3>Report for <%= startDate.format(DateTimeFormatter.ofPattern("MMM dd, yyyy")) %> to <%= endDate.format(DateTimeFormatter.ofPattern("MMM dd, yyyy")) %></h3>
                <table>
                    <thead>
                        <tr>
                            <th>Cashier Name</th>
                            <th>Username</th>
                            <th class="currency">Total Sales</th>
                            <th class="number">Transactions</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection reportConn = null;
                            PreparedStatement reportPstmt = null;
                            ResultSet reportRs = null;
                            boolean foundData = false;

                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                reportConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                String sql = "SELECT " +
                                             "    u.id AS user_id, " +
                                             "    u.first_name, " +
                                             "    u.last_name, " +
                                             "    u.username, " +
                                             "    u.status AS user_status, " +
                                             "    COALESCE(SUM(ps.total_amount), 0) AS total_sales_period, " +
                                             "    COALESCE(COUNT(ps.sale_id), 0) AS total_transactions_period " +
                                             "FROM " +
                                             "    users u " +
                                             "LEFT JOIN " +
                                             "    pos_sales ps ON u.id = ps.cashier_id " +
                                             "               AND DATE(ps.transaction_time) >= ? " +
                                             "               AND DATE(ps.transaction_time) <= ? " +
                                             "WHERE " +
                                             "    u.role = 'Cashier' " +
                                             "GROUP BY " +
                                             "    u.id, u.first_name, u.last_name, u.username, u.status " +
                                             "ORDER BY " +
                                             "    total_sales_period DESC, u.first_name ASC;";

                                reportPstmt = reportConn.prepareStatement(sql);
                                reportPstmt.setDate(1, java.sql.Date.valueOf(startDate));
                                reportPstmt.setDate(2, java.sql.Date.valueOf(endDate));
                                reportRs = reportPstmt.executeQuery();

                                while(reportRs.next()) {
                                    foundData = true;
                                    String cFirstName = reportRs.getString("first_name");
                                    String cLastName = reportRs.getString("last_name");
                                    String fullName = (cFirstName != null ? cFirstName : "") + (cLastName != null ? " " + cLastName : "");
                                    if (fullName.trim().isEmpty()) fullName = "N/A";
                                    
                                    String username = reportRs.getString("username");
                                    double totalSales = reportRs.getDouble("total_sales_period");
                                    int totalTransactions = reportRs.getInt("total_transactions_period");
                                    String userStatus = reportRs.getString("user_status");
                                    String statusClass = "";
                                    if (userStatus != null) {
                                        if (userStatus.equalsIgnoreCase("Active")) {
                                            statusClass = "active";
                                        } else if (userStatus.equalsIgnoreCase("Break")) {
                                            statusClass = "break";
                                        } else if (userStatus.equalsIgnoreCase("Inactive")) {
                                            statusClass = "inactive";
                                        }
                                    }

                        %>
                                <tr>
                                    <td><%= fullName %></td>
                                    <td><%= username != null ? username : "N/A" %></td>
                                    <td class="currency"><%= currencyFormatter.format(totalSales) %></td>
                                    <td class="number"><%= totalTransactions %></td>
                                    <td><span class="status <%= statusClass %>"><%= userStatus != null ? userStatus : "N/A" %></span></td>
                                </tr>
                        <%
                                }
                                if (!foundData) {
                                    out.println("<tr><td colspan='5' class='no-data'>No data found for the selected period.</td></tr>");
                                }

                            } catch (Exception e) {
                                out.println("<tr><td colspan='5' class='no-data' style='color:red;'>Error generating report: " + e.getMessage() + "</td></tr>");
                                e.printStackTrace();
                            } finally {
                                if(reportRs != null) try { reportRs.close(); } catch (SQLException e) {}
                                if(reportPstmt != null) try { reportPstmt.close(); } catch (SQLException e) {}
                                if(reportConn != null) try { reportConn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div class="footer">
                Swift POS © <%= Year.now().getValue() %>.
            </div>
        </div>
    </div>

    <script>
        const mobileNavToggle = document.getElementById('mobileNavToggle');
        const sidebar = document.getElementById('sidebar');
        if (mobileNavToggle && sidebar) {
            mobileNavToggle.addEventListener('click', () => {
                sidebar.classList.toggle('active');
            });
        }
        document.addEventListener('click', function(event) {
            if (sidebar && sidebar.classList.contains('active') && 
                !sidebar.contains(event.target) && 
                !mobileNavToggle.contains(event.target)) {
                sidebar.classList.remove('active');
            }
        });
    </script>
</body>
</html>