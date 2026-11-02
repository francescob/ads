class Communication < ApplicationRecord
  include ValidatedAttachment
  include OwnedThroughBeneficiary

  belongs_to :beneficiary

  has_one_attached :attachment
  validates_attachment :attachment, content_types: ValidatedAttachment::DOCUMENTS

  enum :channel, { pec: 0, email: 1, registered_mail: 2, fax: 3 }
  enum :status, { draft: 0, sent: 1, received: 2 }

  validates :subject, presence: true
end
