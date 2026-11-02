class RecurringExpense < ApplicationRecord
  include OwnedThroughBeneficiary
  include RecurringAmount

  belongs_to :beneficiary

  enum :expense_type, {
    rent: 0,                    # Affitto
    utilities: 1,               # Utenze (luce, gas, acqua)
    insurance: 2,               # Assicurazioni
    health_care: 3,             # Spese sanitarie ricorrenti
    care_services: 4,           # Servizi di assistenza
    condominium_fees: 5,        # Spese condominiali
    phone_internet: 6,          # Telefono/Internet
    subscriptions: 7,           # Abbonamenti (TV, giornali, ecc.)
    transportation: 8,          # Trasporti
    food_allowance: 9,          # Spesa alimentare fissa
    medications: 10,            # Farmaci ricorrenti
    loan_payment: 11,           # Rata prestito/mutuo
    taxes: 12,                  # Tasse ricorrenti
    other_expense: 13           # Altro
  }

  validates :expense_type, presence: true

  scope :active_expenses, -> { where(active: true) }
  scope :inactive_expenses, -> { where(active: false) }
  scope :by_type, ->(type) { where(expense_type: type) }

  # Totale pagato fino ad oggi
  def total_paid
    total_amount_to_date
  end
end
