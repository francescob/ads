class IncomeEntry < ApplicationRecord
  belongs_to :report

  enum :category, { pension: 0, allowance: 1, annuity: 2, other_income: 3 }

  validates :entry_date, :description, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
end