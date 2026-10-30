class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Troppi tentativi. Riprova tra qualche minuto." }

  layout "auth"

  def new
  end

  def create
    user = User.attivi.authenticate_by(params.permit(:email_address, :password))
    if user
      return_to = after_authentication_url
      start_new_session_for user
      redirect_to return_to
    else
      redirect_to new_session_path, alert: "Email o password non corretti."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Disconnesso.", status: :see_other
  end
end
