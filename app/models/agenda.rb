# Raccoglie scadenze e udienze in un intervallo, per promemoria e calendario.
class Agenda
  attr_reader :giorni

  def initialize(giorni: 7)
    @giorni = giorni
  end

  def scadute
    Scadenza.scadute.includes(procedimento: :beneficiario).order(:data_scadenza)
  end

  def scadenze_prossime
    Scadenza.aperte.where(data_scadenza: Date.current..giorni.days.from_now.to_date)
            .includes(procedimento: :beneficiario).order(:data_scadenza)
  end

  def udienze_prossime
    Udienza.where(data_udienza: Time.current..giorni.days.from_now.end_of_day)
           .includes(procedimento: :beneficiario).order(:data_udienza)
  end

  def vuota?
    [ scadute, scadenze_prossime, udienze_prossime ].none?(&:exists?)
  end
end
