/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log("DOM Loaded - Setting up listeners...");

    // --- Modal Elements ---
    const paymentModal = document.getElementById('paymentModal');
    const checkoutBtn = document.getElementById('checkoutBtn');
    const closeModalBtns = document.querySelectorAll('.close-modal'); // Generic close buttons
    const cancelPaymentBtn = paymentModal?.querySelector('.cancel-btn');
    const confirmPaymentBtn = paymentModal?.querySelector('.confirm-btn');

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
    const cartDiscountInput = document.getElementById('cartDiscount');
    const cartDiscountAmountSpan = document.getElementById('cartDiscountAmount');
    const cartTaxRateInput = document.getElementById('cartTaxRate');
    const cartTaxAmountSpan = document.getElementById('cartTaxAmount');
    const cartTotalSpan = document.getElementById('cartTotal');
    const paymentModalTotalH4 = document.getElementById('paymentModalTotal');

    // --- Cash Payment Elements ---
    const cashAmountInput = document.getElementById('cashAmount');
    const changeAmountDisplayDiv = document.getElementById('changeAmountDisplay');

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
        // Handles currency symbols, commas etc.
        return parseFloat(priceString.replace(/[^0-9.]/g, '')) || 0;
    };

    const formatCurrency = (number) => {
        if (typeof number !== 'number' || isNaN(number)) {
            number = 0;
        }
        // Basic US Dollar format, adjust if needed for LKR or other
        return `$${number.toFixed(2)}`;
    };

    // --- Function to update cart totals ---
    const updateCartTotals = () => {
        console.log("Updating cart totals...");
        let subtotal = 0;
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];

        currentCartItems.forEach(item => {
            // Use the visible price <p> tag for calculation
            const priceElement = item.querySelector('.item-info p');
            const quantityElement = item.querySelector('.quantity');

            if (priceElement && quantityElement) {
                const price = parsePrice(priceElement.textContent);
                const quantity = parseInt(quantityElement.textContent, 10) || 1; // Added radix 10
                subtotal += price * quantity;
            } else {
                console.warn("Could not find price or quantity element for cart item:", item);
            }
        });

        // Get Discount and Tax Rate from inputs
        let discountRatePercent = cartDiscountInput?.value === '' ? 0 : parseFloat(cartDiscountInput?.value) || 0;
        const taxRatePercent = cartTaxRateInput?.value === '' ? 0 : parseFloat(cartTaxRateInput?.value) || 0;

        // Validate discount percentage
        if (discountRatePercent < 0) discountRatePercent = 0;
        if (discountRatePercent > 100) discountRatePercent = 100;
        if(cartDiscountInput && parseFloat(cartDiscountInput.value) !== discountRatePercent && cartDiscountInput.value !== '') {
           cartDiscountInput.value = discountRatePercent.toFixed(1); // Update input if validated
        }

        // Calculate amounts
        const discountRateDecimal = discountRatePercent / 100;
        const discountAmount = subtotal * discountRateDecimal;
        const subtotalAfterDiscount = subtotal - discountAmount;
        const taxRateDecimal = taxRatePercent / 100;
        const taxAmount = subtotalAfterDiscount * taxRateDecimal;
        const total = subtotalAfterDiscount + taxAmount;

        // Update cart summary display
        if (cartSubtotalSpan) cartSubtotalSpan.textContent = formatCurrency(subtotal);
        if (cartDiscountAmountSpan) {
             cartDiscountAmountSpan.textContent = `${formatCurrency(discountAmount)} (${discountRatePercent.toFixed(1)}%)`;
             if(discountRatePercent === 0) cartDiscountAmountSpan.textContent = '$0.00'; // Cleaner display for 0%
        }
        if (cartTaxAmountSpan) {
             cartTaxAmountSpan.textContent = `${formatCurrency(taxAmount)} (${taxRatePercent.toFixed(1)}%)`;
             if(taxRatePercent === 0) cartTaxAmountSpan.textContent = '$0.00'; // Cleaner display for 0%
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
        const stockInfoElement = productCard.querySelector('.stock-info span'); // Get stock element

        if (!productNameElement || !productPriceElement || !productIconElement || !stockInfoElement) {
             console.error("Product card is missing required elements (name, price, icon, or stock info).");
             return;
        }

        const productName = productNameElement.textContent;
        const productPrice = productPriceElement.textContent; // Price per item string (e.g., "$19.99")
        const productIconClass = productIconElement.className;

        console.log(`Attempting to add/update: ${productName}`);

        // --- STOCK CHECK ---
        let stockAvailableQuantity = 0;
        const stockText = stockInfoElement.textContent;
        // Try to extract the number in parentheses (e.g., "(45)")
        const stockMatch = stockText.match(/\((\d+)\)/);
        if (stockMatch && stockMatch[1]) {
            stockAvailableQuantity = parseInt(stockMatch[1], 10); // Get the number
        } else if (stockText.toLowerCase().includes('in stock') && !stockText.match(/\(/)) {
            // Assume high stock if it just says "In Stock" without a number (optional)
            stockAvailableQuantity = 999; // Or another large number
            console.warn(`Stock quantity not specified for ${productName}, assuming high stock.`);
        }

        console.log(`Parsed stock for ${productName}: ${stockAvailableQuantity}`);

        // Check if product is completely out of stock before proceeding
        if (stockAvailableQuantity <= 0) {
            alert(`${productName} is currently out of stock.`);
            console.log(`Stock unavailable for ${productName}`);
            return; // Stop if out of stock
        }
        // --- END STOCK CHECK ---


        let existingCartItem = null;
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];
        currentCartItems.forEach(item => {
            const cartItemNameElement = item.querySelector('.item-info h4');
            if (cartItemNameElement && cartItemNameElement.textContent === productName) {
                existingCartItem = item;
            }
        });

        if (existingCartItem) {
            console.log(`Item "${productName}" exists, attempting to increase quantity.`);
            // --- Check stock BEFORE increasing quantity of existing item ---
            const quantitySpan = existingCartItem.querySelector('.quantity');
            const currentCartQuantity = quantitySpan ? parseInt(quantitySpan.textContent, 10) : 0;

            if (currentCartQuantity >= stockAvailableQuantity) {
                alert(`Cannot add more ${productName}. Only ${stockAvailableQuantity} available in stock.`);
                console.log(`Stock limit reached for existing item ${productName}. Cart: ${currentCartQuantity}, Stock: ${stockAvailableQuantity}`);
                return; // Stop if adding one more would exceed stock
            }
            // --- End stock check for existing item ---

            // Find and click the increase button on the existing item
            const increaseBtn = existingCartItem.querySelector('.increase-btn');
            if (increaseBtn) {
                 increaseBtn.click(); // This will trigger increaseQuantity (which also checks stock)
            } else {
                 console.error("Could not find increase button for existing item:", productName);
            }
        } else {
            console.log(`Item "${productName}" is new, creating cart entry.`);
            const newItem = document.createElement('div');
            newItem.classList.add('cart-item');
            newItem.setAttribute('data-product-name', productName); // Useful for identification
            // Store the maximum available stock on the cart item itself
            newItem.setAttribute('data-stock-available', stockAvailableQuantity);

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
                    <button type="button" class="remove-item-btn" style="color: red; background: none; border: none; font-size: 1em; cursor: pointer; margin-left: 10px;">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            `;

            if (cartItemsContainer) {
                // Remove "Cart is empty" message if present
                const emptyCartMsg = cartItemsContainer.querySelector('p');
                if(emptyCartMsg && emptyCartMsg.textContent.includes("Cart is empty")) {
                    emptyCartMsg.remove();
                }
                cartItemsContainer.appendChild(newItem);

                // Add direct event listeners to the new item's buttons
                attachCartItemListeners(newItem);

            } else {
                console.error("cartItemsContainer not found. Cannot add new item.");
            }
            // Update totals after adding the new item
            updateCartTotals();
        }
        // No need to call updateCartTotals() again here if handled by increaseBtn.click() or after adding new item
    };

    // --- Helper function to attach listeners to cart item buttons ---
    const attachCartItemListeners = (cartItem) => {
        const increaseBtn = cartItem.querySelector('.increase-btn');
        const decreaseBtn = cartItem.querySelector('.decrease-btn');
        const removeBtn = cartItem.querySelector('.remove-item-btn');

        if (increaseBtn) {
            increaseBtn.onclick = (e) => {
                e.stopPropagation();
                increaseQuantity(cartItem);
            };
        }
        if (decreaseBtn) {
            decreaseBtn.onclick = (e) => {
                e.stopPropagation();
                decreaseQuantity(cartItem);
            };
        }
        if (removeBtn) {
            removeBtn.onclick = (e) => {
                e.stopPropagation();
                removeCartItem(cartItem, true); // Confirm before removing
            };
        }
    };


    // --- Helper functions for Quantity ---
    const increaseQuantity = (cartItem) => {
        const quantitySpan = cartItem.querySelector('.quantity');
        const productName = cartItem.querySelector('.item-info h4')?.textContent || 'Item';

        // --- STOCK CHECK BEFORE INCREASING ---
        const maxStock = parseInt(cartItem.getAttribute('data-stock-available') || '0', 10); // Read max stock from attribute
        const currentQuantity = quantitySpan ? parseInt(quantitySpan.textContent, 10) : 0;

        if (currentQuantity >= maxStock) {
            alert(`Cannot add more ${productName}. Only ${maxStock} available in stock.`);
            console.log(`Stock limit reached for ${productName}. Cart: ${currentQuantity}, Stock: ${maxStock}`);
            return; // Stop if already at max stock
        }
        // --- END STOCK CHECK ---

        if (quantitySpan) {
            let quantity = parseInt(quantitySpan.textContent, 10) || 0;
            quantitySpan.textContent = quantity + 1; // Increase quantity
            updateCartTotals(); // Update totals only if quantity was changed
        }
    };

    const decreaseQuantity = (cartItem) => {
        const quantitySpan = cartItem.querySelector('.quantity');
        if (quantitySpan) {
            let quantity = parseInt(quantitySpan.textContent, 10) || 0;
            if (quantity > 1) {
                quantitySpan.textContent = quantity - 1;
                updateCartTotals();
            } else {
                // If quantity is 1, clicking decrease should remove the item
                removeCartItem(cartItem, true); // Confirm removal
            }
        }
    };

    // --- Remove Cart Item Function ---
    const removeCartItem = (cartItem, confirmFirst = false) => {
        let removeItem = true;
        if (confirmFirst) {
            removeItem = confirm("Remove this item from the cart?");
        }
        if (removeItem && cartItem) {
            console.log("Removing item:", cartItem.getAttribute('data-product-name'));
            cartItem.remove();
            updateCartTotals();
            // Check if cart is now empty and display message
            if (cartItemsContainer && cartItemsContainer.children.length === 0) {
                 cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
            }
        }
    }

    // --- Update Clear Cart Button ---
    if (clearCartBtn && cartItemsContainer) {
        clearCartBtn.addEventListener('click', () => {
            if (cartItemsContainer.children.length > 0 && !cartItemsContainer.querySelector('p')?.textContent.includes("Cart is empty")) {
                if(confirm("Are you sure you want to clear the entire cart?")){
                    cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                    // Reset discount and tax inputs
                    if(cartDiscountInput) cartDiscountInput.value = '';
                    if(cartTaxRateInput) cartTaxRateInput.value = '';
                    updateCartTotals(); // Reset summary totals
                }
            }
        });
    }

    // --- Event Listener for Product Clicks ---
    if (productGrid) {
        console.log("Adding product grid click listener.");
        productGrid.addEventListener('click', (event) => {
            const clickedCard = event.target.closest('.product-card');
            if (clickedCard) {
                addOrUpdateCartItem(clickedCard);
            }
        });
    } else {
         console.error("Product grid element not found!");
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
             // Check if cart has items (ignore the "Cart is empty" p tag)
             if (!cartItemsContainer.querySelector('.cart-item')) {
                 // Display error message logic (keep existing)
                 const errorMessage = document.createElement('div');
                 errorMessage.className = 'cart-error-message';
                 errorMessage.innerHTML = `<div class="error-content"><i class="fas fa-exclamation-circle"></i><p>Cart is empty. Please add products before checking out.</p></div>`;
                 const existingError = cartItemsContainer.querySelector('.cart-error-message');
                 if (existingError) existingError.remove();
                 // Prepend error message for better visibility
                 cartItemsContainer.prepend(errorMessage);

                 // Ensure "Cart is empty" message remains or is re-added if needed
                 const hasEmptyMsg = cartItemsContainer.querySelector('p')?.textContent.includes("Cart is empty");

                 setTimeout(() => {
                     if (errorMessage.parentNode === cartItemsContainer) errorMessage.remove();
                     // Only add the "Cart is empty" message back if there are *still* no cart items
                     if (!cartItemsContainer.querySelector('.cart-item') && !hasEmptyMsg) {
                         cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                     } else if (!cartItemsContainer.querySelector('.cart-item') && hasEmptyMsg) {
                         // Ensure the empty message is visible if it was already there
                         const emptyMsgElement = cartItemsContainer.querySelector('p');
                         if (emptyMsgElement) emptyMsgElement.style.display = 'block';
                     }
                 }, 3000);
                 return; // Stop execution if cart is empty
             }

             updateCartTotals(); // Ensure totals are current before opening
             openModal(paymentModal);
             // Default to cash payment option active
             paymentOptions?.forEach(opt => opt.classList.remove('active'));
             paymentForms?.forEach(form => form.classList.remove('active'));
             paymentModal?.querySelector('.payment-option[data-method="cash"]')?.classList.add('active');
             if (cashForm) cashForm.classList.add('active');
             updateChange(); // Calculate initial change based on current total
        });
    }

    // 2. Close Payment Modal using its specific buttons
    closeModalBtns.forEach(btn => {
        // Only target close buttons within the payment modal
        if (btn.closest('#paymentModal')) {
             btn.addEventListener('click', () => {
                 const modalToClose = btn.closest('.modal');
                 closeModal(modalToClose);
             });
        }
    });
    if (cancelPaymentBtn) {
        cancelPaymentBtn.addEventListener('click', () => closeModal(paymentModal));
    }

    // 3. Switch Payment Methods
    paymentOptions?.forEach(option => {
        option.addEventListener('click', () => {
            const selectedMethod = option.getAttribute('data-method');
            // Update active states
            paymentOptions.forEach(opt => opt.classList.remove('active'));
            option.classList.add('active');
            paymentForms?.forEach(form => form.classList.remove('active'));
            const correspondingForm = paymentModal?.querySelector(`.payment-form.${selectedMethod}-form`);
            if (correspondingForm) {
                correspondingForm.classList.add('active');
            }
             // Recalculate change if switching to cash
             if (selectedMethod === 'cash') {
                 updateChange();
             }
        });
    });

    // --- Calculate Change for Cash ---
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
        cashAmountInput.addEventListener('input', updateChange); // Update change as user types
    }


    // 4. Handle Confirm Payment Button Click --> Triggers Form Submission
    if (confirmPaymentBtn && paymentModal && cartTotalSpan && cartItemsContainer) {
        confirmPaymentBtn.addEventListener('click', () => {
            const activeOption = paymentModal.querySelector('.payment-option.active');
            const selectedMethod = activeOption ? activeOption.getAttribute('data-method') : null;

            if (!selectedMethod) { alert("Please select a payment method."); return; }

            console.log(`Attempting payment via: ${selectedMethod}`);

            const totalText = cartTotalSpan.textContent;
            const totalAmount = parsePrice(totalText);
            if (totalAmount <= 0) { alert("Cannot process payment for zero or negative total."); return;}

            let paymentSuccessful = false;
            let cardLast4 = null; // To store card last 4 digits if applicable

            // --- Payment Method Validation ---
            if (selectedMethod === 'card') {
                // Card validation logic (keep existing)
                const cardNumber = cardNumberInput?.value.trim() ?? '';
                const expiryDate = expiryDateInput?.value.trim() ?? '';
                const cvv = cvvCodeInput?.value.trim() ?? '';
                const cardHolderName = cardHolderNameInput?.value.trim() ?? '';
                let isValid = true;
                let errorMessage = "Please correct the following card details errors:\n";
                [cardNumberInput, expiryDateInput, cvvCodeInput, cardHolderNameInput].forEach(el => { if(el) el.style.borderColor = ''; }); // Reset borders

                if (cardNumber.length < 13 || cardNumber.length > 19 || !/^\d+$/.test(cardNumber.replace(/\s/g, ''))) { isValid = false; errorMessage += "- Invalid card number format.\n"; if(cardNumberInput) cardNumberInput.style.borderColor = 'red'; }
                if (!/^\d{2}\/\d{2}$/.test(expiryDate)) { isValid = false; errorMessage += "- Invalid expiry date format (MM/YY).\n"; if(expiryDateInput) expiryDateInput.style.borderColor = 'red'; }
                if (cvv.length < 3 || cvv.length > 4 || !/^\d+$/.test(cvv)) { isValid = false; errorMessage += "- Invalid CVV format (3 or 4 digits).\n"; if(cvvCodeInput) cvvCodeInput.style.borderColor = 'red'; }
                if (cardHolderName === '') { isValid = false; errorMessage += "- Cardholder name cannot be empty.\n"; if(cardHolderNameInput) cardHolderNameInput.style.borderColor = 'red'; }

                if (!isValid) { alert(errorMessage); return; } // Stop if invalid

                console.log("Simulating successful card payment...");
                paymentSuccessful = true;
                cardLast4 = cardNumber.replace(/\s/g, '').slice(-4); // Store last 4

            } else if (selectedMethod === 'cash') {
                // Cash validation logic (keep existing)
                if (!cashAmountInput) { console.error("Cash amount input not found."); return; }
                const cashReceived = parseFloat(cashAmountInput.value) || 0;
                 if (cashReceived < totalAmount) {
                     alert(`Cash received (${formatCurrency(cashReceived)}) is less than the total amount (${formatCurrency(totalAmount)}). Please collect the correct amount.`);
                     if(cashAmountInput) cashAmountInput.style.borderColor = 'red';
                     return; // Stop if insufficient cash
                 }
                 if(cashAmountInput) cashAmountInput.style.borderColor = ''; // Reset border
                 console.log("Processing cash payment...");
                 paymentSuccessful = true;

            } else if (selectedMethod === 'digital') {
                 // No specific validation here for simulation
                 console.log("Simulating successful digital payment check...");
                 paymentSuccessful = true;
            }

             // --- If Payment Validation Passed: Create Form and Submit ---
             if (paymentSuccessful) {
                 console.log("Payment successful. Preparing data for receipt page...");
                 closeModal(paymentModal); // Close the payment modal

                 // 1. Gather Data for Receipt
                 const now = new Date();
                 const receiptNumber = `INV-${now.toISOString().slice(0,10).replace(/-/g,'')}-${Math.floor(100 + Math.random()*900)}`;
                 const receiptDate = now.toLocaleString('en-US', { month: 'long', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit', hour12: true });
                 const cashier = document.querySelector('.user-info h4')?.textContent || 'System'; // Get cashier name
                 const subtotal = cartSubtotalSpan?.textContent ?? '$0.00';
                 const discount = cartDiscountAmountSpan?.textContent ?? '$0.00 (0%)';
                 const tax = cartTaxAmountSpan?.textContent ?? '$0.00 (0%)';
                 const total = cartTotalSpan?.textContent ?? '$0.00';
                 const cashReceivedValue = (selectedMethod === 'cash' && cashAmountInput) ? formatCurrency(parseFloat(cashAmountInput.value) || 0) : null;
                 const changeDueValue = (selectedMethod === 'cash' && changeAmountDisplayDiv) ? changeAmountDisplayDiv.textContent : null;

                 // 2. Create Hidden Form
                 const form = document.createElement('form');
                 form.method = 'POST';
                 form.action = 'receipt.jsp'; // Target the receipt page
                 form.style.display = 'none';

                 // Helper to create hidden inputs
                 const createInput = (name, value) => {
                     if (value !== null && value !== undefined) { // Only add input if value exists
                         const input = document.createElement('input');
                         input.type = 'hidden';
                         input.name = name;
                         input.value = value;
                         form.appendChild(input);
                     }
                 };

                 // 3. Add Data to Form
                 createInput('receiptNumber', receiptNumber);
                 createInput('receiptDate', receiptDate);
                 createInput('cashier', cashier);
                 createInput('subtotal', subtotal);
                 createInput('discount', discount);
                 createInput('tax', tax);
                 createInput('total', total);
                 createInput('paymentMethod', selectedMethod);
                 if (cashReceivedValue) createInput('cashReceived', cashReceivedValue);
                 if (changeDueValue) createInput('changeDue', changeDueValue);
                 if (cardLast4) createInput('cardLast4', cardLast4);

                 // Add Cart Items
                 const currentCartItems = cartItemsContainer.querySelectorAll('.cart-item');
                 currentCartItems.forEach(item => {
                     const name = item.querySelector('.item-info h4')?.textContent;
                     const qty = item.querySelector('.quantity')?.textContent;
                     const price = item.querySelector('.item-info p')?.textContent; // Price per item string
                     if (name && qty && price) {
                         // Send item data as separate parameters (more robust for backend)
                         // Use indices or a counter if your backend expects arrays
                         // For simplicity here, we'll just repeat the names.
                         // A better approach might be JSON encoding the cart items.
                         createInput('itemName', name);
                         createInput('itemQty', qty);
                         createInput('itemPrice', price);
                     }
                 });

                 // 4. Append and Submit Form
                 document.body.appendChild(form);
                 console.log("Submitting form to receipt.jsp...");
                 form.submit(); // This navigates the browser to receipt.jsp

                 // 5. Clean up Dashboard (Clear cart, reset forms) - runs after submission starts
                 // Use timeout to ensure form submission has begun
                 setTimeout(() => {
                    console.log("Clearing dashboard state post-submission.");
                    // Click clear button if exists, otherwise manually clear
                    if (clearCartBtn && typeof clearCartBtn.click === 'function') {
                        // Temporarily remove confirmation for programmatic clearing
                        const originalConfirm = window.confirm;
                        window.confirm = () => true; // Auto-confirm
                        clearCartBtn.click();
                        window.confirm = originalConfirm; // Restore original confirm
                    } else if (cartItemsContainer) {
                        // Manual clear if button doesn't exist or click fails
                        cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                        if(cartDiscountInput) cartDiscountInput.value = '';
                        if(cartTaxRateInput) cartTaxRateInput.value = '';
                        updateCartTotals(); // Reset summary totals manually
                    }

                    // Reset payment form fields explicitly
                    if (cashAmountInput) cashAmountInput.value = '';
                    if (changeAmountDisplayDiv) { changeAmountDisplayDiv.textContent = '$0.00'; changeAmountDisplayDiv.style.color = '';}
                    if(cardNumberInput) { cardNumberInput.value = ''; cardNumberInput.style.borderColor = ''; }
                    if(expiryDateInput) { expiryDateInput.value = ''; expiryDateInput.style.borderColor = ''; }
                    if(cvvCodeInput) { cvvCodeInput.value = ''; cvvCodeInput.style.borderColor = ''; }
                    if(cardHolderNameInput) { cardHolderNameInput.value = ''; cardHolderNameInput.style.borderColor = ''; }
                    // Optionally remove the submitted form from the DOM
                    if (form.parentNode) form.remove();
                 }, 100); // Short delay

             } else {
                  console.log("Payment validation failed.");
                  // Keep the payment modal open or show specific error message
             }
        });
    }

    // --- Mobile Navigation Toggle ---
    if (mobileNavToggle && sidebar) {
        mobileNavToggle.addEventListener('click', (e) => {
            e.stopPropagation(); // Prevent triggering the document listener immediately
            sidebar.classList.toggle('open');

            // Add listener to close sidebar when clicking outside
            // Use a named function for easier removal
            function closeSidebarOnClickOutside(event) {
                if (sidebar.classList.contains('open') && !sidebar.contains(event.target) && !mobileNavToggle.contains(event.target)) {
                    sidebar.classList.remove('open');
                    document.removeEventListener('click', closeSidebarOnClickOutside); // Remove listener
                }
                // If sidebar closed via toggle or clicking inside, remove the listener
                else if (!sidebar.classList.contains('open')) {
                    document.removeEventListener('click', closeSidebarOnClickOutside);
                }
            }

            // Add the listener only when the sidebar is opened
            if (sidebar.classList.contains('open')) {
                // Use setTimeout to add the listener after the current click event bubble phase
                setTimeout(() => {
                    document.addEventListener('click', closeSidebarOnClickOutside);
                }, 0);
            } else {
                // If sidebar is closed by the toggle, ensure listener is removed
                document.removeEventListener('click', closeSidebarOnClickOutside);
            }
        });
    }

    // --- Initial Setup ---
    if (cartItemsContainer && !cartItemsContainer.querySelector('.cart-item')) {
        // Ensure "Cart is empty" message is present if no items
        cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
    }
    // Attach listeners to any items potentially loaded server-side (if any)
    cartItemsContainer?.querySelectorAll('.cart-item').forEach(item => attachCartItemListeners(item));

    // Ensure discount and tax fields are empty on page load
    if(cartDiscountInput) cartDiscountInput.value = '';
    if(cartTaxRateInput) cartTaxRateInput.value = '';
    updateCartTotals(); // Calculate initial totals (should be 0)

    // --- Add styles for the cart error message ---
    const style = document.createElement('style');
    style.textContent = `
        .cart-error-message { background-color: #fff3f3; border: 1px solid #dc3545; border-radius: 4px; margin: 10px 0; /* Adjusted margin */ padding: 15px; animation: fadeIn 0.3s ease-in; order: -1; /* Place at the top */ }
        .cart-error-message .error-content { display: flex; align-items: center; gap: 10px; color: #dc3545; }
        .cart-error-message i { font-size: 1.2em; }
        .cart-error-message p { margin: 0; font-size: 1em; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }

        /* Style for stock info */
        .product-card .stock-info { margin-top: 5px; font-size: 0.9em; }
        .product-card .stock-info.low span { color: #ffc107; font-weight: bold; } /* Example: Yellow for low */
        .product-card .stock-info.out span { color: #dc3545; font-weight: bold; } /* Example: Red for out */
        .product-card .stock-info i { margin-right: 4px; }
        .product-card .stock-info .fa-check-circle { color: #28a745; } /* Green check */
        .product-card .stock-info .fa-exclamation-circle { color: #ffc107; } /* Yellow warning */
        .product-card .stock-info .fa-times-circle { color: #dc3545; } /* Red cross (optional) */

        /* Ensure cart container allows prepending */
        .cart-items { display: flex; flex-direction: column; }
    `;
    document.head.appendChild(style);

    console.log("Setup complete.");

});