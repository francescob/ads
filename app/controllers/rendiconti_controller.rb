class RendicontiController < ApplicationController
  include ProcedimentoScoped

  before_action :set_procedimento
  before_action :set_rendiconto, only: %i[edit update destroy]

  def new
    @rendiconto = @procedimento.rendiconti.build
  end

  def edit
  end

  def create
    @rendiconto = @procedimento.rendiconti.build(rendiconto_params)
    if @rendiconto.save
      redirect_to_procedimento "Rendiconto creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @rendiconto.update(rendiconto_params)
      redirect_to_procedimento "Rendiconto aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rendiconto.destroy
    redirect_to_procedimento "Rendiconto eliminato.", status: :see_other
  end

  private

  def set_rendiconto
    @rendiconto = @procedimento.rendiconti.find(params[:id])
  end

  def rendiconto_params
    params.require(:rendiconto).permit(:anno, :data_presentazione, :data_approvazione, :stato, :note, :importo_entrate, :importo_uscite)
  end
end
