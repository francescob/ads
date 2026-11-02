class Report < ApplicationRecord
  belongs_to :beneficiary
  belongs_to :appointment

  has_many :income_entries, dependent: :destroy
  has_many :expense_entries, dependent: :destroy
  has_one_attached :generated_pdf

  enum :status, { draft: 0, completed: 1, filed: 2, approved: 3 }

  validates :reference_year, :period_from, :period_to, presence: true

  scope :drafts, -> { where(status: :draft) }
  scope :for_year, ->(year) { where(reference_year: year) }

  def opening_balance
    previous = beneficiary.reports
                           .where('period_to < ?', period_from)
                           .order(period_to: :desc)
                           .first
    previous&.closing_balance || 0
  end

  def total_income
    income_entries.sum(:amount)
  end

  def total_expenses
    expense_entries.sum(:amount)
  end

  def closing_balance
    opening_balance + total_income - total_expenses
  end

  def status_badge_class
    case status
    when 'draft' then 'bg-gray-100 text-gray-800'
    when 'completed' then 'bg-blue-100 text-blue-800'
    when 'filed' then 'bg-indigo-100 text-indigo-800'
    when 'approved' then 'bg-green-100 text-green-800'
    end
  end
end