class IncomeEntry < ApplicationRecord
  belongs_to :report

  scope :owned_by, ->(user) { joins(report: :beneficiary).where(beneficiaries: { user_id: user.id }) }

  enum :category, { pension: 0, allowance: 1, annuity: 2, other_income: 3 }

  validates :entry_date, :description, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
