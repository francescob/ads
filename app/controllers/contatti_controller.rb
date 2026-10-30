class ContattiController < ApplicationController
  before_action :set_beneficiario
  before_action :set_contatto, only: %i[edit update destroy]

  def new
    @contatto = @beneficiario.contatti.build
  end

  def edit
  end

  def create
    @contatto = @beneficiario.contatti.build(contatto_params)
    if @contatto.save
      redirect_to @beneficiario, notice: "Contatto aggiunto."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contatto.update(contatto_params)
      redirect_to @beneficiario, notice: "Contatto aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contatto.destroy
    redirect_to @beneficiario, notice: "Contatto eliminato.", status: :see_other
  end

  private

  def set_beneficiario
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
  end

  def set_contatto
    @contatto = @beneficiario.contatti.find(params[:id])
  end

  def contatto_params
    params.expect(contatto: [ :nome, :tipo, :ruolo, :telefono, :email, :indirizzo, :note ])
  end
end
