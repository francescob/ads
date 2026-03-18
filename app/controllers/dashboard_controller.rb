class DashboardController < ApplicationController
  def index
    @beneficiari_count = Beneficiario.count
    @procedimenti_attivi = Procedimento.where(stato: 'attivo').count
    @scadenze_in_scadenza = Scadenza.in_scadenza.includes(procedimento: :beneficiario).limit(10)
    @scadenze_scadute = Scadenza.scadute.includes(procedimento: :beneficiario).count
    @prossime_udienze = Udienza.where("data_udienza >= ?", Time.now).order(:data_udienza).includes(procedimento: :beneficiario).limit(5)
  end
end
