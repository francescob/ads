class Liability < ApplicationRecord
  include OwnedThroughBeneficiary

  belongs_to :beneficiary

  enum :liability_type, {
    mortgage: 0,              # Mutuo ipotecario
    car_loan: 1,              # Finanziamento auto
    personal_loan: 2,         # Prestito personale
    credit_card: 3,           # Carta di credito
    business_loan: 4,         # Finanziamento aziendale
    student_loan: 5,          # Prestito studentesco
    overdraft: 6,             # Scoperto bancario
    lease: 7,                 # Leasing
    other: 8                  # Altro
  }

  validates :liability_type, presence: true
  validates :description, presence: true
  validates :creditor, presence: true
  validates :initial_amount, numericality: { greater_than: 0, allow_nil: true }
  validates :remaining_balance, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :monthly_payment, numericality: { greater_than: 0, allow_nil: true }
  # validates :start_date, presence: true

  validate :end_date_after_start_date
  validate :remaining_balance_not_greater_than_initial

  scope :active, -> { where('remaining_balance IS NULL OR remaining_balance > 0') }
  scope :paid_off, -> { where('remaining_balance = 0 AND remaining_balance IS NOT NULL') }
  scope :by_creditor, ->(creditor) { where(creditor: creditor) }

  def paid_off?
    return nil if remaining_balance.nil?
    remaining_balance.zero?
  end

  def percentage_paid
    return nil if initial_amount.nil? || remaining_balance.nil?
    return 100 if initial_amount.zero?
    ((initial_amount - remaining_balance) / initial_amount * 100).round(2)
  end

  def percentage_remaining
    return nil if initial_amount.nil? || remaining_balance.nil?
    return 0 if initial_amount.zero?
    (remaining_balance / initial_amount * 100).round(2)
  end

  def estimated_months_remaining
    return nil if remaining_balance.nil? || monthly_payment.nil?
    return 0 if paid_off? || monthly_payment.zero?
    (remaining_balance / monthly_payment).ceil
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, :must_be_after_start_date)
    end
  end

  def remaining_balance_not_greater_than_initial
    return if initial_amount.blank? || remaining_balance.blank?
    if remaining_balance > initial_amount
      errors.add(:remaining_balance, :cannot_exceed_initial_amount)
    end
  end
end
