class LiabilitiesController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_liability, only: [:show, :edit, :update, :destroy]

  # The list lives in the beneficiary page, in the "liabilities" tab.
  def index
    redirect_to beneficiary_path(@beneficiary, tab: "liabilities")
  end

  def show; end

  def new
    @liability = @beneficiary.liabilities.build
  end

  def create
    @liability = @beneficiary.liabilities.build(liability_params)
    if @liability.save
      redirect_to @liability, notice: t('liabilities.created')
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @liability.update(liability_params)
      redirect_to @liability, notice: t('liabilities.updated')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @liability.beneficiary
    @liability.destroy
    redirect_to beneficiary_path(beneficiary, tab: "liabilities"), status: :see_other, notice: t('liabilities.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_liability
    @liability = Liability.owned_by(current_user)
                          .find(params[:id])
    @beneficiary = @liability.beneficiary
  end

  def liability_params
    params.require(:liability).permit(
      :liability_type, :description, :creditor,
      :initial_amount, :remaining_balance, :interest_rate, :monthly_payment,
      :start_date, :end_date, :notes
    )
  end
end