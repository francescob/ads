class CommunicationsController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_communication, only: [:show, :edit, :update, :destroy]

  def index
    @communications = @beneficiary.communications.order(created_at: :desc)
  end

  def show; end

  def new
    @communication = @beneficiary.communications.build
  end

  def create
    @communication = @beneficiary.communications.build(communication_params)
    if @communication.save
      redirect_to @communication, notice: t('communications.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @communication.update(communication_params)
      redirect_to @communication, notice: t('communications.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @communication.beneficiary
    @communication.destroy
    redirect_to beneficiary_communications_path(beneficiary), notice: t('communications.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_communication
    @communication = Communication.joins(:beneficiary)
                                  .where(beneficiaries: { user_id: current_user.id })
                                  .find(params[:id])
    @beneficiary = @communication.beneficiary
  end

  def communication_params
    params.require(:communication).permit(
      :subject, :body, :counterpart, :channel, :sent_at, :status, :attachment
    )
  end
end