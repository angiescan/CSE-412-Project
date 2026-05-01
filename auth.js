function getEmployees() {
  return JSON.parse(localStorage.getItem('employees') || '[]');
}

function saveEmployees(employees) {
  localStorage.setItem('employees', JSON.stringify(employees));
}

function getSession() {
  return localStorage.getItem('session');
}

function setSession(employee) {
  localStorage.setItem('session', JSON.stringify(employee));
}

async function apiRequest(path, options = {}) {
  const response = await fetch(path, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });

  const data = await response.json();
  if (!response.ok || data.error) {
    throw new Error(data.error || 'Request failed.');
  }
  return data;
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
