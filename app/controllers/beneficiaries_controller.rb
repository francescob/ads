class BeneficiariesController < ApplicationController
  before_action :set_beneficiary, only: [ :show, :edit, :update, :destroy, :generate_asset_inventory, :download_asset_inventory ]

  def index
    @q = user_beneficiaries.ransack(params[:q])
    @beneficiaries = @q.result(distinct: true).order(:last_name, :first_name).page(params[:page])
  end

  def show
    @appointments = @beneficiary.appointments.order(appointment_date: :desc)
    @reports = @beneficiary.reports.order(reference_year: :desc)
    @assets = @beneficiary.assets.order(:asset_type)
    @properties = @beneficiary.properties.ordered
    @liabilities = @beneficiary.liabilities.order(:liability_type, :creditor)
    @recurring_incomes = @beneficiary.recurring_incomes.order(active: :desc, start_date: :desc)
    @recurring_expenses = @beneficiary.recurring_expenses.order(active: :desc, start_date: :desc)
    @deadlines = @beneficiary.deadlines.order(:due_date)
    @hearings = @beneficiary.hearings.order(hearing_date: :desc)
    @documents = @beneficiary.documents.order(created_at: :desc)
    @communications = @beneficiary.communications.order(created_at: :desc)
    @contacts = @beneficiary.contacts.order(:last_name)
  end

  def new
    @beneficiary = user_beneficiaries.build
  end

  def create
    @beneficiary = user_beneficiaries.build(beneficiary_params)
    if @beneficiary.save
      redirect_to @beneficiary, notice: t("beneficiaries.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @beneficiary.update(beneficiary_params)
      redirect_to @beneficiary, notice: t("beneficiaries.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @beneficiary.destroy
    redirect_to beneficiaries_path, notice: t("beneficiaries.deleted")
  end

  def generate_asset_inventory
    GenerateAssetPdfJob.perform_later(@beneficiary.id, current_user.id)
    redirect_to @beneficiary, notice: t("assets.pdf_generation_started")
  end

  def download_asset_inventory
    if @beneficiary.asset_inventory_pdf.attached?
      pdf = @beneficiary.asset_inventory_pdf
      send_data pdf.download, filename: pdf.filename.to_s, type: pdf.content_type, disposition: :attachment
    else
      redirect_to @beneficiary, alert: t("assets.pdf_not_found")
    end
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:id])
  end

  def beneficiary_params
    params.require(:beneficiary).permit(
      :first_name, :last_name, :tax_code, :date_of_birth, :place_of_birth,
      :gender, :street_address, :city, :province, :zip_code,
      :health_condition, :diagnosis, :referring_doctor, :doctor_contact,
      :notes, :status
    )
  end
end
