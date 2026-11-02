# Records that belong to a beneficiary, and therefore to the beneficiary's user.
module OwnedThroughBeneficiary
  extend ActiveSupport::Concern

  included do
    scope :owned_by, ->(user) { joins(:beneficiary).where(beneficiaries: { user_id: user.id }) }
  end
end
