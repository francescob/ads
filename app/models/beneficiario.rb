class Beneficiario < ApplicationRecord
  CODICE_FISCALE_FORMAT = /\A[A-Z]{6}[0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]\z/

  has_many :procedimenti, dependent: :destroy
  has_many :contatti, dependent: :destroy
  has_many :conti, dependent: :destroy
  has_many :movimenti, through: :conti

  normalizes :codice_fiscale, with: ->(cf) { cf.strip.upcase.presence }
  normalizes :email, with: ->(email) { email.strip.downcase.presence }

  validates :nome, :cognome, presence: true
  validates :codice_fiscale, format: { with: CODICE_FISCALE_FORMAT }, uniqueness: true, allow_nil: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  scope :ordinati, -> { order(:cognome, :nome) }
  scope :cerca, ->(q) {
    next all if q.blank?
    term = "%#{sanitize_sql_like(q.strip)}%"
    where("nome LIKE :t OR cognome LIKE :t OR codice_fiscale LIKE :t", t: term)
  }

  def nome_completo
    "#{cognome} #{nome}"
  end
end
