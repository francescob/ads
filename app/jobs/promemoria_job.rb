# Da eseguire una volta al giorno (cron: `bin/rails ads:promemoria`).
class PromemoriaJob < ApplicationJob
  queue_as :default

  def perform(giorni: 7)
    agenda = Agenda.new(giorni: giorni)
    return if agenda.vuota?

    User.destinatari_promemoria.find_each do |user|
      PromemoriaMailer.riepilogo(user, agenda).deliver_now
    end
  end
end
