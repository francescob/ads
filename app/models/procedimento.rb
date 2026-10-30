class Procedimento < ApplicationRecord
  include Tracciabile

  STATI = %w[attivo chiuso sospeso].freeze

  belongs_to :beneficiario
  has_many :udienze, dependent: :destroy
  has_many :scadenze, dependent: :destroy
  has_many :rendiconti, dependent: :destroy
  has_many :attivita, dependent: :destroy
  has_many :documenti, dependent: :destroy
  has_many :istanze, dependent: :destroy

  validates :stato, inclusion: { in: STATI }
  validates :data_chiusura, comparison: { greater_than_or_equal_to: :data_apertura },
                            if: -> { data_chiusura && data_apertura }

  scope :attivi, -> { where(stato: "attivo") }

  after_create_commit :crea_scadenza_rendiconto, if: :data_apertura?

  def titolo
    numero_rg.present? ? "RG #{numero_rg}" : "##{id}"
  end

  private

  # Il rendiconto va depositato ogni anno: lo mettiamo subito in scadenzario.
  def crea_scadenza_rendiconto
    scadenze.create!(titolo: "Deposito rendiconto annuale", tipo: "rendiconto", ricorrenza: "annuale",
                     data_scadenza: data_apertura.next_year)
  end
end
