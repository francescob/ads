class AttivitaController < ApplicationController
  include ProcedimentoScoped

  before_action :set_procedimento
  before_action :set_attivita, only: %i[edit update destroy]

  def new
    @attivita = @procedimento.attivita.build
  end

  def edit
  end

  def create
    @attivita = @procedimento.attivita.build(attivita_params)
    if @attivita.save
      redirect_to_procedimento "Attività creata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @attivita.update(attivita_params)
      redirect_to_procedimento "Attività aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @attivita.destroy
    redirect_to_procedimento "Attività eliminata.", status: :see_other
  end

  private

  def set_attivita
    @attivita = @procedimento.attivita.find(params[:id])
  end

  def attivita_params
    params.expect(attivita: [ :titolo, :descrizione, :data_attivita, :tipo, :completata, :note ])
  end
end
