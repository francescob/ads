class Property < ApplicationRecord
  include OwnedThroughBeneficiary

  belongs_to :beneficiary

  # Tipi di immobile
  enum :property_type, {
    residential: 0,      # Residenziale (appartamento, casa)
    commercial: 1,       # Commerciale (negozio, ufficio)
    agricultural: 2,     # Agricolo (terreno agricolo, rustico)
    land: 3,            # Terreno edificabile
    industrial: 4,       # Industriale (capannone, magazzino)
    garage: 5,          # Box/Garage/Posto auto
    other: 6            # Altro
  }

  # Validazioni
  validates :beneficiary, presence: true
  validates :description, presence: true
  validates :property_type, presence: true
  validates :ownership_numerator, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validates :ownership_denominator, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validate :ownership_fraction_valid
  validates :cadastral_income, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :current_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :initial_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scope utili
  scope :by_type, ->(type) { where(property_type: type) }
  scope :ordered, -> { order(created_at: :desc) }

  # Metodi helper
  def full_address
    parts = [address, zip_code, city, province].compact.reject(&:blank?)
    parts.join(", ")
  end

  def cadastral_reference
    parts = []
    parts << "Foglio #{cadastral_sheet}" if cadastral_sheet.present?
    parts << "Part. #{cadastral_particle}" if cadastral_particle.present?
    parts << "Sub #{cadastral_sub}" if cadastral_sub.present?
    parts.join(", ")
  end

  def cadastral_classification
    parts = []
    parts << "Cat. #{cadastral_category}" if cadastral_category.present?
    parts << "Cl. #{cadastral_class}" if cadastral_class.present?
    parts << "Cons. #{cadastral_consistency}" if cadastral_consistency.present?
    parts.join(", ")
  end

  def owned_value
    return nil unless current_value && ownership_numerator && ownership_denominator
    return nil if ownership_denominator.zero?
    (current_value * ownership_numerator / ownership_denominator.to_f).round(2)
  end

  def ownership_fraction
    return nil unless ownership_numerator && ownership_denominator
    "#{ownership_numerator}/#{ownership_denominator}"
  end

  def ownership_percentage
    return nil unless ownership_numerator && ownership_denominator
    return nil if ownership_denominator.zero?
    ((ownership_numerator.to_f / ownership_denominator) * 100).round(2)
  end

  private

  def ownership_fraction_valid
    return if ownership_numerator.nil? || ownership_denominator.nil?
    
    if ownership_denominator.zero?
      errors.add(:ownership_denominator, "non può essere zero")
    end
    
    if ownership_numerator > ownership_denominator
      errors.add(:ownership_numerator, "non può essere maggiore del denominatore")
    end
  end

  def property_type_i18n
    I18n.t("activerecord.enums.property.property_type.#{property_type}", default: property_type.humanize)
  end
end