class Appointment < ApplicationRecord
  include ValidatedAttachment
  include OwnedThroughBeneficiary

  belongs_to :beneficiary

  # A decree with reports cannot be deleted: reports hold the financial history
  has_many :reports, dependent: :restrict_with_error
  has_many :hearings, dependent: :nullify
  has_one_attached :document
  validates_attachment :document, content_types: ValidatedAttachment::RECEIPTS

  enum :appointment_type, { provisional: 0, definitive: 1, urgent: 2 }

  validates :decree_number, :decree_date, :court, :appointment_date, presence: true

  after_create :create_annual_report_deadlines
  after_save :ensure_mandate_expiry_deadline, if: -> { saved_change_to_mandate_expiry_date? && mandate_expiry_date }

  # Creates (once) the "annual report" deadline for the given year: due March 31st of the next year.
  def ensure_annual_report_deadline(year)
    return if mandate_expiry_date && year >= mandate_expiry_date.year

    beneficiary.deadlines.find_or_create_by!(deadline_type: :report, due_date: Date.new(year + 1, 3, 31)) do |d|
      d.title = I18n.t("appointments.annual_report_deadline.title", year: year)
      d.description = I18n.t("appointments.annual_report_deadline.description", year: year, court: court)
      d.reminder_date = Date.new(year + 1, 2, 1)
      d.status = :open
      d.priority = :high
    end
  end

  private

  # Report deadlines from the appointment year on, skipping those already past
  # (decrees entered retroactively). Open-ended mandates get them up to the current
  # year; the following ones are created as each report is filed (see Report).
  def create_annual_report_deadlines
    return unless appointment_date

    last_year = mandate_expiry_date ? mandate_expiry_date.year - 1 : [ appointment_date.year, Date.current.year ].max
    (appointment_date.year..last_year).each do |year|
      ensure_annual_report_deadline(year) if Date.new(year + 1, 3, 31) >= Date.current
    end
  end

  # Mandate expiry: a renewal deadline with a reminder two months before.
  def ensure_mandate_expiry_deadline
    beneficiary.deadlines.find_or_create_by!(deadline_type: :renewal, due_date: mandate_expiry_date) do |d|
      d.title = I18n.t("appointments.mandate_expiry_deadline.title", decree: decree_number)
      d.reminder_date = mandate_expiry_date - 2.months
      d.status = :open
      d.priority = :high
    end
  end
end
