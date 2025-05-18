/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SupplierDAO;
import model.Supplier;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ViewSuppliersServlet", urlPatterns = {"/admin/viewSuppliers"})
public class ViewSuppliersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ViewSuppliersServlet.class.getName());
    private transient SupplierDAO supplierDAO;

    @Override
    public void init() throws ServletException {
        try {
            supplierDAO = new SupplierDAO();
            LOGGER.info("ViewSuppliersServlet initialized and SupplierDAO created.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize SupplierDAO in ViewSuppliersServlet", e);
            throw new ServletException("Error initializing DAO", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LOGGER.info("ViewSuppliersServlet: doGet() method CALLED."); // Check if servlet is called
        
        // Add test parameter to check if it's a test request
        String test = request.getParameter("test");
        if ("true".equals(test)) {
            response.setContentType("text/plain");
            response.getWriter().write("ViewSuppliersServlet is working!");
            return;
        }
        
        try {
            List<Supplier> suppliersList = supplierDAO.getAllSuppliers();

            // Log DAO output
            if (suppliersList != null) {
                LOGGER.info("ViewSuppliersServlet: Fetched " + suppliersList.size() + " suppliers from DAO.");
                for (Supplier supplier : suppliersList) {
                    LOGGER.info("Supplier found: ID=" + supplier.getSupplierId() + 
                              ", Name=" + supplier.getCompanyName());
                }
            } else {
                LOGGER.warning("ViewSuppliersServlet: SupplierDAO.getAllSuppliers() returned NULL. Initializing to an empty list.");
                suppliersList = new ArrayList<>(); // Ensure list is not null for subsequent processing
            }

            int totalSuppliers = suppliersList.size();
            LOGGER.info("ViewSuppliersServlet: Calculated totalSuppliers = " + totalSuppliers);

            String paginationText;
            if (totalSuppliers == 0) {
                paginationText = "No suppliers found"; // This is the text if list is empty
            } else {
                paginationText = "Showing 1-" + totalSuppliers + " of " + totalSuppliers + " suppliers";
            }
            LOGGER.info("ViewSuppliersServlet: paginationText = \"" + paginationText + "\"");


            // Set attributes for the JSP
            request.setAttribute("suppliersList", suppliersList);
            request.setAttribute("totalSuppliers", totalSuppliers);
            request.setAttribute("paginationText", paginationText);
            LOGGER.info("ViewSuppliersServlet: Request attributes SET. Forwarding to /Admin/suppliers.jsp...");

            // Forward the request to the JSP page for rendering the view
            request.getRequestDispatcher("/Admin/suppliers.jsp").forward(request, response);
            LOGGER.info("ViewSuppliersServlet: Forwarding COMPLETE."); // This log might not show if forward is successful and response is committed

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "ViewSuppliersServlet: CRITICAL ERROR in doGet()", e);
            // response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred processing your request for supplier data.");
            // Sending error after logging to ensure cause is recorded
            throw new ServletException("Error retrieving supplier data for display in ViewSuppliersServlet", e);
        }
    }
}