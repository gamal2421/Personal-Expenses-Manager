document.addEventListener('DOMContentLoaded', function() {
    // Get form and form elements
    const budgetFormContainer = document.getElementById('budgetFormContainer');
    const budgetForm = document.getElementById('budgetForm');
    const budgetFormAction = document.getElementById('budgetFormAction');
    const budgetBudgetId = document.getElementById('budgetBudgetId');
    const budgetCategoryInput = document.getElementById('budgetCategory');
    const budgetAmountInput = document.getElementById('budgetAmount');
    const budgetCurrentSpendingInput = document.getElementById('budgetCurrentSpending');
    const budgetModalTitle = document.getElementById('budgetModalTitle');
    const closeBudgetFormBtn = document.getElementById('closeBudgetForm');
    const cancelBudgetFormBtn = document.getElementById('cancelBudgetForm');
    const budgetTypeInput = document.getElementById('budgetType');
    const periodStartInput = document.getElementById('periodStart');

    // Get delete confirmation modal elements
    const deleteBudgetConfirmModal = document.getElementById('deleteBudgetConfirmModal');
    const confirmDeleteBudgetBtn = document.getElementById('confirmDeleteBudgetBtn');
    const cancelDeleteBudgetBtn = document.getElementById('cancelDeleteBudgetBtn');
    const closeBudgetConfirmModalBtn = document.getElementById('closeBudgetConfirmModal');
    let budgetIdToDelete = null; // Variable to store the ID of the budget to be deleted

    // Function to show the modal form
    function showBudgetForm(action, budget) {
        console.log('Showing budget form for action:', action, 'budget:', budget);
        budgetForm.reset(); // Reset form fields
        budgetFormAction.value = action;
        budgetBudgetId.value = budget ? budget.id : '';
        budgetModalTitle.textContent = action === 'add' ? 'Add Budget' : 'Edit Budget';

        // Populate category dropdown for both add and edit (categories are already in JSP context)
        // For edit, we need to select the correct category.
        if (budget) {
            // Populate form for editing
            // Select the correct category in the dropdown
            if (budgetCategoryInput) {
                budgetCategoryInput.value = budget.categoryId;
            }
            budgetAmountInput.value = budget.budgetAmount;
            budgetCurrentSpendingInput.value = budget.currentSpending;
            if (budgetTypeInput) {
                budgetTypeInput.value = budget.budgetType || 'monthly';
            }
            if (periodStartInput) {
                periodStartInput.value = budget.periodStart || new Date().toISOString().split('T')[0];
            }
        } else {
            if (budgetTypeInput) {
                budgetTypeInput.value = 'monthly';
            }
            if (periodStartInput) {
                periodStartInput.value = new Date().toISOString().split('T')[0];
            }
        }

        // Use class to show for CSS transitions
        budgetFormContainer.classList.add('active');
         console.log('Added active class to budgetFormContainer');
    }

    // Function to hide the modal form
    function hideBudgetForm() {
         console.log('Hiding budget form');
        // Use class to hide for CSS transitions
        budgetFormContainer.classList.remove('active');
         console.log('Removed active class from budgetFormContainer');
    }

    // Add new budget - show form
    // Assuming there is an element with ID 'addBudgetBtn'
    const addBudgetBtn = document.getElementById('addBudgetBtn');
    if (addBudgetBtn) {
         addBudgetBtn.addEventListener('click', function() {
            console.log('Add Budget button clicked');
            showBudgetForm('add');
        });
    }

    // Add event listeners to edit buttons
    document.querySelectorAll('.edit-budget-btn').forEach(button => {
        button.addEventListener('click', function() {
            console.log('Edit budget button clicked', button.getAttribute('data-id'));
            const budget = {
                id: button.getAttribute('data-id'),
                categoryId: button.getAttribute('data-category-id'),
                budgetAmount: button.getAttribute('data-budget-amount'),
                currentSpending: button.getAttribute('data-current-spending'),
                budgetType: button.getAttribute('data-budget-type'),
                periodStart: button.getAttribute('data-period-start')
            };
            showBudgetForm('update', budget);
        });
    });

    // Add event listener for cancel button (add/edit modal)
    if (cancelBudgetFormBtn) {
        cancelBudgetFormBtn.addEventListener('click', hideBudgetForm);
    }

    // Add event listener for close button (X) (add/edit modal)
    if (closeBudgetFormBtn) {
        closeBudgetFormBtn.addEventListener('click', hideBudgetForm);
    }

    // Close modal if user clicks outside of it (add/edit modal)
    window.addEventListener('click', function(event) {
        if (event.target === budgetFormContainer) {
            console.log('Clicked outside budget modal, hiding form');
            hideBudgetForm();
        }
    });

    // Add event listeners to delete buttons
    document.querySelectorAll('.delete-budget-btn').forEach(button => {
         // Remove any existing click listeners to prevent multiple confirmations
        const oldClickListener = button._clickHandler; // Store the handler if needed later, or just remove
        if (oldClickListener) {
            button.removeEventListener('click', oldClickListener);
        }

        // Add the new click listener
        const newClickListener = function() {
            console.log('Delete budget button clicked', this.getAttribute('data-id'));
            budgetIdToDelete = this.getAttribute('data-id'); // Store the ID
            
            console.log('Attempting to show delete confirm modal...');
            console.log('deleteBudgetConfirmModal element:', deleteBudgetConfirmModal);
            console.log('deleteBudgetConfirmModal classList before adding active:', deleteBudgetConfirmModal.classList);
            
            deleteBudgetConfirmModal.classList.add('active'); // Show the confirmation modal
            
            console.log('deleteBudgetConfirmModal classList after adding active:', deleteBudgetConfirmModal.classList); // Debugging line
        };
        button.addEventListener('click', newClickListener);
        button._clickHandler = newClickListener; // Store the new handler
    });

    // Add event listeners for the delete confirmation modal
    if (confirmDeleteBudgetBtn) {
        confirmDeleteBudgetBtn.addEventListener('click', function() {
            console.log('Confirm delete button clicked for budget ID:', budgetIdToDelete);
            if (budgetIdToDelete) {
                // Create and submit the delete form
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'budget.jsp'; // Submit to budget.jsp
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete'; // Action is 'delete'
                form.appendChild(actionInput);
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = budgetIdToDelete;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
            deleteBudgetConfirmModal.classList.remove('active'); // Hide the modal
        });
    }

    if (cancelDeleteBudgetBtn) {
        cancelDeleteBudgetBtn.addEventListener('click', function() {
            console.log('Cancel delete button clicked');
            budgetIdToDelete = null; // Clear the stored ID
            deleteBudgetConfirmModal.classList.remove('active'); // Hide the modal
        });
    }

     if (closeBudgetConfirmModalBtn) {
        closeBudgetConfirmModalBtn.addEventListener('click', function() {
             console.log('Close delete modal button clicked');
             budgetIdToDelete = null; // Clear the stored ID
             deleteBudgetConfirmModal.classList.remove('active'); // Hide the modal
        });
     }

    // Close delete modal if user clicks outside of it
    window.addEventListener('click', function(event) {
        if (event.target === deleteBudgetConfirmModal) {
            console.log('Clicked outside delete modal, hiding');
            budgetIdToDelete = null; // Clear the stored ID
            deleteBudgetConfirmModal.classList.remove('active'); // Hide the modal
        }
    });
}); 