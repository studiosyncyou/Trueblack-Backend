class OtpSession < ApplicationRecord
  validates :phone, :otp, :session_id, :expires_at, presence: true
  validates :session_id, uniqueness: true

  scope :active, -> { where("expires_at > ?", Time.current).where(verified: false) }

  def expired?
    expires_at < Time.current
  end

  def verify!(entered_otp)
    return false if expired?
    return false if verified?

    if otp == entered_otp
      update(verified: true)
      true
    else
      false
    end
  end
end
