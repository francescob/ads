class GenerateAssetPdfJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound

  def perform(beneficiary_id, user_id)
    beneficiary = Beneficiary.find(beneficiary_id)
    user = User.find(user_id)
    pdf = AssetPdfGenerator.new(beneficiary).generate

    beneficiary.asset_inventory_pdf.attach(
      io: StringIO.new(pdf.render),
      filename: "inventario_#{beneficiary.last_name}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.pdf",
      content_type: "application/pdf"
    )

    PdfGeneratedNotifier.notify_pdf_generated(user: user, beneficiary: beneficiary, pdf_type: "asset_inventory")
  end
end
