# Integration Verification Guide

## How to Check if Orders are Hitting Backend and Rista POS

### ✅ Step 1: Verify Backend is Receiving Requests

**Open Terminal and watch Railway logs:**
```bash
cd /Users/teja/Desktop/Backend/trueblack-api
railway logs --follow
```

**What to look for:**
- `POST /api/v1/orders` - Means app sent an order
- `[Orders] Creating order for user X` - Backend received it
- `[Orders] Order created with ID: X` - Saved to database

### ✅ Step 2: Check if Rista POS Received the Order

**Look for these log lines:**
```
[Orders] Proxying order X to Rista
[Orders] Rista order created: INV-123456
```

**Or check order invoice numbers:**
```bash
curl -s 'https://trueblack-api-production.up.railway.app/api/v1/orders' \
  -H 'Authorization: Bearer mock-admin-token-for-testing' | \
  python3 -m json.tool | grep -A 2 invoiceNumber
```

**If you see:**
- `"invoiceNumber": "INV-12345"` ✅ Order synced to Rista
- `"invoiceNumber": null` ❌ Order NOT synced to Rista

### ❌ If Rista Sync Failed

**Check Rista API errors:**
```bash
railway logs --filter='Rista' --tail 100
```

**Common issues:**
1. **"Invalid Rista configuration"** - Check environment variables
2. **"Rista API error: 401"** - Invalid API key or secret
3. **"Rista API error: 404"** - Invalid branch code
4. **"Menu item X has no rista_code"** - Item not in Rista catalog

### 🧪 Test Order Creation

**Create a test order from command line:**
```bash
# Get a real menu item first
curl -s 'https://trueblack-api-production.up.railway.app/api/v1/menu' | \
  python3 -m json.tool | head -30

# Create order with that item
curl -X POST 'https://trueblack-api-production.up.railway.app/api/v1/orders' \
  -H 'Authorization: Bearer mock-admin-token-for-testing' \
  -H 'Content-Type: application/json' \
  -d '{
    "storeId": 1,
    "branchCode": "KKT",
    "items": [{"id": 305, "menu_item_id": 305, "name": "Shot", "quantity": 1, "price": 220}],
    "totalAmount": 220,
    "paymentMethod": "cash",
    "orderType": "pickup",
    "notes": "Test order"
  }' | python3 -m json.tool
```

**Check the response:**
- If `"invoiceNumber"` has a value → Rista sync worked ✅
- If `"invoiceNumber": null` → Check Railway logs for errors ❌

### 📱 Verify from Mobile App

**In Metro console, look for:**
```
[Order] Creating order via backend: {...}
[Order] Order created successfully: {id: X, invoiceNumber: "INV-123"}
```

**In Railway logs, look for:**
```
POST /api/v1/orders 201 Created
[Orders] Proxying order X to Rista
[Orders] Rista order created: INV-123456
```

### 🔐 Verify Environment Variables

```bash
cd /Users/teja/Desktop/Backend/trueblack-api
railway variables

# Should show:
# RISTA_API_KEY=adad8263-1f3c-415f-9384-f486ac6d11ba
# RISTA_SECRET=2-ntQ-6apNWr4SsdOYnHe3XQeDS6sagR0YYgxF1DjeM
# RISTA_API_BASE_URL=https://api.rista.store/api/v1
# RISTA_DEFAULT_BRANCH=KKT
```

## 📊 Quick Status Check

```bash
# Check order history
curl -s 'https://trueblack-api-production.up.railway.app/api/v1/orders' \
  -H 'Authorization: Bearer mock-admin-token-for-testing' | \
  python3 -c "import sys,json; orders=json.load(sys.stdin); print(f'Total orders: {len(orders)}'); [print(f'Order {o[\"id\"]}: Invoice={o[\"invoiceNumber\"] or \"Not synced\"}') for o in orders]"
```

## ✅ Success Indicators

- ✅ Backend logs show `POST /api/v1/orders 201 Created`
- ✅ Order has `"invoiceNumber": "INV-XXXXX"`
- ✅ Rista logs show `Rista order created: INV-XXXXX`
- ✅ Order appears in Rista POS dashboard

## ❌ Failure Indicators

- ❌ `"invoiceNumber": null` in response
- ❌ `"synced": false` in ristaData
- ❌ Rista API errors in Railway logs
- ❌ Order NOT in Rista POS dashboard
