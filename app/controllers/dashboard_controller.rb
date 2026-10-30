class DashboardController < ApplicationController
  def index
    @beneficiari_count = Beneficiario.count
    @procedimenti_attivi = Procedimento.attivi.count
    @scadenze_in_scadenza = Scadenza.in_scadenza.includes(procedimento: :beneficiario).limit(10)
    @scadenze_scadute = Scadenza.scadute.count
    @prossime_udienze = Udienza.future.includes(procedimento: :beneficiario).limit(5)
  end
end
