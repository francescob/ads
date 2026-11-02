class Hearing < ApplicationRecord
  belongs_to :beneficiary
  belongs_to :appointment, optional: true

  validates :hearing_date, presence: true
end