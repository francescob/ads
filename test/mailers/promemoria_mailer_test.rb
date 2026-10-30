require "test_helper"

class PromemoriaMailerTest < ActionMailer::TestCase
  test "il job invia il riepilogo agli utenti attivi che lo richiedono" do
    crea_utente(email: "a@example.com")
    crea_utente(email: "b@example.com").update!(riceve_promemoria: false)
    procedimento = crea_procedimento
    procedimento.scadenze.create!(titolo: "Deposito rendiconto", data_scadenza: 3.days.from_now.to_date)
    procedimento.scadenze.create!(titolo: "Arretrata", data_scadenza: 2.days.ago.to_date)

    assert_emails(1) { PromemoriaJob.perform_now }
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "a@example.com" ], mail.to
    assert_includes mail.text_part.body.to_s, "Deposito rendiconto"
    assert_includes mail.text_part.body.to_s, "SCADENZE SCADUTE"
  end

  test "nessuna email se non c'è nulla" do
    crea_utente
    assert_no_emails { PromemoriaJob.perform_now }
  end
end
