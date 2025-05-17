/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
// Mobile menu toggle functionality
document.addEventListener('DOMContentLoaded', function() {
  const mobileNavToggle = document.getElementById('mobileNavToggle');
  const sidebar = document.getElementById('sidebar');
  
  mobileNavToggle.addEventListener('click', function() {
    sidebar.classList.toggle('active');
    
    // Change toggle button text based on sidebar state
    if (sidebar.classList.contains('active')) {
      mobileNavToggle.textContent = '✕';
    } else {
      mobileNavToggle.textContent = '☰';
    }
  });
  
  // Close sidebar when clicking a menu item on mobile
  const menuItems = document.querySelectorAll('.menu-item');
  menuItems.forEach(item => {
    item.addEventListener('click', function() {
      if (window.innerWidth <= 768) {
        sidebar.classList.remove('active');
        mobileNavToggle.textContent = '☰';
      }
    });
  });
  
  // Handle window resize events
  window.addEventListener('resize', function() {
    if (window.innerWidth > 768) {
      sidebar.classList.remove('active');
    }
  });
});

