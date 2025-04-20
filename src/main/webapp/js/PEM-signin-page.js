const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');
const form = document.getElementById('loginForm');
const passwordError = document.getElementById('passwordError'); 

function isValidEmail(email) {
  return /\S+@\S+\.\S+/.test(email);
}

function isValidPassword(password) {
  passwordError.textContent = ''; 

  if (password.length < 12) {
    passwordError.textContent = 'Password must be at least 12 characters long.';
    return false;
  }
  if (!/[A-Z]/.test(password)) {
    passwordError.textContent = 'Password must contain at least one uppercase letter.';
    return false;
  }
  if (!/[a-z]/.test(password)) {
    passwordError.textContent = 'Password must contain at least one lowercase letter.';
    return false;
  }
  if (!/[0-9]/.test(password)) {
    passwordError.textContent = 'Password must contain at least one number.';
    return false;
  }
  if (!/[^a-zA-Z0-9]/.test(password)) {
    passwordError.textContent = 'Password must contain at least one special character.';
    return false;
  }
  return true;
}

form.addEventListener('submit', (event) => {
  event.preventDefault(); 

  const email = emailInput.value.trim();
  const password = passwordInput.value.trim();

  let isValid = true;

  if (!isValidEmail(email)) {
    emailInput.style.borderColor = 'red';
    isValid = false;
  } else {
    emailInput.style.borderColor = '#ddd';
  }

  if (!isValidPassword(password)) {
    isValid = false; 
  }

  if (isValid) {
   
    alert('Form submitted successfully!');
  }
});

