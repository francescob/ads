module Paginazione
  extend ActiveSupport::Concern

  PER_PAGINA = 25

  included do
    helper_method :pagina_corrente
  end

  private

  def pagina_corrente
    [ params[:pagina].to_i, 1 ].max
  end

  # Restituisce la pagina richiesta e imposta @totale_pagine per il partial shared/paginazione.
  def pagina(scope, per: PER_PAGINA)
    @totale_pagine = [ (scope.count.to_f / per).ceil, 1 ].max
    scope.limit(per).offset((pagina_corrente - 1) * per)
  end
end
