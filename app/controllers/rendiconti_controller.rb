class RendicontiController < ApplicationController
  include ProcedimentoScoped

  before_action :set_procedimento
  before_action :set_rendiconto, only: %i[show edit update destroy ricalcola]

  # Prospetto stampabile del rendiconto (stampa / salva come PDF dal browser)
  def show
    @conti = @beneficiario.conti.order(:nome)
    @totali = @rendiconto.totali_per_categoria
    @movimenti = @rendiconto.movimenti.includes(:conto).cronologici

    respond_to do |format|
      format.html
      format.csv do
        send_data MovimentiCsv.new(@movimenti).to_csv, filename: "rendiconto-#{@rendiconto.anno}.csv", type: "text/csv"
      end
    end
  end

  def ricalcola
    @rendiconto.ricalcola_da_movimenti!
    redirect_to beneficiario_procedimento_rendiconto_path(@beneficiario, @procedimento, @rendiconto),
                notice: "Importi ricalcolati dai movimenti #{@rendiconto.anno}."
  end

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
