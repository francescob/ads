# The linked appointment (decree) must belong to the same beneficiary:
# otherwise a crafted appointment_id could pull another user's decree data
# (court, judge, decree number) into this record and its PDF.
module AppointmentOfSameBeneficiary
  extend ActiveSupport::Concern

  included do
    validate :appointment_belongs_to_beneficiary
  end

  private

  def appointment_belongs_to_beneficiary
    return if appointment.nil? || appointment.beneficiary_id == beneficiary_id

    errors.add(:appointment, :invalid)
  end
end
