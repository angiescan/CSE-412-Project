function getEmployees() {
  return JSON.parse(localStorage.getItem('employees') || '[]');
}

function saveEmployees(employees) {
  localStorage.setItem('employees', JSON.stringify(employees));
}

function getSession() {
  return localStorage.getItem('session');
}

function requireLogin() {
  if (!getSession()) {
    window.location.href = 'login.html';
  }
}

function logout() {
  localStorage.removeItem('session');
  window.location.href = 'login.html';
}
