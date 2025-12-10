class User < ApplicationRecord
  has_secure_password validations: false

  has_many :refresh_tokens, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :phone, presence: true, uniqueness: true, format: { with: /\A\+?[1-9]\d{1,14}\z/, message: "must be a valid E.164 format" }
  validates :name, presence: true

  def generate_jwt
    payload = {
      user_id: id,
      phone: phone,
      name: name,
      exp: 7.days.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE'])
  end

  def generate_refresh_token
    token = RefreshToken.generate_token
    refresh_tokens.create!(
      token: token,
      expires_at: 30.days.from_now
    )
    token
  end

  def self.decode_jwt(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE']).first
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
