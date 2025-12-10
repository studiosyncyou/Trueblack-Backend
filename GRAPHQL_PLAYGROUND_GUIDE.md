# GraphQL Playground Guide for Rista POS Integration

## 🎯 Quick Start

If you have access to Rista's GraphQL Playground, here's how to check if orders are reaching the POS:

---

## 📍 Step 1: Open GraphQL Playground

**URL:** https://api.rista.store/graphql/playground

*(Or the URL provided by Rista)*

---

## 🔐 Step 2: Add Authentication Headers

Click on "HTTP HEADERS" at the bottom of the playground and add:

```json
{
  "x-api-key": "adad8263-1f3c-415f-9384-f486ac6d11ba",
  "x-signature": "GENERATED_SIGNATURE",
  "x-timestamp": "1702134567"
}
```

**Note:** Generating the signature is complex (HMAC-SHA256). Ask your Rista account manager for playground credentials or use the alternative methods below.

---

## 📊 Step 3: Run GraphQL Queries

### Query 1: Get All Recent Sales

Copy and paste this into the playground:

```graphql
query GetRecentSales {
  sales(
    branchCode: "KKT"
    limit: 20
  ) {
    id
    invoiceNumber
    customer {
      name
      phoneNumber
    }
    items {
      name
      quantity
      unitPrice
    }
    totalAmount
    status
    createdAt
  }
}
```

**Look for:**
- Customer name: "Admin"
- Phone: "+919999999999"
- Recent timestamps matching your test orders

---

### Query 2: Check if Specific Order Exists

```graphql
query CheckOrder {
  sale(invoiceNumber: "INV-12345") {
    id
    invoiceNumber
    customer {
      name
      phoneNumber
    }
    items {
      name
      quantity
    }
    totalAmount
    status
  }
}
```

---

### Query 3: Get Branch Info

```graphql
query GetBranches {
  branches {
    code
    name
    address
    isActive
  }
}
```

**Check:** Is "KKT" in the list? If not, that's why orders aren't syncing!

---

### Query 4: Get Menu Catalog

```graphql
query GetMenuCatalog {
  catalog(
    branchCode: "KKT"
    channel: "Dine In"
  ) {
    categories {
      id
      name
      items {
        code
        name
        price
        isAvailable
      }
    }
  }
}
```

---

## ⚡ Alternative: Simpler REST API Check (No Auth Needed)

Since GraphQL requires complex HMAC authentication, **use our backend instead**:

### Open your browser and paste:

```
https://trueblack-api-production.up.railway.app/api/v1/orders
```

**Note:** This won't work in browser due to authentication. Use Terminal instead:

```bash
curl -s 'https://trueblack-api-production.up.railway.app/api/v1/orders' \
  -H 'Authorization: Bearer mock-admin-token-for-testing' | \
  python3 -m json.tool
```

---

## 🔍 What to Look For

### ✅ Success Indicators in GraphQL Playground:

If you run the `GetRecentSales` query and see:

```json
{
  "data": {
    "sales": [
      {
        "id": "12345",
        "invoiceNumber": "INV-67890",
        "customer": {
          "name": "Admin",
          "phoneNumber": "+919999999999"
        },
        "totalAmount": 560,
        "status": "confirmed"
      }
    ]
  }
}
```

**✅ This means orders ARE reaching Rista POS!**

---

### ❌ Failure Indicators:

**No sales found:**
```json
{
  "data": {
    "sales": []
  }
}
```

**Authentication error:**
```json
{
  "errors": [
    {
      "message": "Unauthorized",
      "extensions": {
        "code": "UNAUTHENTICATED"
      }
    }
  ]
}
```

**Branch not found:**
```json
{
  "errors": [
    {
      "message": "Branch KKT not found"
    }
  ]
}
```

---

## 💡 Recommended Approach

Since GraphQL Playground requires complex authentication:

### **Use Railway Logs (Easiest)**

```bash
cd /Users/teja/Desktop/Backend/trueblack-api
railway login  # If needed
railway logs --filter='Rista' --tail 50
```

**Place an order in your app**, then check logs for:
- ✅ `[Orders] Rista order created: INV-12345`
- ❌ `[Orders] Rista API error: ...`

---

## 🎬 Complete Workflow

1. **Place order in app**
2. **Check our backend first:**
   ```bash
   curl -s 'https://trueblack-api-production.up.railway.app/api/v1/orders' \
     -H 'Authorization: Bearer mock-admin-token-for-testing' | \
     grep invoiceNumber
   ```
3. **If invoiceNumber is null, check Railway logs:**
   ```bash
   railway logs --filter='Rista'
   ```
4. **If you have GraphQL Playground access, verify order in Rista:**
   - Use `GetRecentSales` query
   - Look for customer "Admin" with your order amount

---

## 📞 Need Playground Access?

If you don't have GraphQL Playground credentials:

1. Contact your Rista account manager
2. Request GraphQL API access
3. Ask for test credentials with read-only permissions

Or just use Railway logs - they show everything you need! 🎯
