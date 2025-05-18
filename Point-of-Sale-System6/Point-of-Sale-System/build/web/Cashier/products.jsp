<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="../styles.css">
</head>
<body>
    <div class="mobile-top-bar">
        <div class="mobile-logo">
            <img src="Images/logo.png" alt="POS Logo" class="logo-img">
            <h2>Swift</h2>
        </div>
        <button class="mobile-nav-toggle" id="mobileNavToggle">
            <i class="fas fa-bars"></i>
        </button>
    </div>

    <div class="dashboard">
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <img src="Images/logo.png" alt="POS Logo" class="logo-img">
                <h2>Swift</h2>
            </div>

            <ul class="menu">
                <li class="menu-item">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Sales</span>
                </li>
                <li class="menu-item active">
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
                    <a href="logoutAction" style="text-decoration: none; color: inherit;">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </li>
            </ul>
        </div>

        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Products Dashboard</h1>
                <div class="user-profile">
                    <div class="user-image">
                        <img src="Images/logo.png" alt="User avatar">
                    </div>
                    <div class="user-info">
                        <h4>John Doe</h4>
                        <p>Cashier</p>
                    </div>
                </div>
            </div>

            <div class="product-statistics">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-box-open" style="color: var(--primary);"></i>
                    </div>
                    <div class="stat-info">
                        <h3>120</h3>
                        <p>Total Products</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-exclamation-triangle" style="color: var(--warning);"></i>
                    </div>
                    <div class="stat-info">
                        <h3>15</h3>
                        <p>Low Stock</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-times-circle" style="color: var(--danger);"></i>
                    </div>
                    <div class="stat-info">
                        <h3>8</h3>
                        <p>Out of Stock</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-tags" style="color: var(--secondary);"></i>
                    </div>
                    <div class="stat-info">
                        <h3>12</h3>
                        <p>Categories</p>
                    </div>
                </div>
            </div>

            <div class="module-card products-module">
                <div class="module-header">
                    <span>Products List</span>
                    <div class="header-controls">
                        <div class="view-toggle">
                            <button class="view-btn active" data-view="grid">
                                <i class="fas fa-th"></i>
                            </button>
                            <button class="view-btn" data-view="list">
                                <i class="fas fa-list"></i>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="module-content">
                    <div class="search-filters">
                        <div class="search-bar">
                            <input type="text" class="search-input" placeholder="Search products by name, code or category...">
                            <button class="search-btn">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                        <div class="filter-section">
                            <div class="filter-group">
                                <label>Category:</label>
                                <select class="filter-select">
                                    <option value="">All Categories</option>
                                    <option value="food">Food</option>
                                    <option value="beverages">Beverages</option>
                                    <option value="electronics">Electronics</option>
                                    <option value="clothing">Clothing</option>
                                    <option value="home">Home Goods</option>
                                    <option value="stationery">Stationery</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label>Stock Status:</label>
                                <select class="filter-select">
                                    <option value="">All Stock</option>
                                    <option value="in">In Stock</option>
                                    <option value="low">Low Stock</option>
                                    <option value="out">Out of Stock</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label>Sort By:</label>
                                <select class="filter-select">
                                    <option value="name">Name (A-Z)</option>
                                    <option value="name-desc">Name (Z-A)</option>
                                    <option value="price-asc">Price (Low to High)</option>
                                    <option value="price-desc">Price (High to Low)</option>
                                    <option value="stock">Stock Level</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="category-filters">
                        <div class="category-filter active" data-category="All">All</div>
                        <div class="category-filter" data-category="Food">Food</div>
                        <div class="category-filter" data-category="Beverages">Beverages</div>
                        <div class="category-filter" data-category="Electronics">Electronics</div>
                        <div class="category-filter" data-category="Clothing">Clothing</div>
                        <div class="category-filter" data-category="Home">Home Goods</div>
                        <div class="category-filter" data-category="Stationery">Stationery</div>
                    </div>

                    <!-- Grid View (active by default) -->
                    <div class="product-view grid-view active">
                        <div class="product-grid">
                            <!-- Product 1 -->
                            <div class="product-card" data-product-id="1" data-category="Food">
                                <div class="product-icon">
                                    <i class="fas fa-utensils"></i>
                                </div>
                                <h4 class="product-name">Chicken Burger</h4>
                                <p class="product-price">Rs.350.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: F001</p>
                                </div>
                                <div class="stock-info">
                                    <i class="fas fa-check-circle"></i>
                                    <span>In Stock (45)</span>
                                </div>
                            </div>

                            <!-- Product 2 -->
                            <div class="product-card" data-product-id="2" data-category="Beverages">
                                <div class="product-icon">
                                    <i class="fas fa-coffee"></i>
                                </div>
                                <h4 class="product-name">Cappuccino</h4>
                                <p class="product-price">Rs.250.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: B001</p>
                                </div>
                                <div class="stock-info">
                                    <i class="fas fa-check-circle"></i>
                                    <span>In Stock (32)</span>
                                </div>
                            </div>

                            <!-- Product 3 -->
                            <div class="product-card" data-product-id="3" data-category="Electronics">
                                <div class="product-icon">
                                    <i class="fas fa-headphones"></i>
                                </div>
                                <h4 class="product-name">Wireless Headphones</h4>
                                <p class="product-price">Rs.1,800.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: E001</p>
                                </div>
                                <div class="stock-info low">
                                    <i class="fas fa-exclamation-circle"></i>
                                    <span>Low Stock (5)</span>
                                </div>
                            </div>

                            <!-- Product 4 -->
                            <div class="product-card" data-product-id="4" data-category="Food">
                                <div class="product-icon">
                                    <i class="fas fa-pizza-slice"></i>
                                </div>
                                <h4 class="product-name">Pepperoni Pizza</h4>
                                <p class="product-price">Rs.600.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: F002</p>
                                </div>
                                <div class="stock-info">
                                    <i class="fas fa-check-circle"></i>
                                    <span>In Stock (25)</span>
                                </div>
                            </div>

                            <!-- Product 5 -->
                            <div class="product-card" data-product-id="5" data-category="Clothing">
                                <div class="product-icon">
                                    <i class="fas fa-tshirt"></i>
                                </div>
                                <h4 class="product-name">Black T-Shirt</h4>
                                <p class="product-price">Rs.750.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: C001</p>
                                </div>
                                <div class="stock-info out">
                                    <i class="fas fa-times-circle"></i>
                                    <span>Out of Stock (0)</span>
                                </div>
                            </div>

                            <!-- Product 6 -->
                            <div class="product-card" data-product-id="6" data-category="Home">
                                <div class="product-icon">
                                    <i class="fas fa-couch"></i>
                                </div>
                                <h4 class="product-name">Decorative Pillow</h4>
                                <p class="product-price">Rs.450.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: H001</p>
                                </div>
                                <div class="stock-info">
                                    <i class="fas fa-check-circle"></i>
                                    <span>In Stock (18)</span>
                                </div>
                            </div>

                            <!-- Product 7 -->
                            <div class="product-card" data-product-id="7" data-category="Stationery">
                                <div class="product-icon">
                                    <i class="fas fa-pen"></i>
                                </div>
                                <h4 class="product-name">Ballpoint Pen Set</h4>
                                <p class="product-price">Rs.120.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: S001</p>
                                </div>
                                <div class="stock-info low">
                                    <i class="fas fa-exclamation-circle"></i>
                                    <span>Low Stock (8)</span>
                                </div>
                            </div>

                            <!-- Product 8 -->
                            <div class="product-card" data-product-id="8" data-category="Beverages">
                                <div class="product-icon">
                                    <i class="fas fa-wine-bottle"></i>
                                </div>
                                <h4 class="product-name">Sparkling Water</h4>
                                <p class="product-price">Rs.75.00</p>
                                <div class="product-meta">
                                    <p class="product-code">SKU: B002</p>
                                </div>
                                <div class="stock-info">
                                    <i class="fas fa-check-circle"></i>
                                    <span>In Stock (52)</span>
                                </div>
                            </div>

                            <!-- More product cards can be added here -->
                        </div>
                    </div>

                    <!-- List View (initially hidden) -->
                    <div class="product-view list-view">
                        <table class="product-table">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Category</th>
                                    <th>SKU</th>
                                    <th>Price</th>
                                    <th>Stock</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Product 1 -->
                                <tr data-product-id="1" data-category="Food">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-utensils"></i>
                                        </div>
                                        <span>Chicken Burger</span>
                                    </td>
                                    <td>Food</td>
                                    <td>F001</td>
                                    <td class="price-cell">Rs.350.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge in-stock">45</span>
                                    </td>
                                </tr>

                                <!-- Product 2 -->
                                <tr data-product-id="2" data-category="Beverages">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-coffee"></i>
                                        </div>
                                        <span>Cappuccino</span>
                                    </td>
                                    <td>Beverages</td>
                                    <td>B001</td>
                                    <td class="price-cell">Rs.250.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge in-stock">32</span>
                                    </td>
                                </tr>

                                <!-- Product 3 -->
                                <tr data-product-id="3" data-category="Electronics">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-headphones"></i>
                                        </div>
                                        <span>Wireless Headphones</span>
                                    </td>
                                    <td>Electronics</td>
                                    <td>E001</td>
                                    <td class="price-cell">Rs.1,800.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge low-stock">5</span>
                                    </td>
                                </tr>

                                <!-- Product 4 -->
                                <tr data-product-id="4" data-category="Food">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-pizza-slice"></i>
                                        </div>
                                        <span>Pepperoni Pizza</span>
                                    </td>
                                    <td>Food</td>
                                    <td>F002</td>
                                    <td class="price-cell">Rs.600.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge in-stock">25</span>
                                    </td>
                                </tr>

                                <!-- Product 5 -->
                                <tr data-product-id="5" data-category="Clothing">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-tshirt"></i>
                                        </div>
                                        <span>Black T-Shirt</span>
                                    </td>
                                    <td>Clothing</td>
                                    <td>C001</td>
                                    <td class="price-cell">Rs.750.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge out-stock">0</span>
                                    </td>
                                </tr>

                                <!-- Product 6 -->
                                <tr data-product-id="6" data-category="Home">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-couch"></i>
                                        </div>
                                        <span>Decorative Pillow</span>
                                    </td>
                                    <td>Home</td>
                                    <td>H001</td>
                                    <td class="price-cell">Rs.450.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge in-stock">18</span>
                                    </td>
                                </tr>

                                <!-- Product 7 -->
                                <tr data-product-id="7" data-category="Stationery">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-pen"></i>
                                        </div>
                                        <span>Ballpoint Pen Set</span>
                                    </td>
                                    <td>Stationery</td>
                                    <td>S001</td>
                                    <td class="price-cell">Rs.120.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge low-stock">8</span>
                                    </td>
                                </tr>

                                <!-- Product 8 -->
                                <tr data-product-id="8" data-category="Beverages">
                                    <td class="product-name-cell">
                                        <div class="product-mini-icon">
                                            <i class="fas fa-wine-bottle"></i>
                                        </div>
                                        <span>Sparkling Water</span>
                                    </td>
                                    <td>Beverages</td>
                                    <td>B002</td>
                                    <td class="price-cell">Rs.75.00</td>
                                    <td class="stock-cell">
                                        <span class="stock-badge in-stock">52</span>
                                    </td>
                                </tr>

                                <!-- More rows can be added here -->
                            </tbody>
                        </table>
                    </div>

                    <div class="pagination">
                        <button class="page-btn" disabled>
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <button class="page-btn active">1</button>
                        <button class="page-btn">2</button>
                        <button class="page-btn">3</button>
                        <button class="page-btn">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                    </div>
                </div>
            </div>

            <div class="footer">
                Swift POS © 2025.
            </div>
        </div>
    </div>

    <!-- Product Details Modal -->
    <div class="modal" id="productDetailsModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Product Details</h3>
                <button class="close-modal" aria-label="Close product details modal">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <div class="product-details-container">
                    <div class="product-detail-icon">
                        <i class="fas fa-utensils"></i>
                    </div>
                    <h2 class="product-detail-name">Chicken Burger</h2>
                    <div class="product-detail-meta">
                        <span class="badge product-category">Food</span>
                        <span class="badge product-sku">SKU: F001</span>
                    </div>
                    
                    <div class="product-detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Price</span>
                            <span class="detail-value">Rs.350.00</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Stock Level</span>
                            <span class="detail-value in-stock">45 units</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Status</span>
                            <span class="detail-value">Active</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Added On</span>
                            <span class="detail-value">May 12, 2025</span>
                        </div>
                    </div>
                    
                    <div class="product-description">
                        <h4>Description</h4>
                        <p>Delicious chicken burger with fresh lettuce, tomato, and special sauce. Served with a side of crispy fries.</p>
                    </div>
                    
                    <div class="product-stats">
                        <div class="stat-item">
                            <span class="stat-icon"><i class="fas fa-shopping-cart"></i></span>
                            <span class="stat-value">245</span>
                            <span class="stat-label">Units Sold</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-icon"><i class="fas fa-chart-line"></i></span>
                            <span class="stat-value">12%</span>
                            <span class="stat-label">Sales Growth</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
        // Mobile navigation toggle
        const mobileNavToggle = document.getElementById('mobileNavToggle');
        const sidebar = document.getElementById('sidebar');

        if (mobileNavToggle) {
            mobileNavToggle.addEventListener('click', function() {
                sidebar.classList.toggle('active');

                // Toggle the icon between bars and times
                const icon = mobileNavToggle.querySelector('i');
                if (icon.classList.contains('fa-bars')) {
                    icon.classList.remove('fa-bars');
                    icon.classList.add('fa-times');
                } else {
                    icon.classList.remove('fa-times');
                    icon.classList.add('fa-bars');
                }
            });
        }

        // View toggle between grid and list views
        const viewButtons = document.querySelectorAll('.view-btn');
        const gridView = document.querySelector('.grid-view');
        const listView = document.querySelector('.list-view');

        viewButtons.forEach(button => {
            button.addEventListener('click', function() {
                // Remove active class from all buttons
                viewButtons.forEach(btn => btn.classList.remove('active'));

                // Add active class to clicked button
                this.classList.add('active');

                // Toggle view based on button data attribute
                const viewType = this.getAttribute('data-view');

                if (viewType === 'grid') {
                    gridView.classList.add('active');
                    listView.classList.remove('active');
                } else if (viewType === 'list') {
                    listView.classList.add('active');
                    gridView.classList.remove('active');
                }
            });
        });

        // Category filters
        const categoryFilters = document.querySelectorAll('.category-filter');
        const productCards = document.querySelectorAll('.product-card');
        const productRows = document.querySelectorAll('.product-table tbody tr');

        categoryFilters.forEach(filter => {
            filter.addEventListener('click', function() {
                // Remove active class from all filters
                categoryFilters.forEach(f => f.classList.remove('active'));

                // Add active class to clicked filter
                this.classList.add('active');

                const selectedCategory = this.getAttribute('data-category');

                // Filter products in grid view
                productCards.forEach(card => {
                    if (selectedCategory === 'All' || card.getAttribute('data-category') === selectedCategory) {
                        card.style.display = 'flex';
                    } else {
                        card.style.display = 'none';
                    }
                });

                // Filter products in list view
                productRows.forEach(row => {
                    if (selectedCategory === 'All' || row.getAttribute('data-category') === selectedCategory) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        });

        // Search functionality
        const searchInput = document.querySelector('.search-input');
        const searchButton = document.querySelector('.search-btn');

        function performSearch() {
            const searchTerm = searchInput.value.toLowerCase().trim();

            // Search in grid view
            productCards.forEach(card => {
                const productName = card.querySelector('.product-name').textContent.toLowerCase();
                const productCode = card.querySelector('.product-code').textContent.toLowerCase();
                const productCategory = card.getAttribute('data-category').toLowerCase();

                if (
                    productName.includes(searchTerm) || 
                    productCode.includes(searchTerm) || 
                    productCategory.includes(searchTerm)
                ) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });

            // Search in list view
            productRows.forEach(row => {
                const productNameCell = row.querySelector('.product-name-cell span').textContent.toLowerCase();
                const productCategory = row.cells[1].textContent.toLowerCase();
                const productSku = row.cells[2].textContent.toLowerCase();

                if (
                    productNameCell.includes(searchTerm) || 
                    productCategory.includes(searchTerm) || 
                    productSku.includes(searchTerm)
                ) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        if (searchButton) {
            searchButton.addEventListener('click', performSearch);
        }

        if (searchInput) {
            searchInput.addEventListener('keyup', function(event) {
                if (event.key === 'Enter') {
                    performSearch();
                }
            });
        }

        // Dropdown filters functionality
        const filterSelects = document.querySelectorAll('.filter-select');

        filterSelects.forEach(select => {
            select.addEventListener('change', function() {
                applyFilters();
            });
        });

        function applyFilters() {
            const categoryFilter = document.querySelector('.filter-select:nth-child(1)').value;
            const stockFilter = document.querySelector('.filter-select:nth-child(2)').value;
            const sortBy = document.querySelector('.filter-select:nth-child(3)').value;

            // Filter and sort grid view products
            filterProducts(productCards, categoryFilter, stockFilter);
            filterProducts(productRows, categoryFilter, stockFilter);

            // Sort products
            sortProducts(sortBy);
        }

        function filterProducts(products, categoryFilter, stockFilter) {
            products.forEach(product => {
                let shouldShow = true;

                // Apply category filter
                if (categoryFilter && categoryFilter !== '') {
                    const productCategory = product.getAttribute('data-category').toLowerCase();
                    if (productCategory !== categoryFilter) {
                        shouldShow = false;
                    }
                }

                // Apply stock filter
                if (stockFilter && stockFilter !== '') {
                    let stockText;
                    if (product.classList.contains('product-card')) {
                        stockText = product.querySelector('.stock-info').textContent.toLowerCase();
                    } else {
                        // For table rows
                        const stockBadge = product.querySelector('.stock-badge');
                        if (stockBadge.classList.contains('in-stock') && stockFilter === 'in') {
                            // Keep visible
                        } else if (stockBadge.classList.contains('low-stock') && stockFilter === 'low') {
                            // Keep visible
                        } else if (stockBadge.classList.contains('out-stock') && stockFilter === 'out') {
                            // Keep visible
                        } else {
                            shouldShow = false;
                        }
                    }

                    if (product.classList.contains('product-card')) {
                        if (stockFilter === 'in' && !stockText.includes('in stock')) {
                            shouldShow = false;
                        } else if (stockFilter === 'low' && !stockText.includes('low stock')) {
                            shouldShow = false;
                        } else if (stockFilter === 'out' && !stockText.includes('out of stock')) {
                            shouldShow = false;
                        }
                    }
                }

                // Show or hide based on filters
                if (product.classList.contains('product-card')) {
                    product.style.display = shouldShow ? 'flex' : 'none';
                } else {
                    product.style.display = shouldShow ? '' : 'none';
                }
            });
        }

        function sortProducts(sortBy) {
            // Sort cards in grid view
            const productGrid = document.querySelector('.product-grid');
            const cardsArray = Array.from(productCards);

            // Sort table rows in list view
            const productTable = document.querySelector('.product-table tbody');
            const rowsArray = Array.from(productRows);

            // Sorting logic based on sort selection
            switch (sortBy) {
                case 'name':
                    sortElements(cardsArray, productGrid, '.product-name', false);
                    sortElements(rowsArray, productTable, '.product-name-cell span', false);
                    break;
                case 'name-desc':
                    sortElements(cardsArray, productGrid, '.product-name', true);
                    sortElements(rowsArray, productTable, '.product-name-cell span', true);
                    break;
                case 'price-asc':
                    sortElementsByPrice(cardsArray, productGrid, '.product-price', false);
                    sortElementsByPrice(rowsArray, productTable, '.price-cell', false);
                    break;
                case 'price-desc':
                    sortElementsByPrice(cardsArray, productGrid, '.product-price', true);
                    sortElementsByPrice(rowsArray, productTable, '.price-cell', true);
                    break;
                case 'stock':
                    sortElementsByStock(cardsArray, productGrid);
                    sortElementsByStock(rowsArray, productTable, true);
                    break;
            }
        }

        function sortElements(elements, container, selector, reverse) {
            elements.sort((a, b) => {
                const textA = a.querySelector(selector).textContent.trim().toLowerCase();
                const textB = b.querySelector(selector).textContent.trim().toLowerCase();
                return reverse ? textB.localeCompare(textA) : textA.localeCompare(textB);
            });

            // Re-append sorted elements
            elements.forEach(element => {
                container.appendChild(element);
            });
        }

        function sortElementsByPrice(elements, container, selector, reverse) {
            elements.sort((a, b) => {
                // Extract price text and convert to number
                const priceTextA = a.querySelector(selector).textContent.trim();
                const priceTextB = b.querySelector(selector).textContent.trim();

                // Remove currency symbol and commas, then convert to number
                const priceA = parseFloat(priceTextA.replace(/[^0-9.-]+/g, ""));
                const priceB = parseFloat(priceTextB.replace(/[^0-9.-]+/g, ""));

                return reverse ? priceB - priceA : priceA - priceB;
            });

            // Re-append sorted elements
            elements.forEach(element => {
                container.appendChild(element);
            });
        }

        function sortElementsByStock(elements, container, isTable = false) {
            elements.sort((a, b) => {
                let stockA, stockB;

                if (isTable) {
                    // For table rows
                    stockA = parseInt(a.querySelector('.stock-badge').textContent);
                    stockB = parseInt(b.querySelector('.stock-badge').textContent);
                } else {
                    // For grid cards, extract number from stock info text
                    const stockTextA = a.querySelector('.stock-info').textContent;
                    const stockTextB = b.querySelector('.stock-info').textContent;

                    // Extract numbers from stock text using regex
                    const stockMatchA = stockTextA.match(/\d+/);
                    const stockMatchB = stockTextB.match(/\d+/);

                    stockA = stockMatchA ? parseInt(stockMatchA[0]) : 0;
                    stockB = stockMatchB ? parseInt(stockMatchB[0]) : 0;
                }

                // Sort by stock level (descending)
                return stockB - stockA;
            });

            // Re-append sorted elements
            elements.forEach(element => {
                container.appendChild(element);
            });
        }

        // Pagination (basic implementation)
        const pageButtons = document.querySelectorAll('.page-btn');

        pageButtons.forEach(button => {
            button.addEventListener('click', function() {
                if (this.disabled || this.classList.contains('active')) {
                    return;
                }

                // Remove active class from all page buttons
                pageButtons.forEach(btn => btn.classList.remove('active'));

                // Add active class to clicked button
                this.classList.add('active');

                // Here you would implement actual pagination logic
                // For this demo, we'll just simulate by showing/hiding some items

                // Get page number (if available)
                const pageText = this.textContent.trim();
                if (!isNaN(pageText)) {
                    const pageNum = parseInt(pageText);
                    console.log(`Switched to page ${pageNum}`);

                    // Implement pagination logic here
                    // For now, it's just visual feedback
                }
            });
        });

        // Handle product details modal
        const productDetailsModal = document.getElementById('productDetailsModal');
        const closeModalButton = document.querySelector('.close-modal');

        // Make products clickable to show details
        productCards.forEach(card => {
            card.addEventListener('click', function() {
                showProductDetails(this.getAttribute('data-product-id'));
            });
        });

        productRows.forEach(row => {
            row.addEventListener('click', function() {
                showProductDetails(this.getAttribute('data-product-id'));
            });
        });

        function showProductDetails(productId) {
            // Here you would fetch the product details based on the ID
            // For now, we'll just show the modal with sample data

            // Update modal content if needed
            // This would typically be done with actual data from a database

            // Show the modal
            if (productDetailsModal) {
                productDetailsModal.style.display = 'flex';
                document.body.style.overflow = 'hidden'; // Prevent scrolling behind modal
            }
        }

        // Close modal when clicking the close button
        if (closeModalButton) {
            closeModalButton.addEventListener('click', function() {
                productDetailsModal.style.display = 'none';
                document.body.style.overflow = ''; // Restore scrolling
            });
        }

        // Close modal when clicking outside the modal content
        if (productDetailsModal) {
            productDetailsModal.addEventListener('click', function(event) {
                if (event.target === productDetailsModal) {
                    productDetailsModal.style.display = 'none';
                    document.body.style.overflow = ''; // Restore scrolling
                }
            });
        }

        // Close modal on escape key press
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && productDetailsModal.style.display === 'flex') {
                productDetailsModal.style.display = 'none';
                document.body.style.overflow = ''; // Restore scrolling
            }
        });

        // Handle window resize for responsive design adjustments
        window.addEventListener('resize', function() {
            if (window.innerWidth > 768 && sidebar.classList.contains('active')) {
                sidebar.classList.remove('active');

                // Reset the mobile toggle button icon
                const icon = mobileNavToggle.querySelector('i');
                if (icon.classList.contains('fa-times')) {
                    icon.classList.remove('fa-times');
                    icon.classList.add('fa-bars');
                }
            }
        });
    });
    </script>
</body>
</html>