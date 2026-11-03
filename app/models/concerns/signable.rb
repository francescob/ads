# Records whose generated document can be signed digitally outside the app and uploaded back.
# Including models implement #signature_original: the attachment the signature must match.
module Signable
  extend ActiveSupport::Concern

  included do
    has_one :signature, as: :signable, dependent: :destroy
  end

  # Re-check the stored signature, e.g. after the original document was regenerated
  def reverify_signature
    signature&.verify!
  end
end
