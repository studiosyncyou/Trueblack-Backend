# 🎮 How to Use GraphiQL to Monitor Your Backend

## 🌐 Access GraphiQL

Open your browser and go to:
**https://trueblack-api-production.up.railway.app/graphiql**

This is your GraphQL playground - a visual interface to query your Railway backend database.

---

## 📋 Available Queries

### 1. **Check All Orders**

Copy and paste this into GraphiQL:

```graphql
query GetAllOrders {
  orders(limit: 10) {
    id
    status
    totalAmount
    branchCode
    ristaInvoiceNumber
    ristaSynced
    createdAt
    orderItems {
      id
      name
      quantity
      price
      totalPrice
    }
  }
}
```

**What to look for:**
- ✅ `ristaSynced: true` + `ristaInvoiceNumber: "INV-12345"` → Order synced to Rista POS
- ❌ `ristaSynced: false` + `ristaInvoiceNumber: null` → Order NOT synced to Rista

---

### 2. **Check Specific Order by ID**

```graphql
query GetOrderById {
  order(id: "10") {
    id
    status
    totalAmount
    branchCode
    ristaInvoiceNumber
    ristaSynced
    paymentMethod
    orderType
    notes
    createdAt
    orderItems {
      name
      quantity
      price
      totalPrice
      customizations
    }
  }
}
```

**Replace `"10"` with the actual order ID you want to check.**

---

### 3. **Filter Orders by Status**

```graphql
query GetPendingOrders {
  orders(status: "pending", limit: 5) {
    id
    status
    totalAmount
    ristaInvoiceNumber
    ristaSynced
    createdAt
  }
}
```

**Available statuses:** `"pending"`, `"confirmed"`, `"completed"`, `"cancelled"`

---

### 4. **Check All Stores**

```graphql
query GetStores {
  stores {
    id
    name
    address
    phone
    createdAt
  }
}
```

---

## 🎯 How to Run a Query

1. **Open GraphiQL:** https://trueblack-api-production.up.railway.app/graphiql
2. **Delete the default query** in the left panel
3. **Copy one of the queries above** and paste it
4. **Click the ▶️ Play button** (or press Ctrl+Enter / Cmd+Enter)
5. **View results** in the right panel

---

## 🔍 Understanding the Results

### ✅ Order Successfully Synced to Rista

```json
{
  "data": {
    "orders": [
      {
        "id": "10",
        "status": "confirmed",
        "totalAmount": 220.0,
        "branchCode": "KKT",
        "ristaInvoiceNumber": "INV-67890",
        "ristaSynced": true,
        "orderItems": [
          {
            "name": "Shot",
            "quantity": 1,
            "price": 220.0,
            "totalPrice": 220.0
          }
        ]
      }
    ]
  }
}
```

**✅ This means your app → Railway backend → Rista POS integration is working!**

---

### ❌ Order NOT Synced to Rista

```json
{
  "data": {
    "orders": [
      {
        "id": "9",
        "status": "pending",
        "totalAmount": 1617.0,
        "branchCode": null,
        "ristaInvoiceNumber": null,
        "ristaSynced": false
      }
    ]
  }
}
```

**❌ This means orders are reaching your backend but NOT syncing to Rista POS.**

**Common causes:**
1. **`branchCode: null`** → Store doesn't have branch_code set
2. **No Rista logs** → RISTA_API_KEY/RISTA_SECRET missing or invalid
3. **Railway logs show errors** → Check logs with: `railway logs --filter='Rista'`

---

## 🧪 Test Workflow

### Step 1: Place Order in Your App
- Open your mobile app
- Add items to cart
- Go to checkout and place order

### Step 2: Check in GraphiQL
```graphql
query CheckLatestOrders {
  orders(limit: 3) {
    id
    status
    totalAmount
    ristaInvoiceNumber
    ristaSynced
    createdAt
  }
}
```

### Step 3: Verify Rista Sync
- If `ristaSynced: true` → ✅ Working!
- If `ristaSynced: false` → ❌ Check Railway logs

---

## 💡 Pro Tips

### Auto-Complete
- Press **Ctrl+Space** to see available fields
- GraphiQL will show you all possible queries and fields

### Format Query
- Click **Prettify** button to auto-format your query

### View Schema
- Click **Docs** button (top-right) to see all available queries and types

### Multiple Queries
You can run multiple queries at once:

```graphql
query Dashboard {
  storesCount: stores {
    id
  }

  pendingOrders: orders(status: "pending") {
    id
    totalAmount
  }

  recentOrders: orders(limit: 5) {
    id
    ristaInvoiceNumber
    ristaSynced
  }
}
```

---

## 🆚 GraphiQL vs REST API

| Feature | GraphiQL | REST API |
|---------|----------|----------|
| **Access** | Browser (visual) | curl/scripts |
| **Easy to use** | ✅ Yes | Moderate |
| **Filters** | ✅ Built-in | Manual URL params |
| **See all fields** | ✅ Auto-complete | Need docs |
| **Best for** | Quick checks | Automation |

---

## 📊 Example: Full Order Check

```graphql
query FullOrderCheck {
  # Get latest 3 orders
  recentOrders: orders(limit: 3) {
    id
    status
    totalAmount
    branchCode

    # Rista sync status
    ristaInvoiceNumber
    ristaSynced

    # Order details
    paymentMethod
    orderType
    notes
    createdAt

    # Items in order
    orderItems {
      name
      quantity
      price
      totalPrice
    }
  }

  # Get all stores
  stores {
    id
    name
    address
  }
}
```

**This query gives you:**
- Recent orders with full details
- Rista sync status for each order
- All available stores

---

## 🔧 Troubleshooting

### Issue: "Cannot query field 'orders'"

**Cause:** Railway deployment hasn't finished yet.

**Fix:** Wait 1-2 minutes for Railway to deploy the new GraphQL types.

### Issue: All orders show `ristaSynced: false`

**Cause:** Orders aren't syncing to Rista POS.

**Fix:** Check Railway logs:
```bash
cd /Users/teja/Desktop/Backend/trueblack-api
railway logs --filter='Rista'
```

### Issue: No orders returned

**Cause:** No orders in database yet.

**Fix:** Place an order in your mobile app first.

---

## 🎯 Quick Reference

**GraphiQL URL:**
https://trueblack-api-production.up.railway.app/graphiql

**Essential Query:**
```graphql
query {
  orders(limit: 5) {
    id
    ristaInvoiceNumber
    ristaSynced
  }
}
```

**What to check:**
- `ristaSynced: true` → ✅ Working
- `ristaSynced: false` → ❌ Check Railway logs

---

**Happy Monitoring! 🚀**
