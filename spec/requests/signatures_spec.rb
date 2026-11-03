require "rails_helper"

RSpec.describe "Report signatures", type: :request do
  let(:user) { create(:user) }
  let(:report) { create(:report, beneficiary: create(:beneficiary, user: user)) }

  before do
    report.generated_pdf.attach(io: StringIO.new(sample_pdf), filename: "rendiconto.pdf", content_type: "application/pdf")
    sign_in user
  end

  def upload(bytes, filename: "rendiconto.pdf", content_type: "application/pdf")
    post report_signature_path(report), params: { signature: { signed_file: uploaded(bytes, filename: filename, content_type: content_type) } }
  end

  it "stores and verifies a signed PDF, showing the signer on the report" do
    upload(pades(sample_pdf))
    expect(response).to redirect_to(report_path(report))
    expect(flash[:notice]).to be_present

    signature = report.reload.signature
    expect(signature).to be_status_valid_untrusted
    expect(signature.uploaded_by).to eq(user)

    follow_redirect!
    expect(response.body).to include("Mario Rossi", "RSSMRA80A01H501Z", "Firma integra")
  end

  it "accepts a .p7m and replaces the previous signed version" do
    upload(pades(sample_pdf))
    upload(cades(sample_pdf), filename: "rendiconto.pdf.p7m", content_type: "application/pkcs7-mime")
    expect(Signature.where(signable: report).count).to eq(1)
    expect(report.reload.signature.format).to eq("cades")
  end

  it "keeps the uploaded file but reports problems" do
    upload(cades("altro documento"), filename: "x.p7m", content_type: "application/pkcs7-mime")
    expect(flash[:alert]).to be_present
    expect(report.reload.signature).to be_status_mismatch
  end

  it "rejects other file types" do
    upload("ciao", filename: "nota.txt", content_type: "text/plain")
    expect(report.reload.signature).to be_nil
    expect(flash[:alert]).to be_present
  end

  it "is not reachable for other users' reports" do
    sign_in create(:user)
    upload(pades(sample_pdf))
    expect(response).to have_http_status(:not_found)
  end

  it "serves the signed file only to the owner" do
    upload(pades(sample_pdf))
    attachment = report.reload.signature.signed_file.attachment
    get file_path(attachment)
    expect(response.body).to start_with("%PDF")
    sign_in create(:user)
    get file_path(attachment)
    expect(response).to have_http_status(:not_found)
  end

  it "re-checks the signature when the PDF is regenerated" do
    upload(pades(sample_pdf))
    allow_any_instance_of(ReportPdfGenerator).to receive(:generate).and_return(double(render: sample_pdf.sub("/Count 0", "/Count 2")))
    GenerateReportPdfJob.perform_now(report.id, user.id)
    expect(report.reload.signature).to be_status_mismatch
    expect(report.generated_pdf_digest).to be_present
  end

  it "removes the signed version" do
    upload(pades(sample_pdf))
    delete report_signature_path(report)
    expect(report.reload.signature).to be_nil
  end
end
