class DeadlineReminderJob < ApplicationJob
  queue_as :default

  # Deadlines without an explicit reminder date are reminded this many days before.
  DEFAULT_DAYS_BEFORE = 7

  def perform
    today = Date.current
    due = Deadline.open.where(reminder_date: today)
                  .or(Deadline.open.where(reminder_date: nil, due_date: today + DEFAULT_DAYS_BEFORE))

    due.includes(beneficiary: :user).find_each { |d| DeadlineMailer.reminder(d).deliver_later }

    Deadline.open.where(due_date: ...today).update_all(status: Deadline.statuses[:overdue], updated_at: Time.current)
  end
end
