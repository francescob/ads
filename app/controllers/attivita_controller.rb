class AttivitaController < ApplicationController
  before_action :set_context
  before_action :set_attivita, only: [:show, :edit, :update, :destroy]

  def index
    @attivita_list = @procedimento.attivita.order(data_attivita: :desc)
  end

  def show
  end

  def new
    @attivita = @procedimento.attivita.build
  end

  def edit
  end

  def create
    @attivita = @procedimento.attivita.build(attivita_params)
    if @attivita.save
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Attività creata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @attivita.update(attivita_params)
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Attività aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @attivita.destroy
    redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Attività eliminata.", status: :see_other
  end

  private

  def set_context
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
    @procedimento = @beneficiario.procedimenti.find(params[:procedimento_id])
  end

  def set_attivita
    @attivita = @procedimento.attivita.find(params[:id])
  end

  def attivita_params
    params.require(:attivita).permit(:titolo, :descrizione, :data_attivita, :tipo, :completata, :note)
  end
end
