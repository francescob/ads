class Istanza < ApplicationRecord
  TIPI = %w[autorizzazione_spesa atto_straordinario vendita_immobile investimento consenso_sanitario modifica_decreto altro].freeze
  STATI = %w[bozza depositata autorizzata respinta].freeze

  belongs_to :procedimento

  validates :oggetto, presence: true
  validates :tipo, inclusion: { in: TIPI }, allow_blank: true
  validates :stato, inclusion: { in: STATI }
  validates :importo, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :data_decisione, comparison: { greater_than_or_equal_to: :data_deposito },
                             if: -> { data_decisione && data_deposito }

  scope :in_attesa, -> { where(stato: "depositata") }
end
