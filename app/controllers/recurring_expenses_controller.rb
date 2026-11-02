class RecurringExpensesController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_recurring_expense, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @recurring_expenses = @beneficiary.recurring_expenses.order(active: :desc, start_date: :desc)
  end

  def show; end

  def new
    @recurring_expense = @beneficiary.recurring_expenses.build(active: true)
  end

  def create
    @recurring_expense = @beneficiary.recurring_expenses.build(recurring_expense_params)
    if @recurring_expense.save
      redirect_to @recurring_expense, notice: t('recurring_expenses.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @recurring_expense.update(recurring_expense_params)
      redirect_to @recurring_expense, notice: t('recurring_expenses.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @recurring_expense.beneficiary
    @recurring_expense.destroy
    redirect_to beneficiary_recurring_expenses_path(beneficiary), notice: t('recurring_expenses.deleted')
  end

  def toggle_active
    @recurring_expense.update(active: !@recurring_expense.active)
    redirect_to @recurring_expense, notice: t('recurring_expenses.status_updated')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_recurring_expense
    @recurring_expense = RecurringExpense.joins(:beneficiary)
                                         .where(beneficiaries: { user_id: current_user.id })
                                         .find(params[:id])
    @beneficiary = @recurring_expense.beneficiary
  end

  def recurring_expense_params
    params.require(:recurring_expense).permit(
      :expense_type, :description, :amount, :frequency,
      :start_date, :end_date, :notes, :active
    )
  end
end