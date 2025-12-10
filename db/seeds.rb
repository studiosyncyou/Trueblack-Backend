# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting Database Seed..."

# ==========================================
# 1. STORES
# ==========================================
# ==========================================
# 1. STORES
# ==========================================
stores_data = [
  {
    name: 'Kompally',
    space_name: 'Soft Sand',
    area: 'Kompally',
    address: 'Financial District, Kompally, Hyderabad',
    phone: '+91 98765 43210',
    latitude: 17.5367,
    longitude: 78.4878,
    hours: '7:00 AM - 11:00 PM',
    branch_code: 'KKT'
  },
  {
    name: 'Jubilee Hills',
    space_name: 'Modern Beige',
    area: 'Jubilee Hills',
    address: 'Road No. 36, Jubilee Hills, Hyderabad',
    phone: '+91 98765 43211',
    latitude: 17.4326,
    longitude: 78.4071,
    hours: '7:00 AM - 11:00 PM',
    branch_code: 'KKT'
  },
  {
    name: 'Loft',
    space_name: 'Oak Moss',
    area: 'Madhapur',
    address: 'HITEC City, Madhapur, Hyderabad',
    phone: '+91 98765 43212',
    latitude: 17.4483,
    longitude: 78.3915,
    hours: '8:00 AM - 12:00 AM',
    branch_code: 'KKT'
  },
  {
    name: 'Film Nagar',
    space_name: 'Burnt Earth',
    area: 'Film Nagar',
    address: 'Film Nagar, Jubilee Hills, Hyderabad',
    phone: '+91 98765 43213',
    latitude: 17.4134,
    longitude: 78.4084,
    hours: '7:00 AM - 11:00 PM',
    branch_code: 'KKT'
  },
  {
    name: 'Kokapet',
    space_name: 'Travertine',
    area: 'Kokapet',
    address: 'Financial District, Kokapet, Hyderabad',
    phone: '+91 98765 43214',
    latitude: 17.3956,
    longitude: 78.3323,
    hours: '7:00 AM - 11:00 PM',
    branch_code: 'KKT'
  }
]

stores = []
stores_data.each do |store_attrs|
  store = Store.find_or_initialize_by(name: store_attrs[:name])
  store.assign_attributes(store_attrs)
  store.save!
  stores << store
  puts "  ✅ Store: #{store.name} (Lat: #{store.latitude}, Long: #{store.longitude})"
end

# ==========================================
# 2. MENU DATA
# ==========================================
# Helper to map category keys to display names
category_names = {
  'espresso_hot' => 'ESPRESSO HOT',
  'espresso_iced' => 'ESPRESSO ICED',
  'cold_brew' => 'COLD BREW',
  'cremes' => 'CREMES',
  'smoothie_bowls' => 'SMOOTHIE BOWLS',
  'non_coffee' => 'NON COFFEE/TEA',
  'matcha' => 'MATCHA',
  'breakfast_toast' => 'ALL DAY BREAKFAST',
  'french_toast' => 'FRENCH TOAST',
  'burgers' => 'BURGERS',
  'sandwiches' => 'SANDWICHES',
  'focaccia' => 'FOCACCIA',
  'croissant_sandwich' => 'CROISSANT SANDWICH',
  'mains' => 'MAINS',
  'bagels' => 'BAGELS',
  'sides' => 'SIDES',
  'marketplace' => 'MARKETPLACE'
}

menu_items_data = {
  'espresso_hot' => [
    { name: 'Shot', description: 'Single espresso shot', price: 220 },
    { name: 'Long Black', description: 'Espresso with hot water', price: 240 },
    { name: 'Cortado', description: 'Espresso cut with warm milk', price: 260 },
    { name: 'Flat White', description: 'Velvety microfoam with espresso', price: 280 },
    { name: 'Cappuccino', description: 'Equal parts espresso, milk, foam', price: 290 },
    { name: 'Latte', description: 'Smooth espresso with steamed milk', price: 290 },
    { name: 'Spanish Latte', description: 'Sweet with condensed milk', price: 310 },
    { name: 'True Mocha Hot', description: 'Signature dark latte', price: 340 }
  ],
  'espresso_iced' => [
    { name: 'Dirty Coffee', description: 'Cold brew with espresso shot', price: 310 },
    { name: 'Iced Latte', description: 'Cold espresso with milk', price: 290 },
    { name: 'True Vanilla Latte', description: 'House-made vanilla iced latte', price: 340 },
    { name: 'True Mocha Iced', description: 'Chocolate espresso iced', price: 350 },
    { name: 'Vietnamese Latte', description: 'Sweetened condensed milk iced latte', price: 340 },
    { name: 'Cranberry Espresso', description: 'Tart cranberry with espresso', price: 340 },
    { name: 'Valencia Orange Coffee', description: 'Citrus-infused cold coffee', price: 370 },
    { name: 'Espresso Tonic', description: 'Espresso with tonic water', price: 370 }
  ],
  'cold_brew' => [
    { name: 'Cold Brew', description: '18 hour slow-extracted cold brew', price: 290 },
    { name: 'Vanilla Cream', description: 'Cold brew with vanilla cream', price: 340 },
    { name: 'Toffee Nut', description: 'Cold brew with toffee nut', price: 360 },
    { name: 'Nitro', description: 'Nitrogen-infused cold brew', price: 300 }
  ],
  'cremes' => [
    { name: 'OG Gold Coffee', description: 'Rich creamy eggless whipped coffee', price: 340 },
    { name: 'Peanut Butter Creme', description: 'Creamy peanut butter whipped', price: 360 },
    { name: 'Brookie', description: 'Lotus biscoff whipped creme', price: 360 },
    { name: 'Hazelnut Creme', description: 'Rich hazelnut whipped creme', price: 360 },
    { name: 'Matcha Creme', description: 'Japanese matcha whipped creme', price: 420 }
  ],
  'smoothie_bowls' => [
    { name: 'Berry Bowl', description: 'Fresh berry smoothie bowl', price: 400 },
    { name: 'Chocolate Bowl', description: 'Rich chocolate smoothie bowl', price: 400 },
    { name: 'Green Bowl', description: 'Healthy green smoothie bowl', price: 420 },
    { name: 'Yogurt Bowl', description: 'Creamy yogurt smoothie bowl', price: 420 }
  ],
  'non_coffee' => [
    { name: 'True Chocolate Hot', description: 'Rich hot chocolate', price: 300 },
    { name: 'Strawberry Latte', description: 'Fresh strawberry latte', price: 350 },
    { name: 'Kombu INF Iced', description: 'Kombucha infused iced tea', price: 310 },
    { name: 'Rose Oolong Iced', description: 'Floral rose oolong iced tea', price: 370 },
    { name: 'Orange Refresher Iced', description: 'Citrus orange refresher', price: 350 },
    { name: 'Chamomile Tea', description: 'Calming chamomile tea', price: 280 },
    { name: 'Turmeric Ginger', description: 'Spiced turmeric ginger tea', price: 280 },
    { name: 'Blossom Chai', description: 'Aromatic blossom chai', price: 280 },
    { name: 'Watermelon Juice', description: 'Fresh watermelon juice', price: 280 },
    { name: 'Orange Juice', description: 'Fresh orange juice', price: 280 }
  ],
  'matcha' => [
    { name: 'Matcha Latte Hot', description: 'Hot Japanese matcha latte', price: 360 },
    { name: 'Matcha Latte Iced', description: 'Iced Japanese matcha latte', price: 360 },
    { name: 'Cocoa Matcha', description: 'Chocolate matcha fusion', price: 390 }
  ],
  'breakfast_toast' => [
    { name: 'Avocado Toast', description: 'Fresh avocado on sourdough', price: 440 },
    { name: 'Black Summer Toast', description: 'Seasonal black summer toast', price: 450 },
    { name: 'Red Pepper Hummus Toast', description: 'Homemade hummus with peppers', price: 420 },
    { name: 'Eggplant Toast', description: 'Roasted eggplant on sourdough', price: 420 },
    { name: 'Eggs on Toast', description: 'Perfectly cooked eggs on sourdough', price: 430 },
    { name: 'Tumago Egg Toast', description: 'Japanese-style egg on sourdough', price: 440 },
    { name: 'Pesto Chicken Toast', description: 'Pesto grilled chicken on sourdough', price: 460 }
  ],
  'french_toast' => [
    { name: 'Original', description: 'Classic French toast', price: 440 },
    { name: 'Chocolate', description: 'Rich chocolate French toast', price: 460 },
    { name: 'Tiramisu', description: 'Tiramisu-inspired French toast', price: 485 }
  ],
  'burgers' => [
    { name: 'Veg Burger', description: 'Delicious vegetarian burger', price: 430 },
    { name: 'Grilled Chicken Burger', description: 'Juicy grilled chicken burger', price: 450 },
    { name: 'Crispy Chicken Burger', description: 'Crispy fried chicken burger', price: 460 }
  ],
  'sandwiches' => [
    { name: 'Veg Sandwich', description: 'Fresh vegetable sandwich', price: 380 },
    { name: 'Chicken Salad Sandwich', description: 'Chicken salad sandwich', price: 400 }
  ],
  'focaccia' => [
    { name: 'Spiced Honey Bean', description: 'Honey beans on focaccia', price: 440 },
    { name: 'Pesto Paneer', description: 'Pesto paneer on focaccia', price: 470 },
    { name: 'Pepperoni', description: 'Classic pepperoni focaccia', price: 460 },
    { name: 'Chicken Ham', description: 'Chicken ham focaccia', price: 460 }
  ],
  'croissant_sandwich' => [
    { name: 'Mushroom Egg Croissant', description: 'Mushroom and egg in croissant', price: 440 },
    { name: 'Chicken Ham Croissant', description: 'Chicken ham in croissant', price: 420 },
    { name: 'Cottage Cheese Croissant', description: 'Cottage cheese in croissant', price: 470 }
  ],
  'mains' => [
    { name: 'Red Sauce Pasta', description: 'Classic red sauce pasta', price: 430 },
    { name: 'White Sauce Pasta', description: 'Creamy white sauce pasta', price: 430 },
    { name: 'Pesto Aglio Olio Pasta', description: 'Pesto garlic oil pasta', price: 430 },
    { name: 'Pesto Grilled Chicken', description: 'Pesto chicken with sides', price: 495 },
    { name: 'Pesto Grilled Paneer', description: 'Pesto paneer with sides', price: 495 }
  ],
  'bagels' => [
    { name: 'Jalapeno Cream Cheese', description: 'Spicy jalapeno cream cheese bagel', price: 290 },
    { name: 'Classic Cream Cheese', description: 'Classic cream cheese bagel', price: 280 },
    { name: 'Japanese Style', description: 'Japanese-inspired bagel', price: 380 },
    { name: 'Scrambled Egg', description: 'Fluffy scrambled eggs bagel', price: 330 }
  ],
  'sides' => [
    { name: 'Classic Fries', description: 'Crispy golden fries', price: 250 },
    { name: 'Peri Peri Fries', description: 'Spicy peri peri fries', price: 280 },
    { name: 'Cheesy Peri Peri Fries', description: 'Cheesy spicy peri peri fries', price: 330 }
  ],
  'marketplace' => [
    { name: 'Coffee Scrub', description: '100% Arabica coffee body scrub', price: 550 },
    { name: 'Dune Mug', description: 'Handcrafted ceramic mug', price: 850 },
    { name: 'Dune Cup', description: 'Artisan ceramic cup', price: 650 },
    { name: 'Kinto Tumbler Beige', description: 'Insulated travel tumbler', price: 1250 },
    { name: 'Kinto Tumbler Steel', description: 'Stainless steel tumbler', price: 1450 },
    { name: 'Moonlight Cup', description: 'Elegant ceramic cup', price: 750 },
    { name: 'True Mocha Soap', description: 'Coffee & cocoa natural soap', price: 350 },
    { name: 'Valencia Orange Soap', description: 'Valencia orange natural soap', price: 350 }
  ]
}

# ==========================================
# 3. SEEDING
# ==========================================

stores.each do |store|
  puts "  🏪 Seeding Menu for #{store.name}..."

  menu_items_data.each do |category_key, items|
    category_name = category_names[category_key] || category_key.humanize.upcase

    category = store.categories.find_or_create_by!(name: category_name)

    items.each do |item_data|
      # Map item names to filenames where they differ from the slug
      # Based on storeMenus.js and actual files
      filename_mapping = {
        'True Mocha Hot' => 'true-mocha.jpg',
        'Berry Bowl' => 'berry.jpg',
        'Chocolate Bowl' => 'chocolate.jpg',
        'Green Bowl' => 'green.jpg',
        'Yogurt Bowl' => 'yogurt.jpg',
        'True Chocolate Hot' => 'hot-chocolate.jpg',
        'Kombu INF Iced' => 'item-default.jpg', # Placeholder
        'Orange Refresher Iced' => 'item-default.jpg',
        'Chamomile Tea' => 'item-default.jpg',
        'Turmeric Ginger' => 'item-default.jpg',
        'Blossom Chai' => 'item-default.jpg',
        'Watermelon Juice' => 'item-default.jpg',
        'Orange Juice' => 'item-default.jpg',
        'Red Pepper Hummus Toast' => 'item-default.jpg',
        'Tumago Egg Toast' => 'item-default.jpg',
        'Red Sauce Pasta' => 'item-default.jpg',
        'White Sauce Pasta' => 'item-default.jpg',
        'Pesto Aglio Olio Pasta' => 'item-default.jpg',
        'Pesto Grilled Chicken' => 'item-default.jpg',
        'Pesto Grilled Paneer' => 'item-default.jpg',
        'Jalapeno Cream Cheese' => 'item-default.jpg',
        'Classic Cream Cheese' => 'item-default.jpg',
        'Japanese Style' => 'item-default.jpg',
        'Scrambled Egg' => 'item-default.jpg',
        'Cheesy Peri Peri Fries' => 'item-default.jpg'
      }

      # Default slug strategy: "Long Black" -> "long-black.jpg"
      slug = item_data[:name].downcase.gsub(' ', '-')
      filename = filename_mapping[item_data[:name]] || "#{slug}.jpg"

      # Check if file exists in public/images/menu (relative to Rails root)
      # Note: In production, this check runs on the server filesystem
      file_path = Rails.root.join('public', 'images', 'menu', filename)

      # Base URL for the production server
      base_url = "https://trueblack-api-production.up.railway.app/images/menu"

      # If file exists (or we have a mapping which implies we expect it), use it.
      # Otherwise fallback to nil or a default.
      # For now, we assume if it's in the mapping or the slug matches a file, it's good.
      image_url = "#{base_url}/#{filename}"

      category.menu_items.find_or_initialize_by(name: item_data[:name]).tap do |item|
        item.description = item_data[:description]
        item.price = item_data[:price]
        item.image_url = image_url
        item.is_available = true

        # Determine if veg or non-veg
        # Simple logic: if name/description contains chicken, egg, ham, pepperoni, etc -> non-veg
        # But exclude 'eggless'
        non_veg_keywords = [ 'chicken', 'egg', 'ham', 'pepperoni', 'bacon', 'fish', 'prawn', 'shrimp' ]
        text_to_check = "#{item_data[:name]} #{item_data[:description]}".downcase

        is_non_veg = non_veg_keywords.any? do |keyword|
          text_to_check.include?(keyword) && !text_to_check.include?('eggless')
        end

        item.is_veg = !is_non_veg
        item.save!
      end
    end
  end
end

puts "✅ Database Seed Completed Successfully!"
