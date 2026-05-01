async function renderMenu() {
  const grid = document.getElementById('menuGrid');
  grid.innerHTML = '<div class="empty-state">Loading menu...</div>';

  try {
    const menuItems = await apiRequest('/api/menu');
    grid.innerHTML = menuItems.map(item => `
      <div class="menu-card">
        <div class="item-name">${item.name}</div>
        <div class="item-price">$${Number(item.price).toFixed(2)}</div>
      </div>
    `).join('');
  } catch (error) {
    grid.innerHTML = `<div class="empty-state">${error.message}</div>`;
  }
}

renderMenu();
