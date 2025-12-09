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

    # Find or create "Rista" category
    rista_category = find_or_create_rista_category

    ActiveRecord::Base.transaction do
      rista_items.each do |item|
        sync_menu_item(item, rista_category)
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

    # Update attributes
    menu_item.assign_attributes(
      name: name,
      short_name: rista_item['shortName'] || name,
      description: rista_item['description'] || '',
      price: price.to_f,
      category: category,
      is_available: rista_item['status'] == 'Active' || rista_item['available'] != false,
      is_veg: rista_item['isVeg'].nil? ? true : rista_item['isVeg'],
      rista_category_id: rista_item['categoryId']&.to_s,
      rista_subcategory_id: rista_item['subCategoryId']&.to_s,
      image_url: rista_item['image'] || rista_item['imageUrl'],
      last_synced_at: Time.current
    )

    menu_item.save!

    Rails.logger.debug "[MenuSync] Synced: #{name} (#{rista_code})"
    menu_item
  end

  def find_or_create_rista_category
    # Find or create a store for Rista items
    store = Store.find_or_create_by!(name: 'Rista Menu') do |s|
      s.address = 'Synced from Rista POS'
      s.latitude = 0
      s.longitude = 0
    end

    # Find or create category
    Category.find_or_create_by!(name: 'Rista Items', store: store)
  end
end
