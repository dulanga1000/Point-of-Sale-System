<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Product, model.Supplier" %> <%-- Assuming you have these models and ways to fetch them --%>
<%-- <%@ page import="dao.SupplierDAO, dao.ProductDAO, util.DBConnection" %> --%> <%-- You'll need these --%>
<%--
    // Example: Fetch suppliers and products for dropdowns
    // Connection conn = null;
    // List<Supplier> suppliers = null;
    // List<Product> products = null;
    // try {
    // conn = DBConnection.getConnection();
    // if (conn != null) {
    // SupplierDAO supplierDAO = new SupplierDAO(conn);
    // suppliers = supplierDAO.getAllSuppliers(); // Implement this method
    // ProductDAO productDAO = new ProductDAO(conn);
    // products = productDAO.getAllProducts(); // Implement this method
    //     }
    // } catch (Exception e) {
    //     e.printStackTrace();
    // } finally {
    //     DBConnection.closeConnection(conn);
    // }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Purchase Order</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css"> <%-- Your existing stylesheet --%>
    <style>
        .form-container { max-width: 800px; margin: 20px auto; padding: 20px; background-color: #f9f9f9; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input[type="text"], .form-group input[type="date"], .form-group input[type="number"], .form-group select, .form-group textarea {
            width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;
        }
        .form-group textarea { min-height: 80px; }
        .item-row { display: flex; gap: 10px; margin-bottom: 10px; align-items: center; }
        .item-row select, .item-row input { flex-grow: 1; }
        .item-row button { padding: 10px 15px; background-color: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .item-row button:hover { background-color: #c82333; }
        .primary-button { background-color: var(--primary); color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        .primary-button:hover { background-color: var(--primary-dark); }
        #items-container .form-group { border-top: 1px dashed #ccc; padding-top: 10px; margin-top:10px; }
    </style>
</head>
<body>
    <div class="dashboard">
        <jsp:include page="menu.jsp" />
        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Add New Purchase Order</h1>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/addPurchaseOrder" method="POST" id="purchaseOrderForm">
                    <fieldset>
                        <legend>Order Details</legend>
                        <div class="form-group">
                            <label for="orderNumberDisplay">Order Number (e.g., PO-YYYY-XXXX):</label>
                            <input type="text" id="orderNumberDisplay" name="orderNumberDisplay" required>
                        </div>
                        <div class="form-group">
                            <label for="supplierId">Supplier:</label>
                            <select id="supplierId" name="supplierId" required>
                                <option value="">Select Supplier</option>
                                <%-- Example: Iterate over suppliers
                                if (suppliers != null) {
                                    for (Supplier supplier : suppliers) {
                                %>
                                <option value="<%= supplier.getId() %>"><%= supplier.getName() %></option>
                                <%
                                    }
                                }
                                --%>
                                <option value="1">Example Supplier 1</option> <%-- Replace with dynamic data --%>
                                <option value="2">Example Supplier 2</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="orderDateForm">Order Date:</label>
                            <input type="date" id="orderDateForm" name="orderDateForm" required>
                        </div>
                        <div class="form-group">
                            <label for="expectedDeliveryDate">Expected Delivery Date:</label>
                            <input type="date" id="expectedDeliveryDate" name="expectedDeliveryDate" required>
                        </div>
                         <div class="form-group">
                            <label for="paymentTerms">Payment Terms:</label>
                            <input type="text" id="paymentTerms" name="paymentTerms" placeholder="e.g., Net 30">
                        </div>
                        <div class="form-group">
                            <label for="shippingMethod">Shipping Method:</label>
                            <input type="text" id="shippingMethod" name="shippingMethod" placeholder="e.g., Standard Ground">
                        </div>
                        <div class="form-group">
                            <label for="notes">Order Notes:</label>
                            <textarea id="notes" name="notes"></textarea>
                        </div>
                    </fieldset>

                    <fieldset>
                        <legend>Order Items</legend>
                        <div id="items-container">
                            </div>
                        <button type="button" onclick="addItemRow()" class="primary-button" style="background-color: #28a745; margin-top:10px;">Add Item</button>
                    </fieldset>

                    <fieldset>
                        <legend>Order Totals</legend>
                         <div class="form-group">
                            <label for="subtotal">Subtotal:</label>
                            <input type="number" id="subtotal" name="subtotal" step="0.01" placeholder="0.00" readonly>
                        </div>
                        <div class="form-group">
                            <label for="taxPercentage">Tax Percentage (%):</label>
                            <input type="number" id="taxPercentage" name="taxPercentage" step="0.01" placeholder="e.g., 5.00" oninput="calculateTotals()">
                        </div>
                        <div class="form-group">
                            <label for="taxAmount">Tax Amount:</label>
                            <input type="number" id="taxAmount" name="taxAmount" step="0.01" placeholder="0.00" readonly>
                        </div>
                        <div class="form-group">
                            <label for="shippingFee">Shipping Fee:</label>
                            <input type="number" id="shippingFee" name="shippingFee" step="0.01" placeholder="0.00" oninput="calculateTotals()">
                        </div>
                        <div class="form-group">
                            <label for="grandTotal">Grand Total:</label>
                            <input type="number" id="grandTotal" name="grandTotal" step="0.01" placeholder="0.00" readonly>
                        </div>
                    </fieldset>
                     <input type="hidden" name="createdByUserId" value="1"> <%-- Example: get from session --%>
                    <input type="hidden" name="createdByUserFullName" value="Admin User"> <%-- Example: get from session --%>

                    <div class="form-group" style="margin-top: 20px;">
                        <button type="submit" class="primary-button">Create Purchase Order</button>
                    </div>
                </form>
            </div>
            <div class="footer">Swift © 2025.</div>
        </div>
    </div>

    <script>
        let itemIndex = 0;

        function addItemRow() {
            itemIndex++;
            const container = document.getElementById('items-container');
            const itemRow = document.createElement('div');
            itemRow.classList.add('form-group', 'item-row-container'); // Added item-row-container for easier removal
            itemRow.setAttribute('id', 'itemRow' + itemIndex);
            itemRow.innerHTML = \`
                <h4>Item \${itemIndex}</h4>
                <div class="item-row">
                    <select name="items[\${itemIndex-1}].productId" required onchange="updatePrice(this)">
                        <option value="">Select Product</option>
                        <%-- Example: Iterate over products
                        if (products != null) {
                            for (Product p : products) {
                        %>
                        <option value="<%= p.getId() %>" data-price="<%= p.getPrice() %>"><%= p.getName() %></option>
                        <%
                            }
                        }
                        --%>
                        <option value="101" data-price="2.50">Espresso Beans</option> <%-- Replace with dynamic data --%>
                        <option value="102" data-price="15.00">Milk Frother</option>
                        <option value="103" data-price="1.00">Paper Cups (100 pack)</option>
                    </select>
                    <input type="number" name="items[\${itemIndex-1}].quantityOrdered" placeholder="Quantity" min="1" required oninput="calculateRowTotal(this)">
                    <input type="number" name="items[\${itemIndex-1}].unitPriceAtOrder" placeholder="Unit Price" step="0.01" readonly>
                    <input type="number" name="items[\${itemIndex-1}].rowTotalAtOrder" placeholder="Row Total" step="0.01" readonly>
                    <button type="button" onclick="removeItemRow('itemRow\${itemIndex}')">Remove</button>
                </div>
            \`;
            container.appendChild(itemRow);
        }

        function updatePrice(selectElement) {
            const selectedOption = selectElement.options[selectElement.selectedIndex];
            const price = selectedOption.dataset.price || 0;
            const itemRow = selectElement.closest('.item-row');
            itemRow.querySelector('input[name*="unitPriceAtOrder"]').value = parseFloat(price).toFixed(2);
            calculateRowTotal(selectElement);
        }

        function calculateRowTotal(element) {
            const itemRow = element.closest('.item-row');
            const quantity = parseFloat(itemRow.querySelector('input[name*="quantityOrdered"]').value) || 0;
            const unitPrice = parseFloat(itemRow.querySelector('input[name*="unitPriceAtOrder"]').value) || 0;
            const rowTotal = quantity * unitPrice;
            itemRow.querySelector('input[name*="rowTotalAtOrder"]').value = rowTotal.toFixed(2);
            calculateTotals();
        }
        
        function removeItemRow(rowId) {
            const rowToRemove = document.getElementById(rowId);
            if (rowToRemove) {
                rowToRemove.remove();
                // After removing, re-index items for proper form submission if necessary,
                // or handle gaps on the server side. For simplicity, we'll assume server handles gaps or non-sequential indices.
                calculateTotals(); // Recalculate totals after removing an item
            }
        }

        function calculateTotals() {
            let subtotal = 0;
            document.querySelectorAll('input[name*="rowTotalAtOrder"]').forEach(input => {
                subtotal += parseFloat(input.value) || 0;
            });
            document.getElementById('subtotal').value = subtotal.toFixed(2);

            const taxPercentage = parseFloat(document.getElementById('taxPercentage').value) || 0;
            const taxAmount = subtotal * (taxPercentage / 100);
            document.getElementById('taxAmount').value = taxAmount.toFixed(2);

            const shippingFee = parseFloat(document.getElementById('shippingFee').value) || 0;
            const grandTotal = subtotal + taxAmount + shippingFee;
            document.getElementById('grandTotal').value = grandTotal.toFixed(2);
        }

        // Add one item row by default when the page loads
        document.addEventListener('DOMContentLoaded', addItemRow);
    </script>
</body>
</html>