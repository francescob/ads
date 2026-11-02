class DashboardController < ApplicationController
  def index
    @beneficiaries = current_user.beneficiaries.active
    @upcoming_deadlines = Deadline.joins(:beneficiary)
                                  .where(beneficiaries: { user_id: current_user.id })
                                  .open
                                  .where(due_date: ..30.days.from_now)
                                  .order(:due_date)
                                  .limit(10)
    @overdue_deadlines = Deadline.joins(:beneficiary)
                                 .where(beneficiaries: { user_id: current_user.id })
                                 .overdue
                                 .order(:due_date)
    @draft_reports = Report.joins(:beneficiary)
                           .where(beneficiaries: { user_id: current_user.id })
                           .drafts
                           .includes(:beneficiary)
    @active_count = current_user.beneficiaries.active.count
    @upcoming_7_count = Deadline.joins(:beneficiary)
                                .where(beneficiaries: { user_id: current_user.id })
                                .open
                                .where(due_date: Date.today..7.days.from_now)
                                .count
    @upcoming_30_count = Deadline.joins(:beneficiary)
                                 .where(beneficiaries: { user_id: current_user.id })
                                 .open
                                 .where(due_date: Date.today..30.days.from_now)
                                 .count
    @draft_reports_count = @draft_reports.count
  end
end