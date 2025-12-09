class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :menu_items, through: :order_items

  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending confirmed preparing ready completed cancelled] }
  validates :order_type, inclusion: { in: %w[pickup dine-in delivery], allow_nil: true }
  validates :customer_phone, presence: true
  validates :customer_name, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  # Table number only required for dine-in orders
  validates :table_number, presence: true, if: -> { order_type == 'dine-in' }

  # Scopes
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  # Instance methods
  def calculate_total
    order_items.sum { |item| item.price * item.quantity }
  end

  def rista_synced?
    rista_invoice_number.present?
  end
end
