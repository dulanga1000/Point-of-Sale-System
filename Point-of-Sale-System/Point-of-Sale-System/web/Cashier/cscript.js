/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log("DOM Loaded - Setting up listeners...");

    // --- Modal Elements ---
    const paymentModal = document.getElementById('paymentModal');
    const checkoutBtn = document.getElementById('checkoutBtn');
    const closeModalBtns = document.querySelectorAll('.close-modal');
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
    // const cartSummary = document.querySelector('.cart-summary'); // Already declared
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
        const match = priceString.replace(/,/g, '').match(/(\d+(\.\d+)?)/);
        return match ? parseFloat(match[0]) : 0;
    };

    const formatCurrency = (number) => {
        if (typeof number !== 'number' || isNaN(number)) {
            number = 0;
        }
        return `Rs.${number.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
    };

    const updateCartTotals = () => {
        let subtotal = 0;
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];

        currentCartItems.forEach(item => {
            const priceElement = item.querySelector('.item-info p');
            const quantityElement = item.querySelector('.quantity');

            if (priceElement && quantityElement) {
                const price = parsePrice(priceElement.textContent);
                const quantity = parseInt(quantityElement.textContent, 10) || 1;
                subtotal += price * quantity;
            }
        });

        let discountRatePercent = cartDiscountInput?.value === '' ? 0 : parseFloat(cartDiscountInput?.value) || 0;
        const taxRatePercent = cartTaxRateInput?.value === '' ? 0 : parseFloat(cartTaxRateInput?.value) || 0;

        if (discountRatePercent < 0) discountRatePercent = 0;
        if (discountRatePercent > 100) discountRatePercent = 100;
        
        if (cartDiscountInput && parseFloat(cartDiscountInput.value) !== discountRatePercent && cartDiscountInput.value !== '') {
            cartDiscountInput.value = discountRatePercent.toFixed(1);
        }

        const discountRateDecimal = discountRatePercent / 100;
        const discountAmount = subtotal * discountRateDecimal;
        const subtotalAfterDiscount = subtotal - discountAmount;
        const taxRateDecimal = taxRatePercent / 100;
        const taxAmount = subtotalAfterDiscount * taxRateDecimal;
        const total = subtotalAfterDiscount + taxAmount;

        if (cartSubtotalSpan) cartSubtotalSpan.textContent = formatCurrency(subtotal);
        if (cartDiscountAmountSpan) {
            cartDiscountAmountSpan.textContent = `${formatCurrency(discountAmount)} (${discountRatePercent.toFixed(1)}%)`;
            if (discountRatePercent === 0) cartDiscountAmountSpan.textContent = formatCurrency(0);
        }
        if (cartTaxAmountSpan) {
            cartTaxAmountSpan.textContent = `${formatCurrency(taxAmount)} (${taxRatePercent.toFixed(1)}%)`;
            if (taxRatePercent === 0) cartTaxAmountSpan.textContent = formatCurrency(0);
        }
        if (cartTotalSpan) cartTotalSpan.textContent = formatCurrency(total);
        if (paymentModalTotalH4) paymentModalTotalH4.textContent = `Total Amount: ${formatCurrency(total)}`;
        if (cashForm?.classList.contains('active') && cashAmountInput) {
            updateChange();
        }
    };

    const addOrUpdateCartItem = (productCard) => {
        const productNameElement = productCard.querySelector('.product-name');
        const productPriceElement = productCard.querySelector('.product-price');
        const productIconElement = productCard.querySelector('.product-icon i');
        const productImageElement = productCard.querySelector('.product-icon img');
        const stockInfoElement = productCard.querySelector('.stock-info span');
        const productId = productCard.dataset.productId; // *** MODIFIED: Get product ID ***

        if (!productNameElement || !productPriceElement || !stockInfoElement || !productId) { // *** MODIFIED: Added productId check ***
            console.error("Product card is missing required elements including product ID.");
            alert("Error: Product information is incomplete. Cannot add to cart.");
            return;
        }

        const productName = productNameElement.textContent;
        const productPrice = productPriceElement.textContent.trim();

        let productImageHtml = '';
        if (productImageElement) {
            productImageHtml = `<img src="${productImageElement.src}" alt="${productName}" style="width: 40px; height: 40px; object-fit: contain;">`;
        } else if (productIconElement) {
            productImageHtml = `<i class="${productIconElement.className}"></i>`;
        } else {
            productImageHtml = '<i class="fas fa-box"></i>';
        }

        let stockAvailableQuantity = 0;
        const stockText = stockInfoElement.textContent;
        const stockMatch = stockText.match(/\((\d+)\)/);

        if (stockMatch && stockMatch[1]) {
            stockAvailableQuantity = parseInt(stockMatch[1], 10);
        } else if (stockText.toLowerCase().includes('in stock') && !stockText.match(/\(/)) {
            stockAvailableQuantity = 999; // Assuming high stock if no specific number
        }

        if (stockAvailableQuantity <= 0) {
            alert(`${productName} is currently out of stock.`);
            return;
        }

        let existingCartItem = null;
        const currentCartItems = cartItemsContainer ? cartItemsContainer.querySelectorAll('.cart-item') : [];
        currentCartItems.forEach(item => {
            // Prefer matching by product ID if available, otherwise by name
            const cartItemProductId = item.dataset.productId;
            if (cartItemProductId && cartItemProductId === productId) {
                 existingCartItem = item;
            } else if (!cartItemProductId && item.dataset.productName === productName) { // Fallback for items without ID (should be rare with new changes)
                 existingCartItem = item;
            }
        });

        if (existingCartItem) {
            const quantitySpan = existingCartItem.querySelector('.quantity');
            const currentCartQuantity = quantitySpan ? parseInt(quantitySpan.textContent, 10) : 0;

            if (currentCartQuantity >= stockAvailableQuantity) {
                alert(`Cannot add more ${productName}. Only ${stockAvailableQuantity} available in stock.`);
                return;
            }
            increaseQuantity(existingCartItem); // Directly call increaseQuantity
        } else {
            const newItem = document.createElement('div');
            newItem.classList.add('cart-item');
            newItem.setAttribute('data-product-name', productName); // Keep name for display/fallback
            newItem.setAttribute('data-product-id', productId);    // *** MODIFIED: Store product ID ***
            newItem.setAttribute('data-stock-available', stockAvailableQuantity);

            newItem.innerHTML = `
                <div class="item-details">
                    <div class="item-image">
                        ${productImageHtml}
                    </div>
                    <div class="item-info">
                        <h4>${productName}</h4>
                        <p>${productPrice}</p>
                    </div>
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
                const emptyCartMsg = cartItemsContainer.querySelector('p');
                if(emptyCartMsg && emptyCartMsg.textContent.includes("Cart is empty")) {
                    emptyCartMsg.remove();
                }
                cartItemsContainer.appendChild(newItem);
                attachCartItemListeners(newItem);
            }
            updateCartTotals();
        }
    };

    const attachCartItemListeners = (cartItem) => {
        const increaseBtn = cartItem.querySelector('.increase-btn');
        const decreaseBtn = cartItem.querySelector('.decrease-btn');
        const removeBtn = cartItem.querySelector('.remove-item-btn');

        if (increaseBtn) increaseBtn.onclick = (e) => { e.stopPropagation(); increaseQuantity(cartItem); };
        if (decreaseBtn) decreaseBtn.onclick = (e) => { e.stopPropagation(); decreaseQuantity(cartItem); };
        if (removeBtn) removeBtn.onclick = (e) => { e.stopPropagation(); removeCartItem(cartItem, true); };
    };

    const increaseQuantity = (cartItem) => {
        const quantitySpan = cartItem.querySelector('.quantity');
        const productName = cartItem.dataset.productName || 'Item';
        const maxStock = parseInt(cartItem.getAttribute('data-stock-available') || '0', 10);
        const currentQuantity = quantitySpan ? parseInt(quantitySpan.textContent, 10) : 0;

        if (currentQuantity >= maxStock) {
            alert(`Cannot add more ${productName}. Only ${maxStock} available in stock.`);
            return;
        }
        if (quantitySpan) {
            quantitySpan.textContent = currentQuantity + 1;
            updateCartTotals();
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
                removeCartItem(cartItem, true); // Ask for confirmation before removing if quantity becomes 0
            }
        }
    };

    const removeCartItem = (cartItem, confirmFirst = false) => {
        let removeItem = true;
        if (confirmFirst) {
            removeItem = confirm("Remove this item from the cart?");
        }
        if (removeItem && cartItem) {
            cartItem.remove();
            updateCartTotals();
            if (cartItemsContainer && cartItemsContainer.children.length === 0 && !cartItemsContainer.querySelector('.cart-item')) {
                cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
            }
        }
    }

    if (clearCartBtn && cartItemsContainer) {
        clearCartBtn.addEventListener('click', () => {
            if (cartItemsContainer.children.length > 0 && !cartItemsContainer.querySelector('p')?.textContent.includes("Cart is empty")) {
                if(confirm("Are you sure you want to clear the entire cart?")){
                    cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                    if(cartDiscountInput) cartDiscountInput.value = '';
                    if(cartTaxRateInput) cartTaxRateInput.value = '';
                    updateCartTotals();
                }
            }
        });
    }

    if (productGrid) {
        productGrid.addEventListener('click', (event) => {
            const clickedCard = event.target.closest('.product-card');
            if (clickedCard) {
                addOrUpdateCartItem(clickedCard);
            }
        });
    }

    if (cartDiscountInput) cartDiscountInput.addEventListener('input', updateCartTotals);
    if (cartTaxRateInput) cartTaxRateInput.addEventListener('input', updateCartTotals);

    const updateChange = () => {
        if (!cartTotalSpan || !cashAmountInput || !changeAmountDisplayDiv) return;
        const totalAmount = parsePrice(cartTotalSpan.textContent);
        const cashReceived = parseFloat(cashAmountInput.value) || 0;
        const changeDue = cashReceived - totalAmount;
        changeAmountDisplayDiv.textContent = (changeDue >= 0) ? formatCurrency(changeDue) : `(${formatCurrency(Math.abs(changeDue))})`;
        changeAmountDisplayDiv.style.color = (changeDue >= 0) ? '' : 'red';
    };

    if (cashAmountInput) cashAmountInput.addEventListener('input', updateChange);

    if (checkoutBtn && cartItemsContainer) {
        checkoutBtn.addEventListener('click', () => {
            if (!cartItemsContainer.querySelector('.cart-item')) {
                const errorMessage = document.createElement('div');
                errorMessage.className = 'cart-error-message';
                errorMessage.innerHTML = `<div class="error-content"><i class="fas fa-exclamation-circle"></i><p>Cart is empty. Please add products before checking out.</p></div>`;
                const existingError = cartItemsContainer.querySelector('.cart-error-message');
                if (existingError) existingError.remove();
                
                const emptyMsgElement = cartItemsContainer.querySelector('p');
                const hadEmptyMsg = emptyMsgElement && emptyMsgElement.textContent.includes("Cart is empty");

                if (!hadEmptyMsg) cartItemsContainer.prepend(errorMessage);
                else if (emptyMsgElement) emptyMsgElement.style.display = 'none';


                setTimeout(() => {
                    if (errorMessage.parentNode === cartItemsContainer) errorMessage.remove();
                    if (!cartItemsContainer.querySelector('.cart-item')) {
                         if(!hadEmptyMsg) cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                         else if (emptyMsgElement) emptyMsgElement.style.display = 'block'; // Re-show original if it existed
                    }
                }, 3000);
                return;
            }
            updateCartTotals();
            openModal(paymentModal);
            paymentOptions?.forEach(opt => opt.classList.remove('active'));
            paymentForms?.forEach(form => form.classList.remove('active'));
            paymentModal?.querySelector('.payment-option[data-method="cash"]')?.classList.add('active');
            if (cashForm) cashForm.classList.add('active');
            updateChange();
        });
    }

    closeModalBtns.forEach(btn => {
        if (btn.closest('#paymentModal')) {
            btn.addEventListener('click', () => closeModal(btn.closest('.modal')));
        }
    });
    if (cancelPaymentBtn) cancelPaymentBtn.addEventListener('click', () => closeModal(paymentModal));

    paymentOptions?.forEach(option => {
        option.addEventListener('click', () => {
            const selectedMethod = option.getAttribute('data-method');
            paymentOptions.forEach(opt => opt.classList.remove('active'));
            option.classList.add('active');
            paymentForms?.forEach(form => form.classList.remove('active'));
            const correspondingForm = paymentModal?.querySelector(`.payment-form.${selectedMethod}-form`);
            if (correspondingForm) correspondingForm.classList.add('active');
            if (selectedMethod === 'cash') updateChange();
        });
    });

    if (confirmPaymentBtn && paymentModal && cartTotalSpan && cartItemsContainer) {
        confirmPaymentBtn.addEventListener('click', () => {
            const activeOption = paymentModal.querySelector('.payment-option.active');
            const selectedMethod = activeOption ? activeOption.getAttribute('data-method') : null;
            if (!selectedMethod) { alert("Please select a payment method."); return; }

            const totalAmount = parsePrice(cartTotalSpan.textContent);
            if (totalAmount <= 0) { alert("Cannot process payment for zero or negative total."); return; }

            let paymentSuccessful = false;
            let cardLast4 = null;

            if (selectedMethod === 'card') {
                const cardNumber = cardNumberInput?.value.trim() ?? '';
                const expiryDate = expiryDateInput?.value.trim() ?? '';
                const cvv = cvvCodeInput?.value.trim() ?? '';
                const cardHolderName = cardHolderNameInput?.value.trim() ?? '';
                let isValid = true;
                let errorMsg = "Please correct card details errors:\n";
                [cardNumberInput, expiryDateInput, cvvCodeInput, cardHolderNameInput].forEach(el => { if(el) el.style.borderColor = ''; });
                if (cardNumber.length < 13 || cardNumber.length > 19 || !/^\d+$/.test(cardNumber.replace(/\s/g, ''))) { isValid = false; errorMsg += "- Invalid card number.\n"; if(cardNumberInput) cardNumberInput.style.borderColor = 'red'; }
                if (!/^\d{2}\/\d{2}$/.test(expiryDate)) { isValid = false; errorMsg += "- Invalid expiry (MM/YY).\n"; if(expiryDateInput) expiryDateInput.style.borderColor = 'red'; }
                if (cvv.length < 3 || cvv.length > 4 || !/^\d+$/.test(cvv)) { isValid = false; errorMsg += "- Invalid CVV.\n"; if(cvvCodeInput) cvvCodeInput.style.borderColor = 'red'; }
                if (cardHolderName === '') { isValid = false; errorMsg += "- Cardholder name empty.\n"; if(cardHolderNameInput) cardHolderNameInput.style.borderColor = 'red'; }
                if (!isValid) { alert(errorMsg); return; }
                paymentSuccessful = true;
                cardLast4 = cardNumber.replace(/\s/g, '').slice(-4);
            } else if (selectedMethod === 'cash') {
                if (!cashAmountInput) { console.error("Cash amount input not found."); return; }
                const cashReceived = parseFloat(cashAmountInput.value) || 0;
                if (cashReceived < totalAmount) {
                    alert(`Cash (${formatCurrency(cashReceived)}) is less than total (${formatCurrency(totalAmount)}).`);
                    if(cashAmountInput) cashAmountInput.style.borderColor = 'red'; return;
                }
                if(cashAmountInput) cashAmountInput.style.borderColor = '';
                paymentSuccessful = true;
            } else if (selectedMethod === 'digital') {
                paymentSuccessful = true;
            }

            if (paymentSuccessful) {
                closeModal(paymentModal);
                const now = new Date();
                const receiptNumber = `INV-${now.toISOString().slice(0,10).replace(/-/g,'')}-${Math.floor(100 + Math.random()*900)}`;
                const receiptDate = now.toLocaleString('en-US', { month: 'long', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit', hour12: true });
                const cashier = document.querySelector('.user-info h4')?.textContent || 'System';
                
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'receipt.jsp'; // Your existing receipt page
                form.style.display = 'none';

                const createInput = (name, value) => {
                    if (value !== null && value !== undefined) {
                        const input = document.createElement('input');
                        input.type = 'hidden'; input.name = name; input.value = value;
                        form.appendChild(input);
                    }
                };

                createInput('receiptNumber', receiptNumber);
                createInput('receiptDate', receiptDate);
                createInput('cashier', cashier);
                createInput('subtotal', cartSubtotalSpan?.textContent ?? formatCurrency(0));
                createInput('discount', cartDiscountAmountSpan?.textContent ?? `${formatCurrency(0)} (0%)`);
                createInput('tax', cartTaxAmountSpan?.textContent ?? `${formatCurrency(0)} (0%)`);
                createInput('total', cartTotalSpan?.textContent ?? formatCurrency(0));
                createInput('paymentMethod', selectedMethod);
                if (selectedMethod === 'cash' && cashAmountInput) createInput('cashReceived', formatCurrency(parseFloat(cashAmountInput.value) || 0));
                if (selectedMethod === 'cash' && changeAmountDisplayDiv) createInput('changeDue', changeAmountDisplayDiv.textContent);
                if (cardLast4) createInput('cardLast4', cardLast4);

                const currentCartItems = cartItemsContainer.querySelectorAll('.cart-item');
                currentCartItems.forEach(item => {
                    const name = item.dataset.productName; // Use data attribute for consistency
                    const qty = item.querySelector('.quantity')?.textContent;
                    const price = item.querySelector('.item-info p')?.textContent;
                    const productId = item.dataset.productId; // *** MODIFIED: Get product ID ***

                    if (name && qty && price && productId) { // *** MODIFIED: Ensure productId is present ***
                        createInput('itemName', name);
                        createInput('itemQty', qty);
                        createInput('itemPrice', price);
                        createInput('productId', productId); // *** MODIFIED: Send productId to server ***
                    }
                });

                document.body.appendChild(form);
                form.submit();

                setTimeout(() => { // Clear after form submission has a chance to start
                    if (clearCartBtn && typeof clearCartBtn.click === 'function') {
                        const originalConfirm = window.confirm;
                        window.confirm = () => true; 
                        clearCartBtn.click();
                        window.confirm = originalConfirm; 
                    } else if (cartItemsContainer) {
                        cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
                        if(cartDiscountInput) cartDiscountInput.value = '';
                        if(cartTaxRateInput) cartTaxRateInput.value = '';
                        updateCartTotals();
                    }
                    // Reset payment modal fields
                    if (cashAmountInput) cashAmountInput.value = '';
                    if (changeAmountDisplayDiv) { changeAmountDisplayDiv.textContent = formatCurrency(0); changeAmountDisplayDiv.style.color = '';}
                    if(cardNumberInput) { cardNumberInput.value = ''; cardNumberInput.style.borderColor = ''; }
                    if(expiryDateInput) { expiryDateInput.value = ''; expiryDateInput.style.borderColor = ''; }
                    if(cvvCodeInput) { cvvCodeInput.value = ''; cvvCodeInput.style.borderColor = ''; }
                    if(cardHolderNameInput) { cardHolderNameInput.value = ''; cardHolderNameInput.style.borderColor = ''; }
                    if (form.parentNode) form.remove();
                }, 150); // Increased delay slightly
            }
        });
    }

    if (mobileNavToggle && sidebar) {
        mobileNavToggle.addEventListener('click', (e) => {
            e.stopPropagation();
            sidebar.classList.toggle('open');
            const closeSidebarOnClickOutside = (event) => {
                if (sidebar.classList.contains('open') && !sidebar.contains(event.target) && !mobileNavToggle.contains(event.target)) {
                    sidebar.classList.remove('open');
                    document.removeEventListener('click', closeSidebarOnClickOutside);
                } else if (!sidebar.classList.contains('open')) {
                    document.removeEventListener('click', closeSidebarOnClickOutside);
                }
            };
            if (sidebar.classList.contains('open')) setTimeout(() => document.addEventListener('click', closeSidebarOnClickOutside), 0);
            else document.removeEventListener('click', closeSidebarOnClickOutside);
        });
    }

    const style = document.createElement('style');
    style.textContent = `
        .cart-error-message { background-color: #fff3f3; border: 1px solid #dc3545; border-radius: 4px; margin: 10px 0; padding: 15px; animation: fadeIn 0.3s ease-in; order: -1; }
        .cart-error-message .error-content { display: flex; align-items: center; gap: 10px; color: #dc3545; }
        .cart-error-message i { font-size: 1.2em; } .cart-error-message p { margin: 0; font-size: 1em; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .product-card .stock-info { margin-top: 5px; font-size: 0.9em; }
        .product-card .stock-info.low span { color: #ffc107; font-weight: bold; }
        .product-card .stock-info.out span { color: #dc3545; font-weight: bold; }
        .product-card .stock-info i { margin-right: 4px; }
        .product-card .stock-info .fa-check-circle { color: #28a745; }
        .product-card .stock-info .fa-exclamation-circle { color: #ffc107; }
        .product-card .stock-info .fa-times-circle { color: #dc3545; }
        .cart-items { display: flex; flex-direction: column; }
        .cart-item .item-image img { width: 40px; height: 40px; object-fit: contain; border-radius: 4px; }
    `;
    document.head.appendChild(style);

    if (cartItemsContainer && !cartItemsContainer.querySelector('.cart-item')) {
        cartItemsContainer.innerHTML = '<p style="text-align: center; padding: 20px;">Cart is empty</p>';
    }
    cartItemsContainer?.querySelectorAll('.cart-item').forEach(item => attachCartItemListeners(item));
    if (cartDiscountInput) cartDiscountInput.value = '';
    if (cartTaxRateInput) cartTaxRateInput.value = '';
    updateCartTotals();
    console.log("Setup complete.");
});