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
import java.math.BigDecimal;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/addSupplier")
public class AddSupplierServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SupplierDAO supplierDAO;
    private static final Logger LOGGER = Logger.getLogger(AddSupplierServlet.class.getName());

    @Override
    public void init() {
        supplierDAO = new SupplierDAO();
        LOGGER.info("AddSupplierServlet initialized.");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String targetJsp = "/Admin/suppliers.jsp"; // Target JSP for feedback

        try {
            String companyName = request.getParameter("companyName");
            String category = request.getParameter("supplierCategory");
            String businessRegNo = request.getParameter("businessRegNo");
            String taxId = request.getParameter("taxId");
            String companyAddress = request.getParameter("companyAddress");
            String contactPerson = request.getParameter("contactPerson");
            String contactPosition = request.getParameter("contactPosition");
            String contactPhone = request.getParameter("contactPhone");
            String contactEmail = request.getParameter("contactEmail");
            String paymentMethod = request.getParameter("paymentMethod");
            String paymentTerms = request.getParameter("paymentTerms");
            String creditLimitStr = request.getParameter("creditLimit");
            String deliveryTerms = request.getParameter("deliveryTerms");
            String leadTimeStr = request.getParameter("leadTime");
            String productCategories = request.getParameter("hiddenProductCategories");
            String additionalNotes = request.getParameter("additionalNotes");

            // Basic validation
            if (isEmpty(companyName) || isEmpty(category) || isEmpty(businessRegNo) || isEmpty(companyAddress) ||
                isEmpty(contactPerson) || isEmpty(contactPhone) || isEmpty(contactEmail) || isEmpty(paymentMethod) ||
                isEmpty(paymentTerms) || isEmpty(deliveryTerms) || isEmpty(leadTimeStr) ||
                isEmpty(productCategories) ) {
                request.setAttribute("errorMessage", "All required fields must be filled.");
                request.getRequestDispatcher(targetJsp).forward(request, response);
                return;
            }
            
            int leadTime;
            try {
                leadTime = Integer.parseInt(leadTimeStr);
                if (leadTime <= 0) throw new NumberFormatException("Lead time must be positive.");
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid Lead Time: Must be a positive number.");
                request.getRequestDispatcher(targetJsp).forward(request, response);
                return;
            }

            BigDecimal creditLimit = null;
            if ("credit".equalsIgnoreCase(paymentTerms)) {
                if (isEmpty(creditLimitStr)) {
                    request.setAttribute("errorMessage", "Credit Limit is required when payment terms are 'Credit'.");
                    request.getRequestDispatcher(targetJsp).forward(request, response);
                    return;
                }
                try {
                    creditLimit = new BigDecimal(creditLimitStr);
                    if(creditLimit.compareTo(BigDecimal.ZERO) < 0) {
                        throw new NumberFormatException("Credit limit cannot be negative.");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid Credit Limit format: " + e.getMessage());
                    request.getRequestDispatcher(targetJsp).forward(request, response);
                    return;
                }
            }

            Supplier newSupplier = new Supplier(
                companyName, category, businessRegNo, taxId, companyAddress,
                contactPerson, contactPosition, contactPhone, contactEmail,
                paymentMethod, paymentTerms, creditLimit, deliveryTerms,
                leadTime, productCategories, additionalNotes
            );

            boolean success = supplierDAO.addSupplier(newSupplier);

            if (success) {
                LOGGER.info("Supplier added successfully, forwarding to supplier list.");
                request.setAttribute("feedbackMessage", "Supplier added successfully!");
                // No need for feedbackClass if styling is handled by specific message attributes or CSS classes
                request.getRequestDispatcher(targetJsp).forward(request, response);
            } else {
                LOGGER.warning("Failed to add supplier to database.");
                request.setAttribute("errorMessage", "Database error: Could not save the supplier.");
                request.getRequestDispatcher(targetJsp).forward(request, response);
            }

        } catch (Exception e) { // Catch broader exceptions
             LOGGER.log(Level.SEVERE, "Error processing add supplier request", e);
             request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
             request.getRequestDispatcher(targetJsp).forward(request, response);
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}