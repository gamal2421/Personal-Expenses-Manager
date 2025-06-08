document.addEventListener('DOMContentLoaded', function() {
    // Filter functionality
    document.getElementById('filterInput').addEventListener('input', function() {
        const filterValue = this.value.toLowerCase();
        document.querySelectorAll('.income-card').forEach(card => {
            const source = card.querySelector('.income-source').textContent.toLowerCase();
            card.style.display = source.includes(filterValue) ? 'block' : 'none';
        });
    });

    // Get data from the data-attributes
    const incomeDataContainer = document.getElementById('income-chart-data');
    const labelsString = incomeDataContainer.getAttribute('data-labels');
    const dataString = incomeDataContainer.getAttribute('data-values');
    const labels = JSON.parse(labelsString);
    const data = JSON.parse(dataString);

    // Initialize pie chart
    const ctx = document.getElementById('incomeChart').getContext('2d');
    
    const incomeData = {
        labels: labels,
        datasets: [{
            data: data,
            backgroundColor: [
                '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', 
                '#9966FF', '#FF9F40', '#8AC24A', '#607D8B',
                '#E91E63', '#3F51B5'
            ],
            borderWidth: 1
        }]
    };
    
    const incomeChart = new Chart(ctx, {
        type: 'pie',
        data: incomeData,
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'right',
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const label = context.label || '';
                            const value = context.raw || 0;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = Math.round((value / total) * 100);
                            return `${label}: $${value.toFixed(2)} (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });

    // Get form and form elements
    const incomeFormContainer = document.getElementById('incomeFormContainer');
    const incomeForm = document.getElementById('incomeForm');
    const incomeFormAction = document.getElementById('incomeFormAction');
    const incomeIdInput = document.getElementById('incomeId');
    const incomeSourceInput = document.getElementById('incomeSource');
    const incomeAmountInput = document.getElementById('incomeAmount');
    const incomeModalTitle = document.getElementById('incomeModalTitle');
    const closeIncomeFormBtn = document.getElementById('closeIncomeForm');
    const cancelIncomeFormBtn = document.getElementById('cancelIncomeForm');

    // Get delete confirmation modal elements
    const deleteIncomeConfirmModal = document.getElementById('deleteIncomeConfirmModal');
    const confirmDeleteIncomeBtn = document.getElementById('confirmDeleteIncomeBtn');
    const cancelDeleteIncomeBtn = document.getElementById('cancelDeleteIncomeBtn');
    const closeIncomeConfirmModalBtn = document.getElementById('closeIncomeConfirmModal');
    let incomeIdToDelete = null; // Variable to store the ID of the income to be deleted

    // Function to show the modal form
    function showIncomeForm(action, income) {
        console.log('Showing income form for action:', action, 'income:', income);
        incomeForm.reset(); // Reset form fields
        incomeFormAction.value = action;
        incomeIdInput.value = income ? income.id : '';
        incomeModalTitle.textContent = action === 'add' ? 'Add Income' : 'Edit Income';

        if (income) {
            // Populate form for editing
            incomeSourceInput.value = income.source;
            incomeAmountInput.value = income.amount;
        }

        // Use class to show for CSS transitions
        incomeFormContainer.classList.add('active');
         console.log('Added active class to incomeFormContainer');
    }

    // Function to hide the modal form
    function hideIncomeForm() {
         console.log('Hiding income form');
        // Use class to hide for CSS transitions
        incomeFormContainer.classList.remove('active');
         console.log('Removed active class from incomeFormContainer');
    }

    // Add new income - show form
    // Assuming there is an element with ID 'addIncomeBtn'
    const addIncomeBtn = document.getElementById('addIncomeBtn');
    if (addIncomeBtn) {
         addIncomeBtn.addEventListener('click', function() {
            console.log('Add Income button clicked');
            showIncomeForm('add');
        });
    }

    // Add event listeners to edit buttons
    document.querySelectorAll('.edit-income-btn').forEach(button => {
        button.addEventListener('click', function() {
            console.log('Edit income button clicked', button.getAttribute('data-id'));
            const income = {
                id: button.getAttribute('data-id'),
                source: button.getAttribute('data-source'),
                amount: button.getAttribute('data-amount')
            };
            showIncomeForm('update', income);
        });
    });

    // Add event listener for cancel button (add/edit modal)
    if (cancelIncomeFormBtn) {
        cancelIncomeFormBtn.addEventListener('click', hideIncomeForm);
    }

    // Add event listener for close button (X) (add/edit modal)
    if (closeIncomeFormBtn) {
        closeIncomeFormBtn.addEventListener('click', hideIncomeForm);
    }

    // Close modal if user clicks outside of it (add/edit modal)
    window.addEventListener('click', function(event) {
        if (event.target === incomeFormContainer) {
            console.log('Clicked outside income modal, hiding form');
            hideIncomeForm();
        }
    });

    // Add event listeners to delete buttons
    document.querySelectorAll('.delete-income-btn').forEach(button => {
         // Remove any existing click listeners to prevent multiple confirmations
        const oldClickListener = button._clickHandler; // Store the handler if needed later, or just remove
        if (oldClickListener) {
            button.removeEventListener('click', oldClickListener);
        }

        // Add the new click listener
        const newClickListener = function() {
            console.log('Delete income button clicked', this.getAttribute('data-id'));
            incomeIdToDelete = this.getAttribute('data-id'); // Store the ID
            
            console.log('Attempting to show delete confirm modal...');
            console.log('deleteIncomeConfirmModal element:', deleteIncomeConfirmModal);
            console.log('deleteIncomeConfirmModal classList before adding active:', deleteIncomeConfirmModal.classList);
            
            deleteIncomeConfirmModal.classList.add('active'); // Show the confirmation modal
            
            console.log('deleteIncomeConfirmModal classList after adding active:', deleteIncomeConfirmModal.classList); // Debugging line
        };
        button.addEventListener('click', newClickListener);
        button._clickHandler = newClickListener; // Store the new handler
    });

    // Add event listeners for the delete confirmation modal
    if (confirmDeleteIncomeBtn) {
        confirmDeleteIncomeBtn.addEventListener('click', function() {
            console.log('Confirm delete button clicked for income ID:', incomeIdToDelete);
            if (incomeIdToDelete) {
                // Create and submit the delete form
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'income.jsp'; // Submit to income.jsp
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete'; // Action is 'delete'
                form.appendChild(actionInput);
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = incomeIdToDelete;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
            deleteIncomeConfirmModal.classList.remove('active'); // Hide the modal
        });
    }

    if (cancelDeleteIncomeBtn) {
        cancelDeleteIncomeBtn.addEventListener('click', function() {
            console.log('Cancel delete button clicked');
            incomeIdToDelete = null; // Clear the stored ID
            deleteIncomeConfirmModal.classList.remove('active'); // Hide the modal
        });
    }

     if (closeIncomeConfirmModalBtn) {
        closeIncomeConfirmModalBtn.addEventListener('click', function() {
             console.log('Close delete modal button clicked');
             incomeIdToDelete = null; // Clear the stored ID
             deleteIncomeConfirmModal.classList.remove('active'); // Hide the modal
        });
     }

    // Close delete modal if user clicks outside of it
    window.addEventListener('click', function(event) {
        if (event.target === deleteIncomeConfirmModal) {
            console.log('Clicked outside income modal, hiding');
            incomeIdToDelete = null; // Clear the stored ID
            deleteIncomeConfirmModal.classList.remove('active'); // Hide the modal
        }
    });

}); 