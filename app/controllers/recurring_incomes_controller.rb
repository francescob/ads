class RecurringIncomesController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_recurring_income, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @recurring_incomes = @beneficiary.recurring_incomes.order(active: :desc, start_date: :desc)
  end

  def show; end

  def new
    @recurring_income = @beneficiary.recurring_incomes.build(active: true)
  end

  def create
    @recurring_income = @beneficiary.recurring_incomes.build(recurring_income_params)
    if @recurring_income.save
      redirect_to @recurring_income, notice: t('recurring_incomes.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @recurring_income.update(recurring_income_params)
      redirect_to @recurring_income, notice: t('recurring_incomes.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @recurring_income.beneficiary
    @recurring_income.destroy
    redirect_to beneficiary_recurring_incomes_path(beneficiary), notice: t('recurring_incomes.deleted')
  end

  def toggle_active
    @recurring_income.update(active: !@recurring_income.active)
    redirect_to @recurring_income, notice: t('recurring_incomes.status_updated')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_recurring_income
    @recurring_income = RecurringIncome.joins(:beneficiary)
                                       .where(beneficiaries: { user_id: current_user.id })
                                       .find(params[:id])
    @beneficiary = @recurring_income.beneficiary
  end

  def recurring_income_params
    params.require(:recurring_income).permit(
      :income_type, :description, :amount, :frequency,
      :start_date, :end_date, :notes, :active
    )
  end
end