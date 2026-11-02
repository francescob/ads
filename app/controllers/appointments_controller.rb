class AppointmentsController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]

  def index
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
  end

  def show; end

  def new
    @appointment = @beneficiary.appointments.build
  end

  def create
    @appointment = @beneficiary.appointments.build(appointment_params)
    if @appointment.save
      redirect_to @appointment, notice: t('appointments.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @appointment.update(appointment_params)
      redirect_to @appointment, notice: t('appointments.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @appointment.beneficiary
    @appointment.destroy
    redirect_to beneficiary_appointments_path(beneficiary), notice: t('appointments.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_appointment
    @appointment = Appointment.joins(:beneficiary)
                              .where(beneficiaries: { user_id: current_user.id })
                              .find(params[:id])
    @beneficiary = @appointment.beneficiary
  end

  def appointment_params
    params.require(:appointment).permit(
      :decree_number, :decree_date, :court, :court_section, :judge,
      :appointment_date, :mandate_expiry_date, :appointment_type,
      :financial_powers, :personal_powers,
      :ordinary_expense_limit, :extraordinary_expense_limit,
      :notes, :document
    )
  end
end