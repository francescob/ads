class Scadenza < ApplicationRecord
  include Tracciabile

  TIPI = %w[rendiconto udienza adempimento altro].freeze
  GIORNI_PREAVVISO = 30
  RICORRENZE = { "mensile" => 1, "trimestrale" => 3, "semestrale" => 6, "annuale" => 12 }.freeze

  belongs_to :procedimento

  validates :titolo, :data_scadenza, presence: true
  validates :tipo, inclusion: { in: TIPI }, allow_blank: true
  validates :ricorrenza, inclusion: { in: RICORRENZE.keys }, allow_blank: true

  # Completando una scadenza ricorrente si crea automaticamente la successiva.
  after_update_commit :crea_successiva, if: -> { saved_change_to_completata?(to: true) && ricorrenza.present? }

  scope :aperte, -> { where(completata: false) }
  scope :in_scadenza, -> { aperte.where(data_scadenza: ..GIORNI_PREAVVISO.days.from_now.to_date).order(:data_scadenza) }
  scope :scadute, -> { aperte.where(data_scadenza: ...Date.current) }

  def prossima_data
    data_scadenza.advance(months: RICORRENZE.fetch(ricorrenza))
  end

  def scaduta?
    !completata? && data_scadenza.present? && data_scadenza < Date.current
  end

  private

  def crea_successiva
    procedimento.scadenze.find_or_create_by!(titolo: titolo, data_scadenza: prossima_data) do |s|
      s.assign_attributes(tipo: tipo, descrizione: descrizione, ricorrenza: ricorrenza)
    end
  end
end
