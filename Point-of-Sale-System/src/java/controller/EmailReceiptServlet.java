/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller; // Or your actual controller package

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Properties;
import java.util.stream.Collectors;

// Jakarta Mail imports
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

// For parsing JSON - using org.json library
import org.json.JSONObject;
import org.json.JSONArray;


@WebServlet("/emailReceiptAction")
public class EmailReceiptServlet extends HttpServlet {

    // ***********************************************************************************
    // SMTP Configuration for Gmail
    // ***********************************************************************************
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587"; // For TLS
    
    // This should be the Gmail account you are sending from AND generated the App Password for.
    private static final String SMTP_USER = "dulanga1000@gmail.com"; 
    
    // This should be your 16-character App Password (e.g., "xxxx Abbyzzzzwwww" but without spaces)
    private static final String SMTP_PASSWORD = "fdaycthsjmtjpdbq"; // Corrected: removed spaces if any were present
    
    // This should generally be the same as SMTP_USER for Gmail
    private static final String EMAIL_FROM = "dulanga1000@gmail.com"; 
    private static final String EMAIL_FROM_NAME = "Swift POS Store";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("EmailReceiptServlet: doPost called."); // Log servlet entry
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder sb = new StringBuilder();
        String line;
        try {
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            System.out.println("EmailReceiptServlet: Received request body: " + sb.toString());
        } catch (IOException e) {
            System.err.println("EmailReceiptServlet: Error reading request body: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Error reading request body.\"}");
            e.printStackTrace();
            return;
        }

        JSONObject jsonResponse = new JSONObject();
        String recipientEmail = null;

        // Check if the SMTP_PASSWORD looks like a placeholder (it shouldn't if you've set it)
        if (SMTP_PASSWORD == null || 
            "PASTE_YOUR_16_CHARACTER_APP_PASSWORD_HERE".equals(SMTP_PASSWORD) || 
            SMTP_PASSWORD.trim().isEmpty() ) {

            System.err.println("CRITICAL ERROR: SMTP_PASSWORD is not configured correctly in EmailReceiptServlet.java. " +
                               "It appears to be a placeholder. " +
                               "Current SMTP_PASSWORD value: '" + SMTP_PASSWORD + "'. " +
                               "Please generate a 16-character Gmail App Password and update the SMTP_PASSWORD constant in the servlet code.");
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Email server not configured correctly by the administrator. Cannot send email. Please contact support.");
            try {
                response.getWriter().write(jsonResponse.toString());
            } catch (IOException ioe) {
                System.err.println("EmailReceiptServlet: IOException writing password config error response: " + ioe.getMessage());
            }
            return;
        }
        
        try {
            JSONObject receiptDataJson = new JSONObject(sb.toString());
            recipientEmail = receiptDataJson.optString("recipientEmail", null);
            System.out.println("EmailReceiptServlet: Parsed recipientEmail: " + recipientEmail);


            if (recipientEmail == null || recipientEmail.trim().isEmpty() || !recipientEmail.contains("@")) {
                System.err.println("EmailReceiptServlet: Invalid or missing recipient email: " + recipientEmail);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Invalid or missing recipient email address.");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            String emailSubject = "Your Receipt from " + EMAIL_FROM_NAME + " - #" + receiptDataJson.optString("receiptNumber", "N/A");
            String emailBodyHtml = buildHtmlEmailBody(receiptDataJson);

            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true"); 
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            // props.put("mail.debug", "true"); // Already uncommented below for permanent debugging until resolved

            System.out.println("EmailReceiptServlet: SMTP Properties set. Host: " + SMTP_HOST + ", Port: " + SMTP_PORT + ", User: " + SMTP_USER);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USER, SMTP_PASSWORD);
                }
            });
            session.setDebug(true); // <<< ENABLED JAVA MAIL DEBUGGING HERE

            MimeMessage mimeMessage = new MimeMessage(session);
            mimeMessage.setFrom(new InternetAddress(EMAIL_FROM, EMAIL_FROM_NAME));
            mimeMessage.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            mimeMessage.setSubject(emailSubject);
            mimeMessage.setContent(emailBodyHtml, "text/html; charset=utf-8");

            System.out.println("EmailReceiptServlet: Attempting to send email to: " + recipientEmail + " from: " + SMTP_USER);
            Transport.send(mimeMessage);

            System.out.println("EmailReceiptServlet: Email sent successfully to: " + recipientEmail);
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Email sent successfully to " + recipientEmail);

        } catch (MessagingException e) {
            System.err.println("EmailReceiptServlet: MessagingException occurred.");
            e.printStackTrace(); 
            String specificError = e.getMessage();
            Throwable cause = e.getCause();
            while(cause != null) {
                specificError += " (Caused by: " + cause.getClass().getName() + ": " + cause.getMessage() + ")";
                cause = cause.getCause();
            }
            if (e.getNextException() != null) {
                 specificError += " (Next Exception: " + e.getNextException().getMessage() + ")";
            }
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Failed to send email. Server Error: " + specificError);
            System.err.println("EmailReceiptServlet: MessagingException while trying to send email to " + recipientEmail + ": " + specificError);
        } catch (Exception e) { 
            System.err.println("EmailReceiptServlet: General Exception occurred.");
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "An unexpected error occurred on the server: " + e.getMessage());
            System.err.println("EmailReceiptServlet: General Exception while trying to send email to " + recipientEmail + ": " + e.getMessage());
        }

        try {
            response.getWriter().write(jsonResponse.toString());
            System.out.println("EmailReceiptServlet: Sent JSON response: " + jsonResponse.toString());
        } catch (IOException ioe) {
            System.err.println("EmailReceiptServlet: IOException writing final JSON response: " + ioe.getMessage());
        }
    }

    private String buildHtmlEmailBody(JSONObject data) {
        StringBuilder body = new StringBuilder();
        body.append("<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>");
        body.append("<div style='max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px; background-color: #f9f9f9;'>");
        
        // Header section
        body.append("<div style='text-align: center; border-bottom: 1px dashed #ccc; margin-bottom: 20px; padding-bottom: 15px;'>");
        body.append("<h2 style='margin: 5px 0; color: #2c3e50;'>Swift POS Store</h2>");
        body.append("<p style='margin: 2px 0; font-size: 0.9em;'>123/2, High level Road, Homagama.</p>");
        body.append("<p style='margin: 2px 0; font-size: 0.9em;'>Tel: (+94) 76-2375055</p>");
        body.append("</div>");
        
        // Receipt details
        body.append("<h3 style='color: #3498db; border-bottom: 1px solid #eee; padding-bottom: 5px;'>Transaction Receipt</h3>");
        body.append("<div style='margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px dashed #eee;'>");
        body.append("<p><strong>Receipt #:</strong> ").append(data.optString("receiptNumber", "N/A")).append("</p>");
        body.append("<p><strong>Date:</strong> ").append(data.optString("receiptDate", "N/A")).append("</p>");
        body.append("<p><strong>Cashier:</strong> ").append(data.optString("cashier", "System")).append("</p>");
        body.append("</div>");
        
        // Items purchased
        body.append("<div style='margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px dashed #eee;'>");
        body.append("<h4>Items Purchased:</h4>");
        body.append("<table style='width: 100%; border-collapse: collapse; font-size: 0.95em;'><thead><tr style='background-color: #f0f0f0;'>");
        body.append("<th style='text-align: left; padding: 8px; border-bottom: 1px solid #ddd;'>Item</th>");
        body.append("<th style='text-align: center; padding: 8px; border-bottom: 1px solid #ddd;'>Qty</th>");
        body.append("<th style='text-align: right; padding: 8px; border-bottom: 1px solid #ddd;'>Unit Price</th>");
        body.append("<th style='text-align: right; padding: 8px; border-bottom: 1px solid #ddd;'>Total</th>");
        body.append("</tr></thead><tbody>");
        
        JSONArray itemsArray = data.optJSONArray("items");
        if (itemsArray != null && itemsArray.length() > 0) {
            for (int i = 0; i < itemsArray.length(); i++) {
                JSONObject item = itemsArray.optJSONObject(i);
                if (item != null) {
                    body.append("<tr>");
                    body.append("<td style='padding: 6px; border-bottom: 1px solid #eee;'>").append(item.optString("name", "")).append("</td>");
                    body.append("<td style='text-align: center; padding: 6px; border-bottom: 1px solid #eee;'>").append(item.optString("qty", "")).append("</td>");
                    body.append("<td style='text-align: right; padding: 6px; border-bottom: 1px solid #eee;'>").append(item.optString("unitPrice", "")).append("</td>");
                    body.append("<td style='text-align: right; padding: 6px; border-bottom: 1px solid #eee;'>Rs.").append(item.optString("totalPrice", "")).append("</td>");
                    body.append("</tr>");
                }
            }
        } else {
            body.append("<tr><td colspan='4' style='text-align: center; padding: 10px;'>No items listed in this transaction.</td></tr>");
        }
        body.append("</tbody></table></div>");
        
        // Receipt summary
        body.append("<div style='margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px dashed #eee; font-size: 0.95em;'>");
        body.append("<p style='display: flex; justify-content: space-between;'><span>Subtotal:</span> <span>").append(data.optString("subtotal", "Rs.0.00")).append("</span></p>");
        body.append("<p style='display: flex; justify-content: space-between;'><span>Discount:</span> <span>").append(data.optString("discount", "Rs.0.00 (0%)")).append("</span></p>");
        body.append("<p style='display: flex; justify-content: space-between;'><span>Tax:</span> <span>").append(data.optString("tax", "Rs.0.00 (0%)")).append("</span></p>");
        body.append("<p style='display: flex; justify-content: space-between; font-weight: bold; font-size: 1.1em; margin-top: 10px; padding-top: 10px; border-top: 1px solid #999;'><span>Total:</span> <span>").append(data.optString("total", "Rs.0.00")).append("</span></p>");
        body.append("</div>");
        
        // Payment method details
        body.append("<div style='margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px dashed #eee; font-size: 0.95em;'>");
        String paymentMethod = data.optString("paymentMethod", "N/A");
        if (paymentMethod != null && !paymentMethod.isEmpty()) {
            // Capitalize first letter of payment method
            String displayPaymentMethod = paymentMethod.substring(0, 1).toUpperCase();
            if (paymentMethod.length() > 1) {
                displayPaymentMethod += paymentMethod.substring(1);
            }
            body.append("<p><strong>Payment Method:</strong> ").append(displayPaymentMethod).append("</p>");
            
            if ("cash".equalsIgnoreCase(paymentMethod)) {
                body.append("<p><strong>Cash Received:</strong> ").append(data.optString("cashReceived", "N/A")).append("</p>");
                body.append("<p><strong>Change Due:</strong> ").append(data.optString("changeDue", "N/A")).append("</p>");
            } else if ("card".equalsIgnoreCase(paymentMethod)) {
                body.append("<p><strong>Card Used:</strong> **** **** **** ").append(data.optString("cardLast4", "N/A")).append("</p>");
            }
        } else {
            body.append("<p><strong>Payment Method:</strong> N/A</p>");
        }
        body.append("</div>");
        
        // Footer
        body.append("<div style='text-align: center; font-size: 0.9em; color: #555; margin-top: 20px;'>");
        body.append("<p>Thank you for shopping with us!</p>");
        body.append("<p>Return policy: Items can be returned within 30 days with receipt.</p>");
        body.append("<p style='font-size: 0.8em; color: #777; margin-top: 15px;'>This receipt was sent to: ").append(data.optString("recipientEmail", "")).append("</p>");
        body.append("</div>");
        
        body.append("</div>"); 
        body.append("</body></html>");
        return body.toString();
    }
}