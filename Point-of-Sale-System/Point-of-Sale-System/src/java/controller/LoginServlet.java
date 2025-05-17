/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDao;
import dao.UserDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import model.User;
import util.PasswordUtil;



/**
 *
 * @author dulan
 */

@WebServlet("/loginAction") // URL pattern for the login servlet
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDaoImpl(); // Initialize your DAO
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String usernameOrEmail = request.getParameter("usernameOrEmail");
        String password = request.getParameter("password");
        String loginJspPath = "/Login/login.jsp"; // Assuming login.jsp is at the webapp root

        // Basic validation
        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("loginError", "Username/Email and Password are required.");
            request.getRequestDispatcher(loginJspPath).forward(request, response);
            return;
        }

        User user = null;
        try {
            // Try to find user by username first
            user = userDao.getUserByUsername(usernameOrEmail.trim());
            if (user == null) {
                // If not found by username, try by email
                user = userDao.getUserByEmail(usernameOrEmail.trim());
            }

            if (user != null) {
                // User found, now verify password (server-side verification)
                // IMPORTANT: PasswordUtil.verifyPassword should compare the plain password
                // against the securely hashed password stored in the database.
                if (PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
                    // Password matches - Login successful
                    HttpSession session = request.getSession(); // Create or get session
                    session.setAttribute("loggedInUser", user); // Store the whole user object or specific details
                    session.setAttribute("username", user.getUsername());
                    session.setAttribute("userId", user.getId());
                    session.setAttribute("userRole", user.getRole());
                    session.setAttribute("userFirstName", user.getFirstName());


                    // Redirect based on role
                    String role = user.getRole();
                    String targetPage = "";
                    if ("Admin".equalsIgnoreCase(role)) {
                        targetPage = request.getContextPath() + "/Admin/admin_dashboard.jsp";
                    } else if ("Cashier".equalsIgnoreCase(role)) {
                        targetPage = request.getContextPath() + "/Cashier/cashier_dashboard.jsp";
                    } else if ("Supplier".equalsIgnoreCase(role)) {
                        targetPage = request.getContextPath() + "/Supplier/supplier_dashboard.jsp";
                    } else {
                        // Fallback or error if role is unknown or not permitted to login here
                        request.setAttribute("loginError", "Login successful, but role has no defined dashboard.");
                        request.getRequestDispatcher(loginJspPath).forward(request, response);
                        return;
                    }
                    System.out.println("Login successful for " + user.getUsername() + ". Redirecting to: " + targetPage);
                    response.sendRedirect(targetPage);

                } else {
                    // Password does not match
                    System.out.println("Login failed for " + usernameOrEmail + ": Incorrect password.");
                    request.setAttribute("loginError", "Invalid username/email or password.");
                    request.getRequestDispatcher(loginJspPath).forward(request, response);
                }
            } else {
                // User not found by username or email
                System.out.println("Login failed: User '" + usernameOrEmail + "' not found.");
                request.setAttribute("loginError", "Invalid username/email or password.");
                request.getRequestDispatcher(loginJspPath).forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace(); // Log this error
            System.err.println("SQL Error during login: " + e.getMessage());
            request.setAttribute("loginError", "Database error during login. Please try again later.");
            request.getRequestDispatcher(loginJspPath).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace(); // Log this error
            System.err.println("Unexpected Error during login: " + e.getMessage());
            request.setAttribute("loginError", "An unexpected error occurred. Please try again later.");
            request.getRequestDispatcher(loginJspPath).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests for /loginAction to the login page itself,
        // or handle them if there's a specific reason (e.g., logout action via GET)
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}
