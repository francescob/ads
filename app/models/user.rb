class User < ApplicationRecord
  RUOLI = %w[admin operatore].freeze

  has_secure_password
  has_secure_token :calendar_token
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :nome, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :ruolo, inclusion: { in: RUOLI }
  validates :password, length: { minimum: 10 }, allow_nil: true

  scope :attivi, -> { where(attivo: true) }
  scope :destinatari_promemoria, -> { attivi.where(riceve_promemoria: true) }

  def admin?
    ruolo == "admin"
  end
end
