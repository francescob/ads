class HearingReminderJob < ApplicationJob
  queue_as :default

  def perform
    Hearing.where(hearing_date: Date.today.beginning_of_day..3.days.from_now.end_of_day)
           .includes(beneficiary: :user)
           .each { |h| HearingMailer.reminder(h).deliver_later }
  end
end