require "rails_helper"

RSpec.describe "Navigation after create/delete", type: :request do
  let(:user) { create(:user) }
  let(:beneficiary) { create(:beneficiary, user: user) }

  before { sign_in user }

  {
    appointments: ->(b) { FactoryBot.create(:appointment, beneficiary: b) },
    hearings: ->(b) { FactoryBot.create(:hearing, beneficiary: b) },
    documents: ->(b) { FactoryBot.create(:document, beneficiary: b) },
    recurring_incomes: ->(b) { FactoryBot.create(:recurring_income, beneficiary: b) }
  }.each do |tab, factory|
    it "deleting #{tab.to_s.singularize} lands on the beneficiary page, #{tab} tab" do
      record = factory.call(beneficiary)
      delete polymorphic_path(record)
      expect(response).to redirect_to(beneficiary_path(beneficiary, tab: tab.to_s))
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(data-tabs-initial-value="#{tab}"))
    end
  end

  it "the old index URLs redirect to the tab instead of failing" do
    get beneficiary_liabilities_path(beneficiary)
    expect(response).to redirect_to(beneficiary_path(beneficiary, tab: "liabilities"))
  end

  it "a decree with reports cannot be deleted" do
    report = create(:report, beneficiary: beneficiary)
    delete appointment_path(report.appointment)
    expect(response).to redirect_to(appointment_path(report.appointment))
    expect(Appointment.exists?(report.appointment_id)).to be(true)
  end
end
