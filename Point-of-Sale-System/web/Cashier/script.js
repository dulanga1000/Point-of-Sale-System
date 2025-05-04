/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log("DOM Loaded - Setting up listeners..."); // Log setup start

    // --- Modal Elements ---
    const paymentModal = document.getElementById('paymentModal');
    const receiptModal = document.getElementById('receiptModal');
    const checkoutBtn = document.getElementById('checkoutBtn');
    const closeModalBtns = document.querySelectorAll('.close-modal');
    const cancelPaymentBtn = paymentModal?.querySelector('.cancel-btn');
    const confirmPaymentBtn = paymentModal?.querySelector('.confirm-btn');
    const closeReceiptModalBtn = document.getElementById('closeReceiptModal');

    // --- Payment Method Elements ---
    const paymentOptions = paymentModal?.querySelectorAll('.payment-option');
    const paymentForms = paymentModal?.querySelectorAll('.payment-form');
    const cashForm = paymentModal?.querySelector('.cash-form');
    const cardForm = paymentModal?.querySelector('.card-form');
    const digitalForm = paymentModal?.querySelector('.digital-form');

    // --- Card Form Inputs ---
    const cardNumberInput = document.getElementById('cardNumber');
    const expiryDateInput = document.getElementById('expiryDate');
    const cvvCodeInput = document.getElementById('cvvCode');
    const cardHolderNameInput = document.getElementById('cardHolderName');

    // --- Product & Cart Elements ---
    const productGrid = document.querySelector('.product-grid');
    const cartItemsContainer = document.querySelector('.cart-items');
    const cartSummary = document.querySelector('.cart-summary');
    const clearCartBtn = document.querySelector('.clear-cart-btn');

    // --- Cart Summary Display & Input Elements ---
    const cartSubtotalSpan = document.getElementById('cartSubtotal');
    const cartDiscountInput = document.getElementById('cartDiscount'); // MODIFIED: Now for percentage
    const cartTaxRateInput = document.getElementById('cartTaxRate');
    const cartTaxAmountSpan = document.getElementById('cartTaxAmount');
    const cartTotalSpan = document.getElementById('cartTotal');
    const paymentModalTotalH4 = document.getElementById('paymentModalTotal');

    // --- Cash Payment Elements ---
    const cashAmountInput = document.getElementById('cashAmount');
    const changeAmountDisplayDiv = document.getElementById('changeAmountDisplay');

    // --- Receipt Elements ---
    const receiptNumberSpan = document.getElementById('receiptNumber');
    const receiptDateSpan = document.getElementById('receiptDate');
    const receiptItemsContainer = receiptModal?.querySelector('.receipt-items');
    const receiptSummaryContainer = receiptModal?.querySelector('.receipt-summary');
    const receiptSubtotalSpan = document.getElementById('receiptSubtotal');
    const receiptDiscountSpan = document.getElementById('receiptDiscount');
    const receiptTaxSpan = document.getElementById('receiptTax');
    const receiptTotalSpan = document.getElementById('receiptTotal');


    // --- Mobile Navigation ---
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');

    // --- Helper Functions ---
    const openModal = (modal) => {
        if (modal) modal.style.display = 'flex';
    };

    const closeModal = (modal) => {
        if (modal) modal.style.display = 'none';
    };

    const parsePrice = (priceString) => {
        if (typeof priceString !== 'string') return 0;
        return parseFloat(priceString.replace(/[^0-9.]/g, '')) || 0;
    };

    const formatCurrency = (number) => {
        if (typeof number !== 'number' || isNaN(number)) {
            number = 0;
        }
        return `$${number.toFixed(2)}`;
    };

    // --- Function to update cart totals (MODIFIED: Now uses % discount) ---
    const updateCartTotals = () => {
        console.log("Updating cart totals...");
        let subtotal = 0;
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];

        currentCartItems.forEach(item => {
            const priceElement = item.querySelector('.item-price');
            const quantityElement = item.querySelector('.quantity');

            if (priceElement && quantityElement) {
                const price = parsePrice(priceElement.textContent);
                const quantity = parseInt(quantityElement.textContent) || 1;
                subtotal += price * quantity;
            }
        });

        // Get Discount and Tax Rate from inputs (MODIFIED for % discount)
        let discountRatePercent = cartDiscountInput?.value === '' ? 0 : parseFloat(cartDiscountInput?.value) || 0;
        const taxRatePercent = cartTaxRateInput?.value === '' ? 0 : parseFloat(cartTaxRateInput?.value) || 0;

        // Validate discount percentage (cannot be negative or more than 100%)
        if (discountRatePercent < 0) discountRatePercent = 0;
        if (discountRatePercent > 100) discountRatePercent = 100;
        // Only update the input field if validation changed the value
        if(cartDiscountInput && parseFloat(cartDiscountInput.value) !== discountRatePercent && cartDiscountInput.value !== '') {
           cartDiscountInput.value = discountRatePercent.toFixed(1);
        }

        // Calculate discount amount from percentage
        const discountRateDecimal = discountRatePercent / 100;
        const discountAmount = subtotal * discountRateDecimal;
        
        const subtotalAfterDiscount = subtotal - discountAmount;
        const taxRateDecimal = taxRatePercent / 100;
        const taxAmount = subtotalAfterDiscount * taxRateDecimal;
        const total = subtotalAfterDiscount + taxAmount;

        // Update cart summary display
        if (cartSubtotalSpan) cartSubtotalSpan.textContent = formatCurrency(subtotal);
        // Update discount amount display
        const cartDiscountAmount = document.getElementById('cartDiscountAmount');
        if (cartDiscountAmount) {
            if (cartDiscountInput?.value === '') {
                cartDiscountAmount.textContent = '$0.00';
            } else {
                cartDiscountAmount.textContent = `${formatCurrency(discountAmount)} (${discountRatePercent}%)`;
            }
        }
        // Update tax and total
        if (cartTaxAmountSpan) {
            if (cartTaxRateInput?.value === '') {
                cartTaxAmountSpan.textContent = '$0.00';
            } else {
                cartTaxAmountSpan.textContent = `${formatCurrency(taxAmount)} (${taxRatePercent}%)`;
            }
        }
        if (cartTotalSpan) cartTotalSpan.textContent = formatCurrency(total);

        // Update payment modal total
        if (paymentModalTotalH4) paymentModalTotalH4.textContent = `Total Amount: ${formatCurrency(total)}`;

        // Update cash change dynamically if cash form is active
        if (cashForm?.classList.contains('active') && cashAmountInput) {
           updateChange();
        }
    };

    // --- Function to add/update item in cart ---
    const addOrUpdateCartItem = (productCard) => {
        const productNameElement = productCard.querySelector('.product-name');
        const productPriceElement = productCard.querySelector('.product-price');
        const productIconElement = productCard.querySelector('.product-icon i');

        if (!productNameElement || !productPriceElement || !productIconElement) {
             console.error("Product card is missing required elements (name, price, or icon).");
             return;
        }

        const productName = productNameElement.textContent;
        const productPrice = productPriceElement.textContent;
        const productIconClass = productIconElement.className;

        console.log(`Attempting to add/update: ${productName}`);

        // Stock Check (Simplified - assumes stock info is reliable)
        const stockInfoElement = productCard.querySelector('.stock-info span');
        let stockAvailable = true;
        if (stockInfoElement && stockInfoElement.textContent.toLowerCase().includes('out of stock')) {
            stockAvailable = false;
        }
         const lowStockMatch = stockInfoElement?.textContent.match(/low stock \((\d+)\)/i);
         if (lowStockMatch && parseInt(lowStockMatch[1]) <= 0) {
             stockAvailable = false;
         }

        if (!stockAvailable) {
             alert(`${productName} is currently out of stock.`);
             console.log(`Stock unavailable for ${productName}`);
             return;
        }

        let existingCartItem = null;
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];
        currentCartItems.forEach(item => {
            const cartItemNameElement = item.querySelector('.item-info h4');
            if (cartItemNameElement && cartItemNameElement.textContent === productName) {
                existingCartItem = item;
            }
        });

        if (existingCartItem) {
            console.log(`Item "${productName}" exists, increasing quantity.`);
            const quantitySpan = existingCartItem.querySelector('.quantity');
            if (quantitySpan) {
                 let quantity = parseInt(quantitySpan.textContent) || 0;
                 quantitySpan.textContent = quantity;
            } else {
                 console.error("Could not find quantity span for existing item:", productName);
            }
        } else {
             console.log(`Item "${productName}" is new, creating cart entry.`);
            const newItem = document.createElement('div');
            newItem.classList.add('cart-item');
            newItem.setAttribute('data-product-name', productName);
            newItem.innerHTML = `
                <div class="item-details">
                    <div class="item-image">
                        <i class="${productIconClass}"></i>
                    </div>
                    <div class="item-info">
                        <h4>${productName}</h4>
                        <p>${productPrice}</p> </div>
                </div>
                <div class="item-controls">
                    <div class="quantity-control">
                        <button type="button" class="quantity-btn decrease-btn" data-action="decrease">
                            <i class="fas fa-minus"></i>
                        </button>
                        <span class="quantity">1</span>
                        <button type="button" class="quantity-btn increase-btn" data-action="increase">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>
                    <div class="item-price" style="display: none;">${productPrice}</div>
                    <button type="button" class="remove-item-btn" style="color: red; background: none; border: none; font-size: 1em; cursor: pointer; margin-left: 10px;">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            `;

            if (cartItemsContainer) {
                const emptyCartMsg = cartItemsContainer.querySelector('p');
                if(emptyCartMsg && emptyCartMsg.textContent.includes("Cart is empty")) {
                    emptyCartMsg.remove();
                }
                cartItemsContainer.appendChild(newItem);

                // Add direct event listeners to the buttons
                const increaseBtn = newItem.querySelector('.increase-btn');
                const decreaseBtn = newItem.querySelector('.decrease-btn');
                const removeBtn = newItem.querySelector('.remove-item-btn');

                if (increaseBtn) {
                    increaseBtn.onclick = (e) => {
                        e.stopPropagation();
                        const quantitySpan = newItem.querySelector('.quantity');
                        if (quantitySpan) {
                            let quantity = parseInt(quantitySpan.textContent) || 0;
                            quantitySpan.textContent = quantity + 1;
                            updateCartTotals();
                        }
                    };
                }

                if (decreaseBtn) {
                    decreaseBtn.onclick = (e) => {
                        e.stopPropagation();
                        const quantitySpan = newItem.querySelector('.quantity');
                        if (quantitySpan) {
                            let quantity = parseInt(quantitySpan.textContent) || 0;
                            if (quantity > 1) {
                                quantitySpan.textContent = quantity - 1;
                                updateCartTotals();
                            } else {
                                removeCartItem(newItem, true);
                            }
                        }
                    };
                }

                if (removeBtn) {
                    removeBtn.onclick = (e) => {
                        e.stopPropagation();
                        removeCartItem(newItem, true);
                    };
                }
            } else {
                 console.error("cartItemsContainer not found. Cannot add new item.");
            }
        }

        updateCartTotals();
    };

    // --- Remove Cart Item Function ---
    const removeCartItem = (cartItem, confirmFirst = false) => {
        let removeItem = true;
        if (confirmFirst) {
            removeItem = confirm("Remove this item from the cart?");
        }
        if (removeItem && cartItem) {
            cartItem.remove();
            updateCartTotals();
            // Check if cart is now empty
            if (cartItemsContainer && cartItemsContainer.children.length === 0) {
                 cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
            }
        }
    }

    // --- Update Clear Cart Button ---
    if (clearCartBtn && cartItemsContainer) {
        clearCartBtn.addEventListener('click', () => {
            if (cartItemsContainer.children.length > 0 && !cartItemsContainer.querySelector('p')?.textContent.includes("Cart is empty")) {
                cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                // Reset discount and tax inputs
                if(cartDiscountInput) cartDiscountInput.value = '';
                if(cartTaxRateInput) cartTaxRateInput.value = '';
                updateCartTotals(); // Reset summary totals
            }
        });
    }

    // --- Event Listener for Product Clicks ---
    if (productGrid) {
        console.log("Adding product grid click listener.");
        productGrid.addEventListener('click', (event) => {
            console.log("Product grid clicked!");
            const clickedCard = event.target.closest('.product-card');
            if (clickedCard) {
                console.log("Clicked on a product card.");
                addOrUpdateCartItem(clickedCard);
            }
        });
    } else {
         console.error("Product grid element not found!");
    }

    // --- Event Listener for Cart Item Actions (Event Delegation on Container) ---
    if (cartItemsContainer) {
        cartItemsContainer.addEventListener('click', (event) => {
            event.stopPropagation(); // Stop event from bubbling up
            const cartItem = event.target.closest('.cart-item');
            if (!cartItem) return; // Exit if click wasn't within a cart item

            const increaseBtn = event.target.closest('.quantity-btn[data-action="increase"]');
            const decreaseBtn = event.target.closest('.quantity-btn[data-action="decrease"]');
            const removeBtn = event.target.closest('.remove-item-btn');

            if (increaseBtn) {
                event.preventDefault(); // Prevent default behavior
                increaseQuantity(cartItem);
            } else if (decreaseBtn) {
                event.preventDefault(); // Prevent default behavior
                decreaseQuantity(cartItem);
            } else if (removeBtn) {
                event.preventDefault(); // Prevent default behavior
                removeCartItem(cartItem, true); // Confirm removal
            }
        });
    }


    // --- Event Listeners for Discount and Tax Inputs ---
    if (cartDiscountInput) {
        cartDiscountInput.addEventListener('input', updateCartTotals);
    }
    if (cartTaxRateInput) {
        cartTaxRateInput.addEventListener('input', updateCartTotals);
    }


    // --- Event Listeners (Modal Handling, Payment Switching) ---

    // 1. Open Payment Modal
    if (checkoutBtn && cartItemsContainer) {
        checkoutBtn.addEventListener('click', () => {
             if (!cartItemsContainer.querySelector('.cart-item')) { // Check if any cart item exists
                 // Create error message element
                 const errorMessage = document.createElement('div');
                 errorMessage.className = 'cart-error-message';
                 errorMessage.innerHTML = `
                     <div class="error-content">
                         <i class="fas fa-exclamation-circle"></i>
                         <p>Cart is empty. Please add products before checking out.</p>
                     </div>
                 `;
                 
                 // Remove any existing error message
                 const existingError = cartItemsContainer.querySelector('.cart-error-message');
                 if (existingError) existingError.remove();
                 
                 // Add the error message to cart container
                 cartItemsContainer.appendChild(errorMessage);
                 
                 // Auto-remove the message after 3 seconds
                 setTimeout(() => {
                     if (errorMessage && errorMessage.parentNode === cartItemsContainer) {
                         errorMessage.remove();
                         // If cart is still empty, show the default empty message
                         if (!cartItemsContainer.querySelector('.cart-item')) {
                             cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                         }
                     }
                 }, 3000);
                 
                 return;
             }

             updateCartTotals(); // Ensure totals are current before opening
             openModal(paymentModal);
             // Default to cash
             paymentOptions?.forEach(opt => opt.classList.remove('active'));
             paymentForms?.forEach(form => form.classList.remove('active'));
             paymentModal?.querySelector('.payment-option[data-method="cash"]')?.classList.add('active');
             if (cashForm) cashForm.classList.add('active');
             updateChange(); // Calculate initial change based on current total
        });
    }

    // 2. Close Modals
    closeModalBtns.forEach(btn => {
        btn.addEventListener('click', () => {
             const modalToClose = btn.closest('.modal');
            closeModal(modalToClose);
        });
    });

    if (cancelPaymentBtn) {
        cancelPaymentBtn.addEventListener('click', () => closeModal(paymentModal));
    }

    // 3. Switch Payment Methods
    paymentOptions?.forEach(option => {
        option.addEventListener('click', () => {
            const selectedMethod = option.getAttribute('data-method');
            paymentOptions.forEach(opt => opt.classList.remove('active'));
            option.classList.add('active');
            paymentForms?.forEach(form => form.classList.remove('active'));
            const correspondingForm = paymentModal?.querySelector(`.payment-form.${selectedMethod}-form`);
            if (correspondingForm) {
                correspondingForm.classList.add('active');
            }
             if (selectedMethod === 'cash') {
                 updateChange(); // Recalculate change when switching to cash
             }
        });
    });

     // --- Calculate Change for Cash (Uses cartTotalSpan now) ---
     const updateChange = () => {
         if (!cartTotalSpan || !cashAmountInput || !changeAmountDisplayDiv) return;

         const totalText = cartTotalSpan.textContent;
         const totalAmount = parsePrice(totalText); // Use the final total
         const cashReceived = parseFloat(cashAmountInput.value) || 0;
         const changeDue = cashReceived - totalAmount;

         if (changeDue >= 0) {
            changeAmountDisplayDiv.textContent = formatCurrency(changeDue);
            changeAmountDisplayDiv.style.color = ''; // Reset color
         } else {
            // Show negative change or amount pending
            changeAmountDisplayDiv.textContent = `(${formatCurrency(Math.abs(changeDue))})`; // Indicate amount short
            changeAmountDisplayDiv.style.color = 'red'; // Highlight shortage
         }
     };

     if (cashAmountInput) {
         cashAmountInput.addEventListener('input', updateChange);
     }


    // 4. Handle Confirm Payment Button Click
    if (confirmPaymentBtn && paymentModal && cartTotalSpan) {
        confirmPaymentBtn.addEventListener('click', () => {
            const activeOption = paymentModal.querySelector('.payment-option.active');
            const selectedMethod = activeOption ? activeOption.getAttribute('data-method') : null;

            if (!selectedMethod) { alert("Please select a payment method."); return; }

            console.log(`Attempting payment via: ${selectedMethod}`);

             const totalText = cartTotalSpan.textContent; // Get final total
             const totalAmount = parsePrice(totalText);
              if (totalAmount <= 0) { alert("Cannot process payment for zero or negative total."); return;}


            let paymentSuccessful = false;

            if (selectedMethod === 'card') {
                const cardNumber = cardNumberInput?.value.trim() ?? '';
                const expiryDate = expiryDateInput?.value.trim() ?? '';
                const cvv = cvvCodeInput?.value.trim() ?? '';
                const cardHolderName = cardHolderNameInput?.value.trim() ?? '';
                let isValid = true;
                let errorMessage = "Please correct the following errors:\n";

                if(cardNumberInput) cardNumberInput.style.borderColor = '';
                if(expiryDateInput) expiryDateInput.style.borderColor = '';
                if(cvvCodeInput) cvvCodeInput.style.borderColor = '';
                if(cardHolderNameInput) cardHolderNameInput.style.borderColor = '';

                if (cardNumber.length < 13 || cardNumber.length > 19 || !/^\d+$/.test(cardNumber.replace(/\s/g, ''))) { isValid = false; errorMessage += "- Invalid card number format.\n"; if(cardNumberInput) cardNumberInput.style.borderColor = 'red'; }
                if (!/^\d{2}\/\d{2}$/.test(expiryDate)) { isValid = false; errorMessage += "- Invalid expiry date format (MM/YY).\n"; if(expiryDateInput) expiryDateInput.style.borderColor = 'red'; }
                // Basic CVV check (length only)
                if (cvv.length < 3 || cvv.length > 4 || !/^\d+$/.test(cvv)) { isValid = false; errorMessage += "- Invalid CVV format (3 or 4 digits).\n"; if(cvvCodeInput) cvvCodeInput.style.borderColor = 'red'; }
                if (cardHolderName === '') { isValid = false; errorMessage += "- Cardholder name cannot be empty.\n"; if(cardHolderNameInput) cardHolderNameInput.style.borderColor = 'red'; }

                if (!isValid) { alert(errorMessage); return; }

                console.log("Simulating successful card payment...");
                paymentSuccessful = true;

            } else if (selectedMethod === 'cash') {
                if (!cashAmountInput) { console.error("Cash amount input not found."); return; }
                const cashReceived = parseFloat(cashAmountInput.value) || 0;
                 if (cashReceived < totalAmount) {
                     alert(`Cash received (${formatCurrency(cashReceived)}) is less than the total amount (${formatCurrency(totalAmount)}). Please collect the correct amount.`);
                     if(cashAmountInput) cashAmountInput.style.borderColor = 'red'; // Highlight input
                     return; // Prevent proceeding
                 }
                 if(cashAmountInput) cashAmountInput.style.borderColor = ''; // Reset border on success
                 console.log("Processing cash payment...");
                 paymentSuccessful = true;

            } else if (selectedMethod === 'digital') {
                 console.log("Simulating successful digital payment check...");
                 paymentSuccessful = true; // Assume success for simulation
            }

             if (paymentSuccessful) {
                 closeModal(paymentModal);
                 updateReceiptDetails(selectedMethod); // Update receipt content
                 openModal(receiptModal);
                 // Clear cart after successful checkout
                 if (clearCartBtn) clearCartBtn.click(); // Simulate click to clear cart and reset inputs
                 // Reset payment forms
                 if (cashAmountInput) cashAmountInput.value = '';
                 if (changeAmountDisplayDiv) changeAmountDisplayDiv.textContent = '$0.00';
                 if(cardNumberInput) cardNumberInput.value = '';
                 if(expiryDateInput) expiryDateInput.value = '';
                 if(cvvCodeInput) cvvCodeInput.value = '';
                 if(cardHolderNameInput) cardHolderNameInput.value = '';
             } else {
                  console.log("Payment simulation failed or method not handled.");
             }
        });
    }

    // 5. Close Receipt Modal specifically
     if (closeReceiptModalBtn) {
        closeReceiptModalBtn.addEventListener('click', () => closeModal(receiptModal));
     }

     // --- Function to Update Receipt Modal Content (MODIFIED: Now uses % discount) ---
     function updateReceiptDetails(paymentMethod) {
         // Fix: Removed reference to nonexistent receiptDetailsContainer
         if (!receiptModal || !cartItemsContainer || !receiptSummaryContainer || !receiptItemsContainer) {
             console.error("Cannot update receipt: Required modal or container elements missing.");
             return;
         }

         const currentCartItems = cartItemsContainer.querySelectorAll('.cart-item');

         // Update Date/Time & Receipt Number
          const now = new Date();
         if (receiptDateSpan) { receiptDateSpan.textContent = now.toLocaleString('en-US', { month: 'long', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit', hour12: true }); }
         if (receiptNumberSpan) { receiptNumberSpan.textContent = `INV-${now.toISOString().slice(0,10).replace(/-/g,'')}-${Math.floor(100 + Math.random()*900)}`; } // 3 digit random


         // Clear previous items
         receiptItemsContainer.querySelectorAll('.receipt-item:not(.receipt-item-header)').forEach(item => item.remove());

         // Add current items from cart
         currentCartItems.forEach(cartItem => {
             const nameElement = cartItem.querySelector('.item-info h4');
             const quantityElement = cartItem.querySelector('.quantity');
             const priceElement = cartItem.querySelector('.item-info p'); // Get price from visible info

             if (nameElement && quantityElement && priceElement) {
                 const name = nameElement.textContent;
                 const quantity = quantityElement.textContent;
                 const price = priceElement.textContent; // Price per item
                 const itemDiv = document.createElement('div');
                 itemDiv.classList.add('receipt-item');
                 // Adjust if you want total price (qty * price) here instead
                 itemDiv.innerHTML = `<span class="item-name">${name}</span><span class="item-qty">${quantity}</span><span class="item-price">${price}</span>`;
                 receiptItemsContainer.appendChild(itemDiv);
             }
         });

         // MODIFIED: Calculate discount amount from percent for receipt display
         const subtotal = parsePrice(cartSubtotalSpan?.textContent ?? '0');
         const discountPercent = parseFloat(cartDiscountInput?.value) || 0;
         const discountAmount = subtotal * (discountPercent / 100);
         
         // Update summary section from values
         if(receiptSubtotalSpan) receiptSubtotalSpan.textContent = formatCurrency(subtotal);
         if(receiptDiscountSpan) receiptDiscountSpan.textContent = `${formatCurrency(discountAmount)} (${discountPercent}%)`; // Show both amount and percentage
         if(receiptTaxSpan) receiptTaxSpan.textContent = `${cartTaxAmountSpan?.textContent.split(' (')[0]} (${cartTaxRateInput?.value}%)`; // Show both amount and percentage
         if(receiptTotalSpan) receiptTotalSpan.textContent = cartTotalSpan?.textContent ?? '$0.00';

         // Clear previous payment method details
         receiptSummaryContainer.querySelectorAll('.receipt-row.payment-method').forEach(row => row.remove());

         // Add payment method details based on the method used
         const paymentDetailsDiv = document.createElement('div'); // Container for payment info
         paymentDetailsDiv.classList.add('payment-details-section'); // Add a class for potential styling

         if (paymentMethod === 'cash' && cashAmountInput && changeAmountDisplayDiv) {
            const cashReceived = formatCurrency(parseFloat(cashAmountInput.value) || 0);
            const changeDue = changeAmountDisplayDiv.textContent; // Already formatted
            paymentDetailsDiv.innerHTML = `
                <div class="receipt-row payment-method"><span>Payment Method:</span><span>Cash</span></div>
                <div class="receipt-row payment-method"><span>Cash Received:</span><span>${cashReceived}</span></div>
                <div class="receipt-row payment-method"><span>Change:</span><span>${changeDue}</span></div>`;
         } else if (paymentMethod === 'card' && cardNumberInput) {
             const cardNumberShort = cardNumberInput.value.replace(/\s/g, '').slice(-4);
             paymentDetailsDiv.innerHTML = `
                <div class="receipt-row payment-method"><span>Payment Method:</span><span>Card</span></div>
                <div class="receipt-row payment-method"><span>Card Used:</span><span>**** **** **** ${cardNumberShort}</span></div>`;
         } else if (paymentMethod === 'digital') {
            paymentDetailsDiv.innerHTML = `<div class="receipt-row payment-method"><span>Payment Method:</span><span>Digital Payment</span></div>`;
         }

         // Append the payment details after the total row
         receiptSummaryContainer.appendChild(paymentDetailsDiv);
     }


    // --- Mobile Navigation Toggle ---
    if (mobileNavToggle && sidebar) {
        mobileNavToggle.addEventListener('click', () => {
            sidebar.classList.toggle('open');
            // Optionally close sidebar if user clicks outside of it on mobile
            document.addEventListener('click', (e) => {
                if (sidebar.classList.contains('open') && !sidebar.contains(e.target) && !mobileNavToggle.contains(e.target)) {
                    sidebar.classList.remove('open');
                }
            }, { once: true }); // Listener added only when sidebar is opened
        });
    }

    // --- Initial Setup ---
     if (cartItemsContainer && cartItemsContainer.children.length === 0) {
         // Initial empty message is already in the HTML
     }
    // Ensure discount and tax fields are empty on page load
    if(cartDiscountInput) cartDiscountInput.value = '';
    if(cartTaxRateInput) cartTaxRateInput.value = '';
    updateCartTotals(); // Calculate initial totals (will be 0 if cart empty)

    // Add styles for the error message
    const style = document.createElement('style');
    style.textContent = `
        .cart-error-message {
            background-color: #fff3f3;
            border: 1px solid #dc3545;
            border-radius: 4px;
            margin: 10px;
            padding: 15px;
            animation: fadeIn 0.3s ease-in;
        }

        .cart-error-message .error-content {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #dc3545;
        }

        .cart-error-message i {
            font-size: 1.2em;
        }

        .cart-error-message p {
            margin: 0;
            font-size: 1em;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    `;
    document.head.appendChild(style);

    console.log("Setup complete.");

});

