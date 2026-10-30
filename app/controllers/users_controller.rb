class UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: %i[edit update]

  def index
    @users = User.order(:nome)
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "Utente creato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    attrs = user_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @user == Current.user && (attrs[:attivo] == "0" || attrs[:ruolo].to_s.then { |r| r.present? && r != "admin" })
      @user.errors.add(:base, "Non puoi disattivare o declassare te stesso.")
      return render :edit, status: :unprocessable_entity
    end

    if @user.update(attrs)
      @user.sessions.destroy_all unless @user.attivo?
      redirect_to users_path, notice: "Utente aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:nome, :email_address, :ruolo, :attivo, :password, :password_confirmation)
  end
end
