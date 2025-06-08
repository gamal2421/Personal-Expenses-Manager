document.addEventListener('DOMContentLoaded', function() {
    // Get form and form elements
    const goalFormContainer = document.getElementById('goalFormContainer');
    const goalForm = document.getElementById('goalForm');
    const formAction = document.getElementById('formAction');
    const goalIdInput = document.getElementById('goalId');
    const goalTitleInput = document.getElementById('goalTitle');
    const goalDescriptionInput = document.getElementById('goalDescription');
    const goalTargetAmountInput = document.getElementById('goalTargetAmount');
    const goalCurrentAmountInput = document.getElementById('goalCurrentAmount');
    const goalTargetDateInput = document.getElementById('goalTargetDate');
    const modalTitle = document.getElementById('modalTitle');
    const closeGoalFormBtn = document.getElementById('closeGoalForm');
    const cancelGoalFormBtn = document.getElementById('cancelGoalForm');

    // Get delete confirmation modal elements
    const deleteConfirmModal = document.getElementById('deleteConfirmModal');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
    const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
    const closeConfirmModalBtn = document.getElementById('closeConfirmModal');
    let goalIdToDelete = null; // Variable to store the ID of the goal to be deleted

    // Get search input element
    const goalSearchInput = document.getElementById('goalSearchInput');

    // Function to show the modal form
    function showGoalForm(action, goal) {
        console.log('Showing goal form for action:', action, 'goal:', goal);
        goalForm.reset(); // Reset form fields
        formAction.value = action;
        goalIdInput.value = goal ? goal.id : '';
        modalTitle.textContent = action === 'add' ? 'Add Financial Goal' : 'Edit Financial Goal';

        if (goal) {
            // Populate form for editing
            goalTitleInput.value = goal.title;
            goalDescriptionInput.value = goal.description;
            goalTargetAmountInput.value = goal.targetAmount;
            goalCurrentAmountInput.value = goal.currentAmount;
            goalTargetDateInput.value = goal.targetDate; // YYYY-MM-DD format expected by input type='date'
        }

        // Use class to show for CSS transitions
        goalFormContainer.classList.add('active');
         console.log('Added active class to goalFormContainer');
    }

    // Function to hide the modal form
    function hideGoalForm() {
         console.log('Hiding goal form');
        // Use class to hide for CSS transitions
        goalFormContainer.classList.remove('active');
         console.log('Removed active class from goalFormContainer');
    }

    // Add new goal - show form
    document.getElementById('addGoalBtn').addEventListener('click', function() {
        console.log('Add Goal button clicked');
        showGoalForm('add');
    });

    // Add event listeners to edit buttons
    document.querySelectorAll('.edit-btn').forEach(button => {
        button.addEventListener('click', function() {
            console.log('Edit button clicked', button.getAttribute('data-id'));
            const goal = {
                id: button.getAttribute('data-id'),
                title: button.getAttribute('data-title'),
                description: button.getAttribute('data-description'),
                targetAmount: button.getAttribute('data-targetamount'),
                currentAmount: button.getAttribute('data-currentamount'),
                targetDate: button.getAttribute('data-targetdate')
            };
            showGoalForm('update', goal);
        });
    });

    // Add event listener for cancel button
    cancelGoalFormBtn.addEventListener('click', hideGoalForm);

    // Add event listener for close button (X)
    closeGoalFormBtn.addEventListener('click', hideGoalForm);

    // Close modal if user clicks outside of it
    window.addEventListener('click', function(event) {
        if (event.target === goalFormContainer) {
            console.log('Clicked outside modal, hiding form');
            hideGoalForm();
        }
    });

    // Add event listeners to delete buttons
    document.querySelectorAll('.delete-btn').forEach(button => {
        // Remove any existing click listeners to prevent multiple confirmations
        const oldClickListener = button._clickHandler; // Store the handler if needed later, or just remove
        if (oldClickListener) {
            button.removeEventListener('click', oldClickListener);
        }

        // Add the new click listener
        const newClickListener = function() {
            console.log('Delete button clicked', this.getAttribute('data-id'));
            goalIdToDelete = this.getAttribute('data-id'); // Store the ID
            
            console.log('Attempting to show delete confirm modal...');
            console.log('deleteConfirmModal element:', deleteConfirmModal);
            console.log('deleteConfirmModal classList before adding active:', deleteConfirmModal.classList);
            
            deleteConfirmModal.classList.add('active'); // Show the confirmation modal
            
            console.log('deleteConfirmModal classList after adding active:', deleteConfirmModal.classList);
        };
        button.addEventListener('click', newClickListener);
        button._clickHandler = newClickListener; // Store the new handler
    });

    // Add event listeners for the delete confirmation modal
    confirmDeleteBtn.addEventListener('click', function() {
        console.log('Confirm delete button clicked for goal ID:', goalIdToDelete);
        if (goalIdToDelete) {
            // Create and submit the delete form
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'Financials goals.jsp';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);
            
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'id';
            idInput.value = goalIdToDelete;
            form.appendChild(idInput);
            
            document.body.appendChild(form);
            form.submit();
        }
        deleteConfirmModal.classList.remove('active'); // Hide the modal
    });

    cancelDeleteBtn.addEventListener('click', function() {
        console.log('Cancel delete button clicked');
        goalIdToDelete = null; // Clear the stored ID
        deleteConfirmModal.classList.remove('active'); // Hide the modal
    });

    closeConfirmModalBtn.addEventListener('click', function() {
         console.log('Close delete modal button clicked');
         goalIdToDelete = null; // Clear the stored ID
         deleteConfirmModal.classList.remove('active'); // Hide the modal
    });

    // Close delete modal if user clicks outside of it
    window.addEventListener('click', function(event) {
        if (event.target === deleteConfirmModal) {
            console.log('Clicked outside delete modal, hiding');
            goalIdToDelete = null; // Clear the stored ID
            deleteConfirmModal.classList.remove('active'); // Hide the modal
        }
    });

    // Add event listener for search input
    goalSearchInput.addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        const goalItems = document.querySelectorAll('.budget-item'); // Assuming .budget-item is the class for each goal display item

        goalItems.forEach(item => {
            const title = item.querySelector('.budget-category').textContent.toLowerCase(); // Assuming .budget-category is the title class
            const descriptionElement = item.querySelector('.goal-description'); // Assuming .goal-description is the description class
            const description = descriptionElement ? descriptionElement.textContent.toLowerCase() : '';

            if (title.includes(searchTerm) || description.includes(searchTerm)) {
                item.style.display = ''; // Show the item
            } else {
                item.style.display = 'none'; // Hide the item
            }
        });
    });

}); 