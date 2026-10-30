# Cambio password dell'utente collegato.
class PasswordsController < ApplicationController
  def edit
  end

  def update
    user = Current.user
    unless user.authenticate(params[:password_attuale].to_s)
      return redirect_to edit_password_path, alert: "La password attuale non è corretta."
    end

    if user.update(params.permit(:password, :password_confirmation))
      user.sessions.where.not(id: Current.session.id).destroy_all
      redirect_to root_path, notice: "Password aggiornata."
    else
      flash.now[:alert] = user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
end
