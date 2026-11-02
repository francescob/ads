class DashboardController < ApplicationController
  def index
    deadlines = Deadline.owned_by(current_user).includes(:beneficiary)

    @beneficiaries = current_user.beneficiaries.active
    @upcoming_deadlines = deadlines.upcoming(30).order(:due_date).limit(10)
    @overdue_deadlines = deadlines.past_due.order(:due_date)
    @draft_reports = Report.owned_by(current_user).drafts.includes(:beneficiary)
    @active_count = @beneficiaries.count
    @upcoming_7_count = deadlines.upcoming(7).count
    @upcoming_30_count = deadlines.upcoming(30).count
    @draft_reports_count = @draft_reports.count
  end
end
