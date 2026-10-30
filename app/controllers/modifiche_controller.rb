class ModificheController < ApplicationController
  include Paginazione

  before_action :require_admin

  def index
    scope = Modifica.recenti.includes(:user)
    scope = scope.where(beneficiario_id: params[:beneficiario_id]) if params[:beneficiario_id].present?
    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
    scope = scope.where(record_type: params[:tipo]) if params[:tipo].present?
    @beneficiario = Beneficiario.find_by(id: params[:beneficiario_id])
    @modifiche = pagina(scope)
  end
end
