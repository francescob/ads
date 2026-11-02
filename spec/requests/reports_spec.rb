require "rails_helper"

RSpec.describe "Report status workflow", type: :request do
  let(:user) { create(:user) }
  let(:report) { create(:report, beneficiary: create(:beneficiary, user: user)) }

  before { sign_in user }

  it "moves one step at a time" do
    patch update_status_report_path(report, status: "completed")
    expect(report.reload).to be_completed
    patch update_status_report_path(report, status: "filed")
    expect(report.reload).to be_filed
  end

  it "refuses skipping steps" do
    patch update_status_report_path(report, status: "approved")
    expect(report.reload).to be_draft
    expect(flash[:alert]).to be_present
  end

  it "handles unknown statuses without crashing" do
    patch update_status_report_path(report, status: "boh")
    expect(response).to redirect_to(report_path(report))
    expect(report.reload).to be_draft
  end

  it "filing closes the year's report deadline and schedules the next one" do
    travel_to Date.new(2026, 6, 1) do
      appointment = report.appointment
      expect(report.beneficiary.deadlines.report.pluck(:due_date)).to eq([ Date.new(2027, 3, 31) ])

      report.update!(status: :completed)
      report.update!(status: :filed)

      deadlines = report.beneficiary.deadlines.report.order(:due_date)
      expect(deadlines.map { [ _1.due_date, _1.status ] }).to eq([
        [ Date.new(2027, 3, 31), "completed" ], [ Date.new(2028, 3, 31), "open" ]
      ])
      expect(appointment).to be_persisted
    end
  end
end
