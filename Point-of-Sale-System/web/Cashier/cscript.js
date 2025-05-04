/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log("cscript.js: DOM Loaded - Setting up listeners...");

    // --- Get references to DOM Elements ---
    const paymentModal = document.getElementById('paymentModal');
    // const receiptModal = document.getElementById('receiptModal'); // No longer primary receipt display
    const checkoutBtn = document.getElementById('checkoutBtn');
    const closeModalBtns = document.querySelectorAll('.close-modal');
    const cancelPaymentBtn = paymentModal?.querySelector('.cancel-btn');
    const confirmPaymentBtn = paymentModal?.querySelector('.confirm-btn');
    // const closeReceiptModalBtn = document.getElementById('closeReceiptModal'); // Likely redundant
    const paymentOptions = paymentModal?.querySelectorAll('.payment-option');
    const paymentForms = paymentModal?.querySelectorAll('.payment-form');
    const cashForm = paymentModal?.querySelector('.cash-form');
    const cardForm = paymentModal?.querySelector('.card-form');
    const digitalForm = paymentModal?.querySelector('.digital-form');
    const cardNumberInput = document.getElementById('cardNumber');
    const expiryDateInput = document.getElementById('expiryDate');
    const cvvCodeInput = document.getElementById('cvvCode');
    const cardHolderNameInput = document.getElementById('cardHolderName');
    const productGrid = document.querySelector('.product-grid');
    const cartItemsContainer = document.querySelector('.cart-items');
    const cartSummary = document.querySelector('.cart-summary');
    const clearCartBtn = document.querySelector('.clear-cart-btn');
    const cartSubtotalSpan = document.getElementById('cartSubtotal');
    const cartDiscountInput = document.getElementById('cartDiscount');
    const cartDiscountAmountSpan = document.getElementById('cartDiscountAmount'); // Display calculated amount + %
    const cartTaxRateInput = document.getElementById('cartTaxRate');
    const cartTaxAmountSpan = document.getElementById('cartTaxAmount');
    const cartTotalSpan = document.getElementById('cartTotal');
    const paymentModalTotalH4 = document.getElementById('paymentModalTotal');
    const cashAmountInput = document.getElementById('cashAmount');
    const changeAmountDisplayDiv = document.getElementById('changeAmountDisplay');
    // Receipt modal elements are no longer directly manipulated by default flow
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');

    // --- Helper Functions ---
    const openModal = (modal) => { if (modal) modal.style.display = 'flex'; };
    const closeModal = (modal) => {
        if (modal) {
            modal.style.display = 'none';
            // Reset validation styles when closing payment modal
            if (modal.id === 'paymentModal') {
                resetCardValidationStyles();
                if (cashAmountInput) cashAmountInput.style.borderColor = '';
                if (changeAmountDisplayDiv) changeAmountDisplayDiv.style.color = ''; // Reset change color
            }
        }
    };
    const parsePrice = (priceString) => {
        if (typeof priceString !== 'string') return 0;
        return parseFloat(priceString.replace(/[^0-9.-]+/g, '')) || 0;
    };
    const formatCurrency = (number) => {
        if (typeof number !== 'number' || isNaN(number)) { number = 0; }
        // Using Intl.NumberFormat for potentially better localization (e.g., LKR)
        // Fallback to simple $ format if Intl fails or isn't configured
        try {
             // Adjust 'en-LK' and currency 'LKR' or keep 'en-US' / 'USD' as needed
             // return new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR' }).format(number);
             return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(number); // Sticking to USD for consistency with example
        } catch (e) {
             return `$${number.toFixed(2)}`; // Fallback
        }
    };
    const resetCardValidationStyles = () => {
        if (cardNumberInput) cardNumberInput.style.borderColor = '';
        if (expiryDateInput) expiryDateInput.style.borderColor = '';
        if (cvvCodeInput) cvvCodeInput.style.borderColor = '';
        if (cardHolderNameInput) cardHolderNameInput.style.borderColor = '';
    };

    // --- Function to update cart totals ---
    const updateCartTotals = () => {
        let subtotal = 0;
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];
        currentCartItems.forEach(item => {
            const priceElement = item.querySelector('.item-price'); // Hidden price
            const quantityElement = item.querySelector('.quantity');
            if (priceElement && quantityElement) {
                const price = parsePrice(priceElement.textContent);
                const quantity = parseInt(quantityElement.textContent) || 1;
                subtotal += price * quantity;
            }
        });

        let discountRatePercent = cartDiscountInput?.value === '' ? 0 : parseFloat(cartDiscountInput.value) || 0;
        let taxRatePercent = cartTaxRateInput?.value === '' ? 0 : parseFloat(cartTaxRateInput.value) || 0;

        // Validation (0-100 for discount, >=0 for tax)
        if (discountRatePercent < 0) discountRatePercent = 0;
        if (discountRatePercent > 100) discountRatePercent = 100;
        if (cartDiscountInput && cartDiscountInput.value !== '' && (parseFloat(cartDiscountInput.value) < 0 || parseFloat(cartDiscountInput.value) > 100)) {
            cartDiscountInput.value = discountRatePercent.toFixed(1);
        }
        if (taxRatePercent < 0) taxRatePercent = 0;
        if (cartTaxRateInput && cartTaxRateInput.value !== '' && parseFloat(cartTaxRateInput.value) < 0) {
            cartTaxRateInput.value = taxRatePercent.toFixed(1);
        }

        // Calculations
        const discountAmount = subtotal * (discountRatePercent / 100);
        const subtotalAfterDiscount = subtotal - discountAmount;
        const taxAmount = subtotalAfterDiscount * (taxRatePercent / 100);
        const total = subtotalAfterDiscount + taxAmount;

        // Update UI
        if (cartSubtotalSpan) cartSubtotalSpan.textContent = formatCurrency(subtotal);
        if (cartDiscountAmountSpan) {
            const discRate = cartDiscountInput ? parseFloat(cartDiscountInput.value) : 0;
            cartDiscountAmountSpan.textContent = (!isNaN(discRate) && discRate !== 0) ? `${formatCurrency(discountAmount)} (${discRate.toFixed(1)}%)` : formatCurrency(0);
        }
        if (cartTaxAmountSpan) {
            const taxRate = cartTaxRateInput ? parseFloat(cartTaxRateInput.value) : 0;
            cartTaxAmountSpan.textContent = (!isNaN(taxRate) && taxRate !== 0) ? `${formatCurrency(taxAmount)} (${taxRate.toFixed(1)}%)` : formatCurrency(0);
        }
        if (cartTotalSpan) cartTotalSpan.textContent = formatCurrency(total);
        if (paymentModalTotalH4) paymentModalTotalH4.textContent = `Total Amount: ${formatCurrency(total)}`;
        if (cashForm?.classList.contains('active') && cashAmountInput) { updateChange(); }
    };

    // --- Function to add/update item in cart ---
    const addOrUpdateCartItem = (productCard) => {
        const productNameElement = productCard.querySelector('.product-name');
        const productPriceElement = productCard.querySelector('.product-price');
        const productIconElement = productCard.querySelector('.product-icon i');
        if (!productNameElement || !productPriceElement || !productIconElement || !cartItemsContainer) { console.error("Add Item Error"); return; }

        const productName = productNameElement.textContent;
        const productPriceString = productPriceElement.textContent;
        const productIconClass = productIconElement.className;
        const productRawPrice = parsePrice(productPriceString);

        // Stock Check
        const stockInfoElement = productCard.querySelector('.stock-info span');
        let stockCount = Infinity, isOutOfStock = false;
        if (stockInfoElement) {
            const stockText = stockInfoElement.textContent.toLowerCase();
            if (stockText.includes('out of stock')) { isOutOfStock = true; stockCount = 0; }
            else {
                const lowMatch = stockText.match(/low stock.*?\((\d+)\)/i);
                const inMatch = stockText.match(/in stock.*?\((\d+)\)/i);
                const numMatch = stockText.match(/\((\d+)\)/);
                if (lowMatch) stockCount = parseInt(lowMatch[1], 10);
                else if (inMatch) stockCount = parseInt(inMatch[1], 10);
                else if (numMatch) stockCount = parseInt(numMatch[1], 10);
                if (isNaN(stockCount)) { stockCount = 0; isOutOfStock = true; }
            }
        }

        // Find existing item
        let existingCartItem = null;
        let currentQuantityInCart = 0;
        cartItemsContainer.querySelectorAll('.cart-item').forEach(item => {
            if (item.querySelector('.item-info h4')?.textContent === productName) {
                existingCartItem = item;
                currentQuantityInCart = parseInt(item.querySelector('.quantity')?.textContent || '0', 10);
            }
        });

        // Add or Increment
        if (existingCartItem) {
            const quantitySpan = existingCartItem.querySelector('.quantity');
            if (quantitySpan) {
                if (!isOutOfStock && currentQuantityInCart < stockCount) {
                    quantitySpan.textContent = currentQuantityInCart + 1;
                    updateCartTotals();
                } else { alert(`Cannot add more ${productName}. Max stock (${stockCount}) reached.`); }
            }
        } else {
            if (isOutOfStock || stockCount <= 0) { alert(`${productName} is out of stock.`); return; }
            const newItem = document.createElement('div');
            newItem.classList.add('cart-item');
            newItem.setAttribute('data-product-name', productName);
            newItem.innerHTML = `
                <div class="item-details"><div class="item-image"><i class="${productIconClass}"></i></div><div class="item-info"><h4></h4><p></p></div></div>
                <div class="item-controls"><div class="quantity-control"><button type="button" class="quantity-btn decrease-btn" data-action="decrease" aria-label="Decrease quantity"><i class="fas fa-minus"></i></button><span class="quantity">1</span><button type="button" class="quantity-btn increase-btn" data-action="increase" aria-label="Increase quantity"><i class="fas fa-plus"></i></button></div><div class="item-price" style="display: none;">${productRawPrice}</div><button type="button" class="remove-item-btn" aria-label="Remove item" style="color: red; background: none; border: none; font-size: 1em; cursor: pointer; margin-left: 10px;"><i class="fas fa-trash-alt"></i></button></div>`;
            newItem.querySelector('.item-info h4').textContent = productName;
            newItem.querySelector('.item-info p').textContent = productPriceString;
            const emptyMsg = cartItemsContainer.querySelector('p');
            if (emptyMsg && emptyMsg.textContent.includes("Cart is empty")) emptyMsg.remove();
            cartItemsContainer.appendChild(newItem);
            updateCartTotals();
        }
    };

    // --- Cart Item Control Functions ---
    const findProductCardByName = (name) => {
        if (!productGrid) return null;
        for (const card of productGrid.querySelectorAll('.product-card')) {
           if (card.querySelector('.product-name')?.textContent === name) return card;
        }
        return null;
    };
    const increaseQuantity = (cartItem) => {
        const quantitySpan = cartItem.querySelector('.quantity');
        const productName = cartItem.querySelector('.item-info h4')?.textContent;
        if (!quantitySpan || !productName) return;
        let currentQuantity = parseInt(quantitySpan.textContent) || 0;
        const productCard = findProductCardByName(productName);
        let stockCount = Infinity, isOutOfStock = false;
         if (productCard) {
             const stockInfoElement = productCard.querySelector('.stock-info span');
              if (stockInfoElement) {
                  const stockText = stockInfoElement.textContent.toLowerCase();
                  if (stockText.includes('out of stock')) { isOutOfStock = true; stockCount = 0; }
                  else {
                      const lowStockMatch = stockText.match(/low stock.*?\((\d+)\)/i);
                      const inStockMatch = stockText.match(/in stock.*?\((\d+)\)/i);
                      const numberMatch = stockText.match(/\((\d+)\)/);
                      if (lowStockMatch) { stockCount = parseInt(lowStockMatch[1], 10); }
                      else if (inStockMatch) { stockCount = parseInt(inStockMatch[1], 10); }
                      else if (numberMatch) { stockCount = parseInt(numberMatch[1], 10); }
                      if (isNaN(stockCount)) { stockCount = 0; isOutOfStock = true; }
                  }
              }
         }
         if (!isOutOfStock && currentQuantity < stockCount) {
             quantitySpan.textContent = currentQuantity + 1;
             updateCartTotals();
         } else { alert(`Cannot add more ${productName}. Max stock (${stockCount}) reached.`); }
    };
    const decreaseQuantity = (cartItem) => {
        const quantitySpan = cartItem.querySelector('.quantity');
        if (!quantitySpan) return;
        let quantity = parseInt(quantitySpan.textContent) || 0;
        if (quantity > 1) {
            quantitySpan.textContent = quantity - 1;
            updateCartTotals();
        } else { removeCartItem(cartItem, true); }
    };
    const removeCartItem = (cartItem, confirmFirst = false) => {
        const itemName = cartItem.querySelector('.item-info h4')?.textContent || 'this item';
        let removeItem = !confirmFirst || confirm(`Remove ${itemName} from the cart?`);
        if (removeItem && cartItem && cartItemsContainer) {
            cartItem.remove();
            updateCartTotals();
            if (cartItemsContainer.children.length === 0) {
                cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                if(cartDiscountInput) cartDiscountInput.value = '';
                if(cartTaxRateInput) cartTaxRateInput.value = '';
                updateCartTotals();
            }
        }
    };

    // --- Calculate Change ---
    const updateChange = () => {
        if (!cartTotalSpan || !cashAmountInput || !changeAmountDisplayDiv) return;
        const totalAmount = parsePrice(cartTotalSpan.textContent);
        const cashReceived = parseFloat(cashAmountInput.value) || 0;
        const changeDue = cashReceived - totalAmount;
        if (changeDue >= 0) {
            changeAmountDisplayDiv.textContent = formatCurrency(changeDue);
            changeAmountDisplayDiv.style.color = ''; // Use CSS variable or default
            if (cashAmountInput) cashAmountInput.style.borderColor = '';
        } else {
            changeAmountDisplayDiv.textContent = `(${formatCurrency(Math.abs(changeDue))})`;
            changeAmountDisplayDiv.style.color = 'var(--danger, red)'; // Use CSS variable or default
        }
    };

    // --- Function to prepare receipt data object ---
    function prepareReceiptData(paymentMethod) {
        console.log("cscript.js: Preparing receipt data object...");
        const now = new Date();
        const receiptNumber = `INV-${now.toISOString().slice(0,10).replace(/-/g,'')}-${Math.floor(100 + Math.random()*900)}`;
        const receiptDate = now.toLocaleString('en-US', { month: 'long', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit', hour12: true }); // Adjust locale if needed

        const cartItems = [];
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];
        currentCartItems.forEach(item => {
            const nameElement = item.querySelector('.item-info h4');
            const quantityElement = item.querySelector('.quantity');
            const priceElement = item.querySelector('.item-info p'); // Display price
            if (nameElement && quantityElement && priceElement) {
                cartItems.push({
                    name: nameElement.textContent,
                    quantity: quantityElement.textContent, // Keep as string from UI
                    price: priceElement.textContent // Keep display price string
                });
            }
        });

        // Get totals & details directly from the UI elements for consistency
        const subtotalFormatted = cartSubtotalSpan?.textContent ?? formatCurrency(0);
        const discountRate = cartDiscountInput ? parseFloat(cartDiscountInput.value) : 0;
        const taxRate = cartTaxRateInput ? parseFloat(cartTaxRateInput.value) : 0;
        const discountFormatted = cartDiscountAmountSpan?.textContent + ((!isNaN(discountRate) && discountRate !== 0) ? ` (${discountRate.toFixed(1)}%)` : '');
        const taxFormatted = cartTaxAmountSpan?.textContent + ((!isNaN(taxRate) && taxRate !== 0) ? ` (${taxRate.toFixed(1)}%)` : '');
        const totalFormatted = cartTotalSpan?.textContent ?? formatCurrency(0);

        // Payment method details
        let paymentDetails = { method: paymentMethod };
        if (paymentMethod === 'cash' && cashAmountInput && changeAmountDisplayDiv) {
            paymentDetails.cashReceivedFormatted = formatCurrency(parseFloat(cashAmountInput.value) || 0);
            paymentDetails.changeDueFormatted = changeAmountDisplayDiv.textContent;
        } else if (paymentMethod === 'card' && cardNumberInput) {
            paymentDetails.cardNumberLast4 = cardNumberInput.value.replace(/\s/g, '').slice(-4);
        }

        const cashierName = document.querySelector('.user-info h4')?.textContent || 'N/A'; // Get cashier name from UI

        const data = {
            receiptNumber, receiptDate, cashier: cashierName, items: cartItems,
            subtotalFormatted, discountFormatted, taxFormatted, totalFormatted,
            paymentDetails
        };
        console.log("cscript.js: Prepared receipt data object:", data);
        return data;
    }

    // --- Event Listeners Setup ---

    // Product Grid Click
    if (productGrid) productGrid.addEventListener('click', (e) => { const card = e.target.closest('.product-card'); if (card) addOrUpdateCartItem(card); }); else console.error("Product grid missing!");
    // Cart Item Controls Click
    if (cartItemsContainer) cartItemsContainer.addEventListener('click', (e) => { const item = e.target.closest('.cart-item'); if (!item) return; if (e.target.closest('.increase-btn')) increaseQuantity(item); else if (e.target.closest('.decrease-btn')) decreaseQuantity(item); else if (e.target.closest('.remove-item-btn')) removeCartItem(item, true); }); else console.error("Cart container missing!");
    // Clear Cart Button
    if (clearCartBtn) clearCartBtn.addEventListener('click', () => { if (cartItemsContainer?.querySelector('.cart-item') && confirm("Clear all items?")) { cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>'; if(cartDiscountInput) cartDiscountInput.value = ''; if(cartTaxRateInput) cartTaxRateInput.value = ''; updateCartTotals(); } });
    // Discount/Tax Inputs
    [cartDiscountInput, cartTaxRateInput].forEach(input => { if (input) { input.addEventListener('input', updateCartTotals); input.addEventListener('blur', updateCartTotals); } });
    // Cash Amount Input
    if (cashAmountInput) cashAmountInput.addEventListener('input', updateChange);
    // Open Payment Modal
    if (checkoutBtn) checkoutBtn.addEventListener('click', () => {
        if (!cartItemsContainer?.querySelector('.cart-item')) {
            let err = document.querySelector('.cart-error-message');
             if (!err) {
                err = document.createElement('div'); err.className = 'cart-error-message';
                 err.innerHTML = `<div class="error-content"><i class="fas fa-exclamation-circle"></i><p>Cart is empty. Add products first.</p></div>`;
                 const summary = document.querySelector('.cart-summary');
                 const targetContainer = summary ? summary.parentNode : (cartItemsContainer ? cartItemsContainer.parentNode : document.body);
                 const insertBeforeElement = summary || (cartItemsContainer ? cartItemsContainer.nextSibling : null);
                 if(targetContainer) targetContainer.insertBefore(err, insertBeforeElement);
                 else document.body.appendChild(err); // Fallback append
                 setTimeout(() => err.remove(), 3000);
            }
            return;
        }
        updateCartTotals();
        if (parsePrice(cartTotalSpan.textContent) <= 0) { alert("Cannot checkout zero/negative total."); return; }
        openModal(paymentModal);
        paymentOptions?.forEach(o => o.classList.remove('active')); paymentForms?.forEach(f => f.classList.remove('active'));
        paymentModal?.querySelector('.payment-option[data-method="cash"]')?.classList.add('active'); cashForm?.classList.add('active');
        updateChange(); cashAmountInput?.focus();
     }); else console.error("Checkout button missing!");
    // Close Modals
    closeModalBtns.forEach(btn => btn.addEventListener('click', () => { const modal = btn.closest('.modal'); closeModal(modal); })); // Simplified close
    // Cancel Payment
    if (cancelPaymentBtn) cancelPaymentBtn.addEventListener('click', () => closeModal(paymentModal));
    // Switch Payment Methods
    if (paymentOptions) paymentOptions.forEach(opt => opt.addEventListener('click', () => { const method = opt.getAttribute('data-method'); paymentOptions.forEach(o => o.classList.remove('active')); opt.classList.add('active'); paymentForms?.forEach(f => f.classList.remove('active')); paymentModal?.querySelector(`.payment-form.${method}-form`)?.classList.add('active'); resetCardValidationStyles(); if(cashAmountInput) cashAmountInput.style.borderColor=''; if (method === 'cash') { updateChange(); cashAmountInput?.focus(); } }));

    // --- Handle Confirm Payment Button Click (Using sessionStorage and window.open) ---
    if (confirmPaymentBtn && paymentModal && cartTotalSpan) {
        confirmPaymentBtn.addEventListener('click', () => {
            console.log("cscript.js: Confirm Payment button clicked.");
            const activeOption = paymentModal.querySelector('.payment-option.active');
            const selectedMethod = activeOption ? activeOption.getAttribute('data-method') : null;
            if (!selectedMethod) { alert("Please select a payment method."); return; }

            const totalAmount = parsePrice(cartTotalSpan.textContent);
            if (totalAmount <= 0) { alert("Cannot process payment for zero or negative total."); return; }

            let paymentSuccessful = false;
            let validationPassed = true;

            // --- Validation ---
            console.log("cscript.js: Starting payment validation...");
            resetCardValidationStyles();
            if (cashAmountInput) cashAmountInput.style.borderColor = '';

            if (selectedMethod === 'card') {
                const cardNum = cardNumberInput?.value.trim() ?? '';
                const expiry = expiryDateInput?.value.trim() ?? '';
                const cvv = cvvCodeInput?.value.trim() ?? '';
                const name = cardHolderNameInput?.value.trim() ?? '';
                 if (!cardNum || cardNum.length < 13 || !/^\d+$/.test(cardNum.replace(/\s/g,'')) || !expiry || !/^\d{2}\/\d{2}$/.test(expiry) || !cvv || cvv.length < 3 || !/^\d+$/.test(cvv) || !name) {
                     validationPassed = false; alert("Please check card details (number, MM/YY expiry, CVV, name).");
                     if (!cardNum || cardNum.length < 13 || !/^\d+$/.test(cardNum.replace(/\s/g,''))) cardNumberInput && (cardNumberInput.style.borderColor = 'red');
                      if (!expiry || !/^\d{2}\/\d{2}$/.test(expiry)) expiryDateInput && (expiryDateInput.style.borderColor = 'red');
                      if (!cvv || cvv.length < 3 || !/^\d+$/.test(cvv)) cvvCodeInput && (cvvCodeInput.style.borderColor = 'red');
                      if (!name) cardHolderNameInput && (cardHolderNameInput.style.borderColor = 'red');
                 }
                 // Add more specific validation (e.g., expiry date check) here...
                 if (!validationPassed) { console.log("cscript.js: Card validation failed."); return; }
                 paymentSuccessful = true; console.log("cscript.js: Card validation passed (simulation).");

            } else if (selectedMethod === 'cash') {
                 if (!cashAmountInput) { console.error("Cash amount input not found."); return; }
                 const cashReceived = parseFloat(cashAmountInput.value) || 0;
                 if (cashReceived < totalAmount) {
                     alert(`Cash received (${formatCurrency(cashReceived)}) is less than total (${formatCurrency(totalAmount)}).`);
                     if(cashAmountInput) cashAmountInput.style.borderColor = 'red';
                     validationPassed = false; console.log("cscript.js: Cash validation failed (insufficient amount)."); return;
                 }
                paymentSuccessful = true; console.log("cscript.js: Cash validation passed.");

            } else if (selectedMethod === 'digital') {
                paymentSuccessful = true; console.log("cscript.js: Digital payment assumed successful (simulation).");
            }

            // --- Post-Payment Actions ---
            if (validationPassed && paymentSuccessful) {
                console.log("cscript.js: Payment successful, proceeding...");
                const receiptDataObject = prepareReceiptData(selectedMethod);
                let dataStored = false;
                try {
                    sessionStorage.setItem('receiptDataForPrint', JSON.stringify(receiptDataObject)); // Use consistent key
                    dataStored = true; console.log("cscript.js: Stored receipt data in sessionStorage.");
                } catch (e) {
                    console.error("cscript.js: Error storing receipt data:", e);
                    alert("Storage error. Transaction complete, but receipt cannot be opened automatically.");
                }

                closeModal(paymentModal); // Close modal first
                console.log("cscript.js: Payment modal closed.");

                if (dataStored) { // Only open if storage succeeded
                    console.log("cscript.js: Opening receipt.jsp...");
                    const receiptWindow = window.open('receipt.jsp', '_blank');
                    if (!receiptWindow) {
                        console.error("cscript.js: Failed to open receipt window (pop-up blocker?).");
                        alert("Please allow pop-ups to view receipt. Transaction complete.");
                    } else { console.log("cscript.js: Receipt window opened."); }
                }

                console.log("cscript.js: Clearing cart & forms...");
                if (clearCartBtn) clearCartBtn.click(); // Clear cart
                // Reset forms
                if (cashAmountInput) cashAmountInput.value = '';
                if (changeAmountDisplayDiv) { changeAmountDisplayDiv.textContent = formatCurrency(0); changeAmountDisplayDiv.style.color = ''; }
                resetCardValidationStyles();
                if (cardNumberInput) cardNumberInput.value = ''; if (expiryDateInput) expiryDateInput.value = '';
                if (cvvCodeInput) cvvCodeInput.value = ''; if (cardHolderNameInput) cardHolderNameInput.value = '';
                console.log("cscript.js: Cart & forms reset.");

           } else if (!validationPassed) { console.log("cscript.js: Payment stopped due to validation errors."); }
            else { console.log("cscript.js: Payment simulation failed."); alert("Payment processing failed."); }
        });
    } else { console.error("Confirm Payment button, modal, or total span missing."); }

    // Mobile Navigation Toggle
    if (mobileNavToggle && sidebar) { mobileNavToggle.addEventListener('click', (e) => { e.stopPropagation(); sidebar.classList.toggle('open'); if (sidebar.classList.contains('open')) { setTimeout(() => { document.addEventListener('click', closeSidebarOnClickOutside, { capture: true, once: true }); }, 0); } }); function closeSidebarOnClickOutside(e) { if (sidebar?.classList.contains('open') && !sidebar.contains(e.target) && !mobileNavToggle.contains(e.target)) { sidebar.classList.remove('open'); } } sidebar.querySelectorAll('.menu-item').forEach(item => { item.addEventListener('click', () => { if (sidebar.classList.contains('open')) { sidebar.classList.remove('open'); document.removeEventListener('click', closeSidebarOnClickOutside, { capture: true }); } }); }); }

    // --- Initial Setup ---
    if (cartItemsContainer && !cartItemsContainer.querySelector('.cart-item') && !cartItemsContainer.querySelector('p')) { cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>'; }
    if(cartDiscountInput) cartDiscountInput.value = ''; if(cartTaxRateInput) cartTaxRateInput.value = '';
    updateCartTotals();

    // Style injection for error message
    const style = document.createElement('style');
    style.textContent = `.cart-error-message { background-color: #fff3f3; border: 1px solid #dc3545; border-radius: 4px; margin: 10px; padding: 10px 15px; animation: fadeIn 0.4s ease-out; z-index: 10; position: relative; } .cart-error-message .error-content { display: flex; align-items: center; gap: 10px; color: #721c24; } .cart-error-message i { font-size: 1.1em; color: #dc3545; } .cart-error-message p { margin: 0; font-size: 0.95em; font-weight: 500; } @keyframes fadeIn { from { opacity: 0; transform: translateY(-5px); } to { opacity: 1; transform: translateY(0); } }`;
    document.head.appendChild(style);

    console.log("cscript.js: Setup complete.");
}); // End DOMContentLoaded