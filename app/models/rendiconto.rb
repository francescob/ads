class Rendiconto < ApplicationRecord
  belongs_to :procedimento
  
  STATI = %w[bozza presentato approvato respinto].freeze
  
  def saldo
    (importo_entrate || 0) - (importo_uscite || 0)
  end
end
