class Report < ApplicationRecord
  include OwnedThroughBeneficiary
  include AppointmentOfSameBeneficiary

  belongs_to :beneficiary
  belongs_to :appointment

  has_many :income_entries, dependent: :destroy
  has_many :expense_entries, dependent: :destroy
  has_one_attached :generated_pdf

  enum :status, { draft: 0, completed: 1, filed: 2, approved: 3 }, validate: true

  # Allowed status workflow: draft -> completed -> filed -> approved (one step back allowed before approval)
  TRANSITIONS = {
    "draft" => %w[completed],
    "completed" => %w[draft filed],
    "filed" => %w[completed approved],
    "approved" => []
  }.freeze

  validates :reference_year, :period_from, :period_to, presence: true
  validates :period_to, comparison: { greater_than_or_equal_to: :period_from }, if: -> { period_from && period_to }
  validate :status_transition_allowed, on: :update, if: :will_save_change_to_status?

  after_update_commit :close_annual_deadline, if: -> { saved_change_to_status?(to: "filed") }

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

  def next_statuses
    TRANSITIONS.fetch(status, [])
  end

  def status_badge_class
    case status
    when 'draft' then 'bg-gray-100 text-gray-800'
    when 'completed' then 'bg-blue-100 text-blue-800'
    when 'filed' then 'bg-indigo-100 text-indigo-800'
    when 'approved' then 'bg-green-100 text-green-800'
    end
  end

  private

  # Filing the report closes its annual deadline and schedules the next year's one.
  def close_annual_deadline
    beneficiary.deadlines.report.open_or_overdue
               .where(due_date: Date.new(reference_year + 1).all_year)
               .update_all(status: Deadline.statuses[:completed], updated_at: Time.current)
    appointment&.ensure_annual_report_deadline(reference_year + 1)
  end

  def status_transition_allowed
    from, to = status_change_to_be_saved
    return if from.nil? || TRANSITIONS.fetch(from, []).include?(to)

    errors.add(:status, :invalid_transition,
               from: I18n.t("enums.report.status.#{from}", default: from),
               to: I18n.t("enums.report.status.#{to}", default: to.to_s))
  end
end
