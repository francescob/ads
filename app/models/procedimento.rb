class Procedimento < ApplicationRecord
  belongs_to :beneficiario
  has_many :udienze, dependent: :destroy
  has_many :scadenze, dependent: :destroy
  has_many :rendiconti, dependent: :destroy
  has_many :attivita, dependent: :destroy
  
  validates :stato, inclusion: { in: %w[attivo chiuso sospeso] }, allow_blank: true
  
  STATI = %w[attivo chiuso sospeso].freeze
end
