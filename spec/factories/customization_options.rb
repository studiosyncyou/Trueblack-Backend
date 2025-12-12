FactoryBot.define do
  factory :customization_option do
    option_set { nil }
    name { "MyString" }
    price { "9.99" }
    rista_option_id { "MyString" }
    is_default { false }
  end
end
