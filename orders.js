const customers = {
  101: 'Emily Carter',
  102: 'Daniel Kim',
  103: 'Sophia Patel',
  104: 'Mason Reed',
  105: 'Ava Johnson',
  106: 'Walk-In',
};

const menuItems = {
  1: 'Espresso',
  2: 'Latte',
  3: 'Cappuccino',
  4: 'Mocha',
  5: 'Cold Brew',
  6: 'Blueberry Muffin',
  7: 'Bagel',
  8: 'Matcha Latte',
};

const orders = [
  { order_id: 1001, customer_id: 101, employee_id: 201, order_type: 'mobile',  order_time: '2026-03-01 08:15', status: 'ready',           total_price: 8.50  },
  { order_id: 1002, customer_id: 102, employee_id: 202, order_type: 'dine_in', order_time: '2026-03-01 09:05', status: 'completed',       total_price: 4.95  },
  { order_id: 1003, customer_id: 106, employee_id: 201, order_type: 'counter', order_time: '2026-03-01 09:40', status: 'completed',       total_price: 7.25  },
  { order_id: 1004, customer_id: 103, employee_id: 203, order_type: 'mobile',  order_time: '2026-03-01 10:20', status: 'being_prepared',  total_price: 11.50 },
  { order_id: 1005, customer_id: 104, employee_id: 202, order_type: 'dine_in', order_time: '2026-03-01 11:10', status: 'ready',           total_price: 8.50  },
  { order_id: 1006, customer_id: 105, employee_id: 201, order_type: 'mobile',  order_time: '2026-03-01 12:30', status: 'ordered',         total_price: 10.75 },
  { order_id: 1007, customer_id: 101, employee_id: 203, order_type: 'counter', order_time: '2026-03-01 13:05', status: 'completed',       total_price: 9.25  },
  { order_id: 1008, customer_id: 102, employee_id: 202, order_type: 'mobile',  order_time: '2026-03-01 14:15', status: 'ordered',         total_price: 10.00 },
];

const orderItems = {
  1001: [
    { item_id: 2, qty: 1, size: 'medium', milk: 'oat',    add_on: 'vanilla',     price: 5.25 },
    { item_id: 6, qty: 1, size: null,     milk: null,     add_on: null,          price: 3.25 },
  ],
  1002: [
    { item_id: 3, qty: 1, size: 'small',  milk: 'whole',  add_on: null,          price: 4.95 },
  ],
  1003: [
    { item_id: 5, qty: 1, size: 'large',  milk: null,     add_on: null,          price: 4.50 },
    { item_id: 7, qty: 1, size: null,     milk: null,     add_on: 'cream cheese',price: 2.75 },
  ],
  1004: [
    { item_id: 4, qty: 2, size: 'medium', milk: 'whole',  add_on: 'extra whip',  price: 11.50 },
  ],
  1005: [
    { item_id: 8, qty: 1, size: 'medium', milk: 'almond', add_on: null,          price: 5.50 },
    { item_id: 1, qty: 1, size: 'single', milk: null,     add_on: null,          price: 3.00 },
  ],
  1006: [
    { item_id: 2, qty: 1, size: 'large',  milk: 'whole',  add_on: null,          price: 5.25 },
    { item_id: 7, qty: 2, size: null,     milk: null,     add_on: 'butter',      price: 5.50 },
  ],
  1007: [
    { item_id: 1, qty: 2, size: 'single', milk: null,     add_on: null,          price: 6.00 },
    { item_id: 6, qty: 1, size: null,     milk: null,     add_on: null,          price: 3.25 },
  ],
  1008: [
    { item_id: 5, qty: 1, size: 'medium', milk: null,     add_on: null,          price: 4.50 },
    { item_id: 8, qty: 1, size: 'large',  milk: 'oat',    add_on: 'vanilla',     price: 5.50 },
  ],
};

let currentFilter = 'all';
let selectedOrderId = null;

function statusLabel(s) {
  return s === 'being_prepared' ? 'Preparing' : s.charAt(0).toUpperCase() + s.slice(1);
}

function formatType(t) {
  return { mobile: 'Mobile', dine_in: 'Dine-In', counter: 'Counter' }[t] || t;
}

function renderOrders() {
  const body = document.getElementById('ordersBody');
  const filtered = currentFilter === 'all'
    ? orders
    : orders.filter(o => o.status === currentFilter);

  body.innerHTML = filtered.map(o => `
    <tr onclick="showDetail(${o.order_id})" class="${selectedOrderId === o.order_id ? 'selected' : ''}">
      <td data-label="Order ID">#${o.order_id}</td>
      <td data-label="Customer">${customers[o.customer_id]}</td>
      <td data-label="Type">${formatType(o.order_type)}</td>
      <td data-label="Time">${o.order_time}</td>
      <td data-label="Total">$${o.total_price.toFixed(2)}</td>
      <td data-label="Status"><span class="status-badge status-${o.status}">${statusLabel(o.status)}</span></td>
    </tr>
  `).join('');

  if (filtered.length === 0) {
    body.innerHTML = `<tr><td colspan="6" style="text-align:center;color:#7a5c3e;padding:2rem">No orders found.</td></tr>`;
  }
}

function showDetail(orderId) {
  selectedOrderId = orderId;
  const order = orders.find(o => o.order_id === orderId);
  const items  = orderItems[orderId] || [];
  const panel  = document.getElementById('detailPanel');

  document.getElementById('detailTitle').textContent = `Order #${orderId}`;

  document.getElementById('detailMeta').innerHTML = `
    <div class="meta-item"><strong>${customers[order.customer_id]}</strong>Customer</div>
    <div class="meta-item"><strong>${formatType(order.order_type)}</strong>Type</div>
    <div class="meta-item"><strong>${order.order_time}</strong>Time</div>
    <div class="meta-item"><strong><span class="status-badge status-${order.status}">${statusLabel(order.status)}</span></strong>Status</div>
  `;

  document.getElementById('detailItems').innerHTML = items.map(i => {
    const extras = [i.size, i.milk, i.add_on].filter(Boolean).join(' · ');
    return `
      <div class="detail-item-row">
        <div>
          <div>${menuItems[i.item_id]} × ${i.qty}</div>
          ${extras ? `<div class="di-info">${extras}</div>` : ''}
        </div>
        <div>$${i.price.toFixed(2)}</div>
      </div>
    `;
  }).join('');

  document.getElementById('detailTotal').textContent = `Total: $${order.total_price.toFixed(2)}`;
  panel.classList.add('open');
  panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  renderOrders();
}

function closeDetail() {
  selectedOrderId = null;
  document.getElementById('detailPanel').classList.remove('open');
  renderOrders();
}

// Filter tabs
document.querySelectorAll('#filterTabs button').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('#filterTabs button').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    currentFilter = btn.dataset.status;
    closeDetail();
  });
});

renderOrders();