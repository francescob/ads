# A digitally signed version of a record's document (e.g. a report PDF), signed outside the app
# and uploaded back. See SignatureVerifier for the checks.
class Signature < ApplicationRecord
  include ValidatedAttachment

  SIGNED_FILE_TYPES = %w[
    application/pdf
    application/pkcs7-mime
    application/x-pkcs7-mime
    application/pkcs7-signature
    application/octet-stream
  ].freeze

  belongs_to :signable, polymorphic: true
  belongs_to :uploaded_by, class_name: "User", optional: true

  has_one_attached :signed_file
  validates_attachment :signed_file, content_types: SIGNED_FILE_TYPES
  validates :signed_file, presence: true

  enum :status, { pending: 0, valid_untrusted: 1, valid_trusted: 2, mismatch: 3, invalid: 4 }, prefix: true

  delegate :beneficiary, to: :signable

  def verify!
    original = signable.signature_original
    result = SignatureVerifier.new(signed_file.download, original: original&.attached? ? original.download : nil).call
    update!(**result.to_h, verified_at: Time.current)
  end

  def ok?
    status_valid_untrusted? || status_valid_trusted?
  end

  def errors_list
    details.fetch("errors", [])
  end

  def warnings_list
    details.fetch("warnings", [])
  end
end
