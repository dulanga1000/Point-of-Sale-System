<%-- 
    Document   : stock_count
    Created on : May 17, 2025, 12:00:05 AM
    Author     : dulan
--%>

<%-- 
    Document   : stock_count
    Created on : May 17, 2025, 10:15:45 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Stock Count</title>
  <link rel="Stylesheet" href="styles.css">
</head>
<body>
  <!-- Mobile Top Bar (visible on mobile only) -->
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle">☰</button>
  </div>
  
  <div class="dashboard">
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
      <div class="logo">
        <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
        <h2>Swift</h2>
      </div>
      <jsp:include page="menu.jsp" />
    </div>
    
    <!-- Main Content -->
    <div class="main-content">
      <div class="header">
        <h1 class="page-title">Stock Count</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Count Instructions -->
      <div class="module-card" style="margin-bottom: 20px;">
        <div class="module-header">
          Stock Count Instructions
        </div>
        <div class="module-content">
          <ol style="padding-left: 20px; line-height: 1.6;">
            <li>Scan or search for products to count.</li>
            <li>Enter the actual quantity found for each item.</li>
            <li>System will automatically calculate variances.</li>
            <li>Review discrepancies before finalizing the count.</li>
            <li>Submit the count to update inventory records.</li>
          </ol>
          <div style="margin-top: 15px; display: flex; gap: 10px;">
            <select class="count-select">
              <option value="">Select Count Location</option>
              <option value="main">Main Storage</option>
              <option value="display">Display Area</option>
              <option value="counter">Counter Stock</option>
            </select>
            <select class="count-select">
              <option value="">Select Category</option>
              <option value="beverages">Beverages</option>
              <option value="food">Food Items</option>
              <option value="supplies">Supplies</option>
            </select>
          </div>
        </div>
      </div>
      
      <!-- Search and Filter Area -->
      <div class="module-card" style="margin-bottom: 20px;">
        <div class="module-header">
          Search Products
        </div>
        <div class="module-content">
          <div style="display: flex; gap: 10px; margin-bottom: 15px;">
            <input type="text" placeholder="Search by name or scan barcode..." style="flex: 1; padding: 10px; border: 1px solid #e2e8f0; border-radius: 6px;">
            <button class="search-btn" style="background-color: var(--primary); color: white; border: none; border-radius: 6px; padding: 0 15px; cursor: pointer;">Search</button>
          </div>
          <div style="display: flex; flex-wrap: wrap; gap: 10px;">
            <span class="filter-tag">Coffee ✕</span>
            <span class="filter-tag">Milk ✕</span>
            <span class="filter-tag">Low Stock ✕</span>
          </div>
        </div>
      </div>
      
      <!-- Count Table -->
      <div class="module-card">
        <div class="module-header">
          Item Count Sheet
        </div>
        <div class="module-content">
          <div class="count-summary" style="display: flex; justify-content: space-between; margin-bottom: 20px; padding: 15px; background-color: #f8fafc; border-radius: 6px;">
            <div>
              <div style="font-size: 14px; color: var(--secondary);">Count ID</div>
              <div style="font-weight: 600;">SC-2025-05-17-001</div>
            </div>
            <div>
              <div style="font-size: 14px; color: var(--secondary);">Date</div>
              <div style="font-weight: 600;">May 17, 2025</div>
            </div>
            <div>
              <div style="font-size: 14px; color: var(--secondary);">Status</div>
              <div style="font-weight: 600; color: var(--warning);">In Progress</div>
            </div>
            <div>
              <div style="font-size: 14px; color: var(--secondary);">Items Counted</div>
              <div style="font-weight: 600;">0 of 285</div>
            </div>
          </div>
          
          <table>
            <thead>
              <tr>
                <th style="width: 50px;">
                  <input type="checkbox" id="selectAll">
                </th>
                <th>Product</th>
                <th>SKU</th>
                <th>Category</th>
                <th>System Qty</th>
                <th>Counted Qty</th>
                <th>Variance</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  <input type="checkbox" class="item-checkbox">
                </td>
                <td>
                  <div style="display: flex; align-items: center;">
                    <div style="width: 40px; height: 40px; background-color: #f1f5f9; border-radius: 4px; margin-right: 10px; display: flex; align-items: center; justify-content: center;">
                      ☕
                    </div>
                    <div>
                      <div style="font-weight: 500;">Premium Coffee Beans</div>
                      <div style="font-size: 12px; color: var(--secondary);">Global Coffee Co.</div>
                    </div>
                  </div>
                </td>
                <td>PCB-001</td>
                <td>Beverages</td>
                <td>25</td>
                <td>
                  <input type="number" min="0" value="" placeholder="0" class="count-input">
                </td>
                <td class="variance">-</td>
                <td>
                  <div class="action-buttons">
                    <button class="action-btn note-btn" title="Add Note">📝</button>
                    <button class="action-btn history-btn" title="View History">🕒</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="item-checkbox">
                </td>
                <td>
                  <div style="display: flex; align-items: center;">
                    <div style="width: 40px; height: 40px; background-color: #f1f5f9; border-radius: 4px; margin-right: 10px; display: flex; align-items: center; justify-content: center;">
                      🥛
                    </div>
                    <div>
                      <div style="font-weight: 500;">Organic Milk 1L</div>
                      <div style="font-size: 12px; color: var(--secondary);">Dairy Farms Inc.</div>
                    </div>
                  </div>
                </td>
                <td>OM-002</td>
                <td>Dairy</td>
                <td>8</td>
                <td>
                  <input type="number" min="0" value="" placeholder="0" class="count-input">
                </td>
                <td class="variance">-</td>
                <td>
                  <div class="action-buttons">
                    <button class="action-btn note-btn" title="Add Note">📝</button>
                    <button class="action-btn history-btn" title="View History">🕒</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="item-checkbox">
                </td>
                <td>
                  <div style="display: flex; align-items: center;">
                    <div style="width: 40px; height: 40px; background-color: #f1f5f9; border-radius: 4px; margin-right: 10px; display: flex; align-items: center; justify-content: center;">
                      🍫
                    </div>
                    <div>
                      <div style="font-weight: 500;">Chocolate Syrup</div>
                      <div style="font-size: 12px; color: var(--secondary);">Sweet Supplies Ltd.</div>
                    </div>
                  </div>
                </td>
                <td>CS-003</td>
                <td>Condiments</td>
                <td>3</td>
                <td>
                  <input type="number" min="0" value="" placeholder="0" class="count-input">
                </td>
                <td class="variance">-</td>
                <td>
                  <div class="action-buttons">
                    <button class="action-btn note-btn" title="Add Note">📝</button>
                    <button class="action-btn history-btn" title="View History">🕒</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="item-checkbox">
                </td>
                <td>
                  <div style="display: flex; align-items: center;">
                    <div style="width: 40px; height: 40px; background-color: #f1f5f9; border-radius: 4px; margin-right: 10px; display: flex; align-items: center; justify-content: center;">
                      🥤
                    </div>
                    <div>
                      <div style="font-weight: 500;">Paper Cups 12oz</div>
                      <div style="font-size: 12px; color: var(--secondary);">Package Solutions</div>
                    </div>
                  </div>
                </td>
                <td>PC-004</td>
                <td>Supplies</td>
                <td>15</td>
                <td>
                  <input type="number" min="0" value="" placeholder="0" class="count-input">
                </td>
                <td class="variance">-</td>
                <td>
                  <div class="action-buttons">
                    <button class="action-btn note-btn" title="Add Note">📝</button>
                    <button class="action-btn history-btn" title="View History">🕒</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="item-checkbox">
                </td>
                <td>
                  <div style="display: flex; align-items: center;">
                    <div style="width: 40px; height: 40px; background-color: #f1f5f9; border-radius: 4px; margin-right: 10px; display: flex; align-items: center; justify-content: center;">
                      🧴
                    </div>
                    <div>
                      <div style="font-weight: 500;">Vanilla Flavoring</div>
                      <div style="font-size: 12px; color: var(--secondary);">Flavor Masters</div>
                    </div>
                  </div>
                </td>
                <td>VF-005</td>
                <td>Condiments</td>
                <td>2</td>
                <td>
                  <input type="number" min="0" value="" placeholder="0" class="count-input">
                </td>
                <td class="variance">-</td>
                <td>
                  <div class="action-buttons">
                    <button class="action-btn note-btn" title="Add Note">📝</button>
                    <button class="action-btn history-btn" title="View History">🕒</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
          
          <div class="pagination" style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px;">
            <div>
              <span style="font-size: 14px; color: var(--secondary);">Showing 1-5 of 285 items</span>
            </div>
            <div style="display: flex; gap: 5px;">
              <button class="page-btn" disabled>Previous</button>
              <button class="page-btn active">1</button>
              <button class="page-btn">2</button>
              <button class="page-btn">3</button>
              <span style="padding: 5px;">...</span>
              <button class="page-btn">57</button>
              <button class="page-btn">Next</button>
            </div>
          </div>
          
          <div class="count-actions" style="display: flex; justify-content: space-between; margin-top: 30px;">
            <div>
              <button class="secondary-btn">
                Save Draft
              </button>
            </div>
            <div style="display: flex; gap: 10px;">
              <button class="secondary-btn">
                Cancel Count
              </button>
              <button class="primary-btn">
                Submit Count
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <div class="footer">
        Swift © 2025.
      </div>
    </div>
  </div>
  
  <style>
    /* Additional stock count specific styles */
    .count-select {
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
      flex: 1;
    }
    
    .filter-tag {
      display: inline-block;
      padding: 5px 10px;
      background-color: #e0f2fe;
      color: var(--primary);
      border-radius: 20px;
      font-size: 12px;
      cursor: pointer;
    }
    
    .count-input {
      width: 80px;
      padding: 8px;
      border: 1px solid #e2e8f0;
      border-radius: 4px;
      text-align: center;
    }
    
    .variance {
      font-weight: 500;
    }
    
    .variance.positive {
      color: var(--success);
    }
    
    .variance.negative {
      color: var(--danger);
    }
    
    .action-buttons {
      display: flex;
      gap: 5px;
    }
    
    .action-btn {
      background: none;
      border: none;
      cursor: pointer;
      font-size: 16px;
      padding: 5px;
      border-radius: 4px;
    }
    
    .action-btn:hover {
      background-color: #f1f5f9;
    }
    
    .search-btn:hover {
      background-color: var(--primary-dark);
    }
    
    .page-btn {
      padding: 5px 10px;
      border: 1px solid #e2e8f0;
      background-color: white;
      border-radius: 4px;
      cursor: pointer;
    }
    
    .page-btn.active {
      background-color: var(--primary);
      color: white;
      border-color: var(--primary);
    }
    
    .page-btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    .primary-btn {
      background-color: var(--primary);
      color: white;
      border: none;
      padding: 10px 20px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
    }
    
    .secondary-btn {
      background-color: #e2e8f0;
      color: var(--dark);
      border: none;
      padding: 10px 20px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
    }
    
    .primary-btn:hover {
      background-color: var(--primary-dark);
    }
    
    .secondary-btn:hover {
      background-color: #cbd5e1;
    }
    
    @media (max-width: 768px) {
      .count-actions {
        flex-direction: column;
        gap: 10px;
      }
      
      .count-actions button {
        width: 100%;
      }
      
      .count-summary {
        flex-direction: column;
        gap: 10px;
      }
      
      .action-buttons {
        justify-content: center;
      }
    }
  </style>
</body>
</html>
