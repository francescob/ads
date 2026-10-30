class Scadenza < ApplicationRecord
  TIPI = %w[rendiconto udienza adempimento altro].freeze
  GIORNI_PREAVVISO = 30

  belongs_to :procedimento

  validates :titolo, :data_scadenza, presence: true
  validates :tipo, inclusion: { in: TIPI }, allow_blank: true

  scope :aperte, -> { where(completata: false) }
  scope :in_scadenza, -> { aperte.where(data_scadenza: ..GIORNI_PREAVVISO.days.from_now.to_date).order(:data_scadenza) }
  scope :scadute, -> { aperte.where(data_scadenza: ...Date.current) }

  def scaduta?
    !completata? && data_scadenza.present? && data_scadenza < Date.current
  end
end
