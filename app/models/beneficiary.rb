class Beneficiary < ApplicationRecord
  belongs_to :user

  has_many :appointments, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :assets, dependent: :destroy
  has_many :deadlines, dependent: :destroy
  has_many :hearings, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :communications, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :liabilities, dependent: :destroy
  has_many :recurring_incomes, dependent: :destroy
  has_many :recurring_expenses, dependent: :destroy
  has_many :properties, dependent: :destroy

  has_one_attached :asset_inventory_pdf

  enum :gender, { male: 0, female: 1 }
  enum :status, { active: 0, suspended: 1, closed: 2 }

  validates :first_name, :last_name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "city", "created_at", "date_of_birth", "diagnosis", "doctor_contact", "first_name", "gender", "health_condition", "id", "id_value", "last_name", "notes", "place_of_birth", "province", "referring_doctor", "status", "street_address", "tax_code", "updated_at", "user_id", "zip_code" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user", "appointments", "reports", "assets", "liabilities", "recurring_incomes", "recurring_expenses", "properties", "deadlines", "hearings", "documents", "communications", "contacts" ]
  end

  scope :active, -> { where(status: :active) }
  scope :closed, -> { where(status: :closed) }
  scope :search_by_name, ->(q) { where("first_name LIKE ? OR last_name LIKE ?", "%#{q}%", "%#{q}%") }

  def full_name
    "#{first_name} #{last_name}"
  end

  def total_assets
    assets.sum(:current_value)
  end

  def total_liabilities
    liabilities.sum(:remaining_balance)
  end

  alias_method :net_asset_total, :total_assets

  def net_worth
    total_patrimony - total_liabilities
  end

  def total_patrimony
    total_assets + total_properties_value
  end

  def total_properties_value
    properties.sum(:current_value)
  end

  def total_owned_properties_value
    properties.sum { |p| p.owned_value || 0 }
  end

  # Calcola il totale delle entrate ricorrenti annuali attive
  def total_annual_recurring_income
    recurring_incomes.active_incomes.sum(&:annual_amount)
  end

  # Calcola il totale delle entrate ricorrenti mensili attive
  def total_monthly_recurring_income
    total_annual_recurring_income / 12.0
  end

  # Calcola il totale delle uscite ricorrenti annuali attive
  def total_annual_recurring_expense
    recurring_expenses.active_expenses.sum(&:annual_amount)
  end

  # Calcola il totale delle uscite ricorrenti mensili attive
  def total_monthly_recurring_expense
    total_annual_recurring_expense / 12.0
  end

  # Calcola il bilancio annuale (entrate - uscite ricorrenti)
  def annual_cash_flow
    total_annual_recurring_income - total_annual_recurring_expense
  end

  # Calcola il bilancio mensile medio
  def monthly_cash_flow
    annual_cash_flow / 12.0
  end
end
