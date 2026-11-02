FactoryBot.define do
  factory :recurring_income do
    beneficiary { nil }
    income_type { 1 }
    description { "MyString" }
    amount { "9.99" }
    frequency { 1 }
    start_date { "2026-04-07" }
    end_date { "2026-04-07" }
    notes { "MyText" }
    active { false }
  end
end
