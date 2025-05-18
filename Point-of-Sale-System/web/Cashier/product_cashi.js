/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener('DOMContentLoaded', function() {
  // Get all product cards
  const productCards = Array.from(document.querySelectorAll('.product-card'));
  
  // Store original products for resetting filters
  const originalProducts = productCards.map(card => ({
    element: card,
    name: card.querySelector('.product-name').textContent.toLowerCase(),
    category: card.querySelector('.product-category').textContent.toLowerCase(),
    code: card.querySelector('.product-code').textContent.split(':')[1].trim().toLowerCase()
  }));

  // Mobile menu toggle
  document.getElementById('mobileNavToggle').addEventListener('click', function() {
    document.getElementById('sidebar').classList.toggle('active');
  });
  
  // Filter category selection
  document.querySelectorAll('.filter-category').forEach(item => {
    item.addEventListener('click', function() {
      document.querySelectorAll('.filter-category').forEach(el => {
        el.classList.remove('active');
      });
      this.classList.add('active');
      
      // Get the selected category
      const selectedCategory = this.textContent.trim().toLowerCase();
      
      // Filter products based on category
      filterProducts(selectedCategory, document.querySelector('.search-input').value.trim());
    });
  });
  
  // Search functionality
  document.querySelector('.search-btn').addEventListener('click', function() {
    const searchTerm = document.querySelector('.search-input').value.trim().toLowerCase();
    const activeCategory = document.querySelector('.filter-category.active').textContent.trim().toLowerCase();
    
    filterProducts(activeCategory, searchTerm);
  });
  
  // Search on Enter key press
  document.querySelector('.search-input').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      const searchTerm = this.value.trim().toLowerCase();
      const activeCategory = document.querySelector('.filter-category.active').textContent.trim().toLowerCase();
      
      filterProducts(activeCategory, searchTerm);
    }
  });
  
  // Quick view product on card click
  document.querySelectorAll('.product-card').forEach(card => {
    card.addEventListener('click', function() {
      const productName = this.querySelector('.product-name').textContent;
      // In a real implementation, you would show product details or add to cart
      console.log('Product selected:', productName);
    });
  });
  
  // Pagination
  document.querySelectorAll('.pagination-item').forEach(item => {
    item.addEventListener('click', function() {
      if (this.classList.contains('active')) return;
      
      document.querySelectorAll('.pagination-item').forEach(el => {
        el.classList.remove('active');
      });
      this.classList.add('active');
      
      // In a real implementation, you would load the appropriate page
      console.log('Page selected:', this.textContent);
    });
  });
  
  // Filter products based on category and search term
  function filterProducts(category, searchTerm) {
    const productsGrid = document.querySelector('.products-grid');
    
    // Clear current display
    productsGrid.innerHTML = '';
    
    // Filter logic
    const filteredProducts = originalProducts.filter(product => {
      // Check category filter (skip if "All Products" is selected)
      const categoryMatch = category === 'all products' || 
                          product.category === category;
      
      // Check search term (skip if empty)
      const searchMatch = !searchTerm || 
                         product.name.includes(searchTerm) || 
                         product.category.includes(searchTerm) || 
                         product.code.includes(searchTerm);
      
      return categoryMatch && searchMatch;
    });
    
    // Display filtered products
    if (filteredProducts.length > 0) {
      filteredProducts.forEach(product => {
        productsGrid.appendChild(product.element);
      });
    } else {
      // Show no results message
      productsGrid.innerHTML = `
        <div class="no-results" style="grid-column: 1/-1; text-align: center; padding: 40px;">
          <i class="fas fa-search" style="font-size: 48px; color: var(--gray); margin-bottom: 15px;"></i>
          <h3 style="color: var(--dark);">No products found</h3>
          <p style="color: var(--gray);">Try adjusting your search or filter criteria</p>
        </div>
      `;
    }
  }
  
  // Initialize with all products showing <script src="product_cashi.js"></script>
  filterProducts('all products', '');
});
async function updateCashierInfo() {
  try {
    // This URL is an API endpoint you create on your server
    const response = await fetch('/api/get-cashier-details');
    const data = await response.json();

    document.getElementById('cashier-name').textContent = data.name;
    document.getElementById('cashier-role').textContent = data.role;
  } catch (error) {
    console.error("Error fetching cashier details:", error);
    // Handle error, maybe show default text
  }
}

// Call this function when the page loads
document.addEventListener('DOMContentLoaded', updateCashierInfo);



