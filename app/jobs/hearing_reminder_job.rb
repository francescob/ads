class HearingReminderJob < ApplicationJob
  queue_as :default

  # Runs daily: one reminder 3 days before and one the day before, not one per day.
  REMINDER_DAYS_BEFORE = [ 3, 1 ].freeze

  def perform
    REMINDER_DAYS_BEFORE.each do |days|
      day = days.days.from_now.to_date
      Hearing.where(hearing_date: day.all_day)
             .includes(beneficiary: :user)
             .each { |h| HearingMailer.reminder(h).deliver_later }
    end
  end
end
