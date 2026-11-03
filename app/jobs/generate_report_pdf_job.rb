class GenerateReportPdfJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound

  def perform(report_id, user_id)
    report = Report.find(report_id)
    user = User.find(user_id)
    pdf = ReportPdfGenerator.new(report).generate

    bytes = pdf.render
    report.generated_pdf.attach(
      io: StringIO.new(bytes),
      filename: "report_#{report.reference_year}_#{report.beneficiary.last_name}.pdf",
      content_type: "application/pdf"
    )
    report.update_column(:generated_pdf_digest, Digest::SHA256.hexdigest(bytes))
    # A new PDF no longer matches a signature made on the previous one
    report.reverify_signature

    PdfGeneratedNotifier.notify_pdf_generated(user: user, beneficiary: report.beneficiary, pdf_type: "report", report: report)
  end
end
