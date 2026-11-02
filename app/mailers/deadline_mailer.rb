class DeadlineMailer < ApplicationMailer
  def reminder(deadline)
    @deadline = deadline
    @beneficiary = deadline.beneficiary
    @user = @beneficiary.user

    mail(
      to: @user.email,
      subject: "Promemoria scadenza: #{deadline.title}"
    )
  end
end
