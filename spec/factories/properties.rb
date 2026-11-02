FactoryBot.define do
  factory :property do
    beneficiary { nil }
    property_type { 1 }
    description { "MyString" }
    address { "MyString" }
    city { "MyString" }
    province { "MyString" }
    zip_code { "MyString" }
    cadastral_sheet { "MyString" }
    cadastral_particle { "MyString" }
    cadastral_sub { "MyString" }
    cadastral_category { "MyString" }
    cadastral_class { "MyString" }
    cadastral_consistency { "MyString" }
    cadastral_income { "9.99" }
    ownership_percentage { "9.99" }
    current_value { "9.99" }
    initial_value { "9.99" }
    valuation_date { "2026-04-08" }
    notes { "MyText" }
  end
end
