FactoryBot.define do
  factory :liability do
    beneficiary { nil }
    liability_type { 1 }
    description { "MyString" }
    creditor { "MyString" }
    initial_amount { "9.99" }
    remaining_balance { "9.99" }
    interest_rate { "9.99" }
    monthly_payment { "9.99" }
    start_date { "2026-03-18" }
    end_date { "2026-03-18" }
    notes { "MyText" }
  end
end
