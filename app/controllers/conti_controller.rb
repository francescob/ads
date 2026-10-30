class ContiController < ApplicationController
  before_action :set_beneficiario
  before_action :set_conto, only: %i[show edit update destroy]

  def show
    @anno = (params[:anno].presence || Date.current.year).to_i
    @movimenti = @conto.movimenti.nell_anno(@anno).cronologici
    @saldo_inizio = @conto.saldo(al: Date.new(@anno) - 1)
    @saldo_fine = @conto.saldo(al: Date.new(@anno).end_of_year)

    respond_to do |format|
      format.html
      format.csv do
        send_data MovimentiCsv.new(@movimenti).to_csv,
                  filename: "movimenti-#{@conto.nome.parameterize}-#{@anno}.csv", type: "text/csv"
      end
    end
  end

  def new
    @conto = @beneficiario.conti.build(data_saldo_iniziale: Date.current)
  end

  def edit
  end

  def create
    @conto = @beneficiario.conti.build(conto_params)
    if @conto.save
      redirect_to [ @beneficiario, @conto ], notice: "Conto creato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @conto.update(conto_params)
      redirect_to [ @beneficiario, @conto ], notice: "Conto aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @conto.destroy
    redirect_to @beneficiario, notice: "Conto eliminato.", status: :see_other
  end

  private

  def set_beneficiario
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
  end

  def set_conto
    @conto = @beneficiario.conti.find(params[:id])
  end

  def conto_params
    params.require(:conto).permit(:nome, :tipo, :istituto, :iban, :saldo_iniziale, :data_saldo_iniziale, :attivo, :note)
  end
end
