class DeadlinesController < ApplicationController
  before_action :set_beneficiary, only: [:new, :create]
  before_action :set_deadline, only: [:show, :edit, :update, :destroy]

  def index
    if params[:beneficiary_id]
      @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
      @deadlines = @beneficiary.deadlines.order(:due_date).page(params[:page])
    else
      @deadlines = Deadline.joins(:beneficiary)
                           .where(beneficiaries: { user_id: current_user.id })
                           .order(:due_date)
                           .includes(:beneficiary)
                           .page(params[:page])
    end
  end

  def calendar
    @month = params[:month] ? Date.parse(params[:month]) : Date.today
    @deadlines = Deadline.joins(:beneficiary)
                         .where(beneficiaries: { user_id: current_user.id })
                         .where(due_date: @month.beginning_of_month..@month.end_of_month)
                         .order(:due_date)
                         .includes(:beneficiary)
    @hearings = Hearing.joins(:beneficiary)
                       .where(beneficiaries: { user_id: current_user.id })
                       .where(hearing_date: @month.beginning_of_month..@month.end_of_month)
                       .order(:hearing_date)
                       .includes(:beneficiary)
  end

  def show; end

  def new
    @deadline = @beneficiary.deadlines.build
  end

  def create
    @deadline = @beneficiary.deadlines.build(deadline_params)
    if @deadline.save
      redirect_to @deadline, notice: t('deadlines.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @deadline.update(deadline_params)
      redirect_to @deadline, notice: t('deadlines.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @deadline.beneficiary
    @deadline.destroy
    redirect_to beneficiary_deadlines_path(beneficiary), notice: t('deadlines.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_deadline
    @deadline = Deadline.joins(:beneficiary)
                       .where(beneficiaries: { user_id: current_user.id })
                       .find(params[:id])
    @beneficiary = @deadline.beneficiary
  end

  def deadline_params
    params.require(:deadline).permit(
      :title, :description, :due_date, :reminder_date,
      :deadline_type, :status, :priority
    )
  end
end