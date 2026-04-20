const menuItems = [
  { id: 1, name: 'Espresso',         price: 3.00 },
  { id: 2, name: 'Latte',            price: 5.25 },
  { id: 3, name: 'Cappuccino',       price: 4.95 },
  { id: 4, name: 'Mocha',            price: 5.75 },
  { id: 5, name: 'Cold Brew',        price: 4.50 },
  { id: 6, name: 'Blueberry Muffin', price: 3.25 },
  { id: 7, name: 'Bagel',            price: 2.75 },
  { id: 8, name: 'Matcha Latte',     price: 5.50 },
];

function renderMenu() {
  const grid = document.getElementById('menuGrid');
  grid.innerHTML = menuItems.map(item => `
    <div class="menu-card">
      <div class="item-name">${item.name}</div>
      <div class="item-price">$${item.price.toFixed(2)}</div>
    </div>
  `).join('');
}

renderMenu();