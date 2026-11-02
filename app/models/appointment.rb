class Appointment < ApplicationRecord
  belongs_to :beneficiary

  has_many :reports, dependent: :destroy
  has_many :hearings, dependent: :nullify
  has_one_attached :document

  enum :appointment_type, { provisional: 0, definitive: 1, urgent: 2 }

  validates :decree_number, :decree_date, :court, :appointment_date, presence: true

  after_create :create_annual_report_deadlines

  private

  def create_annual_report_deadlines
    return unless appointment_date && mandate_expiry_date

    (appointment_date.year...mandate_expiry_date.year).each do |year|
      beneficiary.deadlines.create!(
        title:          "Annual report #{year}",
        description:    "Report for year #{year} - to be filed at #{court}",
        due_date:       Date.new(year + 1, 3, 31),
        reminder_date:  Date.new(year + 1, 2, 1),
        deadline_type:  :report,
        status:         :open,
        priority:       :high
      )
    end
  end
end