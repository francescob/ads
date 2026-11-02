class ExpenseEntry < ApplicationRecord
  include ValidatedAttachment

  belongs_to :report

  scope :owned_by, ->(user) { joins(report: :beneficiary).where(beneficiaries: { user_id: user.id }) }

  has_one_attached :receipt_file
  validates_attachment :receipt_file, content_types: ValidatedAttachment::RECEIPTS

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
      errors.add(:amount, :exceeds_extraordinary_limit,
                 limit: ActiveSupport::NumberHelper.number_to_currency(limit, unit: "€", separator: ",", delimiter: ".", format: "%n %u"))
    end
  end
end