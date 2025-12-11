# How to Get Exact Store Coordinates from Google Maps

## Step-by-Step Guide:

### 1. Open Google Maps
Go to https://www.google.com/maps

### 2. Search for Each Store Location
Search for the exact address of each TRUE BLACK store:

- **Kompally**: Financial District, Kompally, Hyderabad
- **Jubilee Hills**: Road No. 36, Jubilee Hills, Hyderabad
- **Loft (Hitech City)**: HITEC City, Madhapur, Hyderabad
- **Film Nagar**: Film Nagar, Jubilee Hills, Hyderabad
- **Kokapet**: Financial District, Kokapet, Hyderabad

### 3. Get Precise Coordinates

#### Method 1: Right-Click on Map
1. Find the exact location of the store
2. **Right-click** on the store location
3. Click the **coordinates** (first option in menu)
4. Coordinates will be copied! Format: `17.4239, 78.4738`

#### Method 2: From URL
1. Click on the store location
2. Look at the URL in your browser
3. Find numbers like: `@17.4239,78.4738,17z`
4. The first number is **latitude**: `17.4239`
5. The second number is **longitude**: `78.4738`

#### Method 3: Drop a Pin
1. **Long-press** (or right-click) on the exact store location
2. A red pin will appear
3. At the bottom, click the location card
4. Coordinates will be shown

### 4. Update the Migration File

Edit: `/Users/teja/Desktop/Backend/trueblack-api/db/migrate/20251211101640_add_coordinates_to_stores.rb`

Replace the coordinates with the exact ones from Google Maps:

```ruby
Store.find_by(name: 'Kompally')&.update(
  latitude: 17.XXXXXX,   # Replace with actual coordinates
  longitude: 78.XXXXXX
)
```

### 5. Example - How to Copy Coordinates:

**Before (approximate):**
```
latitude: 17.5500000
longitude: 78.4900000
```

**After (from Google Maps):**
```
latitude: 17.54523981
longitude: 78.48932104
```

### 6. Run the Migration

```bash
cd /Users/teja/Desktop/Backend/trueblack-api
bin/rails db:migrate
git add .
git commit -m "Add accurate store coordinates from Google Maps"
git push
```

### 7. Verify on Railway

After deployment, test the API:
```bash
curl https://trueblack-api-production.up.railway.app/api/v1/stores
```

You should see `latitude` and `longitude` fields for each store!

## Why This Matters:

- **Accurate Dine-In Detection**: 30-meter proximity will work correctly
- **Better User Experience**: Users see correct distances
- **Proper Store Selection**: Nearest store calculation is precise

## Tips for Best Accuracy:

1. **Use Street View**: Switch to Street View to see the exact building
2. **Drop Pin at Entrance**: Put the pin at the store's main entrance
3. **Zoom In**: Zoom in as much as possible before dropping the pin
4. **Check Building Number**: Verify you're at the correct address

## Current Store Addresses:

1. **Kompally** - Financial District, Kompally, Hyderabad
2. **Jubilee Hills** - Road No. 36, Jubilee Hills, Hyderabad
3. **Loft** - HITEC City, Madhapur, Hyderabad
4. **Film Nagar** - Film Nagar, Jubilee Hills, Hyderabad
5. **Kokapet** - Financial District, Kokapet, Hyderabad

---

**After you get the coordinates, I'll help you deploy to Railway!** 🎯
