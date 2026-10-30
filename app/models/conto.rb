class Conto < ApplicationRecord
  include Tracciabile

  TIPI = %w[conto_corrente libretto_postale deposito_titoli carta_prepagata contanti altro].freeze

  belongs_to :beneficiario
  has_many :movimenti, dependent: :destroy

  normalizes :iban, with: ->(iban) { iban.gsub(/\s/, "").upcase.presence }

  validates :nome, presence: true
  validates :tipo, inclusion: { in: TIPI }, allow_blank: true
  validates :iban, format: { with: /\A[A-Z]{2}\d{2}[A-Z0-9]{11,30}\z/ }, allow_nil: true
  validates :saldo_iniziale, numericality: true

  scope :attivi, -> { where(attivo: true) }

  # Saldo a fine giornata della data indicata (default: oggi).
  def saldo(al: Date.current)
    saldo_iniziale + movimenti.where(data: ..al).sum(Movimento::IMPORTO_CON_SEGNO)
  end
end
