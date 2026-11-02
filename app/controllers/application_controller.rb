class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_beneficiary

  private

  def current_beneficiary
    @current_beneficiary ||= current_user.beneficiaries.find(params[:beneficiary_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to beneficiaries_path, alert: t("errors.beneficiary_not_found")
  end

  def user_beneficiaries
    current_user.beneficiaries
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :tax_code, :address, :phone, :account_type
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :tax_code, :address, :phone, :account_type
    ])
  end
end
