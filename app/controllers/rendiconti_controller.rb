class RendicontiController < ApplicationController
  before_action :set_context
  before_action :set_rendiconto, only: [:show, :edit, :update, :destroy]

  def index
    @rendiconti = @procedimento.rendiconti.order(anno: :desc)
  end

  def show
  end

  def new
    @rendiconto = @procedimento.rendiconti.build
  end

  def edit
  end

  def create
    @rendiconto = @procedimento.rendiconti.build(rendiconto_params)
    if @rendiconto.save
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Rendiconto creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @rendiconto.update(rendiconto_params)
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Rendiconto aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rendiconto.destroy
    redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Rendiconto eliminato.", status: :see_other
  end

  private

  def set_context
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
    @procedimento = @beneficiario.procedimenti.find(params[:procedimento_id])
  end

  def set_rendiconto
    @rendiconto = @procedimento.rendiconti.find(params[:id])
  end

  def rendiconto_params
    params.require(:rendiconto).permit(:anno, :data_presentazione, :data_approvazione, :stato, :note, :importo_entrate, :importo_uscite)
  end
end
