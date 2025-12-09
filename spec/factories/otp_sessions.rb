FactoryBot.define do
  factory :otp_session do
    phone { "MyString" }
    otp { "MyString" }
    session_id { "MyString" }
    expires_at { "2025-12-09 16:54:05" }
    verified { false }
  end
end
