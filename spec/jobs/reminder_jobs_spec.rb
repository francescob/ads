require "rails_helper"

RSpec.describe "reminder jobs" do
  it "HearingReminderJob reminds 3 days and 1 day before, not every day" do
    travel_to Time.zone.local(2026, 11, 2, 8) do
      create(:hearing, hearing_date: Time.zone.local(2026, 11, 5, 10))
      create(:hearing, hearing_date: Time.zone.local(2026, 11, 3, 10))
      create(:hearing, hearing_date: Time.zone.local(2026, 11, 4, 10))
      expect { HearingReminderJob.perform_now }.to have_enqueued_mail(HearingMailer, :reminder).twice
    end
  end

  it "DeadlineReminderJob uses the reminder date or 7 days before, and flags overdue" do
    travel_to Date.new(2026, 11, 2) do
      create(:deadline, reminder_date: Date.new(2026, 11, 2), due_date: Date.new(2026, 12, 1))
      create(:deadline, reminder_date: nil, due_date: Date.new(2026, 11, 9))
      create(:deadline, reminder_date: nil, due_date: Date.new(2026, 11, 20))
      late = create(:deadline, due_date: Date.new(2026, 10, 1))
      expect { DeadlineReminderJob.perform_now }.to have_enqueued_mail(DeadlineMailer, :reminder).twice
      expect(late.reload).to be_overdue
    end
  end
end
