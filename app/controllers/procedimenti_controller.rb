class ProcedimentiController < ApplicationController
  before_action :set_beneficiario
  before_action :set_procedimento, only: %i[show edit update destroy]

  def show
    @udienze = @procedimento.udienze.order(:data_udienza)
    @scadenze = @procedimento.scadenze.order(:data_scadenza)
    @rendiconti = @procedimento.rendiconti.order(anno: :desc)
    @attivita = @procedimento.attivita.order(data_attivita: :desc)
    @istanze = @procedimento.istanze.order(created_at: :desc)
    @documenti = @procedimento.documenti.with_attached_file.order(data_documento: :desc, created_at: :desc)
  end

  def new
    @procedimento = @beneficiario.procedimenti.build
  end

  def edit
  end

  def create
    @procedimento = @beneficiario.procedimenti.build(procedimento_params)
    if @procedimento.save
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Procedimento creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @procedimento.update(procedimento_params)
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Procedimento aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @procedimento.destroy
    redirect_to @beneficiario, notice: "Procedimento eliminato.", status: :see_other
  end

  private

  def set_beneficiario
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
  end

  def set_procedimento
    @procedimento = @beneficiario.procedimenti.find(params[:id])
  end

  def procedimento_params
    params.require(:procedimento).permit(:numero_rg, :tribunale, :giudice_tutelare, :data_apertura, :data_chiusura, :stato, :note)
  end
end
