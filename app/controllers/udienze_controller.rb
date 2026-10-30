class UdienzeController < ApplicationController
  include ProcedimentoScoped

  before_action :set_procedimento, except: :index
  before_action :set_udienza, only: %i[edit update destroy]

  def index
    @udienze = Udienza.future.includes(procedimento: :beneficiario)
  end

  def new
    @udienza = @procedimento.udienze.build
  end

  def edit
  end

  def create
    @udienza = @procedimento.udienze.build(udienza_params)
    if @udienza.save
      redirect_to_procedimento "Udienza creata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @udienza.update(udienza_params)
      redirect_to_procedimento "Udienza aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @udienza.destroy
    redirect_to_procedimento "Udienza eliminata.", status: :see_other
  end

  private

  def set_udienza
    @udienza = @procedimento.udienze.find(params[:id])
  end

  def udienza_params
    params.require(:udienza).permit(:data_udienza, :tipo, :luogo, :note, :esito)
  end
end
