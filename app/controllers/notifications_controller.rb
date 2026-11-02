class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [ :mark_as_read ]

  def index
    @notifications = current_user.notifications
                                 .includes(:event)
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(20)

    @unread_count = current_user.notifications.unread.count
  end

  def mark_as_read
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back fallback_location: notifications_path, notice: "Notifica contrassegnata come letta." }
      format.turbo_stream
      format.json { head :ok }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.mark_as_read!

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Tutte le notifiche sono state contrassegnate come lette." }
      format.turbo_stream
      format.json { head :ok }
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Notifica eliminata." }
      format.turbo_stream
      format.json { head :ok }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
