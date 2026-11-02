require "rails_helper"

RSpec.describe "Data isolation between users", type: :request do
  let(:user) { create(:user) }
  let(:beneficiary) { create(:beneficiary, user: user) }
  let(:own_appointment) { create(:appointment, beneficiary: beneficiary) }
  let(:foreign_appointment) { create(:appointment, court: "Tribunale Riservato", judge: "Giudice Riservato") }

  before { sign_in user }

  it "rejects a report linked to another user's decree" do
    expect {
      post beneficiary_reports_path(beneficiary), params: {
        report: { appointment_id: foreign_appointment.id, reference_year: 2026, period_from: "2026-01-01", period_to: "2026-12-31" }
      }
    }.not_to change(Report, :count)
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "rejects a hearing linked to another user's decree" do
    post beneficiary_hearings_path(beneficiary), params: {
      hearing: { appointment_id: foreign_appointment.id, hearing_date: 5.days.from_now }
    }
    expect(response).to have_http_status(:unprocessable_content)
    expect(Hearing.count).to eq(0)
  end

  it "does not show other users' records" do
    get appointment_path(foreign_appointment)
    expect(response).to have_http_status(:not_found)
  end

  describe "file downloads" do
    let(:document) do
      create(:document, beneficiary: beneficiary,
                        file: Rack::Test::UploadedFile.new(file_fixture("decreto.pdf"), "application/pdf"))
    end

    it "serves the file to its owner" do
      get file_path(document.file.attachment)
      expect(response).to have_http_status(:ok)
      expect(response.body).to start_with("%PDF")
    end

    it "hides it from other users" do
      sign_in create(:user)
      get file_path(document.file.attachment)
      expect(response).to have_http_status(:not_found)
    end

    it "requires login" do
      sign_out user
      get file_path(document.file.attachment)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "has no public Active Storage route" do
      expect(Rails.application.routes.url_helpers).not_to respond_to(:rails_blob_path)
    end
  end
end
