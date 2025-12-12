class MenuItemOptionSet < ApplicationRecord
  belongs_to :menu_item
  belongs_to :option_set
end
