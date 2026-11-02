class DeadlineReminderJob < ApplicationJob
  queue_as :default

  def perform
    Deadline.open.where(reminder_date: Date.today)
            .includes(beneficiary: :user)
            .each { |d| DeadlineMailer.reminder(d).deliver_later }

    Deadline.open.where('due_date < ?', Date.today)
            .update_all(status: :overdue)
  end
end