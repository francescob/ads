class Procedimento < ApplicationRecord
  STATI = %w[attivo chiuso sospeso].freeze

  belongs_to :beneficiario
  has_many :udienze, dependent: :destroy
  has_many :scadenze, dependent: :destroy
  has_many :rendiconti, dependent: :destroy
  has_many :attivita, dependent: :destroy

  validates :stato, inclusion: { in: STATI }
  validates :data_chiusura, comparison: { greater_than_or_equal_to: :data_apertura },
                            if: -> { data_chiusura && data_apertura }

  scope :attivi, -> { where(stato: "attivo") }

  def titolo
    numero_rg.present? ? "RG #{numero_rg}" : "##{id}"
  end
end
