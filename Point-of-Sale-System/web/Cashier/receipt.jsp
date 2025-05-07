<%-- 
    Document   : receipt
    Created on : May 5, 2025, 4:34:42 PM
    Author     : dulan
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Receipt</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="Stylesheet" href="styles.css">
    <style>
  
        .receipt-header { text-align: center; border-bottom: 1px dashed #ccc; margin-bottom: 15px; padding-bottom: 10px; }
        .receipt-header img { max-width: 80px; margin-bottom: 5px; }
        .action-buttons { text-align: center; margin-top: 20px; }
        .action-buttons button { padding: 10px 15px; margin: 0 5px; cursor: pointer; background-color: #007bff; color: white; border: none; border-radius: 4px; font-size: 1em; }
        .action-buttons button:hover { background-color: #0056b3; }
        .action-buttons i { margin-right: 5px; }

        @media print {
            body { margin: 0; background-color: #fff; }
            .receipt-container { margin: 0; border: none; box-shadow: none; max-width: 100%; }
            .action-buttons { display: none; }
        }
    </style>
</head>
<body>

<%
    // --- Retrieve Data from Request ---
    request.setCharacterEncoding("UTF-8"); // Ensure correct character encoding

    // Details
    String receiptNumber = request.getParameter("receiptNumber");
    String receiptDate = request.getParameter("receiptDate");
    String cashier = request.getParameter("cashier");

    // Items (Arrays)
    String[] itemNames = request.getParameterValues("itemName");
    String[] itemQtys = request.getParameterValues("itemQty");
    String[] itemPrices = request.getParameterValues("itemPrice"); // Price per item

    // Summary
    String subtotal = request.getParameter("subtotal");
    String discount = request.getParameter("discount"); // Format: "$SAmount (Rate%)"
    String tax = request.getParameter("tax");           // Format: "$Amount (Rate%)"
    String total = request.getParameter("total");

    // Payment
    String paymentMethod = request.getParameter("paymentMethod");
    String cashReceived = request.getParameter("cashReceived"); // Only if method is 'cash'
    String changeDue = request.getParameter("changeDue");       // Only if method is 'cash'
    String cardLast4 = request.getParameter("cardLast4");       // Only if method is 'card'

    // --- Basic Validation/Defaults (Optional but Recommended) ---
    if (receiptNumber == null) receiptNumber = "N/A";
    if (receiptDate == null) receiptDate = "N/A";
    if (cashier == null) cashier = "System";
    if (subtotal == null) subtotal = "Rs.0.00";
    if (discount == null) discount = "Rs.0.00 (0%)";
    if (tax == null) tax = "Rs.0.00 (0%)";
    if (total == null) total = "Rs.0.00";
    if (paymentMethod == null) paymentMethod = "Unknown";

%>

<div class="receipt-container">
    <div class="receipt-header">
        <div class="store-logo" id="store-logo">
            <img src="../Images/logo.png" alt="POS Logo" class="logo-img">
        </div>
        <h2>Swift POS Store</h2>
        <p>123/2, High level Road, Homagama.</p>
        <p>Tel: (+94) 76-2375055</p>
    </div>

    <div class="receipt-details">
        <div class="receipt-row">
            <span>Receipt #:</span>
            <span><%= receiptNumber %></span>
        </div>
        <div class="receipt-row">
            <span>Date:</span>
            <span><%= receiptDate %></span>
        </div>
        <div class="receipt-row">
            <span>Cashier:</span>
            <span><%= cashier %></span>
        </div>
    </div>

    <div class="receipt-items">
        <div class="receipt-item-header">
            <span class="item-name">Item</span>
            <span class="item-qty">Qty</span>
            <span class="item-price">Price</span>
        </div>
        <%
            // Loop through items if they exist
            if (itemNames != null && itemQtys != null && itemPrices != null && itemNames.length == itemQtys.length && itemNames.length == itemPrices.length) {
                for (int i = 0; i < itemNames.length; i++) {
        %>
            <div class="receipt-item">
                <span class="item-name"><%= itemNames[i] %></span>
                <span class="item-qty"><%= itemQtys[i] %></span>
                <span class="item-price"><%= itemPrices[i] %></span> <%-- Displaying price per item --%>
            </div>
        <%
                }
            } else {
        %>
            <div class="receipt-item"><span colspan="3">No items found.</span></div>
        <%
            }
        %>
    </div>

    <div class="receipt-summary">
        <div class="receipt-row">
            <span>Subtotal:</span>
            <span><%= subtotal %></span>
        </div>
        <div class="receipt-row">
            <span>Discount:</span>
            <span><%= discount %></span>
        </div>
        <div class="receipt-row">
            <span>Tax:</span>
            <span><%= tax %></span>
        </div>
        <div class="receipt-row total">
            <span>Total:</span>
            <span><%= total %></span>
        </div>
    </div>

    <div class="payment-details-section">
         <div class="receipt-row payment-method">
            <span>Payment Method:</span>
            <span><%= paymentMethod.substring(0, 1).toUpperCase() + paymentMethod.substring(1) %></span> <%-- Capitalize --%>
        </div>
       <% if ("cash".equalsIgnoreCase(paymentMethod) && cashReceived != null && changeDue != null) { %>
            <div class="receipt-row payment-method">
                <span>Cash Received:</span>
                <span><%= cashReceived %></span>
            </div>
            <div class="receipt-row payment-method">
                <span>Change:</span>
                <span><%= changeDue %></span>
            </div>
       <% } else if ("card".equalsIgnoreCase(paymentMethod) && cardLast4 != null) { %>
            <div class="receipt-row payment-method">
                <span>Card Used:</span>
                <span>**** **** **** <%= cardLast4 %></span>
            </div>
       <% } %>
       <%-- No specific details needed for 'digital' in this example --%>
    </div>


    <div class="receipt-footer">
        <p>Thank you for shopping with us!</p>
        <p>Return policy: Items can be returned within 30 days with receipt</p>
        <div class="barcode">
            <img src="https://barcode.tec-it.com/barcode.ashx?data=<%= receiptNumber %>&code=Code128&translate-esc=on" alt="Barcode" style="height: 50px;">
        </div>
    </div>
</div>

<div class="action-buttons">
    <button onclick="window.print();">
        <i class="fas fa-print"></i> Print Receipt
    </button>
    <button onclick="window.location.href='mailto:?subject=Receipt%20<%= receiptNumber %>&body=See%20attached%20receipt%20or%20details...';">
         <i class="fas fa-envelope"></i> Email Receipt (Basic)
    </button>
     <button onclick="window.location.href='cashier_dashboard.jsp';">
         <i class="fas fa-arrow-left"></i> Back to Dashboard
    </button>
</div>

</body>
</html>
