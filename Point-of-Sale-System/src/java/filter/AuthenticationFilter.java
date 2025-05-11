/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {
        "*.jsp",         // Protect all JSP files
        "/userAction",   // Protect the UserServlet for CUD operations
        "/Admin/*",      // Admin area
        "/Cashier/*",    // Cashier area
        "/Supplier/*"    // Supplier area
})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AuthenticationFilter initialized (protecting *.jsp and other configured paths).");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        // Fixed login path
        final String loginPage = contextPath + "/Login/login.jsp";
        final String loginAction = contextPath + "/loginAction";
        final String logoutAction = contextPath + "/logoutAction";

        // Allow resources used in the login page
        boolean isLoginPage = requestURI.equals(loginPage);
        boolean isLoginAction = requestURI.equals(loginAction);
        boolean isLogoutAction = requestURI.equals(logoutAction);
        boolean isStaticResource =
                requestURI.startsWith(contextPath + "/Login/") ||
                requestURI.startsWith(contextPath + "/Images/") ||
                requestURI.startsWith(contextPath + "/styles.css");

        boolean loggedIn = (session != null && session.getAttribute("loggedInUser") != null);
        String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

        System.out.println("AuthFilter: URI=" + requestURI + ", loggedIn=" + loggedIn +
                ", isLoginPage=" + isLoginPage + ", isLoginAction=" + isLoginAction +
                ", isStaticResource=" + isStaticResource);

        if (loggedIn) {
            if (isLoginPage && !isLoginAction) {
                String dashboardUrl = getDashboardUrlForRole(userRole, contextPath);
                System.out.println("AuthFilter: Logged in user accessing login page. Redirecting to " + dashboardUrl);
                httpResponse.sendRedirect(dashboardUrl);
                return;
            }
            chain.doFilter(request, response);
        } else {
            if (isLoginPage || isLoginAction || isLogoutAction || isStaticResource) {
                chain.doFilter(request, response);
            } else {
                System.out.println("AuthFilter: Not logged in. Redirecting to login page from " + requestURI);
                if (session == null) session = httpRequest.getSession(true);
                session.setAttribute("loginErrorRedirect", "Please log in to access the requested page.");
                httpResponse.sendRedirect(loginPage);
            }
        }
    }

    private String getDashboardUrlForRole(String role, String contextPath) {
        if (role == null) return contextPath + "/Login/login.jsp";

        switch (role.toLowerCase()) {
            case "admin":
                return contextPath + "/Admin/admin_dashboard.jsp";
            case "cashier":
                return contextPath + "/Cashier/cashier_dashboard.jsp";
            case "supplier":
                return contextPath + "/Supplier/supplier_dashboard.jsp";
            default:
                System.out.println("AuthFilter: Unknown role '" + role + "'. Redirecting to login.");
                return contextPath + "/Login/login.jsp";
        }
    }

    @Override
    public void destroy() {
        System.out.println("AuthenticationFilter destroyed.");
    }
}