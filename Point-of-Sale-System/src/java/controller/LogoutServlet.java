/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;


/**
 *
 * @author dulan
 */

@WebServlet("/logoutAction")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false); // Get existing session, don't create new
        if (session != null) {
            session.removeAttribute("loggedInUser"); // Remove specific attributes
            session.removeAttribute("username");
            session.removeAttribute("userId");
            session.removeAttribute("userRole");
            session.removeAttribute("userFirstName");
            session.invalidate(); // Invalidate the entire session
            System.out.println("User logged out, session invalidated.");
        }
        // Redirect to the login page
        response.sendRedirect(request.getContextPath() + "/Login/login.jsp");
    }
}
