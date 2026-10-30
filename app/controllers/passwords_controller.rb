# Profilo dell'utente collegato: password e preferenze.
class PasswordsController < ApplicationController
  def edit
  end

  def update
    user = Current.user
    if params[:solo_preferenze]
      user.update!(riceve_promemoria: params[:riceve_promemoria] == "1")
      return redirect_to edit_password_path, notice: "Preferenze salvate."
    end

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
