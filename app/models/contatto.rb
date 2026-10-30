class Contatto < ApplicationRecord
  TIPI = %w[familiare servizi_sociali medico struttura banca legale altro].freeze

  belongs_to :beneficiario

  normalizes :email, with: ->(email) { email.strip.downcase.presence }

  validates :nome, presence: true
  validates :tipo, inclusion: { in: TIPI }, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
end
