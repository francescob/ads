# Carica beneficiario e procedimento per le risorse annidate sotto
# /beneficiari/:beneficiario_id/procedimenti/:procedimento_id/...
module ProcedimentoScoped
  extend ActiveSupport::Concern

  private

  def set_procedimento
    @beneficiario = Beneficiario.find(params[:beneficiario_id])
    @procedimento = @beneficiario.procedimenti.find(params[:procedimento_id])
  end

  def redirect_to_procedimento(notice, **options)
    redirect_to beneficiario_procedimento_path(@beneficiario, @procedimento), notice: notice, **options
  end
end
