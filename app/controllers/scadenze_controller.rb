class ScadenzeController < ApplicationController
  include ProcedimentoScoped
  include Paginazione

  FILTRI = {
    "imminenti" => -> { Scadenza.in_scadenza },
    "scadute" => -> { Scadenza.scadute.order(:data_scadenza) },
    "aperte" => -> { Scadenza.aperte.order(:data_scadenza) },
    "completate" => -> { Scadenza.where(completata: true).order(data_scadenza: :desc) }
  }.freeze

  before_action :set_procedimento, except: :index
  before_action :set_scadenza, only: %i[edit update destroy]

  def index
    @filtro = FILTRI.key?(params[:filtro]) ? params[:filtro] : "imminenti"
    @scadenze = pagina(FILTRI[@filtro].call.includes(procedimento: :beneficiario))
  end

  def new
    @scadenza = @procedimento.scadenze.build
  end

  def edit
  end

  def create
    @scadenza = @procedimento.scadenze.build(scadenza_params)
    if @scadenza.save
      redirect_to_procedimento "Scadenza creata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @scadenza.update(scadenza_params)
      redirect_to_procedimento "Scadenza aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @scadenza.destroy
    redirect_to_procedimento "Scadenza eliminata.", status: :see_other
  end

  private

  def set_scadenza
    @scadenza = @procedimento.scadenze.find(params[:id])
  end

  def scadenza_params
    params.require(:scadenza).permit(:titolo, :descrizione, :data_scadenza, :completata, :tipo, :ricorrenza, :note)
  end
end
