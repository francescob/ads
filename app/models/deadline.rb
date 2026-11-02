class Deadline < ApplicationRecord
  belongs_to :beneficiary

  enum :deadline_type, { report: 0, hearing: 1, renewal: 2, administrative: 3, medical: 4, other_deadline: 5 }
  enum :status, { open: 0, completed: 1, overdue: 2 }
  enum :priority, { high: 0, medium: 1, low: 2 }

  validates :title, :due_date, presence: true

  scope :open, -> { where(status: :open) }
  scope :overdue, -> { where(status: :overdue) }
  scope :upcoming, -> { open.where(due_date: Date.today..7.days.from_now) }
  scope :by_priority, -> { order(priority: :asc) }

  def priority_color
    case priority
    when 'high' then 'red'
    when 'medium' then 'orange'
    when 'low' then 'green'
    end
  end

  def overdue?
    open? && due_date < Date.today
  end
end