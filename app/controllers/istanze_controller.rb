class IstanzeController < ApplicationController
  include ProcedimentoScoped

  before_action :set_procedimento
  before_action :set_istanza, only: %i[edit update destroy]

  def new
    @istanza = @procedimento.istanze.build
  end

  def edit
  end

  def create
    @istanza = @procedimento.istanze.build(istanza_params)
    if @istanza.save
      redirect_to_procedimento "Istanza creata con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @istanza.update(istanza_params)
      redirect_to_procedimento "Istanza aggiornata con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @istanza.destroy
    redirect_to_procedimento "Istanza eliminata.", status: :see_other
  end

  private

  def set_istanza
    @istanza = @procedimento.istanze.find(params[:id])
  end

  def istanza_params
    params.expect(istanza: [ :oggetto, :tipo, :stato, :data_deposito, :data_decisione, :importo, :esito, :note ])
  end
end
