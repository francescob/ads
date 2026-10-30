class Rendiconto < ApplicationRecord
  include Tracciabile

  STATI = %w[bozza presentato approvato respinto].freeze

  belongs_to :procedimento

  validates :anno, presence: true, uniqueness: { scope: :procedimento_id },
                   numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: -> { Date.current.year + 1 } }
  validates :stato, inclusion: { in: STATI }
  validates :importo_entrate, :importo_uscite, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :data_approvazione, comparison: { greater_than_or_equal_to: :data_presentazione },
                                if: -> { data_approvazione && data_presentazione }

  def saldo
    (importo_entrate || 0) - (importo_uscite || 0)
  end

  def periodo
    Date.new(anno).all_year
  end

  def movimenti
    Movimento.joins(:conto).where(conti: { beneficiario_id: procedimento.beneficiario_id }).nell_anno(anno)
  end

  # Totali per categoria: { ["entrata", "pensione"] => 12000.0, ... }
  def totali_per_categoria
    movimenti.group(:verso, :categoria).order(:verso, :categoria).sum(:importo)
  end

  # Aggiorna entrate/uscite dalla somma dei movimenti dell'anno.
  def ricalcola_da_movimenti!
    update!(importo_entrate: movimenti.entrate.sum(:importo), importo_uscite: movimenti.uscite.sum(:importo))
  end
end
