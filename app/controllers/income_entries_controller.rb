class IncomeEntriesController < ApplicationController
  before_action :set_report, only: [ :new, :create ]
  before_action :set_income_entry, only: [ :edit, :update, :destroy ]

  def new
    @income_entry = @report.income_entries.build
  end

  def create
    @income_entry = @report.income_entries.build(income_entry_params)
    if @income_entry.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @report, notice: t("income_entries.created") }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @income_entry.update(income_entry_params)
      respond_to do |format|
        format.turbo_stream { @report = @income_entry.report }
        format.html { redirect_to @income_entry.report, notice: t("income_entries.updated") }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @report = @income_entry.report
    @income_entry.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @report, notice: t("income_entries.deleted") }
    end
  end

  private

  def set_report
    @report = Report.owned_by(current_user)
                    .find(params[:report_id])
  end

  def set_income_entry
    @income_entry = IncomeEntry.owned_by(current_user)
                               .find(params[:id])
  end

  def income_entry_params
    params.require(:income_entry).permit(:entry_date, :description, :amount, :category, :source)
  end
end
