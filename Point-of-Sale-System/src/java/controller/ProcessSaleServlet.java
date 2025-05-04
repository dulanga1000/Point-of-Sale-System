/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import com.google.gson.Gson; // Import Gson
import com.google.gson.reflect.TypeToken; // For List parsing
import model.CartItem;
import model.PaymentDetails;
import model.Receipt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map; // To receive generic JSON object first
import java.util.Random;

/**
 *
 * @author dulan
 */


@WebServlet("/processSale") // Maps this servlet to the /processSale URL
public class ProcessSaleServlet extends HttpServlet {

    private static final Gson gson = new Gson(); // Reusable Gson instance

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        } catch (IOException e) {
            System.err.println("Error reading request body: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Error reading request data\"}");
            return;
        }

        String jsonPayload = sb.toString();
        System.out.println("Received JSON Payload: " + jsonPayload); // Debugging

        try {
            // Use a Map to parse the generic structure first
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> dataMap = gson.fromJson(jsonPayload, mapType);

            // --- Create Receipt Object from Map ---
            Receipt receipt = new Receipt();

            // Generate server-side receipt details
            receipt.setReceiptNumber(generateReceiptNumber());
            receipt.setReceiptDate(new Date()); // Use current server time

            receipt.setCashier((String) dataMap.getOrDefault("cashier", "N/A"));

            // Parse Items (Gson needs help with nested lists/generics)
            List<Map<String, Object>> itemMaps = (List<Map<String, Object>>) dataMap.get("items");
            List<CartItem> cartItems = new ArrayList<>();
            if (itemMaps != null) {
                for (Map<String, Object> itemMap : itemMaps) {
                    CartItem item = new CartItem();
                    item.setName((String) itemMap.get("name"));
                    // Handle potential Double from JSON, convert to int/BigDecimal
                    Object qtyObj = itemMap.get("quantity");
                    if (qtyObj instanceof Double) {
                        item.setQuantity(((Double) qtyObj).intValue());
                    } else if (qtyObj instanceof String) {
                         try { item.setQuantity(Integer.parseInt((String)qtyObj)); } catch (NumberFormatException ne) { item.setQuantity(0); }
                    } else {
                         item.setQuantity(0); // Default or handle error
                    }

                    Object priceObj = itemMap.get("price"); // This is likely formatted string like "$19.99"
                     if (priceObj instanceof String) {
                         try {
                             String priceStr = ((String) priceObj).replaceAll("[^\\d.]", ""); // Remove currency symbols etc.
                             item.setPrice(new BigDecimal(priceStr));
                         } catch (NumberFormatException | NullPointerException ne) {
                             item.setPrice(BigDecimal.ZERO);
                         }
                     } else {
                         item.setPrice(BigDecimal.ZERO);
                     }

                    cartItems.add(item);
                }
            }
            receipt.setItems(cartItems);

             // Parse totals and rates (remove formatting, convert to BigDecimal)
            receipt.setSubtotal(parseCurrency((String) dataMap.get("subtotalFormatted")));
            receipt.setTotal(parseCurrency((String) dataMap.get("totalFormatted")));

            // Extract discount/tax amounts and rates if possible (might need adjustments based on exact JS format)
            String discountStr = (String) dataMap.get("discountFormatted"); // e.g., "$5.00 (10.0%)"
            String taxStr = (String) dataMap.get("taxFormatted");       // e.g., "$8.50 (8.5%)"
            receipt.setDiscountAmount(parseCurrency(discountStr));
            receipt.setTaxAmount(parseCurrency(taxStr));
            receipt.setDiscountRate(extractRate(discountStr));
            receipt.setTaxRate(extractRate(taxStr));


            // Parse Payment Details
            Map<String, Object> paymentMap = (Map<String, Object>) dataMap.get("paymentDetails");
            if (paymentMap != null) {
                PaymentDetails paymentDetails = new PaymentDetails((String) paymentMap.get("method"));
                if ("cash".equals(paymentDetails.getMethod())) {
                    paymentDetails.setCashReceived(parseCurrency((String) paymentMap.get("cashReceivedFormatted")));
                    paymentDetails.setChangeDue(parseCurrency((String) paymentMap.get("changeDueFormatted")));
                } else if ("card".equals(paymentDetails.getMethod())) {
                    paymentDetails.setCardNumberLast4((String) paymentMap.get("cardNumberLast4"));
                }
                receipt.setPaymentDetails(paymentDetails);
            }

            System.out.println("Parsed Receipt Object: " + receipt); // Debugging

            // --- TODO: Persist to Database (Optional but Recommended) ---
            // Example:
            // SalesDAO salesDAO = new SalesDAOImpl(); // Get your DAO instance
            // boolean saved = salesDAO.saveSale(receipt);
            // if (!saved) {
            //    throw new ServletException("Failed to save sale to database.");
            // }
            // ProductDAO productDAO = new ProductDAOImpl();
            // for(CartItem item : receipt.getItems()) {
            //     productDAO.updateStock(item.getName(), item.getQuantity());
            // }
            // --- End Persistence ---


            // Store the receipt object in the session for the JSP
            HttpSession session = request.getSession();
            session.setAttribute("currentReceipt", receipt); // Key "currentReceipt"

            // Option 1: Forward to the JSP (URL in browser doesn't change)
             System.out.println("Forwarding to receipt.jsp...");
             request.getRequestDispatcher("/Cashier/receipt.jsp").forward(request, response);

            // Option 2: Redirect to the JSP (URL changes, data MUST be in session)
            // System.out.println("Redirecting to receipt.jsp...");
            // response.sendRedirect(request.getContextPath() + "/Cashier/receipt.jsp");

        } catch (Exception e) {
            System.err.println("Error processing sale: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
            // Inform the client
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
             response.setContentType("application/json");
             response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Error processing sale on server: " + e.getMessage() + "\"}");
             // OR forward to an error page:
             // request.setAttribute("errorMessage", "Error processing sale: " + e.getMessage());
             // request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }

    // --- Helper Methods ---

    private String generateReceiptNumber() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String datePart = sdf.format(new Date());
        int randomPart = new Random().nextInt(900) + 100; // 100-999
        return "INV-" + datePart + "-" + randomPart;
    }

     // Helper to parse currency strings like "$19.99" or "($5.00)" or "$5.00 (10.0%)"
    private BigDecimal parseCurrency(String currencyString) {
        if (currencyString == null || currencyString.isEmpty()) {
            return BigDecimal.ZERO;
        }
        try {
            // Remove currency symbols, parentheses, text after space (like rate %)
            String numberPart = currencyString.split(" ")[0]; // Take only part before space if exists
            String cleaned = numberPart.replaceAll("[^\\d.-]", "");
            if (cleaned.isEmpty()) return BigDecimal.ZERO;
            return new BigDecimal(cleaned);
        } catch (NumberFormatException e) {
            System.err.println("Could not parse currency string: " + currencyString);
            return BigDecimal.ZERO;
        }
    }

    // Helper to extract rate like "10.0" from strings like "$5.00 (10.0%)"
    private BigDecimal extractRate(String inputString) {
        if (inputString == null || !inputString.contains("(") || !inputString.contains("%)")) {
            return BigDecimal.ZERO;
        }
        try {
            int openParen = inputString.lastIndexOf('(');
            int percentSign = inputString.lastIndexOf('%');
            if (openParen != -1 && percentSign != -1 && percentSign > openParen) {
                String ratePart = inputString.substring(openParen + 1, percentSign).trim();
                 // Convert percentage to decimal rate (e.g., 10.0 -> 0.10)
                 return new BigDecimal(ratePart).divide(BigDecimal.valueOf(100));
            }
        } catch (NumberFormatException | IndexOutOfBoundsException e) {
             System.err.println("Could not extract rate from string: " + inputString);
        }
        return BigDecimal.ZERO;
    }
}