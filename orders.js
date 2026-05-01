let currentFilter = 'all';
let selectedOrderId = null;
let orders = [];

function statusLabel(status) {
  return status === 'being_prepared'
    ? 'Preparing'
    : status.charAt(0).toUpperCase() + status.slice(1);
}

function formatType(type) {
  return { mobile: 'Mobile', dine_in: 'Dine-In', counter: 'Counter' }[type] || type;
}

function formatTime(value) {
  return String(value).replace('T', ' ').slice(0, 16);
}

async function loadOrders() {
  const body = document.getElementById('ordersBody');
  body.innerHTML = `<tr><td colspan="6" class="empty-state">Loading orders...</td></tr>`;

  try {
    orders = await apiRequest(`/api/orders?status=${currentFilter}`);
    renderOrders();
  } catch (error) {
    body.innerHTML = `<tr><td colspan="6" class="empty-state">${error.message}</td></tr>`;
  }
}

function renderOrders() {
  const body = document.getElementById('ordersBody');

  body.innerHTML = orders.map(order => `
    <tr onclick="showDetail(${order.order_id})" class="${selectedOrderId === order.order_id ? 'selected' : ''}">
      <td data-label="Order ID">#${order.order_id}</td>
      <td data-label="Customer">${order.customer_name}</td>
      <td data-label="Type">${formatType(order.order_type)}</td>
      <td data-label="Time">${formatTime(order.order_time)}</td>
      <td data-label="Total">$${Number(order.total_price).toFixed(2)}</td>
      <td data-label="Status"><span class="status-badge status-${order.status}">${statusLabel(order.status)}</span></td>
    </tr>
  `).join('');

  if (orders.length === 0) {
    body.innerHTML = `<tr><td colspan="6" class="empty-state">No orders found.</td></tr>`;
  }
}

async function showDetail(orderId) {
  selectedOrderId = orderId;
  renderOrders();

  try {
    const data = await apiRequest(`/api/orders/${orderId}`);
    const order = data.order;
    const items = data.items;
    const panel = document.getElementById('detailPanel');

    document.getElementById('detailTitle').textContent = `Order #${orderId}`;
    document.getElementById('detailMeta').innerHTML = `
      <div class="meta-item"><strong>${order.customer_name}</strong>Customer</div>
      <div class="meta-item"><strong>${formatType(order.order_type)}</strong>Type</div>
      <div class="meta-item"><strong>${formatTime(order.order_time)}</strong>Time</div>
      <div class="meta-item"><strong><span class="status-badge status-${order.status}">${statusLabel(order.status)}</span></strong>Status</div>
    `;

    document.getElementById('detailItems').innerHTML = items.map(item => {
      const extras = [item.size, item.milk_type, item.add_on].filter(Boolean).join(' | ');
      return `
        <div class="detail-item-row">
          <div>
            <div>${item.name} x ${item.quantity}</div>
            ${extras ? `<div class="di-info">${extras}</div>` : ''}
          </div>
          <div>$${Number(item.line_price).toFixed(2)}</div>
        </div>
      `;
    }).join('');

    document.getElementById('detailTotal').innerHTML = `
      <div>Total: $${Number(order.total_price).toFixed(2)}</div>
      <div class="status-actions">
        <button onclick="updateStatus(${orderId}, 'ordered')">Ordered</button>
        <button onclick="updateStatus(${orderId}, 'being_prepared')">Preparing</button>
        <button onclick="updateStatus(${orderId}, 'ready')">Ready</button>
        <button onclick="updateStatus(${orderId}, 'completed')">Completed</button>
      </div>
    `;

    panel.classList.add('open');
    panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  } catch (error) {
    alert(error.message);
  }
}

function closeDetail() {
  selectedOrderId = null;
  document.getElementById('detailPanel').classList.remove('open');
  renderOrders();
}

async function updateStatus(orderId, status) {
  try {
    await apiRequest(`/api/orders/${orderId}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    });
    await loadOrders();
    await showDetail(orderId);
  } catch (error) {
    alert(error.message);
  }
}

document.querySelectorAll('#filterTabs button').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('#filterTabs button').forEach(item => item.classList.remove('active'));
    button.classList.add('active');
    currentFilter = button.dataset.status;
    closeDetail();
    loadOrders();
  });
});

loadOrders();
