<%-- 
    Document   : user_management
    Created on : May 9, 2025, 1:16:48 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>User Management</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    :root {
      --primary: #2563eb;
      --primary-dark: #1d4ed8;
      --secondary: #64748b;
      --light: #f1f5f9;
      --dark: #1e293b;
      --success: #10b981;
      --warning: #f59e0b;
      --danger: #ef4444;
    }

    body {
      background-color: #f8fafc;
      color: var(--dark);
    }

    .dashboard {
      display: flex;
      min-height: 100vh;
    }

    .sidebar {
      width: 250px;
      background-color: var(--dark);
      color: white;
      padding: 20px 0;
      transition: all 0.3s;
    }

    .logo {
      display: flex;
      align-items: center;
      padding: 0 20px 20px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      margin-bottom: 20px;
    }

    .logo img {
      width: 40px;
      height: auto;
      margin-right: 10px;
      filter: invert(1) brightness(2); /* change the logo color to white */
    }

    .logo h2 {
      font-size: 24px;
      font-weight: 700;
    }

    .menu {
      list-style: none;
    }

    .menu-item {
      padding: 12px 20px;
      display: flex;
      align-items: center;
      cursor: pointer;
      transition: all 0.3s;
    }

    .menu-item:hover,
    .menu-item.active {
      background-color: rgba(255, 255, 255, 0.1);
    }

    .menu-item i {
      margin-right: 12px;
      font-size: 18px;
    }

    .main-content {
      flex: 1;
      padding: 20px;
      overflow-y: auto;
    }

    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
    }

    .page-title {
      font-size: 24px;
      font-weight: 600;
    }

    .user-profile {
      display: flex;
      align-items: center;
      cursor: pointer;
    }

    .user-profile img {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      margin-right: 10px;
    }

    .stats-container {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }

    .stat-card {
      background-color: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    }

    .stat-card h3 {
      color: var(--secondary);
      font-size: 14px;
      margin-bottom: 10px;
    }

    .stat-card .value {
      font-size: 24px;
      font-weight: 700;
      margin-bottom: 5px;
    }

    .stat-card .trend {
      display: flex;
      align-items: center;
      font-size: 12px;
    }

    .trend.up {
      color: var(--success);
    }

    .trend.down {
      color: var(--danger);
    }

    .module-card {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      overflow: hidden;
      margin-bottom: 20px;
    }

    .module-header {
      padding: 15px 20px;
      background-color: var(--primary);
      color: white;
      font-weight: 600;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .module-content {
      padding: 20px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th, td {
      padding: 12px 15px;
      text-align: left;
    }

    thead {
      background-color: #f8fafc;
    }

    th {
      font-weight: 500;
      color: var(--secondary);
      font-size: 14px;
    }

    tbody tr {
      border-bottom: 1px solid #f1f5f9;
    }

    tbody tr:hover {
      background-color: #f8fafc;
    }

    .status {
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
    }

    .status.active {
      background-color: #d1fae5;
      color: var(--success);
    }

    .status.break {
      background-color: #fef3c7;
      color: var(--warning);
    }

    .status.inactive {
      background-color: #fee2e2;
      color: var(--danger);
    }

    .action-buttons {
      display: flex;
      gap: 8px;
    }

    .btn {
      padding: 6px 12px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 12px;
      font-weight: 500;
      transition: all 0.2s;
    }

    .btn-primary {
      background-color: var(--primary);
      color: white;
    }

    .btn-primary:hover {
      background-color: var(--primary-dark);
    }

    .btn-warning {
      background-color: var(--warning);
      color: white;
    }

    .btn-danger {
      background-color: var(--danger);
      color: white;
    }

    .btn-add {
      background-color: var(--success);
      color: white;
      display: flex;
      align-items: center;
    }

    .btn-add:hover {
      background-color: #0d9669;
    }

    .search-filter-container {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }

    .search-container {
      display: flex;
      gap: 10px;
      align-items: center;
    }

    .search-input {
      padding: 8px 12px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
      min-width: 250px;
    }

    .filter-buttons {
      display: flex;
      gap: 10px;
    }

    .filter-btn {
      padding: 8px 16px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      background-color: white;
      cursor: pointer;
      transition: all 0.2s;
    }

    .filter-btn.active {
      background-color: var(--primary);
      color: white;
      border-color: var(--primary);
    }

    .pagination {
      display: flex;
      justify-content: center;
      align-items: center;
      margin-top: 20px;
      gap: 10px;
    }

    .pagination button {
      padding: 8px 16px;
      border: 1px solid #e2e8f0;
      background-color: white;
      cursor: pointer;
      border-radius: 6px;
      transition: all 0.2s;
    }

    .pagination button:hover {
      background-color: #f8fafc;
    }

    .pagination button:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }

    .pagination span {
      padding: 8px 16px;
    }

    .modal {
      display: none;
      position: fixed;
      z-index: 1000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.5);
    }

    .modal-content {
      background-color: white;
      margin: 10% auto;
      padding: 20px;
      border-radius: 8px;
      max-width: 500px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }

    .modal-title {
      font-size: 18px;
      font-weight: 600;
    }

    .close-modal {
      background: none;
      border: none;
      font-size: 24px;
      cursor: pointer;
    }

    .form-group {
      margin-bottom: 15px;
    }

    .form-group label {
      display: block;
      margin-bottom: 5px;
      font-weight: 500;
      font-size: 14px;
    }

    .form-group input, .form-group select {
      width: 100%;
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
    }

    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      margin-top: 20px;
    }

    /* Mobile responsiveness */
    .mobile-top-bar {
      display: none;
      align-items: center;
      justify-content: space-between;
      background-color: var(--dark);
      color: white;
      padding: 15px;
      width: 100%;
    }

    .mobile-logo {
      display: flex;
      align-items: center;
    }

    .mobile-logo img {
      width: 40px;
      height: auto;
      margin-right: 10px;
      filter: invert(1) brightness(2);
    }

    .mobile-logo h2 {
      font-size: 18px;
      font-weight: 700;
    }

    .mobile-nav-toggle {
      display: none;
      background: none;
      border: none;
      color: white;
      font-size: 24px;
      cursor: pointer;
      padding: 10px;
    }

    @media (max-width: 768px) {
      .dashboard {
        flex-direction: column;
      }

      .sidebar {
        width: 100%;
        position: fixed;
        top: 60px;
        left: -100%;
        height: calc(100% - 60px);
        z-index: 100;
        transition: left 0.3s ease;
      }

      .sidebar.active {
        left: 0;
      }

      .mobile-top-bar {
        display: flex;
        position: fixed;
        top: 0;
        left: 0;
        z-index: 101;
      }

      .mobile-nav-toggle {
        display: block;
      }

      .main-content {
        margin-top: 60px;
        padding: 15px;
      }

      .search-filter-container {
        flex-direction: column;
        gap: 10px;
        align-items: flex-start;
      }

      .filter-buttons {
        width: 100%;
        overflow-x: auto;
        padding-bottom: 5px;
      }

      .search-container {
        width: 100%;
      }

      .search-input {
        flex-grow: 1;
        min-width: unset;
      }

      table {
        display: block;
        overflow-x: auto;
        white-space: nowrap;
      }

      .module-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
      }

      .header {
        flex-direction: column;
        align-items: flex-start;
        gap: 15px;
      }
    }

    .footer {
      margin-top: 30px;
      text-align: center;
      font-size: 14px;
      color: var(--secondary);
      padding: 20px 0;
    }
  </style>
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
        <h1 class="page-title">User Management</h1>
        <div class="user-profile">
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Stats Cards -->
      <div class="stats-container">
        <div class="stat-card">
          <h3>TOTAL USERS</h3>
          <div class="value">124</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            10 more than last month
          </div>
        </div>
        
        <div class="stat-card">
          <h3>NEW USERS</h3>
          <div class="value">15</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            8 more than last month
          </div>
        </div>
        
        <div class="stat-card">
          <h3>ACTIVE USERS</h3>
          <div class="value">99</div>
          <div class="trend down">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            5 less than last month
          </div>
        </div>
      </div>
      
      <!-- User Management Table Module -->
      <div class="module-card">
        <div class="module-header">
          <div>User List</div>
          <button class="btn btn-add" onclick="openAddUserModal()">
            + Add New User
          </button>
        </div>
        <div class="module-content">
          <!-- Search and Filter Controls -->
          <div class="search-filter-container">
            <div class="search-container">
              <input type="text" class="search-input" id="searchInput" placeholder="Search users...">
              <button class="btn btn-primary">Search</button>
            </div>
            <div class="filter-buttons">
              <button class="filter-btn active" onclick="filterUsers('All')">All</button>
              <button class="filter-btn" onclick="filterUsers('Admin')">Admin</button>
              <button class="filter-btn" onclick="filterUsers('Cashier')">Cashier</button>
              <button class="filter-btn" onclick="filterUsers('Supplier')">Supplier</button>
            </div>
          </div>
          
          <!-- Users Table -->
          <table id="usersTable">
            <thead>
              <tr>
                <th>User ID</th>
                <th>First Name</th>
                <th>Last Name</th>
                <th>Username</th>
                <th>Email</th>
                <th>Role</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>001</td>
                <td>john_doe</td>
                <td>john</td>
                <td>doe</td>
                <td>john.doe@example.com</td>
                <td>Admin</td>
                <td><span class="status active">Active</span></td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-primary" onclick="editUser(1)">Edit</button>
                    <button class="btn btn-danger" onclick="deleteUser(1)">Delete</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>002</td>
                <td>john</td>
                <td>doe</td>
                <td>emma_wilson</td>
                <td>emma.wilson@example.com</td>
                <td>Cashier</td>
                <td><span class="status active">Active</span></td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-primary" onclick="editUser(2)">Edit</button>
                    <button class="btn btn-danger" onclick="deleteUser(2)">Delete</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>003</td>
                <td>john</td>
                <td>doe</td>
                <td>michael_brown</td>
                <td>michael.brown@example.com</td>
                <td>Cashier</td>
                <td><span class="status active">Active</span></td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-primary" onclick="editUser(3)">Edit</button>
                    <button class="btn btn-danger" onclick="deleteUser(3)">Delete</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>004</td>
                <td>john</td>
                <td>doe</td>
                <td>sarah_johnson</td>
                <td>sarah.johnson@example.com</td>
                <td>Cashier</td>
                <td><span class="status break">Break</span></td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-primary" onclick="editUser(4)">Edit</button>
                    <button class="btn btn-danger" onclick="deleteUser(4)">Delete</button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>005</td>
                <td>john</td>
                <td>doe</td>
                <td>global_coffee</td>
                <td>contact@globalcoffee.com</td>
                <td>Supplier</td>
                <td><span class="status active">Active</span></td>
                <td>
                  <div class="action-buttons">
                    <button class="btn btn-primary" onclick="editUser(5)">Edit</button>
                    <button class="btn btn-danger" onclick="deleteUser(5)">Delete</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
          
          <!-- Pagination -->
          <div class="pagination">
            <button id="prevBtn" disabled>&lt; Previous</button>
            <span>Page 1 of 3</span>
            <button id="nextBtn">Next &gt;</button>
          </div>
        </div>
      </div>
      
      <div class="footer">
        Swift © 2025
      </div>
    </div>
  </div>
  
  <!-- Add User Modal -->
  <div id="addUserModal" class="modal">
    <div class="modal-content">
      <div class="modal-header">
        <h2 class="modal-title">Add New User</h2>
        <button class="close-modal" onclick="closeAddUserModal()">&times;</button>
      </div>
      <form id="addUserForm">
        <div class="form-group">
          <label for="firstname">First Name</label>
          <input type="text" id="firstname" name="firstname" required>
        </div>
        <div class="form-group">
          <label for="lastname"> Last Name</label>
          <input type="text" id="lastname" name="lastname" required>
        </div>
        <div class="form-group">
          <label for="username">Username</label>
          <input type="text" id="username" name="username" required>
        </div>
        <div class="form-group">
          <label for="email">Email</label>
          <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
          <label for="role">Role</label>
          <select id="role" name="role" required>
            <option value="Admin">Admin</option>
            <option value="Cashier">Cashier</option>
            <option value="Supplier">Supplier</option>
          </select>
        </div>
        <div class="form-group">
          <label for="status">Status</label>
          <select id="status" name="status" required>
            <option value="Active">Active</option>
            <option value="Break">Break</option>
            <option value="Inactive">Inactive</option>
          </select>
        </div>
        <div class="form-actions">
          <button type="button" class="btn" onclick="closeAddUserModal()">Cancel</button>
          <button type="submit" class="btn btn-primary">Add User</button>
        </div>
      </form>
    </div>
  </div>
  
  <!-- Edit User Modal -->
  <div id="editUserModal" class="modal">
    <div class="modal-content">
      <div class="modal-header">
        <h2 class="modal-title">Edit User</h2>
        <button class="close-modal" onclick="closeEditUserModal()">&times;</button>
      </div>
      <form id="editUserForm">
        <input type="hidden" id="editUserId" name="userId">
        <div class="form-group">
          <label for="editfirstname">First Name</label>
          <input type="text" id="editfirstname" name="firstname" required>
        </div>
        <div class="form-group">
          <label for="editlastname"> Last Name</label>
          <input type="text" id="editlastname" name="lastname" required>
        </div>
        <div class="form-group">
          <label for="editUsername">Username</label>
          <input type="text" id="editUsername" name="username" required>
        </div>
        <div class="form-group">
          <label for="editEmail">Email</label>
          <input type="email" id="editEmail" name="email" required>
        </div>
        <div class="form-group">
          <label for="editRole">Role</label>
          <select id="editRole" name="role" required>
            <option value="Admin">Admin</option>
            <option value="Cashier">Cashier</option>
            <option value="Supplier">Supplier</option>
          </select>
        </div>
        <div class="form-group">
          <label for="editStatus">Status</label>
          <select id="editStatus" name="status" required>
            <option value="Active">Active</option>
            <option value="Break">Break</option>
            <option value="Inactive">Inactive</option>
          </select>
        </div>
        <div class="form-actions">
          <button type="button" class="btn" onclick="closeEditUserModal()">Cancel</button>
          <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
      </form>
    </div>
  </div>

  <script>
    // Mobile navigation toggle
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    // Modal functions
    function openAddUserModal() {
      document.getElementById('addUserModal').style.display = 'block';
    }
    
    function closeAddUserModal() {
      document.getElementById('addUserModal').style.display = 'none';
    }
    
    function openEditUserModal(userId, username, email, role, status) {
      document.getElementById('editUserId').value = userId;
      document.getElementById('editUsername').value = username;
      document.getElementById('editEmail').value = email;
      document.getElementById('editRole').value = role;
      document.getElementById('editStatus').value = status;
      document.getElementById('editUserModal').style.display = 'block';
    }
    
    function closeEditUserModal() {
      document.getElementById('editUserModal').style.display = 'none';
    }
    
    // User actions
    function editUser(userId) {
      // In a real application, you would fetch user data from the server
      // For demonstration, we'll use hardcoded values based on userId
      const userData = {
        1: { username: 'john_doe', email: 'john.doe@example.com', role: 'Admin', status: 'Active' },
        2: { username: 'emma_wilson', email: 'emma.wilson@example.com', role: 'Cashier', status: 'Active' },
        3: { username: 'michael_brown', email: 'michael.brown@example.com', role: 'Cashier', status: 'Active' },
        4: { username: 'sarah_johnson', email: 'sarah.johnson@example.com', role: 'Cashier', status: 'Break' },
        5: { username: 'global_coffee', email: 'contact@globalcoffee.com', role: 'Supplier', status: 'Active' }
      };
      
      const user = userData[userId];
      openEditUserModal(userId, user.username, user.email, user.role, user.status);
    }
    
    function deleteUser(userId) {
      if (confirm('Are you sure you want to delete this user?')) {
        // In a real application, you would send a delete request to the server
        console.log('Deleting user with ID:', userId);
        // For demonstration, we'll just show an alert
        alert('User deleted successfully!');
      }
    }
    
    // Filter users by role
    function filterUsers(role) {
      console.log('Filtering by role:', role);
      // Update active state on filter buttons
      document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
      });
      event.target.classList.add('active');
      
      // In a real application, you would filter the table or request filtered data from the server
    }
    
    // Form submissions
    document.getElementById('addUserForm').addEventListener('submit', function(e) {
      e.preventDefault();
      // In a real application, you would send form data to the server
      console.log('Adding new user:', {
        username: document.getElementById('username').value,
        email: document.getElementById('email').value,
        role: document.getElementById('role').value,
        status: document.getElementById('status').value
      });
      alert('User added successfully!');
      closeAddUserModal();
    });
    
    document.getElementById('editUserForm').addEventListener('submit', function(e) {
      e.preventDefault();
      // In a real application, you would send form data to the server
      console.log('Updating user:', {
        userId: document.getElementById('editUserId').value,
        username: document.getElementById('editUsername').value,
        email: document.getElementById('editEmail').value,
        role: document.getElementById('editRole').value,
        status: document.getElementById('editStatus').value
      });
      alert('User updated successfully!');
      closeEditUserModal();
    });
    
    // Close modals when clicking outside of the modal content
    window.addEventListener('click', function(event) {
      if (event.target === document.getElementById('addUserModal')) {
        closeAddUserModal();
      }
      if (event.target === document.getElementById('editUserModal')) {
        closeEditUserModal();
      }
    });
  </script>
</body>
</html>