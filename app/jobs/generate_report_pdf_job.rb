class GenerateReportPdfJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound

  def perform(report_id, user_id)
    report = Report.find(report_id)
    user = User.find(user_id)
    pdf = ReportPdfGenerator.new(report).generate

    report.generated_pdf.attach(
      io: StringIO.new(pdf.render),
      filename: "report_#{report.reference_year}_#{report.beneficiary.last_name}.pdf",
      content_type: "application/pdf"
    )

    PdfGeneratedNotifier.notify_pdf_generated(user: user, beneficiary: report.beneficiary, pdf_type: "report", report: report)
  end
end
