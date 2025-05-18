/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
// Global Variables
let allUsers = []; // Initialize the array
let currentPage = 1;
let currentFilter = 'All';
const usersPerPage = 10;

// APP_CONTEXT_PATH is expected to be defined globally in the JSP by <script> const APP_CONTEXT_PATH = "..."; </script>
const DEFAULT_USER_IMAGE_PATH = (typeof APP_CONTEXT_PATH !== 'undefined' ? `${APP_CONTEXT_PATH}/Images/placeholder-user.png` : './Images/placeholder-user.png');

document.addEventListener('DOMContentLoaded', async function() {
    showSpinner(true);
    await fetchAllUsersFromServer(); // Fetch users on page load
    setupEventListeners();
    // displayUsers() and updateStats() will be called by fetchAllUsersFromServer on success
    showSpinner(false);

    // Clear server-sent session messages after a short delay
    setTimeout(() => {
        const serverNotifications = document.querySelectorAll('.server-notification');
        serverNotifications.forEach(notif => {
            // Optional: fade out before removing
            notif.style.opacity = '0';
            setTimeout(() => notif.style.display = 'none', 500);
        });
    }, 7000);
});

async function fetchAllUsersFromServer() {
    try {
        showSpinner(true);
        const response = await fetch(`${APP_CONTEXT_PATH}/userAction?action=listall`);
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Failed to fetch users: ${response.status} ${errorText}`);
        }
        const serverUsers = await response.json();
        
        allUsers = serverUsers.map(user => ({
            id: user.id, // Use the actual database ID directly
            dbId: user.id, // Keep dbId for backward compatibility
            userDisplayId: user.userDisplayId,
            firstName: user.firstName,
            lastName: user.lastName,
            username: user.username,
            email: user.email,
            image: user.profileImagePath ? `${APP_CONTEXT_PATH}/${user.profileImagePath}` : null,
            role: user.role,
            status: user.status
        }));

        console.log('Fetched users:', allUsers); // Debug log
        currentPage = 1;
        displayUsers();
        updateStats();

    } catch (error) {
        console.error('Error fetching users from server:', error);
        showJsNotification('Could not load user data from server. ' + error.message, 'error');
        allUsers = [];
        displayUsers();
        updateStats();
    } finally {
        showSpinner(false);
    }
}


function setupEventListeners() {
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');
    if (mobileNavToggle) mobileNavToggle.addEventListener('click', () => sidebar.classList.toggle('active'));

    const prevBtn = document.getElementById('prevBtn');
    if (prevBtn) prevBtn.addEventListener('click', () => changePage(-1));
    const nextBtn = document.getElementById('nextBtn');
    if (nextBtn) nextBtn.addEventListener('click', () => changePage(1));
    
    const searchButton = document.getElementById('searchButton');
    if (searchButton) searchButton.addEventListener('click', performSearch);

    ['addPassword', 'addConfirmPassword', 'editNewPassword', 'editConfirmNewPassword'].forEach(idPrefix => {
        const input = document.getElementById(idPrefix);
        if (input) {
            input.addEventListener('input', () => {
                // Clear error for the current input
                setPasswordError(idPrefix, ""); 
                // If it's a confirm field, also clear the main password field's error if it was about matching
                // Or if it's a main password field, clear the confirm field's error if it was about matching
                const confirmId = idPrefix.includes('Confirm') ? idPrefix.replace('Confirm', '') : idPrefix + 'Confirm';
                const errorElConfirm = document.getElementById(confirmId + "Error");
                if (errorElConfirm && errorElConfirm.textContent.toLowerCase().includes('match')) {
                    setPasswordError(confirmId, "");
                }
                 const errorElCurrent = document.getElementById(idPrefix + "Error");
                 if(errorElCurrent && errorElCurrent.textContent.toLowerCase().includes('match')){
                     const mainId = idPrefix.includes('Confirm') ? idPrefix.replace('Confirm','') : idPrefix;
                     setPasswordError(mainId,"");
                 }
            });
        }
    });
}

function changePage(direction) {
    const newPage = currentPage + direction;
    const totalFilteredUsers = getFilteredAndSearchedUsers(false).length; // Based on client-side filtered data
    const totalPages = Math.ceil(totalFilteredUsers / usersPerPage) || 1;
    if (newPage >= 1 && newPage <= totalPages) {
        currentPage = newPage;
        displayUsers(); // Re-render with new page from client-side data
    }
}


function previewModalImage(inputElement, previewElementId, placeholderElementId) {
    const previewImg = document.getElementById(previewElementId);
    const placeholderDiv = document.getElementById(placeholderElementId);
    const file = inputElement.files[0];

    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            if (previewImg) { previewImg.src = e.target.result; previewImg.style.display = 'block'; }
            if (placeholderDiv) placeholderDiv.style.display = 'none';
        };
        reader.readAsDataURL(file);
    } else {
        if (previewImg) { previewImg.src = '#'; previewImg.style.display = 'none'; }
        if (placeholderDiv) { placeholderDiv.style.display = 'flex'; placeholderDiv.textContent = "No Image"; }
    }
}

function getFilteredAndSearchedUsers(applyPagination = true) {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    let processedUsers = allUsers.filter(user => {
        const matchesFilter = (currentFilter === 'All' || user.role === currentFilter);
        const matchesSearch = !searchTerm || (
            (user.firstName && user.firstName.toLowerCase().includes(searchTerm)) ||
            (user.lastName && user.lastName.toLowerCase().includes(searchTerm)) ||
            (user.username && user.username.toLowerCase().includes(searchTerm)) ||
            (user.email && user.email.toLowerCase().includes(searchTerm)) ||
            (user.userDisplayId && user.userDisplayId.toLowerCase().includes(searchTerm))
        );
        return matchesFilter && matchesSearch;
    });
    if (applyPagination) {
        const start = (currentPage - 1) * usersPerPage;
        return processedUsers.slice(start, start + usersPerPage);
    }
    return processedUsers;
}

function displayUsers() {
    const usersToDisplay = getFilteredAndSearchedUsers(true);
    const allFilteredUsersCount = getFilteredAndSearchedUsers(false).length;
    const usersTbody = document.getElementById('usersTbody');
    usersTbody.innerHTML = '';

    if (usersToDisplay.length === 0) {
        const tr = usersTbody.insertRow();
        tr.insertCell().colSpan = 9;
        tr.cells[0].textContent = 'No users found.';
        tr.cells[0].style.textAlign = 'center';
    } else {
        usersToDisplay.forEach(user => {
            const tr = usersTbody.insertRow();
            tr.id = `user-row-${user.id}`; // Use the actual database ID

            const imgCell = tr.insertCell();
            let imageSrcToDisplay = DEFAULT_USER_IMAGE_PATH;
            if (user.image && user.image !== '#') {
                if (user.image.startsWith('data:image')) {
                    imageSrcToDisplay = user.image;
                } 
                else if (user.image.startsWith(APP_CONTEXT_PATH + '/uploads/')) {
                    imageSrcToDisplay = user.image;
                }
            }

            if (imageSrcToDisplay && imageSrcToDisplay !== DEFAULT_USER_IMAGE_PATH) {
                const img = document.createElement('img');
                img.src = imageSrcToDisplay;
                img.alt = `${user.firstName} ${user.lastName}`;
                img.className = 'user-table-profile-img';
                imgCell.appendChild(img);
            } else {
                const placeholder = document.createElement('div');
                placeholder.className = 'user-table-profile-img-placeholder';
                placeholder.textContent = (user.firstName && user.lastName) ? `${user.firstName.charAt(0)}${user.lastName.charAt(0)}` : '??';
                imgCell.appendChild(placeholder);
            }
            
            tr.insertCell().textContent = user.userDisplayId;
            tr.insertCell().textContent = user.firstName;
            tr.insertCell().textContent = user.lastName;
            tr.insertCell().textContent = user.username;
            tr.insertCell().textContent = user.email;
            tr.insertCell().textContent = user.role;
            tr.insertCell().innerHTML = `<span class="status ${user.status.toLowerCase()}">${user.status}</span>`;
            
            // Pass the actual database ID to the delete function
            tr.insertCell().innerHTML = `
                <div class="action-buttons">
                    <button class="btn btn-primary" onclick="openEditUserModal(${user.id})">Edit</button>
                    <button class="btn btn-danger" onclick="confirmDeleteUser(${user.id})">Delete</button>
                </div>`;
        });
    }
    updatePaginationControls(allFilteredUsersCount);
}

function updatePaginationControls(totalItems) {
    const totalPages = Math.ceil(totalItems / usersPerPage) || 1;
    document.getElementById('prevBtn').disabled = currentPage <= 1;
    document.getElementById('nextBtn').disabled = currentPage >= totalPages;
    document.querySelector('.pagination span').textContent = `Page ${currentPage} of ${totalPages}`;
}

function filterUsers(button, filter) { /* ... as before ... */
    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
    button.classList.add('active');
    currentFilter = filter;
    currentPage = 1;
    displayUsers();
}
function handleSearchInput(event) { if (event.key === 'Enter') performSearch(); }
function performSearch() { currentPage = 1; displayUsers(); }

function setPasswordError(elementId, message) { /* ... as before ... */
    const errorEl = document.getElementById(elementId + "Error");
    if (errorEl) { errorEl.textContent = message; errorEl.style.display = message ? 'block' : 'none'; }
}
function clearPasswordError(elementIdPrefix) { /* ... as before ... */
    setPasswordError(elementIdPrefix, "");
    const confirmId = elementIdPrefix.includes('Confirm') ? elementIdPrefix.replace('ConfirmPassword', 'Password') : elementIdPrefix + 'ConfirmPassword';
    const errorElTarget = document.getElementById(elementIdPrefix + "Error");
    const errorElConfirm = document.getElementById(confirmId.replace('NewP','ConfirmNewP').replace('addP','addConfirmP') + "Error");

    if (errorElTarget) setPasswordError(elementIdPrefix, "");
    if (errorElConfirm && errorElConfirm.textContent.toLowerCase().includes('match')) {
         setPasswordError(confirmId.replace('NewP','ConfirmNewP').replace('addP','addConfirmP'), "");
    }
}


// --- Modal Open/Close Functions ---
function openAddUserModal() { /* ... as before ... */
    document.getElementById('addUserForm').reset();
    const previewImg = document.getElementById('addUserImagePreview');
    const placeholderDiv = document.getElementById('addUserImagePreviewPlaceholder');
    if (previewImg) { previewImg.src = '#'; previewImg.style.display = 'none'; }
    if (placeholderDiv) { placeholderDiv.textContent = "No Image"; placeholderDiv.style.display = 'flex'; }
    document.getElementById('addUserFileInput').value = '';
    clearPasswordError('addPassword');
    clearPasswordError('addConfirmPassword');
    document.getElementById('addUserModal').style.display = 'block';
}
function closeAddUserModal() { document.getElementById('addUserModal').style.display = 'none'; }

function openEditUserModal(dbUserId) { // Now takes DB ID
    const user = allUsers.find(u => u.dbId === dbUserId); // Find user by DB ID
    if (!user) { console.error("User not found for edit (DB ID):", dbUserId); showJsNotification("User data not found to edit.", "error"); return; }

    document.getElementById('editUserForm').reset();
    document.getElementById('editUserId').value = user.dbId; // Store DB ID
    document.getElementById('editUserInternalId').value = user.id; // Client-side array ID, if still used

    document.getElementById('editFirstName').value = user.firstName;
    document.getElementById('editLastName').value = user.lastName;
    document.getElementById('editUsername').value = user.username;
    document.getElementById('editEmail').value = user.email;
    document.getElementById('editUserDisplayId').value = user.userDisplayId;
    document.getElementById('editRole').value = user.role;
    document.getElementById('editStatus').value = user.status;

    document.getElementById('editNewPassword').value = '';
    document.getElementById('editConfirmNewPassword').value = '';
    clearPasswordError('editNewPassword');
    clearPasswordError('editConfirmNewPassword');

    const imagePreview = document.getElementById('editUserImagePreview');
    const imagePlaceholder = document.getElementById('editUserImagePreviewPlaceholder');
    document.getElementById('editUserFileInput').value = '';
    
    let imageSrcToDisplay = DEFAULT_USER_IMAGE_PATH;
    if (user.image && user.image !== '#') { // user.image is server path or Base64 for new uploads
        imageSrcToDisplay = user.image.startsWith('data:image') ? user.image : user.image; // Already full path from server
    }

    if (imageSrcToDisplay && imageSrcToDisplay !== DEFAULT_USER_IMAGE_PATH) {
        imagePreview.src = imageSrcToDisplay;
        imagePreview.style.display = 'block';
        imagePlaceholder.style.display = 'none';
    } else {
        imagePreview.src = '#'; imagePreview.style.display = 'none';
        imagePlaceholder.textContent = (user.firstName && user.lastName) ? `${user.firstName.charAt(0)}${user.lastName.charAt(0)}` : "No Image";
        imagePlaceholder.style.display = 'flex';
    }
    document.getElementById('editUserModal').style.display = 'block';
}
function closeEditUserModal() { document.getElementById('editUserModal').style.display = 'none'; }

// --- AJAX Form Submission Functions (submit to server) ---
async function submitAddUserForm() {
    clearPasswordError('addPassword'); clearPasswordError('addConfirmPassword');
    let isValid = true;

    const firstName = document.getElementById('addFirstName').value.trim();
    const lastName = document.getElementById('addLastName').value.trim();
    const username = document.getElementById('addUsername').value.trim();
    const email = document.getElementById('addEmail').value.trim();
    const password = document.getElementById('addPassword').value;
    const confirmPassword = document.getElementById('addConfirmPassword').value;
    const role = document.getElementById('addRole').value;
    const status = document.getElementById('addStatus').value;
    
    // For User Display ID, it's best if the server generates this or it's manually entered and validated.
    // For this demo, let's assume it's entered or we generate a temporary one.
    // A proper system would require this in the form or generate it.
    // Let's make it a required field in the form for this example.
    const userDisplayIdInput = document.createElement('input'); // Temp for this example
    userDisplayIdInput.type = 'text';
    userDisplayIdInput.value = 'NEW' + String(Date.now()).slice(-4); // Example, should be a form field
    // Prompt or add a field for User Display ID in your Add User Modal HTML
    const userDisplayId = prompt("Enter User Display ID (e.g., EMP001):", userDisplayIdInput.value);
     if (!userDisplayId || userDisplayId.trim() === "") {
        alert("User Display ID is required.");
        return;
    }


    if (!firstName) { alert("First name is required."); isValid = false; }
    if (!lastName) { alert("Last name is required."); isValid = false; }
    if (!username) { alert("Username is required."); isValid = false; }
    if (!email || !/^\S+@\S+\.\S+$/.test(email)) { alert("Valid email is required."); isValid = false; }
    if (!password) { setPasswordError('addPassword', 'Password is required.'); isValid = false; }
    if (password && password.length < 6) { setPasswordError('addPassword', 'Password min 6 chars.'); isValid = false; }
    if (!confirmPassword) { setPasswordError('addConfirmPassword', 'Confirm password.'); isValid = false; }
    if (password && confirmPassword && password !== confirmPassword) {
        setPasswordError('addConfirmPassword', 'Passwords do not match.'); isValid = false;
    }
    if (!isValid) return;

    const formData = new FormData();
    formData.append('action', 'add');
    formData.append('userDisplayId', userDisplayId.trim());
    formData.append('firstName', firstName);
    formData.append('lastName', lastName);
    formData.append('username', username);
    formData.append('email', email);
    formData.append('password', password); // Send PLAIN password to server
    formData.append('confirmPassword', confirmPassword);
    formData.append('role', role);
    formData.append('status', status);

    const imagePreview = document.getElementById('addUserImagePreview');
    if (imagePreview.src && imagePreview.src !== '#' && imagePreview.src.startsWith('data:image')) {
        formData.append('imageBase64', imagePreview.src);
    }

    try {
        showSpinner(true);
        const response = await fetch(`${APP_CONTEXT_PATH}/userAction`, {
            method: 'POST',
            body: formData
        });
        // Server redirects, browser handles it. Page will reload.
        // Session messages on JSP will display success/error.
        if (response.redirected) { window.location.href = response.url; }
        else if(!response.ok) { // If server didn't redirect but sent an error status
            const errorText = await response.text();
            showJsNotification(`Error adding user: ${response.status} - ${errorText || 'Server error'}`, 'error');
        } else { // OK but not redirected (should not happen with current servlet logic)
            window.location.reload(); // Force reload to see changes
        }
    } catch (error) {
        console.error('Error submitting add form:', error);
        showJsNotification('Network error or server unavailable when adding user.', 'error');
    } finally {
        showSpinner(false);
        closeAddUserModal(); // Close modal regardless, page reload will refresh.
    }
}

async function submitEditUserForm() {
    clearPasswordError('editNewPassword'); clearPasswordError('editConfirmNewPassword');
    let isValid = true;

    const dbId = document.getElementById('editUserId').value;
    const userDisplayId = document.getElementById('editUserDisplayId').value.trim();
    const firstName = document.getElementById('editFirstName').value.trim();
    const lastName = document.getElementById('editLastName').value.trim();
    const username = document.getElementById('editUsername').value.trim();
    const email = document.getElementById('editEmail').value.trim();
    const role = document.getElementById('editRole').value;
    const status = document.getElementById('editStatus').value;
    const newPassword = document.getElementById('editNewPassword').value;
    const confirmNewPassword = document.getElementById('editConfirmNewPassword').value;

    if (!dbId) { alert("User ID missing for update."); return; }
    if (!firstName) { alert("First name required."); isValid = false; }
    if (!userDisplayId) { alert("User Display ID is required."); isValid = false; }


    if (newPassword || confirmNewPassword) {
        if (!newPassword) { setPasswordError('editNewPassword', 'New password required if changing.'); isValid = false; }
        if (newPassword && newPassword.length < 6) { setPasswordError('editNewPassword', 'Min 6 chars.'); isValid = false; }
        if (newPassword !== confirmNewPassword) {
            setPasswordError('editConfirmNewPassword', 'Passwords do not match.'); isValid = false;
        }
    }
    if (!isValid) return;

    const formData = new FormData();
    formData.append('action', 'update');
    formData.append('userId', dbId);
    formData.append('userDisplayId', userDisplayId);
    formData.append('firstName', firstName);
    formData.append('lastName', lastName);
    formData.append('username', username);
    formData.append('email', email);
    formData.append('role', role);
    formData.append('status', status);
    if (newPassword) {
        formData.append('newPassword', newPassword);
        formData.append('confirmNewPassword', confirmNewPassword);
    }

    const imagePreview = document.getElementById('editUserImagePreview');
    if (imagePreview.src && imagePreview.src !== '#' && imagePreview.src.startsWith('data:image')) {
        formData.append('imageBase64', imagePreview.src);
    }

    try {
        showSpinner(true);
        const response = await fetch(`${APP_CONTEXT_PATH}/userAction`, {
            method: 'POST',
            body: formData
        });
        if (response.redirected) { window.location.href = response.url; }
        else if(!response.ok) {
            const errorText = await response.text();
            showJsNotification(`Error updating user: ${response.status} - ${errorText || 'Server error'}`, 'error');
        } else {
             window.location.reload();
        }
    } catch (error) {
        console.error('Error submitting edit form:', error);
        showJsNotification('Network error during user update.', 'error');
    } finally {
        showSpinner(false);
        closeEditUserModal();
    }
}

async function confirmDeleteUser(userId) {
    console.log('Delete button clicked for user ID:', userId);
    console.log('Current allUsers array:', allUsers);
    
    // Find user by ID
    const user = allUsers.find(u => u.id === userId);
    console.log('Found user for deletion:', user);
    
    if (!user) { 
        console.error("User not found for delete:", userId);
        showJsNotification("User not found for deletion.", "error");
        return; 
    }
    
    if (confirm(`Are you sure you want to delete ${user.firstName} ${user.lastName} (ID: ${user.userDisplayId})? This action is permanent.`)) {
        console.log('Delete confirmed for user:', user);
        const formData = new FormData();
        formData.append('action', 'delete');
        formData.append('userId', userId);

        try {
            showSpinner(true);
            const url = `${APP_CONTEXT_PATH}/userAction`;
            console.log('Sending delete request to:', url);
            
            const response = await fetch(url, {
                method: 'POST',
                body: formData
            });
            
            console.log('Delete response status:', response.status);
            
            if (response.redirected) { 
                console.log('Response redirected to:', response.url);
                window.location.href = response.url; 
            }
            else if(!response.ok) {
                const errorText = await response.text();
                console.error('Delete failed:', response.status, errorText);
                showJsNotification(`Error deleting user: ${response.status} - ${errorText || 'Server error'}`, 'error');
            } else {
                console.log('Delete successful, reloading page');
                window.location.reload();
            }
        } catch (error) {
            console.error('Error during delete:', error);
            showJsNotification('Network error during user deletion.', 'error');
        } finally {
            showSpinner(false);
        }
    }
}

// --- Utility Functions ---
function updateStats() {
    const totalUsers = allUsers.length; // Now reflects server data count
    const activeUsers = allUsers.filter(u => u.status && u.status.toLowerCase() === 'active').length;
    document.getElementById('totalUsers').textContent = totalUsers;
    document.getElementById('activeUsers').textContent = activeUsers;
    // New users count would ideally come from server logic (e.g., users created in last 24h)
    // For now, it's a placeholder or could be removed if not meaningful client-side.
    document.getElementById('newUsers').textContent = "N/A"; // Or fetch this stat from server

    document.getElementById('totalUsersTrendText').textContent = `from DB`;
    document.getElementById('newUsersTrendText').textContent = `from DB`;
    document.getElementById('activeUsersTrendText').textContent = `from DB`;
}

function showJsNotification(message, type = 'success') { /* ... as before ... */
    const notificationArea = document.querySelector('.main-content');
    if (!notificationArea) { console.error("Notification area not found"); return; }
    const notification = document.createElement('div');
    notification.className = `notification ${type === 'success' ? 'success-notification' : 'error-notification'}`;
    notification.textContent = message;
    notification.style.position = 'fixed'; notification.style.top = '20px'; notification.style.right = '20px'; notification.style.zIndex = '1001';
    document.body.insertBefore(notification, document.body.firstChild);
    setTimeout(() => notification.remove(), 5000);
}

function showSpinner(show) { /* ... as before ... */
    let spinner = document.getElementById('loadingSpinner');
    if (show) {
        if (!spinner) {
            spinner = document.createElement('div'); spinner.id = 'loadingSpinner';
            spinner.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background-color:rgba(0,0,0,0.5);z-index:9999;display:flex;justify-content:center;align-items:center;';
            spinner.innerHTML = '<div style="color:white;font-size:20px;padding:20px;background:rgba(0,0,0,0.7);border-radius:5px;">Loading...</div>';
            document.body.appendChild(spinner);
        }
        spinner.style.display = 'flex';
    } else {
        if (spinner) spinner.style.display = 'none';
    }
}
// The CSS styles that were previously in JS should be kept in the JSP's <style> tag
// to avoid duplication and keep JS focused on behavior.
document.addEventListener('DOMContentLoaded', function() {
    // Add CSS for modals and other elements
    const style = document.createElement('style');
    style.textContent = `
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal-content {
            position: relative;
            background-color: #fff;
            margin: 10% auto;
            padding: 0;
            width: 50%;
            max-width: 500px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            animation: modalFade 0.3s ease-out forwards;
        }

        @keyframes modalFade {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            background-color: var(--primary);
            color: white;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
        }

        .close-modal {
            background: none;
            border: none;
            color: white;
            font-size: 24px;
            cursor: pointer;
        }

        form {
            padding: 20px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 4px;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
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

        .btn-add {
            background-color: var(--success);
            color: white;
        }

        /* Image Upload Styles */
        .image-upload-container {
            text-align: center;
            margin-bottom: 20px;
        }

        .image-upload-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }

        #fileInput {
            display: none;
        }

        .upload-btn {
            display: inline-block;
            padding: 8px 16px;
            background-color: var(--primary);
            color: white;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 10px;
        }

        .image-preview {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            display: none;
            margin: 0 auto;
            border: 3px solid #e2e8f0;
        }

        /* Status Styles */
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

        /* Search and Filter Styles */
        .search-filter-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .search-container {
            display: flex;
            gap: 10px;
        }

        .search-input {
            padding: 8px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 4px;
            width: 250px;
        }

        .filter-buttons {
            display: flex;
            gap: 10px;
        }

        .filter-btn {
            padding: 8px 16px;
            background-color: #f1f5f9;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
        }

        .filter-btn.active {
            background-color: var(--primary);
            color: white;
        }

        /* Responsive Styles */
        @media (max-width: 768px) {
            .search-filter-container {
                flex-direction: column;
                align-items: stretch;
            }

            .search-container {
                width: 100%;
            }

            .search-input {
                flex: 1;
            }

            .filter-buttons {
                width: 100%;
                overflow-x: auto;
                padding-bottom: 10px;
            }

            .modal-content {
                width: 90%;
                margin: 20% auto;
            }
        }
    `;
    document.head.appendChild(style);
});

