class Hearing < ApplicationRecord
  include OwnedThroughBeneficiary
  include AppointmentOfSameBeneficiary

  belongs_to :beneficiary
  belongs_to :appointment, optional: true

  validates :hearing_date, presence: true
end