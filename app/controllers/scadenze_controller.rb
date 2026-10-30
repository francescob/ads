class ScadenzeController < ApplicationController
  include ProcedimentoScoped

  before_action :set_procedimento, except: :index
  before_action :set_scadenza, only: %i[edit update destroy]

  def index
    @scadenze = Scadenza.in_scadenza.includes(procedimento: :beneficiario)
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
    params.require(:scadenza).permit(:titolo, :descrizione, :data_scadenza, :completata, :tipo, :note)
  end
end
