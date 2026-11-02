class ExpenseEntry < ApplicationRecord
  belongs_to :report

  has_one_attached :receipt_file

  enum :category, { medical: 0, food: 1, housing: 2, clothing: 3, taxes: 4, ordinary: 5, extraordinary: 6, other_expense: 7 }

  validates :entry_date, :description, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }

  validate :within_extraordinary_limit, if: -> { category == 'extraordinary' }

  private

  def within_extraordinary_limit
    limit = report&.beneficiary
                  &.appointments
                  &.order(appointment_date: :desc)
                  &.first
                  &.extraordinary_expense_limit
    return unless limit

    if amount && amount > limit
      errors.add(:amount,
        "exceeds the extraordinary expense limit (#{limit} EUR) " \
        "set by appointment decree")
    end
  end
end