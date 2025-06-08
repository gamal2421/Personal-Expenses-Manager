// Modal functions
function openAddModal() {
    document.getElementById('addExpenseModal').classList.add('active');
}

function closeAddModal() {
    document.getElementById('addExpenseModal').classList.remove('active');
}

function openEditModal(expenseId, categoryId, amount, description) {
    document.getElementById('editExpenseId').value = expenseId;
    document.getElementById('editCategory').value = categoryId;
    document.getElementById('editAmount').value = amount;
    document.getElementById('editDescription').value = description;
    document.getElementById('editExpenseModal').classList.add('active');
}

function closeEditModal() {
    document.getElementById('editExpenseModal').classList.remove('active');
}

let expenseToDelete = null;

function deleteExpense(expenseId) {
    expenseToDelete = expenseId;
    document.getElementById('deleteExpenseModal').classList.add('active');
}

function closeDeleteModal() {
    expenseToDelete = null;
    document.getElementById('deleteExpenseModal').classList.remove('active');
}

function confirmDelete() {
    if (expenseToDelete) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'expenses.jsp';
        
        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'delete';
        form.appendChild(actionInput);
        
        const idInput = document.createElement('input');
        idInput.type = 'hidden';
        idInput.name = 'expenseId';
        idInput.value = expenseToDelete;
        form.appendChild(idInput);
        
        document.body.appendChild(form);
        form.submit();
    }
}

// Form validation
document.getElementById('addExpenseForm').addEventListener('submit', function(e) {
    const category = document.getElementById('category');
    const amount = parseFloat(document.getElementById('amount').value);
    const description = document.getElementById('description').value.trim();
    
    if (category.value === '') {
        alert('Please select a category');
        e.preventDefault();
        return;
    }
    
    if (isNaN(amount) || amount <= 0) {
        alert('Please enter a valid amount greater than 0');
        e.preventDefault();
        return;
    }
    
    if (description === '') {
        alert('Please enter a description');
        e.preventDefault();
        return;
    }
});

document.getElementById('editExpenseForm').addEventListener('submit', function(e) {
    const category = document.getElementById('editCategory');
    const amount = parseFloat(document.getElementById('editAmount').value);
    const description = document.getElementById('editDescription').value.trim();
    
    if (category.value === '') {
        alert('Please select a category');
        e.preventDefault();
        return;
    }
    
    if (isNaN(amount) || amount <= 0) {
        alert('Please enter a valid amount greater than 0');
        e.preventDefault();
        return;
    }
    
    if (description === '') {
        alert('Please enter a description');
        e.preventDefault();
        return;
    }
});

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('addExpenseBtn').addEventListener('click', openAddModal);
}); 