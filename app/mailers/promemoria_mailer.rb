class PromemoriaMailer < ApplicationMailer
  def riepilogo(user, agenda)
    @user = user
    @agenda = agenda
    mail to: user.email_address, subject: "ADS — scadenze e udienze dei prossimi #{agenda.giorni} giorni"
  end
end
