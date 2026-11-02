class GenerateAssetPdfJob < ApplicationJob
  queue_as :default

  def perform(beneficiary_id, user_id)
    Rails.logger.info("🔵 [GenerateAssetPdfJob] Starting for beneficiary #{beneficiary_id}, user #{user_id}")
    
    beneficiary = Beneficiary.find(beneficiary_id)
    user = User.find(user_id)
    
    Rails.logger.info("🔵 [GenerateAssetPdfJob] Found beneficiary: #{beneficiary.full_name}, user: #{user.full_name}")
    
    # Elimina il vecchio PDF se esiste per evitare problemi di cache
    beneficiary.asset_inventory_pdf.purge if beneficiary.asset_inventory_pdf.attached?
    
    pdf = AssetPdfGenerator.new(beneficiary).generate

    beneficiary.asset_inventory_pdf.attach(
      io: StringIO.new(pdf.render),
      filename: "inventario_#{beneficiary.last_name}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.pdf",
      content_type: 'application/pdf'
    )
    
    Rails.logger.info("🔵 [GenerateAssetPdfJob] PDF attached successfully")

    # Invia notifica di completamento
    Rails.logger.info("🔵 [GenerateAssetPdfJob] Delivering notification...")
    PdfGeneratedNotifier.notify_pdf_generated(
      user: user,
      beneficiary: beneficiary,
      pdf_type: "asset_inventory"
    )
    
    Rails.logger.info("🔵 [GenerateAssetPdfJob] Notification delivered")

    # Broadcast toast notification via Turbo Stream per mostrare il toast real-time
    Rails.logger.info("🔵 [GenerateAssetPdfJob] Looking for notification...")
    notification = user.notifications.order(created_at: :desc).first
    
    if notification.present?
      Rails.logger.info("🔵 [GenerateAssetPdfJob] Found notification ID: #{notification.id}")
      Rails.logger.info("🔵 [GenerateAssetPdfJob] Broadcasting to channel: notifications_#{user.id}")
      
      Turbo::StreamsChannel.broadcast_append_to(
        "notifications_#{user.id}",
        target: "notifications",
        partial: "notifications/toast",
        locals: { 
          notification: notification,
          notification_type: 'success'
        }
      )
      
      Rails.logger.info("🔵 [GenerateAssetPdfJob] Broadcast sent successfully")
    else
      Rails.logger.error("🔴 [GenerateAssetPdfJob] No notification found for user #{user.id}")
    end
    
    Rails.logger.info("✅ [GenerateAssetPdfJob] Completed successfully")
  end
end