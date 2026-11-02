class HearingsController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_hearing, only: [:show, :edit, :update, :destroy]

  def index
    @hearings = @beneficiary.hearings.order(hearing_date: :desc)
  end

  def show; end

  def new
    @hearing = @beneficiary.hearings.build
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
  end

  def create
    @hearing = @beneficiary.hearings.build(hearing_params)
    if @hearing.save
      redirect_to @hearing, notice: t('hearings.created')
    else
      @appointments = @beneficiary.appointments.order(appointment_date: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
  end

  def update
    if @hearing.update(hearing_params)
      redirect_to @hearing, notice: t('hearings.updated')
    else
      @appointments = @beneficiary.appointments.order(appointment_date: :desc)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @hearing.beneficiary
    @hearing.destroy
    redirect_to beneficiary_hearings_path(beneficiary), notice: t('hearings.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_hearing
    @hearing = Hearing.joins(:beneficiary)
                      .where(beneficiaries: { user_id: current_user.id })
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