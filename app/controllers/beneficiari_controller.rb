class BeneficiariController < ApplicationController
  before_action :set_beneficiario, only: [:show, :edit, :update, :destroy]

  def index
    @beneficiari = Beneficiario.order(:cognome, :nome)
  end

  def show
    @procedimenti = @beneficiario.procedimenti.order(created_at: :desc)
  end

  def new
    @beneficiario = Beneficiario.new
  end

  def edit
  end

  def create
    @beneficiario = Beneficiario.new(beneficiario_params)
    if @beneficiario.save
      redirect_to @beneficiario, notice: "Beneficiario creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @beneficiario.update(beneficiario_params)
      redirect_to @beneficiario, notice: "Beneficiario aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @beneficiario.destroy
    redirect_to beneficiari_path, notice: "Beneficiario eliminato.", status: :see_other
  end

  private

  def set_beneficiario
    @beneficiario = Beneficiario.find(params[:id])
  end

  def beneficiario_params
    params.require(:beneficiario).permit(:nome, :cognome, :codice_fiscale, :data_nascita, :luogo_nascita, :indirizzo, :telefono, :email, :note)
  end
end
