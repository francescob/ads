class ReportsController < ApplicationController
  before_action :set_beneficiary, only: [ :index, :new, :create ]
  before_action :set_report, only: [ :show, :edit, :update, :destroy, :generate_pdf, :update_status ]

  def index
    @reports = @beneficiary.reports.order(reference_year: :desc).page(params[:page])
  end

  def show
    @income_entries = @report.income_entries.order(:entry_date)
    @expense_entries = @report.expense_entries.order(:entry_date)
    @income_entry = @report.income_entries.build
    @expense_entry = @report.expense_entries.build
  end

  def new
    @report = @beneficiary.reports.build
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
  end

  def create
    @report = @beneficiary.reports.build(report_params)
    if @report.save
      redirect_to @report, notice: t("reports.created")
    else
      @appointments = @beneficiary.appointments.order(appointment_date: :desc)
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
  end

  def update
    if @report.update(report_params)
      redirect_to @report, notice: t("reports.updated")
    else
      @appointments = @beneficiary.appointments.order(appointment_date: :desc)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @report.beneficiary
    @report.destroy
    redirect_to beneficiary_reports_path(beneficiary), notice: t("reports.deleted")
  end

  def generate_pdf
    GenerateReportPdfJob.perform_later(@report.id, current_user.id)
    redirect_to @report, notice: t("reports.pdf_generating")
  end

  def update_status
    if @report.update(status: params[:status].to_s)
      redirect_to @report, notice: t("reports.status_updated")
    else
      redirect_to @report, alert: [ t("reports.status_update_failed"), @report.errors.full_messages.to_sentence ].join(" ")
    end
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_report
    @report = Report.owned_by(current_user)
                    .find(params[:id])
    @beneficiary = @report.beneficiary
  end

  def report_params
    params.require(:report).permit(
      :appointment_id, :reference_year, :period_from, :period_to,
      :filing_date, :court_notes
    )
  end
end
