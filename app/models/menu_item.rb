class MenuItem < ApplicationRecord
  belongs_to :category
  has_many :menu_item_option_sets, dependent: :destroy
  has_many :option_sets, through: :menu_item_option_sets

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :available, -> { where(is_available: true) }
  scope :synced_from_rista, -> { where.not(rista_code: nil) }
  scope :needs_sync, -> { where('last_synced_at IS NULL OR last_synced_at < ?', 24.hours.ago) }

  # Rista integration methods
  def synced_from_rista?
    rista_code.present?
  end

  def needs_sync?
    last_synced_at.nil? || last_synced_at < 24.hours.ago
  end

  def mark_synced!
    update(last_synced_at: Time.current)
  end
end
