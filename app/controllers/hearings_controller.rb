class HearingsController < ApplicationController
  before_action :set_beneficiary, only: [ :index, :new, :create ]
  before_action :set_hearing, only: [ :show, :edit, :update, :destroy ]

  # The list lives in the beneficiary page, in the "hearings" tab.
  def index
    redirect_to beneficiary_path(@beneficiary, tab: "hearings")
  end

  def show; end

  def new
    @hearing = @beneficiary.hearings.build
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
  end

  def create
    @hearing = @beneficiary.hearings.build(hearing_params)
    if @hearing.save
      redirect_to @hearing, notice: t("hearings.created")
    else
      @appointments = @beneficiary.appointments.order(appointment_date: :desc)
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
  end

  def update
    if @hearing.update(hearing_params)
      redirect_to @hearing, notice: t("hearings.updated")
    else
      @appointments = @beneficiary.appointments.order(appointment_date: :desc)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @hearing.beneficiary
    @hearing.destroy
    redirect_to beneficiary_path(beneficiary, tab: "hearings"), status: :see_other, notice: t("hearings.deleted")
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_hearing
    @hearing = Hearing.owned_by(current_user)
                      .find(params[:id])
    @beneficiary = @hearing.beneficiary
  end

  def hearing_params
    params.require(:hearing).permit(
      :appointment_id, :hearing_date, :court, :courtroom,
      :subject, :outcome, :next_hearing_date, :notes
    )
  end
end
