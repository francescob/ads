class Deadline < ApplicationRecord
  include OwnedThroughBeneficiary

  belongs_to :beneficiary

  enum :deadline_type, { report: 0, hearing: 1, renewal: 2, administrative: 3, medical: 4, other_deadline: 5 }
  enum :status, { open: 0, completed: 1, overdue: 2 }
  enum :priority, { high: 0, medium: 1, low: 2 }

  validates :title, :due_date, presence: true

  # `open` and `overdue` scopes come from the enum. Until the nightly job flips
  # them to `overdue`, open deadlines with a past due date are overdue too.
  scope :past_due, -> { overdue.or(open.where(due_date: ...Date.current)) }
  scope :open_or_overdue, -> { where(status: [ :open, :overdue ]) }
  scope :upcoming, ->(days = 7) { open.where(due_date: Date.current..days.days.from_now.to_date) }
  scope :by_priority, -> { order(priority: :asc) }

  def priority_color
    case priority
    when "high" then "red"
    when "medium" then "orange"
    when "low" then "green"
    end
  end

  def overdue?
    super || (open? && due_date.present? && due_date < Date.current)
  end
end
