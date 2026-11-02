class RecurringIncome < ApplicationRecord
  include OwnedThroughBeneficiary
  include RecurringAmount

  belongs_to :beneficiary

  enum :income_type, {
    pension: 0,                # Pensione
    salary: 1,                 # Stipendio
    disability_allowance: 2,   # Indennità di invalidità
    annuity: 3,                # Rendita
    rent_income: 4,            # Reddito da affitto
    investment_income: 5,      # Reddito da investimenti
    alimony: 6,                # Alimenti/Mantenimento
    social_security: 7,        # Assistenza sociale
    other_income: 8            # Altro
  }

  validates :income_type, presence: true

  scope :active_incomes, -> { where(active: true) }
  scope :inactive_incomes, -> { where(active: false) }
  scope :by_type, ->(type) { where(income_type: type) }

  # Totale ricevuto fino ad oggi
  def total_received
    total_amount_to_date
  end
end
