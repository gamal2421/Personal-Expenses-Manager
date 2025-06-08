document.addEventListener('DOMContentLoaded', function() {
    const signinBtn = document.getElementById('signinBtn');
    if (signinBtn) {
        signinBtn.addEventListener('click', function() {
            window.location.href = 'login.jsp';
        });
    }
}); 