class AppointmentsController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]

  # The list lives in the beneficiary page, in the "appointments" tab.
  def index
    redirect_to beneficiary_path(@beneficiary, tab: "appointments")
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
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @appointment.update(appointment_params)
      redirect_to @appointment, notice: t('appointments.updated')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @appointment.beneficiary
    unless @appointment.destroy
      return redirect_to @appointment, alert: t('appointments.has_reports')
    end

    redirect_to beneficiary_path(beneficiary, tab: "appointments"), status: :see_other, notice: t('appointments.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_appointment
    @appointment = Appointment.owned_by(current_user)
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