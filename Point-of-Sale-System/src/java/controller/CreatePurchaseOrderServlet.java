/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.PurchaseOrderDAO;
import dao.SupplierDAO; // To get supplier email
import util.DBConnection;
import util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/Admin/createPurchaseOrderAction") // Changed action URL
public class CreatePurchaseOrderServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CreatePurchaseOrderServlet.class.getName());
    private static final DecimalFormat df = new DecimalFormat("#.00");


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String redirectPage = request.getContextPath() + "/Admin/create_purchase_order.jsp";

        Connection conn = null;
        boolean poSavedSuccessfully = false;
        boolean emailSentSuccessfully = false;
        String supplierNameForEmail = ""; // To store supplier name for email subject/body

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                throw new SQLException("Failed to establish database connection.");
            }
            conn.setAutoCommit(false); // Start transaction

            PurchaseOrderDAO poDAO = new PurchaseOrderDAO();
            SupplierDAO supplierDAO = new SupplierDAO(); // For getting supplier email

            // --- Retrieve Main PO Details ---
            String orderReferenceNo = request.getParameter("order_id");
            int supplierId = Integer.parseInt(request.getParameter("supplier_id"));
            String orderDateStr = request.getParameter("order_date");
            String expectedDateStr = request.getParameter("expected_date");
            String paymentTerms = request.getParameter("payment_terms");
            String shippingMethod = request.getParameter("shipping_method");
            double taxPercentage = Double.parseDouble(request.getParameter("tax_percentage"));
            double shippingCost = Double.parseDouble(request.getParameter("shipping_cost"));
            String notes = request.getParameter("notes");

            // --- Retrieve Item Details (Arrays) ---
            String[] productIdsStr = request.getParameterValues("product_id[]");
            String[] quantitiesStr = request.getParameterValues("quantity[]");
            // We need to get product names and unit prices for each selected product_id
            // This will be done inside the loop or by enhancing the form to send them.
            // For now, let's assume we can re-fetch them or they are passed.
            // The JSP sends unit price via data-price, but it's not directly submitted with a name.
            // Let's assume we'll reconstruct unit prices and totals here for DB saving.

            if (productIdsStr == null || productIdsStr.length == 0) {
                throw new ServletException("No products were added to the purchase order.");
            }
            
            // Calculate subtotal, tax amount, grand total on the server-side for accuracy
            double calculatedSubtotal = 0;
            // Temporary lists to hold item details for email
            StringBuilder itemsForEmailHtml = new StringBuilder();
            itemsForEmailHtml.append("<table border='1' cellpadding='5' cellspacing='0' style='border-collapse:collapse; width:100%;'>")
                             .append("<tr><th>Product</th><th>Quantity</th><th>Unit Price</th><th>Total</th></tr>");


            // We need product names and unit prices. The JSP populates this for display,
            // but for saving, we should rely on the product_id and fetch current price from DB
            // or trust hidden fields if you add them. For simplicity, we'll simulate this.
            // A better approach would be to pass unit prices along with product_id and quantity.
            // For now, let's assume the JavaScript correctly calculates and the form could pass these.
            // We'll use dummy values if not passed, but this needs to be robust.

            // This part is tricky because the JSP's `updateProductPrice` and `updateRowTotal`
            // update the display, but the actual unit prices for each row aren't directly submitted
            // with distinct names. The `product_id[]` and `quantity[]` are arrays.
            // We'll need to adjust how items are processed.
            // Let's assume for now that the JSP will be modified to send unit_price[] and item_total[]
            // OR we fetch product details based on product_id[] within the loop.
            // For this example, I'll assume we fetch based on product_id.
            // This requires a getProductById method in ProductDAO.
            dao.ProductDAO productDAO = new dao.ProductDAO(conn); // Assuming you have a ProductDAO

            for (int i = 0; i < productIdsStr.length; i++) {
                int productId = Integer.parseInt(productIdsStr[i]);
                int quantity = Integer.parseInt(quantitiesStr[i]);
                
                model.Product product = productDAO.getProductById(productId); // Fetch product details
                if (product == null) {
                    throw new SQLException("Product with ID " + productId + " not found. Cannot create PO item.");
                }
                double unitPrice = product.getPrice(); // Use price from DB
                double itemTotal = unitPrice * quantity;
                calculatedSubtotal += itemTotal;

                itemsForEmailHtml.append("<tr><td>").append(product.getName()).append("</td>")
                                 .append("<td style='text-align:center;'>").append(quantity).append("</td>")
                                 .append("<td style='text-align:right;'>Rs.").append(df.format(unitPrice)).append("</td>")
                                 .append("<td style='text-align:right;'>Rs.").append(df.format(itemTotal)).append("</td></tr>");
            }
            itemsForEmailHtml.append("</table>");


            double calculatedTaxAmount = (calculatedSubtotal * taxPercentage) / 100.0;
            double calculatedGrandTotal = calculatedSubtotal + calculatedTaxAmount + shippingCost;

            // --- Save Main PO ---
            int poId = poDAO.savePurchaseOrder(conn, orderReferenceNo, supplierId, orderDateStr, expectedDateStr,
                                             paymentTerms, shippingMethod, taxPercentage, shippingCost,
                                             calculatedSubtotal, calculatedTaxAmount, calculatedGrandTotal, notes);

            // --- Save PO Items ---
            for (int i = 0; i < productIdsStr.length; i++) {
                int productId = Integer.parseInt(productIdsStr[i]);
                int quantity = Integer.parseInt(quantitiesStr[i]);
                
                model.Product product = productDAO.getProductById(productId); // Fetch again or store earlier
                double unitPrice = product.getPrice();
                double itemTotal = unitPrice * quantity;
                String productName = product.getName();

                if (!poDAO.savePurchaseOrderItem(conn, poId, productId, productName, quantity, unitPrice, itemTotal)) {
                    throw new SQLException("Failed to save purchase order item: " + productName);
                }
            }

            conn.commit(); // Commit transaction
            poSavedSuccessfully = true;
            LOGGER.info("Purchase Order " + orderReferenceNo + " saved successfully. PO ID: " + poId);
            session.setAttribute("poMessage", "Purchase Order " + orderReferenceNo + " created successfully!");
            session.setAttribute("poMessageType", "success");

            // --- Send Email to Supplier ---
            if (poSavedSuccessfully) {
                String supplierEmail = supplierDAO.getSupplierEmailById(supplierId);
                model.Supplier selectedSupplier = supplierDAO.getAllSuppliers().stream()
                                                    .filter(s -> s.getSupplierId() == supplierId)
                                                    .findFirst().orElse(null);
                if(selectedSupplier != null) supplierNameForEmail = selectedSupplier.getCompanyName();


                if (supplierEmail != null && !supplierEmail.isEmpty()) {
                    String emailSubject = "New Purchase Order " + orderReferenceNo + " from Swift POS Store";
                    
                    StringBuilder emailBody = new StringBuilder();
                    emailBody.append("<html><body>");
                    emailBody.append("<h2>New Purchase Order: ").append(orderReferenceNo).append("</h2>");
                    emailBody.append("<p>Dear ").append(supplierNameForEmail == null || supplierNameForEmail.isEmpty() ? "Supplier" : supplierNameForEmail).append(",</p>");
                    emailBody.append("<p>Please find attached a new purchase order from Swift POS Store. Details are as follows:</p>");
                    emailBody.append("<p><strong>PO Number:</strong> ").append(orderReferenceNo).append("<br>");
                    emailBody.append("<strong>Order Date:</strong> ").append(orderDateStr).append("<br>");
                    emailBody.append("<strong>Expected Delivery Date:</strong> ").append(expectedDateStr).append("<br>");
                    emailBody.append("<strong>Payment Terms:</strong> ").append(paymentTerms).append("<br>");
                    emailBody.append("<strong>Shipping Method:</strong> ").append(shippingMethod).append("</p>");
                    
                    emailBody.append("<h3>Order Items:</h3>");
                    emailBody.append(itemsForEmailHtml.toString()); // Add the items table

                    emailBody.append("<h3>Summary:</h3>");
                    emailBody.append("<p><strong>Subtotal:</strong> Rs.").append(df.format(calculatedSubtotal)).append("<br>");
                    emailBody.append("<strong>Tax (").append(df.format(taxPercentage)).append("%):</strong> Rs.").append(df.format(calculatedTaxAmount)).append("<br>");
                    emailBody.append("<strong>Shipping Cost:</strong> Rs.").append(df.format(shippingCost)).append("<br>");
                    emailBody.append("<strong>Total Amount: Rs.").append(df.format(calculatedGrandTotal)).append("</strong></p>");

                    if (notes != null && !notes.isEmpty()) {
                        emailBody.append("<p><strong>Notes:</strong><br>").append(notes.replace("\n", "<br>")).append("</p>");
                    }
                    emailBody.append("<p>Please confirm receipt of this purchase order and provide an estimated shipping date if possible.</p>");
                    emailBody.append("<p>Thank you,<br>Swift POS Store</p>");
                    emailBody.append("</body></html>");

                    emailSentSuccessfully = EmailUtil.sendHtmlEmail(supplierEmail, emailSubject, emailBody.toString());
                    if (emailSentSuccessfully) {
                        session.setAttribute("poMessage", "Purchase Order " + orderReferenceNo + " created and email sent to supplier!");
                        LOGGER.info("Email for PO " + orderReferenceNo + " sent successfully to " + supplierEmail);
                    } else {
                        session.setAttribute("poMessage", "Purchase Order " + orderReferenceNo + " created, but FAILED to send email to supplier.");
                        LOGGER.warning("Failed to send PO email for " + orderReferenceNo + " to " + supplierEmail);
                    }
                } else {
                    session.setAttribute("poMessage", "Purchase Order " + orderReferenceNo + " created, but supplier email is not available. Email not sent.");
                    LOGGER.warning("Supplier email not found for supplier ID: " + supplierId + ". PO email not sent for " + orderReferenceNo);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error processing purchase order: " + e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            session.setAttribute("poMessage", "Error creating purchase order: Database operation failed. " + e.getMessage());
            session.setAttribute("poMessageType", "error");
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid number format in purchase order form: " + e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            session.setAttribute("poMessage", "Error creating purchase order: Invalid number format for one or more fields.");
            session.setAttribute("poMessageType", "error");
        }
         catch (ServletException e) { // Catching ServletException for "No products"
            LOGGER.log(Level.WARNING, "Error processing purchase order: " + e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            session.setAttribute("poMessage", "Error creating purchase order: " + e.getMessage());
            session.setAttribute("poMessageType", "error");
        }
        catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error processing purchase order: " + e.getMessage(), e);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Rollback failed", ex); }
            }
            session.setAttribute("poMessage", "An unexpected error occurred. Please try again.");
            session.setAttribute("poMessageType", "error");
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to close database connection", e);
                }
            }
        }
        response.sendRedirect(redirectPage);
    }
}
