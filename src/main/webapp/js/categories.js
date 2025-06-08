console.log('categories.js loaded');
document.addEventListener('DOMContentLoaded', function() {
    // Get modal elements
    const categoryFormContainer = document.getElementById('categoryFormContainer');
    const categoryForm = document.getElementById('categoryForm');
    const categoryFormAction = document.getElementById('categoryFormAction');
    const categoryIdInput = document.getElementById('categoryId');
    const categoryNameInput = document.getElementById('categoryName');
    const categoryModalTitle = document.getElementById('categoryModalTitle');
    const closeCategoryFormBtn = document.getElementById('closeCategoryForm');
    const cancelCategoryFormBtn = document.getElementById('cancelCategoryForm');

    // Get delete confirmation modal elements
    const deleteCategoryConfirmModal = document.getElementById('deleteCategoryConfirmModal');
    const confirmDeleteCategoryBtn = document.getElementById('confirmDeleteCategoryBtn');
    const cancelDeleteCategoryBtn = document.getElementById('cancelDeleteCategoryBtn');
    const closeDeleteConfirmModalBtn = document.getElementById('closeDeleteConfirmModal');
    let categoryIdToDelete = null;

    // Function to show the modal form
    function showCategoryForm(action, category) {
        categoryForm.reset(); // Reset form fields
        categoryFormAction.value = action;
        categoryIdInput.value = category ? category.id : '';
        categoryModalTitle.textContent = action === 'add' ? 'Add Category' : 'Edit Category';

        if (category) {
            categoryNameInput.value = category.name;
        }
        categoryFormContainer.classList.add('active');
    }

    // Function to hide the modal form
    function hideCategoryForm() {
        categoryFormContainer.classList.remove('active');
    }

    // Filter categories
    const filterInput = document.getElementById('filterInput');
    if (filterInput) {
        filterInput.addEventListener('input', function() {
            const filterValue = this.value.toLowerCase();
            document.querySelectorAll('.category-card').forEach(card => {
                const name = card.querySelector('.category-name').textContent.toLowerCase();
                card.style.display = name.includes(filterValue) ? 'flex' : 'none';
            });
        });
    }

    // Add category button (only for admin)
    const addBtn = document.getElementById('addCategoryBtn');
    if (addBtn) {
        addBtn.addEventListener('click', function() {
            showCategoryForm('add');
        });
    }

    // Event listeners for edit buttons
    document.querySelectorAll('.edit-btn').forEach(button => {
        button.addEventListener('click', function() {
            const category = {
                id: this.dataset.id,
                name: this.dataset.name
            };
            showCategoryForm('update', category);
        });
    });

    // Event listeners for delete buttons
    document.querySelectorAll('.delete-btn').forEach(button => {
        button.addEventListener('click', function() {
            categoryIdToDelete = this.dataset.id;
            deleteCategoryConfirmModal.classList.add('active');
        });
    });

    // Add event listeners for modal close buttons
    if (closeCategoryFormBtn) {
        closeCategoryFormBtn.addEventListener('click', hideCategoryForm);
    }
    if (cancelCategoryFormBtn) {
        cancelCategoryFormBtn.addEventListener('click', hideCategoryForm);
    }
    if (closeDeleteConfirmModalBtn) {
        closeDeleteConfirmModalBtn.addEventListener('click', function() {
            categoryIdToDelete = null;
            deleteCategoryConfirmModal.classList.remove('active');
        });
    }
    if (cancelDeleteCategoryBtn) {
        cancelDeleteCategoryBtn.addEventListener('click', function() {
            categoryIdToDelete = null;
            deleteCategoryConfirmModal.classList.remove('active');
        });
    }

    // Close modals if user clicks outside of them
    window.addEventListener('click', function(event) {
        if (event.target === categoryFormContainer) {
            hideCategoryForm();
        }
        if (event.target === deleteCategoryConfirmModal) {
            categoryIdToDelete = null;
            deleteCategoryConfirmModal.classList.remove('active');
        }
    });

    // Confirm delete action
    confirmDeleteCategoryBtn.addEventListener('click', function() {
        if (categoryIdToDelete) {
            console.log('Attempting to delete category with ID:', categoryIdToDelete);
            fetch('../deleteCategory', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'categoryId=' + categoryIdToDelete
            })
            .then(response => {
                console.log('Delete response status:', response.status, 'ok:', response.ok);
                // Log the full response object for inspection
                console.log('Delete raw response:', response);
                if (response.ok) {
                    return response.text().then(text => {
                        console.log('Delete successful response text:', text);
                        return text; // Pass the text along
                    });
                } else {
                    return response.text().then(text => {
                        console.error('Server responded with non-OK status. Response text:', text);
                        throw new Error(text || 'Failed to delete category.');
                    });
                }
            })
            .then(data => {
                console.log('Delete operation data (after text() has resolved):', data);
                if (data.trim() === "Success") { // Use .trim() to handle potential whitespace
                    alert("Category deleted successfully!");
                    location.reload();
                } else {
                    alert("Failed to delete category: " + data);
                }
            })
            .catch(error => {
                console.error('Caught error during delete fetch:', error);
                alert("Error deleting category: " + error.message);
            });
        }
        deleteCategoryConfirmModal.classList.remove('active');
    });

    // Add new category action
    document.getElementById('categoryForm').addEventListener('submit', function(event) {
        event.preventDefault(); // Prevent default form submission
        const action = categoryFormAction.value;
        const id = categoryIdInput.value;
        const name = categoryNameInput.value.trim();

        if (!name) {
            alert('Category name cannot be empty.');
            return;
        }

        let url = '';
        let body = '';

        if (action === 'add') {
            url = '../addCategory';
            body = 'categoryName=' + encodeURIComponent(name);
        } else if (action === 'update') {
            url = '../editCategory';
            body = 'categoryId=' + encodeURIComponent(id) + '&newName=' + encodeURIComponent(name);
        }

        console.log(`Attempting to ${action} category. URL: ${url}, Body: ${body}`);

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: body
        })
        .then(response => {
            console.log(`Response for ${action} category: status`, response.status, 'ok:', response.ok);
            // Log the full response object for inspection
            console.log(`Raw response for ${action} category:`, response);
            if (response.ok) {
                return response.text().then(text => {
                    console.log(`${action} successful response text:`, text);
                    return text; // Pass the text along
                });
            } else {
                return response.text().then(text => {
                    console.error(`Server responded with non-OK status for ${action} category. Response text:`, text);
                    throw new Error(text || 'Operation failed.');
                });
            }
        })
        .then(data => {
            console.log(`${action} operation data (after text() has resolved):`, data);
            if (data.trim() === "Success") { // Use .trim() to handle potential whitespace
                alert(`Category ${action === 'add' ? 'added' : 'updated'} successfully!`);
                location.reload();
            } else {
                alert(`Failed to ${action === 'add' ? 'add' : 'update'} category: ` + data);
            }
        })
        .catch(error => {
            console.error(`Caught error during ${action} category fetch:`, error);
            alert(`Error ${action === 'add' ? 'adding' : 'updating'} category: ` + error.message);
        });

        hideCategoryForm();
    });

    // Profile click event (from original JSP)
    document.getElementById('profile-section').addEventListener('click', function() {
        document.getElementById('profileOverlay').style.display = 'block';
        document.getElementById('profileCard').style.display = 'block';
    });

    // Close popups when clicking overlay (from original JSP)
    document.getElementById('profileOverlay')?.addEventListener('click', function() {
        this.style.display = 'none';
        document.getElementById('profileCard').style.display = 'none';
    });

    // Settings button click (from original JSP)
    document.querySelector('.settings-btn')?.addEventListener('click', function() {
        document.getElementById('settingsOverlay').style.display = 'block';
        document.getElementById('settingsCard').style.display = 'block';
    });
}); 