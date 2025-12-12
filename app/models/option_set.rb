class OptionSet < ApplicationRecord
  has_many :customization_options, dependent: :destroy
  has_many :menu_item_option_sets, dependent: :destroy
  has_many :menu_items, through: :menu_item_option_sets
end
