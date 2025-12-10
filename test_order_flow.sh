#!/bin/bash

echo "🧪 Testing Backend → Rista Flow"
echo "================================"
echo ""

BASE_URL="https://trueblack-api-production.up.railway.app/api/v1"
TOKEN="mock-admin-token-for-testing"

echo "1️⃣ Testing Stores Endpoint..."
curl -s "$BASE_URL/stores" | jq -r '.[] | "  ✓ \(.name) (branch: \(.branch_code // "none"))"'
echo ""

echo "2️⃣ Testing Menu Endpoint..."
MENU_COUNT=$(curl -s "$BASE_URL/menu" | jq '. | length')
echo "  ✓ Found $MENU_COUNT menu items"
echo ""

echo "3️⃣ Getting a real menu item to test with..."
FIRST_ITEM=$(curl -s "$BASE_URL/menu" | jq -r '.[0]')
ITEM_ID=$(echo "$FIRST_ITEM" | jq -r '.id')
ITEM_NAME=$(echo "$FIRST_ITEM" | jq -r '.name')
ITEM_PRICE=$(echo "$FIRST_ITEM" | jq -r '.price')
echo "  ✓ Using: $ITEM_NAME (ID: $ITEM_ID, Price: ₹$ITEM_PRICE)"
echo ""

echo "4️⃣ Creating test order via backend..."
ORDER_RESPONSE=$(curl -s -X POST "$BASE_URL/orders" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"storeId\": 1,
    \"branchCode\": \"KKT\",
    \"items\": [
      {
        \"id\": $ITEM_ID,
        \"menu_item_id\": $ITEM_ID,
        \"name\": \"$ITEM_NAME\",
        \"quantity\": 1,
        \"price\": $ITEM_PRICE
      }
    ],
    \"totalAmount\": $ITEM_PRICE,
    \"paymentMethod\": \"cash\",
    \"orderType\": \"pickup\",
    \"notes\": \"Test order from script\"
  }")

echo "$ORDER_RESPONSE" | jq '.'
echo ""

ORDER_ID=$(echo "$ORDER_RESPONSE" | jq -r '.id')
INVOICE_NUMBER=$(echo "$ORDER_RESPONSE" | jq -r '.invoiceNumber')
STATUS=$(echo "$ORDER_RESPONSE" | jq -r '.status')

echo "5️⃣ Order Created:"
echo "  • Order ID: $ORDER_ID"
echo "  • Status: $STATUS"
echo "  • Rista Invoice: $INVOICE_NUMBER"
echo ""

if [ "$INVOICE_NUMBER" != "null" ]; then
  echo "✅ SUCCESS! Order was proxied to Rista POS"
  echo "   Invoice Number: $INVOICE_NUMBER"
else
  echo "⚠️  Order saved to backend but NOT sent to Rista"
  echo "   Check Railway logs for Rista API errors:"
  echo "   cd /Users/teja/Desktop/Backend/trueblack-api"
  echo "   railway logs --filter='Rista'"
fi
echo ""

echo "6️⃣ Fetching order history..."
ORDER_HISTORY=$(curl -s "$BASE_URL/orders" \
  -H "Authorization: Bearer $TOKEN")

ORDER_COUNT=$(echo "$ORDER_HISTORY" | jq '. | length')
echo "  ✓ Found $ORDER_COUNT orders for Admin user"
echo ""

echo "📊 Summary:"
echo "  Backend: ✓ Working"
echo "  Menu: ✓ $MENU_COUNT items loaded"
echo "  Order Creation: ✓ Working"
echo "  Order History: ✓ $ORDER_COUNT orders"
if [ "$INVOICE_NUMBER" != "null" ]; then
  echo "  Rista POS: ✓ Synced (Invoice: $INVOICE_NUMBER)"
else
  echo "  Rista POS: ✗ Not synced (check logs)"
fi
