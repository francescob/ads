class ScadenzeController < ApplicationController
  before_action :set_context, except: [:index]
  before_action :set_scadenza, only: [:show, :edit, :update, :destroy]

  def index
    @scadenze = Scadenza.in_scadenza.includes(procedimento: :beneficiario)
  end

  def show
  end

  def new
    @scadenza = @procedimento.scadenze.build
  end

  def edit
  end

  def create
    @scadenza = @procedimento.scadenze.build(scadenza_params)
    if @scadenza.save
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Scadenza creata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @scadenza.update(scadenza_params)
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Scadenza aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @scadenza.destroy
    redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Scadenza eliminata.", status: :see_other
  end

  private

  def set_context
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
    @procedimento = @beneficiario.procedimenti.find(params[:procedimento_id])
  end

  def set_scadenza
    @scadenza = @procedimento.scadenze.find(params[:id])
  end

  def scadenza_params
    params.require(:scadenza).permit(:titolo, :descrizione, :data_scadenza, :completata, :tipo, :note)
  end
end
