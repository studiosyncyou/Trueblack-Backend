class MenuSyncService
  def self.sync_from_rista(branch_code = nil, force: false)
    new(branch_code, force: force).sync
  end

  def initialize(branch_code = nil, force: false)
    @branch_code = branch_code || ENV.fetch('RISTA_DEFAULT_BRANCH', 'KKT')
    @force = force
    @rista_api = RistaApiService.new
  end

  def sync
    # Check if sync is needed (unless forced)
    unless @force || needs_sync?
      Rails.logger.info "[MenuSync] Skipping sync - last successful sync was recent"
      return { skipped: true, message: 'Sync not needed' }
    end

    # Create sync log
    log = MenuSyncLog.create!(
      status: 'running',
      started_at: Time.current
    )

    begin
      Rails.logger.info "[MenuSync] Starting menu sync for branch: #{@branch_code}"

      # Fetch catalog from Rista
      catalog = @rista_api.fetch_catalog(@branch_code)

      unless catalog && catalog['items'].is_a?(Array)
        raise "Invalid catalog response from Rista"
      end

      items_synced = sync_menu_items(catalog['items'])

      # Mark sync as successful
      log.update!(
        status: 'success',
        items_synced: items_synced,
        completed_at: Time.current
      )

      Rails.logger.info "[MenuSync] Completed successfully - synced #{items_synced} items"

      {
        success: true,
        items_synced: items_synced,
        duration: log.duration
      }

    rescue => e
      Rails.logger.error "[MenuSync] Failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      log.update!(
        status: 'failed',
        error_message: e.message,
        completed_at: Time.current
      )

      raise
    end
  end

  private

  def needs_sync?
    last_sync = MenuSyncLog.last_successful
    last_sync.nil? || last_sync.completed_at < 24.hours.ago
  end

  def sync_menu_items(rista_items)
    items_synced = 0

    # Clear old categories and duplicates BEFORE syncing
    cleanup_old_rista_category

    # Initialize category cache
    @category_cache = {}

    # Fetch full catalog with categories for mapping
    catalog = @rista_api.fetch_catalog(@branch_code)
    category_map = build_category_map(catalog['categories'] || [])

    ActiveRecord::Base.transaction do
      rista_items.each do |item|
        app_category = map_item_to_app_category(item, category_map)
        # Skip items that are mapped to nil (addons, staff items, wastage, etc.)
        next if app_category.nil?

        sync_menu_item(item, app_category)
        items_synced += 1
      end
    end

    items_synced
  end

  def sync_menu_item(rista_item, category)
    # Extract Rista data
    rista_code = rista_item['code'] || rista_item['skuCode'] || rista_item['itemCode']
    name = rista_item['name'] || rista_item['itemName']
    price = rista_item['price'] || rista_item['unitPrice']

    return unless rista_code.present? && name.present?

    # Find or initialize menu item by rista_code
    menu_item = MenuItem.find_or_initialize_by(rista_code: rista_code)

    # Determine dietary type from itemTagIds
    dietary_type = determine_dietary_type(rista_item['itemTagIds'] || [])

    # Update attributes
    menu_item.assign_attributes(
      name: name,
      short_name: rista_item['shortName'] || name,
      description: rista_item['description'] || '',
      price: price.to_f,
      category: category,
      is_available: rista_item['status'] == 'Active' || rista_item['available'] != false,
      is_veg: rista_item['isVeg'].nil? ? true : rista_item['isVeg'],
      dietary_type: dietary_type,
      rista_category_id: rista_item['categoryId']&.to_s,
      rista_subcategory_id: rista_item['subCategoryId']&.to_s,
      image_url: rista_item['image'] || rista_item['imageUrl'],
      last_synced_at: Time.current
    )

    menu_item.save!

    Rails.logger.debug "[MenuSync] Synced: #{name} (#{rista_code}) - #{dietary_type}"
    menu_item
  end

  # Build a map of Rista category/subcategory IDs to names
  def build_category_map(rista_categories)
    map = {}

    rista_categories.each do |category|
      cat_id = category['id'] || category['categoryId']
      cat_name = category['name'] || category['categoryName']

      map[cat_id] = {
        name: cat_name,
        subcategories: {}
      }

      # Map subcategories
      if category['subCategories']
        category['subCategories'].each do |sub|
          sub_id = sub['id'] || sub['subCategoryId']
          sub_name = sub['name'] || sub['subCategoryName']
          map[cat_id][:subcategories][sub_id] = sub_name
        end
      end
    end

    map
  end

  # Map Rista item to app category based on Rista category/subcategory
  def map_item_to_app_category(item, category_map)
    rista_cat_id = item['categoryId']
    rista_subcat_id = item['subCategoryId']

    rista_category_info = category_map[rista_cat_id]
    return find_or_create_app_category('Other') unless rista_category_info

    rista_cat_name = rista_category_info[:name]
    rista_subcat_name = rista_category_info[:subcategories][rista_subcat_id]

    # Determine app category name based on mapping
    app_category_name = determine_app_category(rista_cat_name, rista_subcat_name, item['name'])

    # Return nil if category should be skipped (addons, staff, etc.)
    return nil if app_category_name.nil?

    find_or_create_app_category(app_category_name)
  end

  # Map Rista categories to app categories
  def determine_app_category(rista_category, rista_subcategory, item_name)
    # Normalize category names for matching
    cat = rista_category&.downcase&.strip || ''
    subcat = rista_subcategory&.downcase&.strip || ''

    # Skip addons, staff items, wastage, and others - these should not appear in menu
    return nil if cat.include?('addon')
    return nil if cat.include?('staff')
    return nil if cat.include?('wastage')
    return nil if cat == 'others' # Generic "Others" category should be hidden

    # Espresso Based mapping
    if cat.include?('espresso')
      return 'ESPRESSO ICED' if subcat.include?('iced')
      return 'ESPRESSO HOT' if subcat.include?('hot')
      return 'ESPRESSO HOT' # default for espresso
    end

    # Cold Brew
    return 'COLD BREW' if cat.include?('cold brew')

    # Drip Coffee
    return 'DRIP COFFEE' if cat.include?('drip coffee')

    # Pour Over
    return 'POUR OVER' if cat.include?('pour over')

    # Cremes
    return 'CREMES' if cat.include?('creme')

    # Non Coffee / Tea
    if cat.include?('non coffee') || cat.include?('matcha') || cat.include?('tea')
      return 'MATCHA' if subcat.include?('matcha')
      return 'NON COFFEE/TEA'
    end

    # Food categories
    if cat.include?('food')
      return 'FRENCH TOAST' if subcat.include?('french toast')
      return 'BREAKFAST/TOAST' if subcat.include?('sourdough') || subcat.include?('toast')
      return 'SMOOTHIE BOWLS' if subcat.include?('smoothie')
      return 'BURGERS' if subcat.include?('burger')
      return 'SANDWICHES' if subcat.include?('sandwich')
      return 'BAGELS' if subcat.include?('bagel')
      return 'MAINS' if subcat.include?('mains') || subcat.include?('shareable')
      return 'SIDES' if subcat.include?('salad') || subcat.include?('sides')
    end

    # Desserts
    return 'DESSERTS' if cat.include?('dessert')

    # Marketplace / Merchandise / Roasted Coffee
    return 'MARKETPLACE' if cat.include?('market') || cat.include?('merchandise') || cat.include?('roasted coffee')

    # Default to Other for unmapped categories
    'Other'
  end

  def find_or_create_app_category(category_name)
    # Return nil if category name is blank (should never happen but extra safety)
    return nil if category_name.blank?

    # Return cached category if already found/created
    return @category_cache[category_name] if @category_cache&.key?(category_name)

    # Find or create default store
    store = Store.find_or_create_by!(name: 'TRUE BLACK Coffee') do |s|
      s.address = 'Multiple Locations'
      s.latitude = 17.385044
      s.longitude = 78.486671
    end

    # Find category by name only (don't create duplicates across stores)
    category = Category.find_by(name: category_name)

    unless category
      category = Category.create!(name: category_name, store: store)
    end

    # Cache the category
    @category_cache ||= {}
    @category_cache[category_name] = category

    category
  end

  def find_or_create_rista_category
    # Deprecated: Use find_or_create_app_category instead
    find_or_create_app_category('Other')
  end

  def cleanup_old_rista_category
    # One-time cleanup: Mark items from old "Rista Items" category as unavailable (can't delete due to FK)
    old_category = Category.find_by(name: 'Rista Items')
    if old_category
      old_items_count = old_category.menu_items.where(is_available: true).count
      if old_items_count > 0
        Rails.logger.info "[MenuSync] Marking #{old_items_count} items from old 'Rista Items' category as unavailable"
        MenuItem.where(category: old_category).update_all(is_available: false)
        Rails.logger.info "[MenuSync] Cleanup completed"
      end
    end

    # Mark old items without rista_code as unavailable (can't delete due to FK constraints with orders)
    # Check for both nil and empty string
    items_without_code = MenuItem.where("rista_code IS NULL OR rista_code = ''").where(is_available: true).count
    if items_without_code > 0
      Rails.logger.info "[MenuSync] Marking #{items_without_code} items without rista_code as unavailable (old local data)"
      MenuItem.where("rista_code IS NULL OR rista_code = ''").update_all(is_available: false)
      Rails.logger.info "[MenuSync] Marked #{items_without_code} items as unavailable"
    end

    # Mark addon items from previous syncs as unavailable (they should not appear in menu)
    # Get addon category IDs from Rista
    addon_rista_category_ids = []
    catalog = @rista_api.fetch_catalog(@branch_code)
    if catalog && catalog['categories']
      addon_categories = catalog['categories'].select { |c| (c['name'] || '').downcase.include?('addon') }
      addon_rista_category_ids = addon_categories.map { |c| c['categoryId'] || c['id'] }.compact
    end

    if addon_rista_category_ids.any?
      addon_items = MenuItem.where(rista_category_id: addon_rista_category_ids.map(&:to_s), is_available: true).count
      if addon_items > 0
        Rails.logger.info "[MenuSync] Marking #{addon_items} addon items as unavailable"
        MenuItem.where(rista_category_id: addon_rista_category_ids.map(&:to_s)).update_all(is_available: false)
      end
    end

    # Clean up duplicate categories (keep only first of each name)
    Category.select('name, MIN(id) as min_id').group('name').having('COUNT(*) > 1').each do |result|
      category_name = result.name
      keep_id = result.min_id

      duplicates = Category.where(name: category_name).where.not(id: keep_id)
      if duplicates.any?
        Rails.logger.info "[MenuSync] Cleaning up #{duplicates.count} duplicate '#{category_name}' categories"

        # Reassign items to the category we're keeping
        keeper = Category.find(keep_id)
        duplicates.each do |dup|
          MenuItem.where(category: dup).update_all(category_id: keeper.id)
          dup.destroy
        end
      end
    end
  end

  # Determine dietary type from Rista itemTagIds
  def determine_dietary_type(tag_ids)
    # Rista dietary tag IDs (from catalog analysis)
    dietary_tags = {
      'vegan' => ['687f3350dbd358736dc6e259'],
      'egg' => ['687f3350dbd358736dc6e256'],
      'non_veg' => ['687f3350dbd358736dc6e253'],
      'veg' => ['687f3350dbd358736dc6e252', '69101374bedff124ac09b15c', '69101394c9682e7770ec12e5']
    }

    # Priority order: vegan > egg > non_veg > veg
    # This ensures proper classification (e.g., egg items aren't classified as veg)
    return 'vegan' if (tag_ids & dietary_tags['vegan']).any?
    return 'egg' if (tag_ids & dietary_tags['egg']).any?
    return 'non_veg' if (tag_ids & dietary_tags['non_veg']).any?
    return 'veg' if (tag_ids & dietary_tags['veg']).any?

    # Default to veg if no dietary tags found (most items in coffee shop are veg)
    'veg'
  end
end
