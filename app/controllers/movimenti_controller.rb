class MovimentiController < ApplicationController
  before_action :set_conto
  before_action :set_movimento, only: %i[edit update destroy]

  def new
    @movimento = @conto.movimenti.build(data: Date.current, verso: params[:verso].presence_in(Movimento::VERSI) || "uscita")
  end

  def edit
  end

  def create
    @movimento = @conto.movimenti.build(movimento_params)
    if @movimento.save
      redirect_to_conto "Movimento registrato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @movimento.update(movimento_params)
      redirect_to_conto "Movimento aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @movimento.destroy
    redirect_to_conto "Movimento eliminato.", status: :see_other
  end

  private

  def set_conto
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
    @conto = @beneficiario.conti.find(params[:conto_id])
  end

  def set_movimento
    @movimento = @conto.movimenti.find(params[:id])
  end

  def redirect_to_conto(notice, **options)
    redirect_to beneficiario_conto_path(@beneficiario, @conto, anno: @movimento.data&.year), notice: notice, **options
  end

  def movimento_params
    params.expect(movimento: [ :data, :descrizione, :verso, :importo, :categoria, :note ])
  end
end
