class Contact < ApplicationRecord
  belongs_to :beneficiary

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end