class Document < ApplicationRecord
  include ValidatedAttachment
  include OwnedThroughBeneficiary

  belongs_to :beneficiary

  has_one_attached :file
  validates_attachment :file, content_types: ValidatedAttachment::DOCUMENTS

  enum :document_type, { identity: 0, medical_doc: 1, legal: 2, financial: 3, correspondence: 4, other_doc: 5 }

  validates :title, presence: true

  def expiring_soon?
    expiry_date.present? && expiry_date <= 30.days.from_now && expiry_date >= Date.current
  end

  def expired?
    expiry_date.present? && expiry_date < Date.current
  end
end