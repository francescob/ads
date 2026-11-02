FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "utente#{n}@example.com" }
    password { "password123" }
    first_name { "Giulia" }
    last_name { "Verdi" }
  end

  factory :beneficiary do
    user
    first_name { "Mario" }
    last_name { "Rossi" }
    status { :active }
  end

  factory :appointment do
    beneficiary
    sequence(:decree_number) { |n| "#{n}/2026" }
    decree_date { Date.new(2026, 1, 10) }
    appointment_date { Date.new(2026, 1, 15) }
    court { "Tribunale di Milano" }
    judge { "Dott. Bianchi" }
  end

  factory :report do
    beneficiary
    appointment { association :appointment, beneficiary: beneficiary }
    reference_year { 2026 }
    period_from { Date.new(2026, 1, 1) }
    period_to { Date.new(2026, 12, 31) }
  end

  factory :hearing do
    beneficiary
    hearing_date { 10.days.from_now }
  end

  factory :deadline do
    beneficiary
    title { "Scadenza" }
    due_date { 10.days.from_now.to_date }
    status { :open }
    priority { :medium }
    deadline_type { :administrative }
  end

  factory :document do
    beneficiary
    title { "Carta d'identità" }
  end

  factory :expense_entry do
    report
    entry_date { Date.new(2026, 3, 1) }
    description { "Farmacia" }
    amount { 50 }
    category { :medical }
  end

  factory :recurring_income do
    beneficiary
    income_type { :pension }
    description { "Pensione INPS" }
    amount { 1000 }
    frequency { :monthly }
    start_date { Date.new(2026, 1, 15) }
    active { true }
  end
end
