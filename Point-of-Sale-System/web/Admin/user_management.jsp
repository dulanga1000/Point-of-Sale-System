<%--
    Document   : user_management
    Created on : May 9, 2025, 1:16:48 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>User Management</title>
  <link rel="stylesheet" href="styles.css"/>
  <style>
.module-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
}

.module-header button {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 5px;
}

.search-filter-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 15px;
}

.search-container {
  display: flex;
  gap: 10px;
  flex: 1;
  max-width: 400px;
}

.search-input {
  padding: 10px 12px;
  border: 1px solid #e2e8f0;
  border-radius: 4px;
  flex: 1;
  font-size: 14px;
}

.filter-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-btn {
  padding: 8px 16px;
  background-color: #f1f5f9;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.filter-btn:hover {
  background-color: #e2e8f0;
}

.filter-btn.active {
  background-color: var(--primary);
  color: white;
}

/* User List Table */
#usersTable {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

#usersTable th {
  background-color: #f8fafc;
  padding: 12px 15px;
  text-align: left;
  font-weight: 600;
  color: var(--secondary);
  border-bottom: 2px solid #e2e8f0;
}

#usersTable td {
  padding: 12px 15px;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: middle; /* <<< MODIFIED: Align content vertically */
}

#usersTable tr:hover {
  background-color: #f8fafc;
}

/* <<< NEW: Style for user profile images in the table >>> */
.user-table-profile-img {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    object-fit: cover;
    border: 1px solid #e2e8f0;
}
.user-table-profile-img-placeholder {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background-color: #e2e8f0; /* Placeholder background */
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    color: var(--secondary);
    border: 1px solid #cbd5e1;
    text-transform: uppercase;
}


.action-buttons {
  display: flex;
  gap: 8px;
}

.action-buttons button {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
}

.btn-primary {
  background-color: var(--primary);
  color: white;
}

.btn-primary:hover {
  background-color: var(--primary-dark);
}

.btn-danger {
  background-color: var(--danger);
  color: white;
}

.btn-danger:hover {
  opacity: 0.9;
}

.status {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status.active {
  background-color: #d1fae5;
  color: #065f46;
}

.status.break {
  background-color: #fef3c7;
  color: #92400e;
}

.status.inactive {
  background-color: #fee2e2;
  color: #991b1b;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 20px;
}

.pagination button {
  padding: 8px 16px;
  background-color: var(--primary);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.pagination button:disabled {
  background-color: #cbd5e1;
  cursor: not-allowed;
}

.pagination span {
  font-size: 14px;
  color: var(--secondary);
}

/* Modal Animations */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideIn {
  from { transform: translateY(-50px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.modal {
  animation: fadeIn 0.3s ease-out;
}

.modal-content {
  animation: slideIn 0.3s ease-out;
}

/* Notification styling */
.notification {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 15px 20px;
  border-radius: 6px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  animation: slideInFromRight 0.3s ease-out, fadeOut 0.5s ease-in 4.5s forwards;
  max-width: 350px;
}

@keyframes slideInFromRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@keyframes fadeOut {
  from { opacity: 1; }
  to { opacity: 0; }
}

.success-notification {
  background-color: #d1fae5;
  color: #065f46;
  border-left: 4px solid #10b981;
}

.error-notification {
  background-color: #fee2e2;
  color: #991b1b;
  border-left: 4px solid #ef4444;
}

/* Responsive design for mobile */
@media (max-width: 768px) {
  .search-filter-container {
    flex-direction: column;
    align-items: stretch;
  }

  .search-container {
    max-width: 100%;
  }

  .filter-buttons {
    overflow-x: auto;
    white-space: nowrap;
    padding-bottom: 10px;
    justify-content: flex-start;
  }

  .module-header {
    flex-direction: column;
    gap: 10px;
    align-items: flex-start;
  }

  .action-buttons {
    flex-direction: column;
    gap: 5px;
  }

  .action-buttons button {
    width: 100%;
  }
}

/* Add this to make the modal look better on small screens */
@media (max-width: 600px) {
  .modal-content {
    width: 95%;
    margin: 5% auto;
  }

  .form-actions {
    flex-direction: column;
  }

  .form-actions button {
    width: 100%;
  }
}

/* <<< MODIFIED: Image Upload specific styles for modals >>> */
.image-upload-container {
    text-align: center;
    margin-bottom: 15px;
}
.image-upload-label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
    color: var(--dark);
}
.image-upload-container input[type="file"] {
    display: none; /* Hide the default file input */
}
.upload-btn {
    display: inline-block;
    padding: 8px 16px;
    background-color: var(--primary);
    color: white;
    border-radius: 4px;
    cursor: pointer;
    margin-bottom: 10px;
    transition: background-color 0.2s;
}
.upload-btn:hover {
    background-color: var(--primary-dark);
}
.image-preview {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    object-fit: cover;
    display: block; 
    margin: 10px auto;
    border: 3px solid #e2e8f0;
    background-color: #f8fafc; 
}
.image-preview[src="#"], .image-preview:not([src]) { 
    display: none;
}
.image-preview-placeholder {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    background-color: #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px; /* Larger font for initials */
    color: var(--secondary);
    margin: 10px auto;
    border: 3px solid #cbd5e1;
    text-transform: uppercase;
}
  </style>
</head>
<body>
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle">☰</button>
  </div>

  <div class="dashboard">
    <div class="sidebar" id="sidebar">
      <div class="logo">
        <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
        <h2>Swift</h2>
      </div>
      <jsp:include page="menu.jsp" />
    </div>

    <div class="main-content">
      <div class="header">
        <h1 class="page-title">User Management</h1>
        <div class="user-profile">
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile">
          <div><h4>Admin User</h4></div>
        </div>
      </div>

      <%
          String successMessage = (String) session.getAttribute("userActionSuccess");
          String errorMessage = (String) session.getAttribute("userActionError");
          if (successMessage != null) {
      %>
          <div class="server-notification success-server-notification">
              <%= successMessage %>
          </div>
      <%
          session.removeAttribute("userActionSuccess");
          }
          if (errorMessage != null) {
      %>
          <div class="server-notification error-server-notification">
              <%= errorMessage %>
          </div>
      <%
          session.removeAttribute("userActionError");
          }
      %>

      <div class="stats-container">
        <div class="stat-card">
          <h3>TOTAL USERS</h3> <div class="value" id="totalUsers">0</div>
          <div class="trend up"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg> <span id="totalUsersTrendText">...</span></div>
        </div>
        <div class="stat-card">
          <h3>NEW USERS</h3> <div class="value" id="newUsers">0</div>
          <div class="trend up"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg> <span id="newUsersTrendText">...</span></div>
        </div>
        <div class="stat-card">
          <h3>ACTIVE USERS</h3> <div class="value" id="activeUsers">0</div>
          <div class="trend down"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg> <span id="activeUsersTrendText">...</span></div>
        </div>
      </div>

      <div class="module-card">
        <div class="module-header">
          <div>User List</div>
          <button class="btn btn-add" onclick="openAddUserModal()">+ Add New User</button>
        </div>
        <div class="module-content">
          <div class="search-filter-container">
            <div class="search-container">
              <input type="text" class="search-input" id="searchInput" placeholder="Search users..." onkeyup="handleSearchInput(event)">
              <button class="btn btn-primary" id="searchButton">Search</button>
            </div>
            <div class="filter-buttons">
              <button class="filter-btn active" onclick="filterUsers(this, 'All')">All</button>
              <button class="filter-btn" onclick="filterUsers(this, 'Admin')">Admin</button>
              <button class="filter-btn" onclick="filterUsers(this, 'Cashier')">Cashier</button>
              <button class="filter-btn" onclick="filterUsers(this, 'Supplier')">Supplier</button>
            </div>
          </div>
          <table id="usersTable">
            <thead><tr><th>Image</th><th>User ID</th><th>First Name</th><th>Last Name</th><th>Username</th><th>Email</th><th>Role</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody id="usersTbody"></tbody>
          </table>
          <div class="pagination">
            <button id="prevBtn" disabled>&lt; Previous</button>
            <span>Page 1 of 1</span>
            <button id="nextBtn" disabled>Next &gt;</button>
          </div>
        </div>
      </div>
      <div class="footer">Swift © 2025</div>
    </div>
  </div>

  <div id="addUserModal" class="modal">
    <div class="modal-content">
      <div class="modal-header"><h2 class="modal-title">Add New User</h2><button class="close-modal" onclick="closeAddUserModal()">&times;</button></div>
      <form id="addUserForm">
        <div class="image-upload-container">
          <label class="image-upload-label">Profile Image</label>
          <img id="addUserImagePreview" class="image-preview" src="#" alt="Preview">
          <div id="addUserImagePreviewPlaceholder" class="image-preview-placeholder">No Image</div>
          <input type="file" id="addUserFileInput" accept="image/*" onchange="previewModalImage(this, 'addUserImagePreview', 'addUserImagePreviewPlaceholder')">
          <label for="addUserFileInput" class="upload-btn">Choose Image</label>
        </div>
        <div class="form-group"><label for="addFirstName">First Name</label><input type="text" id="addFirstName" required></div>
        <div class="form-group"><label for="addLastName">Last Name</label><input type="text" id="addLastName" required></div>
        <div class="form-group"><label for="addUsername">Username</label><input type="text" id="addUsername" required></div>
        <div class="form-group"><label for="addEmail">Email</label><input type="email" id="addEmail" required></div>
        <div class="form-group"><label for="addPassword">Password</label><input type="password" id="addPassword" required><div id="addPasswordError" class="password-error"></div></div>
        <div class="form-group"><label for="addConfirmPassword">Confirm Password</label><input type="password" id="addConfirmPassword" required><div id="addConfirmPasswordError" class="password-error"></div></div>
        <div class="form-group"><label for="addRole">Role</label><select id="addRole" required><option value="Admin">Admin</option><option value="Cashier">Cashier</option><option value="Supplier">Supplier</option></select></div>
        <div class="form-group"><label for="addStatus">Status</label><select id="addStatus" required><option value="Active">Active</option><option value="Break">Break</option><option value="Inactive">Inactive</option></select></div>
        <div class="form-actions">
          <button type="button" class="btn" onclick="closeAddUserModal()">Cancel</button>
          <button type="button" class="btn btn-primary" onclick="submitAddUserForm()">Add User</button>
        </div>
      </form>
    </div>
  </div>

  <div id="editUserModal" class="modal">
    <div class="modal-content">
      <div class="modal-header"><h2 class="modal-title">Edit User</h2><button class="close-modal" onclick="closeEditUserModal()">&times;</button></div>
      <form id="editUserForm">
        <input type="hidden" id="editUserId" name="userId"> <input type="hidden" id="editUserInternalId" name="internalId"> <div class="image-upload-container">
          <label class="image-upload-label">Profile Image</label>
          <img id="editUserImagePreview" class="image-preview" src="#" alt="Current User Image">
          <div id="editUserImagePreviewPlaceholder" class="image-preview-placeholder">No Image</div>
          <input type="file" id="editUserFileInput" accept="image/*" onchange="previewModalImage(this, 'editUserImagePreview', 'editUserImagePreviewPlaceholder')">
          <label for="editUserFileInput" class="upload-btn">Change Image</label>
        </div>
        <div class="form-group"><label for="editFirstName">First Name</label><input type="text" id="editFirstName" required></div>
        <div class="form-group"><label for="editLastName">Last Name</label><input type="text" id="editLastName" required></div>
        <div class="form-group"><label for="editUsername">Username</label><input type="text" id="editUsername" required></div>
        <div class="form-group"><label for="editEmail">Email</label><input type="email" id="editEmail" required></div>
        <div class="form-group"><label for="editUserDisplayId">User Display ID</label><input type="text" id="editUserDisplayId" required></div>
        <hr><p style="margin:10px 0 5px 0; font-weight: bold;">Change Password (optional):</p>
        <div class="form-group">
          <label for="editNewPassword">New Password</label><input type="password" id="editNewPassword">
          <small>Leave blank to keep current password.</small><div id="editNewPasswordError" class="password-error"></div>
        </div>
        <div class="form-group">
          <label for="editConfirmNewPassword">Confirm New Password</label><input type="password" id="editConfirmNewPassword">
          <div id="editConfirmNewPasswordError" class="password-error"></div>
        </div>
        <hr style="margin-bottom: 15px;">
        <div class="form-group"><label for="editRole">Role</label><select id="editRole" required><option value="Admin">Admin</option><option value="Cashier">Cashier</option><option value="Supplier">Supplier</option></select></div>
        <div class="form-group"><label for="editStatus">Status</label><select id="editStatus" required><option value="Active">Active</option><option value="Break">Break</option><option value="Inactive">Inactive</option></select></div>
        <div class="form-actions">
          <button type="button" class="btn" onclick="closeEditUserModal()">Cancel</button>
          <button type="button" class="btn btn-primary" onclick="submitEditUserForm()">Save Changes</button>
        </div>
      </form>
    </div>
  </div>

  <script type="text/javascript">
      const APP_CONTEXT_PATH = "${pageContext.request.contextPath}";
      // This variable is now available for user_management.js
  </script>
  <script src="user_management.js"></script>
</body>
</html>