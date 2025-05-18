/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException; // Import SQLException
import util.DBConnection; // Import your DBConnection utility

/**
 * Servlet to handle product deletion requests.
 * It receives the product ID from the products.jsp page via a POST request
 * and attempts to delete the corresponding product from the database.
 *
 * @author YourName (replace with your name)
 */
@WebServlet("/deleteProduct") // This maps the servlet to the /deleteProduct URL
public class DeleteProductServlet extends HttpServlet {

    /**
     * Handles the HTTP POST method.
     * Processes the request to delete a product.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the product ID from the request parameters
        String productIdParam = request.getParameter("productId");
        int productId = -1; // Default to an invalid ID

        // Validate and parse the product ID
        if (productIdParam != null && !productIdParam.isEmpty()) {
            try {
                productId = Integer.parseInt(productIdParam);
            } catch (NumberFormatException e) {
                // Log the error and redirect with an invalid ID error
                System.err.println("Invalid product ID format for deletion: " + productIdParam);
                e.printStackTrace(); // Log the stack trace
                response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=invalid_id");
                return; // Stop further processing
            }
        } else {
            // Product ID parameter is missing
            System.err.println("Product ID parameter is missing for deletion.");
            response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=missing_id");
            return; // Stop further processing
        }

        Connection conn = null;
        boolean success = false;

        try {
            // Get database connection using the utility class
            conn = DBConnection.getConnection();

            if (conn != null) {
                // Create ProductDAO and attempt deletion
                ProductDAO productDAO = new ProductDAO(conn);
                success = productDAO.deleteProduct(productId);

                if (success) {
                    System.out.println("Product with ID " + productId + " deleted successfully.");
                    // Redirect back to products page with success message
                    response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?success=delete");
                } else {
                    System.err.println("Failed to delete product with ID " + productId + " from database.");
                    // Redirect back with a database error message
                    response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=db_delete_failed");
                }
            } else {
                // Database connection failed
                System.err.println("Database connection failed for product deletion.");
                response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=db_connection_failed");
            }

        } catch (SQLException e) {
            // Catch database errors
            System.err.println("SQL error during product deletion: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
            response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=sql_exception&details=" + e.getMessage());
        } catch (Exception e) {
            // Catch any other unexpected errors
            System.err.println("An unexpected error occurred during product deletion: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
             // Redirect back to products page with a generic error flag
            response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=unexpected");
        } finally {
            // Always close the database connection
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Servlet for deleting products";
    }
}