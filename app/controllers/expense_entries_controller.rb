class ExpenseEntriesController < ApplicationController
  before_action :set_report, only: [:new, :create]
  before_action :set_expense_entry, only: [:edit, :update, :destroy]

  def new
    @expense_entry = @report.expense_entries.build
  end

  def create
    @expense_entry = @report.expense_entries.build(expense_entry_params)
    if @expense_entry.save
      respond_to do |format|
        format.turbo_stream { @report = @expense_entry.report }
        format.html { redirect_to @report, notice: t('expense_entries.created') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @expense_entry.update(expense_entry_params)
      respond_to do |format|
        format.turbo_stream { @report = @expense_entry.report }
        format.html { redirect_to @expense_entry.report, notice: t('expense_entries.updated') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report = @expense_entry.report
    @expense_entry.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @report, notice: t('expense_entries.deleted') }
    end
  end

  private

  def set_report
    @report = Report.joins(:beneficiary)
                    .where(beneficiaries: { user_id: current_user.id })
                    .find(params[:report_id])
  end

  def set_expense_entry
    @expense_entry = ExpenseEntry.joins(report: :beneficiary)
                                 .where(beneficiaries: { user_id: current_user.id })
                                 .find(params[:id])
  end

  def expense_entry_params
    params.require(:expense_entry).permit(
      :entry_date, :description, :amount, :category,
      :supplier, :receipt_number, :receipt_file
    )
  end
end