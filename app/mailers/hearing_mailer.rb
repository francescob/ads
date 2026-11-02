class HearingMailer < ApplicationMailer
  def reminder(hearing)
    @hearing = hearing
    @beneficiary = hearing.beneficiary
    @user = @beneficiary.user

    mail(
      to: @user.email,
      subject: "Promemoria udienza: #{hearing.subject || 'Udienza'} - #{hearing.hearing_date.strftime('%d/%m/%Y')}"
    )
  end
end
