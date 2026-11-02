class GenerateReportPdfJob < ApplicationJob
  queue_as :default

  def perform(report_id, user_id)
    report = Report.find(report_id)
    user = User.find(user_id)
    pdf = ReportPdfGenerator.new(report).generate

    report.generated_pdf.attach(
      io: StringIO.new(pdf.render),
      filename: "report_#{report.reference_year}_#{report.beneficiary.last_name}.pdf",
      content_type: 'application/pdf'
    )

    # Invia notifica di completamento
    PdfGeneratedNotifier.notify_pdf_generated(
      user: user,
      beneficiary: report.beneficiary,
      pdf_type: "report",
      report: report
    )

    # Broadcast toast notification via Turbo Stream per mostrare il toast real-time
    notification = user.notifications.order(created_at: :desc).first
    Turbo::StreamsChannel.broadcast_append_to(
      "notifications_#{user.id}",
      target: "notifications",
      partial: "notifications/toast",
      locals: { 
        notification: notification,
        notification_type: 'success'
      }
    )
  end
end