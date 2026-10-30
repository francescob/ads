# Feed .ics autenticato da token personale: i client calendario non fanno login.
class CalendariController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    user = User.attivi.find_by(calendar_token: params[:token].to_s)
    return head :not_found unless user

    send_data CalendarioIcs.new(host: request.host).to_ics, type: "text/calendar; charset=utf-8", disposition: :inline
  end

  def rigenera
    Current.user.regenerate_calendar_token
    redirect_to edit_password_path, notice: "Nuovo link calendario generato: il precedente non funziona più."
  end
end
