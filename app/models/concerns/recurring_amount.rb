# Shared schedule logic for RecurringIncome and RecurringExpense
# (amount + frequency + start_date/end_date + active flag).
module RecurringAmount
  extend ActiveSupport::Concern

  MONTHS_BETWEEN_PAYMENTS = { "monthly" => 1, "bimonthly" => 2, "quarterly" => 3, "semiannual" => 6, "annual" => 12 }.freeze

  included do
    enum :frequency, { monthly: 0, bimonthly: 1, quarterly: 2, semiannual: 3, annual: 4 }

    validates :description, :frequency, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validate :end_date_after_start_date

    scope :active_on_date, ->(date) {
      where(active: true).where(start_date: ..date).where("end_date IS NULL OR end_date >= ?", date)
    }
    scope :starting_after, ->(date) { where(start_date: date..) }
  end

  def annual_amount
    return 0 unless amount && frequency

    amount * (12 / MONTHS_BETWEEN_PAYMENTS.fetch(frequency))
  end

  def currently_active?(on: Date.current)
    active? && start_date.present? && start_date <= on && (end_date.nil? || end_date >= on)
  end

  # Payments due from start_date (first payment included) up to the given day or end_date.
  def payments_count(on: Date.current)
    last_day = [ on, end_date ].compact.min
    return 0 if start_date.nil? || frequency.nil? || start_date > last_day

    months = (last_day.year * 12 + last_day.month) - (start_date.year * 12 + start_date.month)
    k = months / months_between_payments
    k -= 1 if payment_date(k) > last_day
    k + 1
  end

  def total_amount_to_date(on: Date.current)
    payments_count(on: on) * (amount || 0)
  end

  # First scheduled payment on or after the given day, nil if none is left.
  def next_payment_date(on: Date.current)
    return nil unless active? && start_date && frequency

    date = payment_date(payments_count(on: on - 1))
    date unless end_date && date > end_date
  end

  private

  def months_between_payments
    MONTHS_BETWEEN_PAYMENTS.fetch(frequency)
  end

  # Date of the k-th payment (0 = start_date)
  def payment_date(k)
    start_date.advance(months: k * months_between_payments)
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank? || end_date >= start_date

    errors.add(:end_date, :must_be_after_start_date)
  end
end
