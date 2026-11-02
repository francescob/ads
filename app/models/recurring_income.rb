class RecurringIncome < ApplicationRecord
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

  enum :frequency, {
    monthly: 0,      # Mensile
    bimonthly: 1,    # Bimestrale
    quarterly: 2,    # Trimestrale
    semiannual: 3,   # Semestrale
    annual: 4        # Annuale
  }

  validates :income_type, presence: true
  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :frequency, presence: true
  #validates :start_date, presence: true

  validate :end_date_after_start_date

  scope :active_incomes, -> { where(active: true) }
  scope :inactive_incomes, -> { where(active: false) }
  scope :by_type, ->(type) { where(income_type: type) }
  scope :starting_after, ->(date) { where('start_date >= ?', date) }
  scope :active_on_date, ->(date) do
    where(active: true)
      .where('start_date <= ?', date)
      .where('end_date IS NULL OR end_date >= ?', date)
  end

  # Calcola l'importo annuale basato sulla frequenza
  def annual_amount
    return 0 unless amount.present? && frequency.present?

    case frequency
    when 'monthly'
      amount * 12
    when 'bimonthly'
      amount * 6
    when 'quarterly'
      amount * 4
    when 'semiannual'
      amount * 2
    when 'annual'
      amount
    else
      0
    end
  end

  # Verifica se l'entrata è attualmente attiva
  def currently_active?
    return false unless active?
    return false if start_date.nil? || start_date > Date.today
    return false if end_date.present? && end_date < Date.today
    true
  end

  # Calcola il numero di pagamenti ricevuti
  def payments_count
    return 0 if start_date.nil? || start_date > Date.today

    end_calc_date = end_date.present? && end_date < Date.today ? end_date : Date.today
    months = ((end_calc_date.year * 12 + end_calc_date.month) - (start_date.year * 12 + start_date.month))

    case frequency
    when 'monthly'
      months
    when 'bimonthly'
      (months / 2.0).floor
    when 'quarterly'
      (months / 3.0).floor
    when 'semiannual'
      (months / 6.0).floor
    when 'annual'
      ((end_calc_date.year - start_date.year)).abs
    else
      0
    end
  end

  # Calcola il totale ricevuto fino ad oggi
  def total_received
    payments_count * (amount || 0)
  end

  # Prossima data di pagamento prevista
  def next_payment_date
    return nil unless currently_active?

    base_date = start_date
    today = Date.today

    case frequency
    when 'monthly'
      base_date >> (((today.year - base_date.year) * 12 + (today.month - base_date.month)) + 1)
    when 'bimonthly'
      base_date >> ((((today.year - base_date.year) * 12 + (today.month - base_date.month)) / 2 + 1) * 2)
    when 'quarterly'
      base_date >> ((((today.year - base_date.year) * 12 + (today.month - base_date.month)) / 3 + 1) * 3)
    when 'semiannual'
      base_date >> ((((today.year - base_date.year) * 12 + (today.month - base_date.month)) / 6 + 1) * 6)
    when 'annual'
      Date.new(today.year + 1, start_date.month, start_date.day)
    else
      nil
    end
  rescue
    nil
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, :must_be_after_start_date)
    end
  end
end
