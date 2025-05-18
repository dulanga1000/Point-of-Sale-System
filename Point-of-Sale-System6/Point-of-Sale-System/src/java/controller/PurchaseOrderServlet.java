/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.PurchaseOrderDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author TUF
 */
@WebServlet("/Admin/PurchaseOrderServlet")
public class PurchaseOrderServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productIdsParam = request.getParameter("product_ids");
        String quantitiesParam = request.getParameter("quantities");

        if (productIdsParam == null || quantitiesParam == null || productIdsParam.isEmpty() || quantitiesParam.isEmpty()) {
            request.setAttribute("message", "❌ Missing product or quantity data.");
            request.getRequestDispatcher("/create_purchase_order.jsp").forward(request, response);
            return;
        }

        try {
            String[] productIdStrings = productIdsParam.split(",");
            String[] quantityStrings = quantitiesParam.split(",");

            if (productIdStrings.length != quantityStrings.length) {
                request.setAttribute("message", "❌ Product and quantity count mismatch.");
                request.getRequestDispatcher("/create_purchase_order.jsp").forward(request, response);
                return;
            }

            List<Integer> productIds = new ArrayList<>();
            List<Integer> quantities = new ArrayList<>();
            for (int i = 0; i < productIdStrings.length; i++) {
                productIds.add(Integer.parseInt(productIdStrings[i]));
                quantities.add(Integer.parseInt(quantityStrings[i]));
            }

            int supplierId = Integer.parseInt(request.getParameter("supplier_id"));
            String paymentTerms = request.getParameter("payment_terms");
            String shippingMethod = request.getParameter("shipping_method");
            String notes = request.getParameter("notes");
            double taxRate = Double.parseDouble(request.getParameter("tax_rate"));
            double shipping = Double.parseDouble(request.getParameter("shipping_amount"));
            double subtotal = Double.parseDouble(request.getParameter("subtotal"));
            double total = Double.parseDouble(request.getParameter("total"));

            boolean success = PurchaseOrderDAO.createPurchaseOrder(
                supplierId,
                paymentTerms,
                shippingMethod,
                notes,
                taxRate,
                shipping,
                subtotal,
                total,
                productIds,
                quantities
            );

            if (success) {
                request.setAttribute("message", "✅ Purchase Order Successfully Created!");
            } else {
                request.setAttribute("message", "❌ Failed to create Purchase Order.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "❌ Error processing order: " + e.getMessage());
        }

        request.getRequestDispatcher("/purchases.jsp").forward(request, response);

    }
}