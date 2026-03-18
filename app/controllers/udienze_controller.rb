class UdienzeController < ApplicationController
  before_action :set_context, except: [:index]
  before_action :set_udienza, only: [:show, :edit, :update, :destroy]

  def index
    @udienze = Udienza.where("data_udienza >= ?", Time.now).order(:data_udienza).includes(procedimento: :beneficiario)
  end

  def show
  end

  def new
    @udienza = @procedimento.udienze.build
  end

  def edit
  end

  def create
    @udienza = @procedimento.udienze.build(udienza_params)
    if @udienza.save
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Udienza creata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @udienza.update(udienza_params)
      redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Udienza aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @udienza.destroy
    redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: "Udienza eliminata.", status: :see_other
  end

  private

  def set_context
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
    @procedimento = @beneficiario.procedimenti.find(params[:procedimento_id])
  end

  def set_udienza
    @udienza = @procedimento.udienze.find(params[:id])
  end

  def udienza_params
    params.require(:udienza).permit(:data_udienza, :tipo, :luogo, :note, :esito)
  end
end
