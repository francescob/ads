require "rails_helper"

RSpec.describe Deadline do
  it "is overdue when flagged by the job or when an open deadline is past due" do
    expect(build(:deadline, status: :overdue, due_date: 3.days.ago)).to be_overdue
    expect(build(:deadline, status: :open, due_date: 3.days.ago)).to be_overdue
    expect(build(:deadline, status: :open, due_date: 3.days.from_now)).not_to be_overdue
    expect(build(:deadline, status: :completed, due_date: 3.days.ago)).not_to be_overdue
  end

  it "past_due includes open deadlines before the nightly job runs" do
    late = create(:deadline, due_date: 2.days.ago)
    flagged = create(:deadline, status: :overdue, due_date: 5.days.ago)
    create(:deadline, due_date: 2.days.from_now)
    expect(Deadline.past_due).to contain_exactly(late, flagged)
  end
end

RSpec.describe Appointment do
  it "creates a report deadline also for open-ended mandates and a renewal deadline on expiry" do
    travel_to Date.new(2026, 6, 1) do
      a = create(:appointment, appointment_date: Date.new(2026, 1, 15), mandate_expiry_date: nil)
      expect(a.beneficiary.deadlines.report.pluck(:due_date)).to eq([ Date.new(2027, 3, 31) ])

      a.update!(mandate_expiry_date: Date.new(2028, 1, 15))
      renewal = a.beneficiary.deadlines.renewal.sole
      expect(renewal.due_date).to eq(Date.new(2028, 1, 15))
      expect(renewal.reminder_date).to eq(Date.new(2027, 11, 15))
    end
  end

  it "does not create already expired deadlines for decrees entered retroactively" do
    travel_to Date.new(2026, 6, 1) do
      a = create(:appointment, appointment_date: Date.new(2020, 5, 1), mandate_expiry_date: Date.new(2030, 5, 1))
      expect(a.beneficiary.deadlines.report.minimum(:due_date)).to eq(Date.new(2027, 3, 31))
    end
  end
end

RSpec.describe ExpenseEntry do
  it "enforces the extraordinary expense limit with an Italian message" do
    report = create(:report)
    report.appointment.update!(extraordinary_expense_limit: 1000)
    entry = build(:expense_entry, report: report, category: :extraordinary, amount: 1500)
    expect(entry).not_to be_valid
    expect(entry.errors[:amount].first).to include("1.000,00 €")
  end

  it "accepts only PDF or image receipts" do
    entry = build(:expense_entry, receipt_file: Rack::Test::UploadedFile.new(file_fixture("programma.exe"), "application/x-msdownload"))
    expect(entry).not_to be_valid
    expect(entry.errors[:receipt_file]).to be_present
  end
end

RSpec.describe RecurringIncome do
  subject(:income) { build(:recurring_income, start_date: Date.new(2026, 1, 20), frequency: :monthly, amount: 1000) }

  it "computes payments and next payment date from the start day" do
    expect(income.payments_count(on: Date.new(2026, 11, 2))).to eq(10) # Jan..Oct
    expect(income.next_payment_date(on: Date.new(2026, 11, 2))).to eq(Date.new(2026, 11, 20))
    expect(income.next_payment_date(on: Date.new(2026, 11, 20))).to eq(Date.new(2026, 11, 20))
    expect(income.total_received).to be_a(Numeric)
  end

  it "handles annual and quarterly schedules" do
    income.frequency = :annual
    expect(income.next_payment_date(on: Date.new(2026, 11, 2))).to eq(Date.new(2027, 1, 20))
    expect(income.annual_amount).to eq(1000)
    income.frequency = :quarterly
    expect(income.payments_count(on: Date.new(2026, 11, 2))).to eq(4) # Jan, Apr, Jul, Oct
    expect(income.annual_amount).to eq(4000)
  end

  it "stops at the end date" do
    income.end_date = Date.new(2026, 3, 31)
    expect(income.payments_count(on: Date.new(2026, 11, 2))).to eq(3)
    expect(income.next_payment_date(on: Date.new(2026, 11, 2))).to be_nil
  end

  it "validates the end date with a translated message" do
    income.end_date = Date.new(2025, 1, 1)
    expect(income).not_to be_valid
    expect(income.errors[:end_date].first).not_to include("translation missing")
  end
end
