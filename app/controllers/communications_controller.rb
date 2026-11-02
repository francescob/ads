class CommunicationsController < ApplicationController
  before_action :set_beneficiary, only: [ :index, :new, :create ]
  before_action :set_communication, only: [ :show, :edit, :update, :destroy ]

  # The list lives in the beneficiary page, in the "communications" tab.
  def index
    redirect_to beneficiary_path(@beneficiary, tab: "communications")
  end

  def show; end

  def new
    @communication = @beneficiary.communications.build
  end

  def create
    @communication = @beneficiary.communications.build(communication_params)
    if @communication.save
      redirect_to @communication, notice: t("communications.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @communication.update(communication_params)
      redirect_to @communication, notice: t("communications.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @communication.beneficiary
    @communication.destroy
    redirect_to beneficiary_path(beneficiary, tab: "communications"), status: :see_other, notice: t("communications.deleted")
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_communication
    @communication = Communication.owned_by(current_user)
                                  .find(params[:id])
    @beneficiary = @communication.beneficiary
  end

  def communication_params
    params.require(:communication).permit(
      :subject, :body, :counterpart, :channel, :sent_at, :status, :attachment
    )
  end
end
