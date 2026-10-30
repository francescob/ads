namespace :ads do
  desc "Invia via email il riepilogo di scadenze e udienze (GIORNI=7)"
  task promemoria: :environment do
    PromemoriaJob.perform_now(giorni: ENV.fetch("GIORNI", 7).to_i)
  end
end
