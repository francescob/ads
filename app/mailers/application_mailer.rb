class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "ADS <noreply@example.com>")
  layout "mailer"
end
