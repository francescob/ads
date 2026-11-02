class Asset < ApplicationRecord
  include OwnedThroughBeneficiary

  belongs_to :beneficiary

  enum :asset_type, { bank_account: 0, real_estate: 1, vehicle: 2, securities: 3, cash: 4, other_asset: 5 }

  validates :description, presence: true
end