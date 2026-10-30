module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session.present?
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    return unless (id = cookies.signed[:session_id])

    Session.joins(:user).merge(User.attivi).find_by(id: id)
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url if request.request_method.in?(%w[GET HEAD])
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    reset_session
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |s|
      Current.session = s
      cookies.signed.permanent[:session_id] = { value: s.id, httponly: true, same_site: :lax, secure: Rails.env.production? }
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
    reset_session
  end

  def require_admin
    redirect_to root_path, alert: "Operazione riservata agli amministratori." unless Current.user&.admin?
  end
end
