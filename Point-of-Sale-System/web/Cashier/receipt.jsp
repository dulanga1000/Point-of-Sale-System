<%-- 
    Document   : receipt
    Created on : May 4, 2025, 8:15:53 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.UUID"%>
<%@page import="java.util.Random"%>

<%
    // This would normally come from a database or session
    // For this example, we'll simulate receipt data
    String receiptId = "INV-" + new SimpleDateFormat("yyyyMMdd").format(new Date()) + "-" + 
                       String.format("%03d", new Random().nextInt(1000));
    String dateStr = new SimpleDateFormat("MMMM dd, yyyy hh:mm a").format(new Date());
    String cashierName = "John Doe";
    
    // These values would normally come from the session or request parameters
    // For demo purposes, we're hardcoding some sample values
    double subtotal = 0.0;
    double discount = 0.0;
    double tax = 0.0;
    double total = 0.0;
    
    // Sample items - in real implementation, these would come from the cart in session
    String[][] items = {
        {"T-Shirt", "1", "$19.99"},
        {"Headphones", "1", "$49.99"},
        {"Coffee Mug", "2", "$9.99"}
    };
    
    // Calculate totals based on items
    for(String[] item : items) {
        subtotal += Double.parseDouble(item[2].replace("$", "")) * Integer.parseInt(item[1]);
    }
    
    // Apply a sample discount (10%)
    discount = subtotal * 0.1;
    
    // Apply tax (8.5%)
    tax = (subtotal - discount) * 0.085;
    
    // Calculate total
    total = subtotal - discount + tax;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receipt - <%= receiptId %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f9f9f9;
            color: #333;
        }
        
        .print-container {
            max-width: 80mm;
            margin: 0 auto;
            background-color: white;
            padding: 15px;
            box-shadow: 0 0 5px rgba(0,0,0,0.1);
        }
        
        .receipt-header {
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 1px dashed #ccc;
        }
        
        .store-logo {
            text-align: center;
            margin-bottom: 10px;
        }
        
        .store-logo img {
            height: 40px;
        }
        
        .receipt-header h2 {
            margin: 5px 0;
            font-size: 16px;
        }
        
        .receipt-header p {
            margin: 5px 0;
            font-size: 12px;
        }
        
        .receipt-details {
            padding: 10px 0;
            border-bottom: 1px dashed #ccc;
            font-size: 12px;
        }
        
        .receipt-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
        }
        
        .receipt-items {
            padding: 10px 0;
            border-bottom: 1px dashed #ccc;
        }
        
        .receipt-item-header {
            display: flex;
            justify-content: space-between;
            font-weight: bold;
            margin-bottom: 5px;
            font-size: 12px;
        }
        
        .receipt-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-size: 12px;
        }
        
        .item-name {
            flex: 2;
        }
        
        .item-qty, .item-price {
            flex: 1;
            text-align: right;
        }
        
        .receipt-summary {
            padding: 10px 0;
            border-bottom: 1px dashed #ccc;
            font-size: 12px;
        }
        
        .receipt-footer {
            padding-top: 10px;
            text-align: center;
            font-size: 11px;
        }
        
        .total {
            font-weight: bold;
            font-size: 14px;
        }
        
        .barcode {
            text-align: center;
            margin-top: 15px;
        }
        
        .barcode img {
            max-width: 100%;
        }
        
        .buttons {
            margin-top: 20px;
            text-align: center;
        }
        
        .print-btn {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        @media print {
            .buttons {
                display: none;
            }
            
            body {
                padding: 0;
                background-color: white;
            }
            
            .print-container {
                box-shadow: none;
                max-width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="print-container">
        <div class="receipt-header">
            <div class="store-logo">
                <img src="../Images/logo.png" alt="POS Logo">
            </div>
            <h2>Swift POS Store</h2>
            <p>123/2, High level Road, Homagama.</p>
            <p>Tel: (+94) 76-2375055</p>
        </div>
        
        <div class="receipt-details">
            <div class="receipt-row">
                <span>Receipt #:</span>
                <span><%= receiptId %></span>
            </div>
            <div class="receipt-row">
                <span>Date:</span>
                <span><%= dateStr %></span>
            </div>
            <div class="receipt-row">
                <span>Cashier:</span>
                <span><%= cashierName %></span>
            </div>
        </div>
        
        <div class="receipt-items">
            <div class="receipt-item-header">
                <span class="item-name">Item</span>
                <span class="item-qty">Qty</span>
                <span class="item-price">Price</span>
            </div>
            
            <% for(String[] item : items) { %>
            <div class="receipt-item">
                <span class="item-name"><%= item[0] %></span>
                <span class="item-qty"><%= item[1] %></span>
                <span class="item-price"><%= item[2] %></span>
            </div>
            <% } %>
        </div>
        
        <div class="receipt-summary">
            <div class="receipt-row">
                <span>Subtotal:</span>
                <span>$<%= String.format("%.2f", subtotal) %></span>
            </div>
            <div class="receipt-row">
                <span>Discount (10%):</span>
                <span>$<%= String.format("%.2f", discount) %></span>
            </div>
            <div class="receipt-row">
                <span>Tax (8.5%):</span>
                <span>$<%= String.format("%.2f", tax) %></span>
            </div>
            <div class="receipt-row total">
                <span>Total:</span>
                <span>$<%= String.format("%.2f", total) %></span>
            </div>
        </div>
        
        <div class="receipt-footer">
            <p>Thank you for shopping with us!</p>
            <p>Return policy: Items can be returned within 30 days with receipt</p>
            <div class="barcode">
                <img src="https://barcode.tec-it.com/barcode.ashx?data=<%= receiptId %>&code=Code128&translate-esc=on" alt="Barcode" style="height: 50px;">
            </div>
        </div>
    </div>
    
    <div class="buttons">
        <button class="print-btn" onclick="window.print();">Print Receipt</button>
    </div>
    
    <script>
        // Auto-print when page loads (optional)
        // window.onload = function() {
        //     window.print();
        // }
    </script>
</body>
</html>