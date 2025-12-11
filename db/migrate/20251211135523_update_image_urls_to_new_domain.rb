class UpdateImageUrlsToNewDomain < ActiveRecord::Migration[8.0]
  def up
    # Update all menu item image URLs from old Railway domain to new domain
    MenuItem.where("image_url LIKE ?", "%trueblack-api-production.up.railway.app%").find_each do |item|
      new_url = item.image_url.gsub(
        "trueblack-api-production.up.railway.app",
        "trueblack-backend-production.up.railway.app"
      )
      item.update_column(:image_url, new_url)
    end
  end

  def down
    # Revert back to old domain (optional, for rollback)
    MenuItem.where("image_url LIKE ?", "%trueblack-backend-production.up.railway.app%").find_each do |item|
      old_url = item.image_url.gsub(
        "trueblack-backend-production.up.railway.app",
        "trueblack-api-production.up.railway.app"
      )
      item.update_column(:image_url, old_url)
    end
  end
end
