<%-- 
    Document   : cashier_dashboard
    Created on : May 4, 2025, 4:20:32 AM
    Author     : dulan
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Product" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.SQLException" %>

<%
    List<Product> productList = new ArrayList<>();
    List<String> categoryList = new ArrayList<>();
    Connection conn = null;
    String dbErrorMessage = null; // Renamed to avoid conflict with potential JS variables

    try {
        conn = DBConnection.getConnection();
        if (conn == null) {
            dbErrorMessage = "Failed to establish database connection.";
        } else {
            ProductDAO productDAO = new ProductDAO(conn);
            productList = productDAO.getAllProducts(); // Fetch all products
            categoryList = productDAO.getAllCategories(); // Fetch all categories
        }
    } catch (SQLException e) {
        dbErrorMessage = "SQL Error: " + e.getMessage();
        // Log to server console for detailed debugging
        System.err.println("SQLException in cashier_dashboard.jsp: " + e.getMessage());
        e.printStackTrace();
    } catch (Exception e) {
        dbErrorMessage = "An unexpected error occurred while fetching data: " + e.getMessage();
        System.err.println("Exception in cashier_dashboard.jsp: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try {
                DBConnection.closeConnection(conn);
            } catch (Exception e) {
                // Log to server console
                System.err.println("Error closing connection in cashier_dashboard.jsp: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="Stylesheet" href="styles.css">
</head>
<body>
    <div class="mobile-top-bar">
        <div class="mobile-logo">
            <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img"> <%-- Use context path --%>
            <h2>Swift</h2>
        </div>
        <button class="mobile-nav-toggle" id="mobileNavToggle">
            <i class="fas fa-bars"></i>
        </button>
    </div>

    <div class="dashboard">
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img"> <%-- Use context path --%>
                <h2>Swift</h2>
            </div>

            <ul class="menu">
                <li class="menu-item active">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Sales</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-box"></i>
                    <span>Products</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-chart-bar"></i>
                    <span>Reports</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-warehouse"></i>
                    <span>Inventory</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-receipt"></i>
                    <span>Transactions</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-cog"></i>
                    <span>Settings</span>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/logoutAction" style="text-decoration: none; color: inherit;">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </li>
            </ul>
        </div>

        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Cashier Dashboard</h1>
                <div class="user-profile">
                    <div class="user-image">
                        <img src="<%= request.getContextPath() %>/Images/logo.png" alt="User avatar"> <%-- Use context path, consider dynamic user image --%>
                    </div>
                    <div class="user-info">
                        <h4>John Doe</h4> <%-- Consider replacing with dynamic user data --%>
                        <p>Cashier</p>
                    </div>
                </div>
            </div>

            <div class="quick-actions">
                <div class="action-card">
                    <div class="action-icon">
                        <i class="fas fa-plus-circle" style="color: var(--success);"></i>
                    </div>
                    <h3 class="action-title">New Sale</h3>
                    <p class="action-description">Start a new transaction</p>
                </div>
                <div class="action-card">
                    <div class="action-icon">
                        <i class="fas fa-history" style="color: var(--primary);"></i>
                    </div>
                    <h3 class="action-title">Recent Sales</h3>
                    <p class="action-description">View recent transactions</p>
                </div>
                <div class="action-card">
                    <div class="action-icon">
                        <i class="fas fa-search" style="color: var(--secondary);"></i>
                    </div>
                    <h3 class="action-title">Stock Check</h3>
                    <p class="action-description">View available products</p>
                </div>
            </div>

            <div class="modules-container">
                <div class="module-card"> <%-- Product Module --%>
                    <div class="module-header">
                        <span>Products</span>
                        <button class="mobile-nav-toggle" style="display: none;">
                            <i class="fas fa-arrow-left"></i>
                        </button>
                    </div>
                    <div class="module-content">
                        <% if (dbErrorMessage != null) { %>
                            <div style="color: red; background-color: #ffebee; padding: 10px; border: 1px solid red; border-radius: var(--border-radius); margin-bottom: 15px;">
                                <strong>Database Error:</strong> <%= dbErrorMessage %>
                                <p>Please check server logs for more details or contact an administrator.</p>
                            </div>
                        <% } %>
                        <div class="product-search">
                            <div class="search-bar">
                                <input type="text" class="search-input" placeholder="Search products by name or code...">
                                <button class="search-btn">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                            <div class="category-filters">
                                <div class="category-filter active" data-category="All">All</div>
                                <% if (!categoryList.isEmpty()) {
                                    for (String category : categoryList) {
                                %>
                                    <div class="category-filter" data-category="<%= category %>"><%= category %></div>
                                <%
                                    }
                                } else if (dbErrorMessage == null) { // Only show if no DB error
                                %>
                                    <%-- <p style="font-size: 0.9em; color: var(--gray);">No categories found.</p> --%>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                        <div class="product-grid">
                            <% if (!productList.isEmpty()) {
                                for (Product product : productList) {
                                    String stockStatusClass = "";
                                    String stockIconClass = "fas fa-check-circle";
                                    String stockText = "In Stock";
                                    int currentStock = product.getStock();

                                    // Determine stock status based on product.getStock() and product.getStatus()
                                    // Assuming product.getStatus() could be "Active", "Inactive", "Out of Stock" etc.
                                    // And product.getStock() is the numerical quantity.
                                    // Low stock threshold (e.g., <= 10)
                                    int lowStockThreshold = 10; 

                                    if ("Out of Stock".equalsIgnoreCase(product.getStatus()) || currentStock <= 0) {
                                        stockStatusClass = "out"; // CSS class for out of stock styling
                                        stockIconClass = "fas fa-times-circle"; // Icon for out of stock
                                        stockText = "Out of Stock";
                                        currentStock = 0; // Ensure stock display is 0 if status says out of stock
                                    } else if (currentStock > 0 && currentStock <= lowStockThreshold) {
                                        stockStatusClass = "low"; // CSS class for low stock styling
                                        stockIconClass = "fas fa-exclamation-circle"; // Icon for low stock
                                        stockText = "Low Stock";
                                    }
                                    // Else, it remains "In Stock" with the check-circle icon
                            %>
                                <div class="product-card" data-product-id="<%= product.getId() %>" data-category="<%= product.getCategory() != null ? product.getCategory() : "" %>">
                                    <div class="product-icon">
                                        <% 
                                        String imagePath = product.getImagePath();
                                        String contextPath = request.getContextPath();
                                        if (imagePath != null && !imagePath.isEmpty() && !imagePath.toLowerCase().endsWith("default.jpg") && !imagePath.equals("Images/default.jpg")) { 
                                        %>
                                            <img src="<%= contextPath + "/" + imagePath %>" alt="<%= product.getName() %>" style="width: 40px; height: 40px; object-fit: contain;">
                                        <% } else { 
                                            String faIconClass = "fas fa-box"; // Default icon
                                            String categoryName = product.getCategory() != null ? product.getCategory().toLowerCase() : "";
                                            if (categoryName.contains("food") || categoryName.contains("utensils")) faIconClass = "fas fa-utensils";
                                            else if (categoryName.contains("beverage") || categoryName.contains("coffee") || categoryName.contains("drink")) faIconClass = "fas fa-coffee";
                                            else if (categoryName.contains("electronic")) faIconClass = "fas fa-tv";
                                            else if (categoryName.contains("clothing") || categoryName.contains("shirt")) faIconClass = "fas fa-tshirt";
                                            else if (categoryName.contains("home") || categoryName.contains("goods")) faIconClass = "fas fa-home";
                                            else if (categoryName.contains("book") || categoryName.contains("notebook")) faIconClass = "fas fa-book";
                                            else if (categoryName.contains("pen") || categoryName.contains("stationery")) faIconClass = "fas fa-pen";
                                            else if (categoryName.contains("glasses") || categoryName.contains("sunglasses")) faIconClass = "fas fa-glasses";
                                            else if (categoryName.contains("mobile") || categoryName.contains("phone")) faIconClass = "fas fa-mobile-alt";
                                            else if (categoryName.contains("headphone")) faIconClass = "fas fa-headphones";
                                        %>
                                            <i class="<%= faIconClass %>"></i>
                                        <% } %>
                                    </div>
                                    <h4 class="product-name"><%= product.getName() %></h4>
                                    <p class="product-price">Rs.<%= String.format("%.2f", product.getPrice()) %></p>
                                    <div class="stock-info <%= stockStatusClass %>">
                                        <i class="<%= stockIconClass %>"></i>
                                        <span><%= stockText %> (<%= currentStock %>)</span>
                                    </div>
                                </div>
                            <%
                                }
                            } else if (dbErrorMessage == null) { // Only show "no products" if there wasn't a DB error
                            %>
                                <p style="text-align: center; padding: 20px; color: var(--gray);">No products found in the database.</p>
                            <%
                                }
                            %>
                        </div>
                    </div>
                </div>

                <div class="module-card"> <%-- Cart Module --%>
                    <div class="module-header">
                        <span>Current Cart</span>
                        <button class="clear-cart-btn">Clear Cart</button>
                    </div>
                    <div class="module-content cart-module">
                        <div class="cart-items">
                            <%-- Initial empty message, JS will replace this if items are added OR if cart is cleared --%>
                            <p style="text-align: center; padding: 20px;">Cart is empty</p>
                        </div>
                        <div class="cart-summary">
                            <div class="summary-row">
                                <span>Subtotal</span>
                                <span id="cartSubtotal">Rs.0.00</span>
                            </div>
                            <div class="summary-row input-row">
                                <label for="cartDiscount">Discount (%)</label>
                                <div class="input-with-symbol">
                                    <input type="number" id="cartDiscount" value="" min="0" max="100" step="0.1" placeholder="0.0">
                                    <span>%</span>
                                </div>
                            </div>
                            <div class="summary-row">
                                <span>Discount</span>
                                <span id="cartDiscountAmount">Rs.0.00 (0.0%)</span>
                            </div>
                            <div class="summary-row input-row">
                                <label for="cartTaxRate">Tax (%)</label>
                                <div class="input-with-symbol">
                                    <input type="number" id="cartTaxRate" value="" min="0" step="0.1" placeholder="0.0">
                                    <span>%</span>
                                </div>
                            </div>
                            <div class="summary-row">
                                <span>Tax</span>
                                <span id="cartTaxAmount">Rs.0.00 (0.0%)</span>
                            </div>
                            <div class="summary-row total">
                                <span>Total</span>
                                <span id="cartTotal">Rs.0.00</span>
                            </div>
                            <button class="checkout-btn" id="checkoutBtn">
                                Proceed to Checkout
                            </button>
                        </div>
                    </div>
                </div>
            </div> <%-- End modules-container --%>

            <div class="footer">
                Swift POS © 2025.
            </div>
        </div> <%-- End main-content --%>
    </div> <%-- End dashboard --%>

    <%-- Payment Modal --%>
    <div class="modal" id="paymentModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Checkout - Payment</h3>
                <button class="close-modal" aria-label="Close payment modal">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <h4 id="paymentModalTotal">Total Amount: Rs.0.00</h4>
                <div class="payment-options">
                    <div class="payment-option active" data-method="cash">
                        <i class="fas fa-money-bill-wave"></i>
                        <span>Cash</span>
                    </div>
                    <div class="payment-option" data-method="card">
                        <i class="fas fa-credit-card"></i>
                        <span>Card</span>
                    </div>
                    <div class="payment-option" data-method="digital">
                        <i class="fas fa-mobile-alt"></i>
                        <span>Digital Payment</span>
                    </div>
                </div>

                <div class="payment-form cash-form active">
                    <div class="form-group">
                        <label for="cashAmount">Cash Received</label>
                        <div class="input-with-icon">
                            <span class="currency-symbol">Rs.</span>
                            <input type="number" id="cashAmount" placeholder="Enter amount" min="0" step="0.01">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Change Due</label>
                        <div class="change-amount" id="changeAmountDisplay">Rs.0.00</div>
                    </div>
                </div>

                <div class="payment-form card-form">
                    <div class="form-group">
                        <label for="cardNumber">Card Number</label>
                        <input type="text" id="cardNumber" placeholder="XXXX XXXX XXXX XXXX" inputmode="numeric">
                    </div>
                    <div class="form-row">
                        <div class="form-group half">
                            <label for="expiryDate">Expiry Date</label>
                            <input type="text" id="expiryDate" placeholder="MM/YY" inputmode="numeric">
                        </div>
                        <div class="form-group half">
                            <label for="cvvCode">CVV</label>
                            <input type="text" id="cvvCode" placeholder="XXX" inputmode="numeric" maxlength="4">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="cardHolderName">Cardholder Name</label>
                        <input type="text" id="cardHolderName" placeholder="Enter name as on card">
                    </div>
                </div>

                <div class="payment-form digital-form">
                    <div class="qr-code-container">
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=PaymentDataHere" alt="QR Code" class="qr-code">
                    </div>
                    <p class="qr-instruction">Scan QR code with your payment app</p>
                    <div class="digital-options">
                        <div class="digital-option"><i class="fab fa-apple-pay"></i></div>
                        <div class="digital-option"><i class="fab fa-google-pay"></i></div>
                        <div class="digital-option"><i class="fas fa-qrcode"></i></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="cancel-btn close-modal">Cancel</button> <%-- Added close-modal class for JS --%>
                <button type="button" class="confirm-btn">Complete Payment</button>
            </div>
        </div>
    </div>

    <script src="cscript.js"></script>
</body>
</html>