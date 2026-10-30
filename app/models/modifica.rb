# Registro delle modifiche (chi ha cambiato cosa e quando).
class Modifica < ApplicationRecord
  AZIONI = %w[create update destroy].freeze
  ETICHETTE_AZIONI = { "create" => "Creato", "update" => "Modificato", "destroy" => "Eliminato" }.freeze

  belongs_to :user, optional: true
  belongs_to :beneficiario, optional: true

  validates :azione, inclusion: { in: AZIONI }

  scope :recenti, -> { order(created_at: :desc, id: :desc) }

  def readonly?
    persisted?
  end
end
