# Content type and size checks for Active Storage attachments.
#
#   validates_attachment :file, content_types: ValidatedAttachment::DOCUMENTS
module ValidatedAttachment
  extend ActiveSupport::Concern

  PDF = %w[application/pdf].freeze
  IMAGES = %w[image/jpeg image/png image/heic image/webp].freeze
  OFFICE = %w[
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.oasis.opendocument.text
    application/vnd.oasis.opendocument.spreadsheet
  ].freeze
  RECEIPTS = (PDF + IMAGES).freeze
  DOCUMENTS = (PDF + IMAGES + OFFICE).freeze
  MAX_SIZE = 20.megabytes

  class_methods do
    def validates_attachment(name, content_types:, max_size: MAX_SIZE)
      validate do
        attachment = public_send(name)
        next unless attachment.attached?

        unless content_types.include?(attachment.blob.content_type)
          errors.add(name, :content_type_not_allowed, allowed: allowed_extensions(content_types))
        end
        if attachment.blob.byte_size > max_size
          errors.add(name, :file_too_large, max: ActiveSupport::NumberHelper.number_to_human_size(max_size))
        end
      end
    end
  end

  private

  def allowed_extensions(content_types)
    content_types.filter_map { |t| Marcel::Magic.new(t).extensions.first&.upcase }.uniq.join(", ")
  end
end
