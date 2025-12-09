class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token, :expires_at, presence: true
  validates :token, uniqueness: true

  scope :active, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def self.generate_token
    SecureRandom.hex(32)
  end
end
