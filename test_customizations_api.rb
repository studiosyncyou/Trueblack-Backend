#!/usr/bin/env ruby
# Test script to verify customizations API response structure

require_relative 'config/environment'

puts "=== Testing Customizations API Response Structure ==="
puts ""

# Create test data
puts "Creating test option set..."
option_set = OptionSet.create!(
  name: "Size Options",
  display_name: "Choose Your Size",
  rista_option_set_id: "test-size-set",
  min_selections: 1,
  max_selections: 1
)

puts "Creating test customization options..."
small = CustomizationOption.create!(
  option_set: option_set,
  name: "Small (8oz)",
  price: 0.0,
  is_default: true,
  rista_option_id: "test-small",
  rista_item_id: "test-small-item"
)

large = CustomizationOption.create!(
  option_set: option_set,
  name: "Large (16oz)",
  price: 60.0,
  is_default: false,
  rista_option_id: "test-large",
  rista_item_id: "test-large-item"
)

puts "Finding or creating test menu item..."
category = Category.first || Category.create!(name: "Test Category", store: Store.first!)
menu_item = MenuItem.find_or_create_by!(rista_code: "TEST-ITEM") do |item|
  item.name = "Test Latte"
  item.short_name = "Latte"
  item.price = 200.0
  item.category = category
  item.is_veg = true
  item.dietary_type = 'veg'
end

puts "Linking option set to menu item..."
MenuItemOptionSet.find_or_create_by!(
  menu_item: menu_item,
  option_set: option_set
)

puts ""
puts "=== Test Data Created ==="
puts "Option Set: #{option_set.name}"
puts "Options: #{option_set.customization_options.count}"
puts "Menu Item: #{menu_item.name}"
puts ""

# Test the API response structure (simulate controller transform)
puts "=== Simulating API Response ==="
puts ""

transformed = {
  id: menu_item.id,
  name: menu_item.name,
  shortName: menu_item.short_name,
  description: menu_item.description,
  price: menu_item.price.to_f,
  image: menu_item.image_url,
  isVeg: menu_item.is_veg,
  dietaryType: menu_item.dietary_type,
  allergenInfo: menu_item.allergen_info&.split(',') || [],
  isAvailable: menu_item.is_available,
  categoryId: menu_item.category_id,
  customizations: menu_item.option_sets.includes(:customization_options).map do |os|
    {
      id: os.id,
      name: os.name,
      displayName: os.display_name,
      minSelections: os.min_selections,
      maxSelections: os.max_selections,
      options: os.customization_options.map do |opt|
        {
          id: opt.id,
          name: opt.name,
          price: opt.price.to_f,
          isDefault: opt.is_default || false
        }
      end
    }
  end,
  ristaData: {
    code: menu_item.rista_code,
    categoryId: menu_item.rista_category_id,
    subCategoryId: menu_item.rista_subcategory_id
  }
}

require 'json'
puts JSON.pretty_generate(transformed)

puts ""
puts "=== Cleaning up test data ==="
MenuItemOptionSet.where(menu_item: menu_item).delete_all
option_set.destroy
menu_item.destroy if menu_item.rista_code == "TEST-ITEM"

puts "✓ Test completed successfully!"
