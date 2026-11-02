# To deliver this notification:
#
# PdfGeneratedNotifier.with(
#   beneficiary: @beneficiary,
#   pdf_type: "asset_inventory",
#   title: "Inventario Patrimoniale Generato",
#   message: "L'inventario patrimoniale di ... è stato generato con successo.",
#   url: download_asset_inventory_beneficiary_path(@beneficiary),
#   icon: "📄"
# ).deliver(current_user)

class PdfGeneratedNotifier < ApplicationNotifier
  # Deliver to database (for in-app notifications)
  deliver_by :database

  # Required params
  required_param :beneficiary
  required_param :pdf_type
  required_param :title
  required_param :message
  required_param :url
  required_param :icon

  # Helper method to create notification with all params
  def self.notify_pdf_generated(user:, beneficiary:, pdf_type:, report: nil)
    title, message, url, icon = case pdf_type
    when "asset_inventory"
      [
        "Inventario Patrimoniale Generato",
        "L'inventario patrimoniale di #{beneficiary.full_name} è stato generato con successo.",
        Rails.application.routes.url_helpers.download_asset_inventory_beneficiary_path(beneficiary),
        "📄"
      ]
    when "report"
      [
        "Rendiconto Generato",
        "Il rendiconto per #{beneficiary.full_name} è stato generato con successo.",
        report ? Rails.application.routes.url_helpers.report_path(report) : Rails.application.routes.url_helpers.beneficiary_path(beneficiary),
        "📊"
      ]
    else
      [
        "PDF Generato",
        "Il PDF è stato generato con successo.",
        Rails.application.routes.url_helpers.beneficiary_path(beneficiary),
        "✅"
      ]
    end

    event = with(
      beneficiary: beneficiary,
      pdf_type: pdf_type,
      title: title,
      message: message,
      url: url,
      icon: icon
    ).deliver(user)

    # Real-time toast for the user who is waiting for the PDF
    notification = event.notifications.find_by(recipient: user)
    Turbo::StreamsChannel.broadcast_append_to(
      "notifications_#{user.id}",
      target: "notifications",
      partial: "notifications/toast",
      locals: { notification: notification, notification_type: "success" }
    )
    notification
  end
end
