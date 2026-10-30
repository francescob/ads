puts "Creazione dati di esempio..."

admin_password = ENV.fetch("ADMIN_PASSWORD", "cambiami-subito")
User.find_or_create_by!(email_address: ENV.fetch("ADMIN_EMAIL", "admin@example.com")) do |u|
  u.nome = "Amministratore"
  u.ruolo = "admin"
  u.password = admin_password
end

# Beneficiari
mario = Beneficiario.create!(
  nome: "Mario",
  cognome: "Rossi",
  codice_fiscale: "RSSMRA80A01H501Z",
  data_nascita: Date.new(1980, 1, 1),
  luogo_nascita: "Roma",
  indirizzo: "Via Roma 1, 00100 Roma",
  telefono: "06 12345678",
  email: "mario.rossi@example.com",
  note: "Beneficiario con limitata capacità di gestione finanziaria."
)

lucia = Beneficiario.create!(
  nome: "Lucia",
  cognome: "Bianchi",
  codice_fiscale: "BNCLCU75B41F205X",
  data_nascita: Date.new(1975, 2, 1),
  luogo_nascita: "Milano",
  indirizzo: "Via Milano 10, 20100 Milano",
  telefono: "02 98765432",
  email: "lucia.bianchi@example.com"
)

giuseppe = Beneficiario.create!(
  nome: "Giuseppe",
  cognome: "Verdi",
  data_nascita: Date.new(1945, 6, 15),
  luogo_nascita: "Napoli",
  indirizzo: "Via Napoli 5, 80100 Napoli"
)

# Procedimenti
proc1 = mario.procedimenti.create!(
  numero_rg: "1234/2023",
  tribunale: "Tribunale di Roma",
  giudice_tutelare: "Dott.ssa Giuditta Ferrara",
  data_apertura: Date.new(2023, 3, 15),
  stato: "attivo",
  note: "Procedimento aperto per difficoltà nella gestione del patrimonio."
)

proc2 = lucia.procedimenti.create!(
  numero_rg: "567/2022",
  tribunale: "Tribunale di Milano",
  giudice_tutelare: "Dott. Alberto Conti",
  data_apertura: Date.new(2022, 6, 1),
  stato: "attivo"
)

proc3 = giuseppe.procedimenti.create!(
  numero_rg: "89/2021",
  tribunale: "Tribunale di Napoli",
  giudice_tutelare: "Dott.ssa Maria Esposito",
  data_apertura: Date.new(2021, 9, 10),
  stato: "attivo"
)

# Udienze
proc1.udienze.create!(
  data_udienza: 30.days.from_now,
  tipo: "verifica",
  luogo: "Tribunale di Roma, Aula 3",
  note: "Verifica annuale delle condizioni."
)

proc1.udienze.create!(
  data_udienza: 2.days.from_now,
  tipo: "rendiconto",
  luogo: "Tribunale di Roma",
  esito: nil
)

proc2.udienze.create!(
  data_udienza: 15.days.from_now,
  tipo: "prima udienza",
  luogo: "Tribunale di Milano, Sala A"
)

# Scadenze
proc1.scadenze.create!(
  titolo: "Presentazione Rendiconto Annuale 2024",
  descrizione: "Rendiconto annuale delle spese e entrate del beneficiario.",
  data_scadenza: 10.days.from_now,
  completata: false,
  tipo: "rendiconto"
)

proc1.scadenze.create!(
  titolo: "Rinnovo patrocinio legale",
  descrizione: "Rinnovo dell'incarico al legale di fiducia.",
  data_scadenza: 5.days.ago,
  completata: false,
  tipo: "adempimento"
)

proc2.scadenze.create!(
  titolo: "Udienza di verifica",
  descrizione: "Prima udienza di verifica dello stato del beneficiario.",
  data_scadenza: 20.days.from_now,
  completata: false,
  tipo: "udienza"
)

proc3.scadenze.create!(
  titolo: "Rendiconto 2023",
  descrizione: "Rendiconto finanziario anno 2023.",
  data_scadenza: 7.days.from_now,
  completata: false,
  tipo: "rendiconto"
)

# Rendiconti
proc1.rendiconti.create!(
  anno: 2023,
  data_presentazione: Date.new(2024, 1, 15),
  data_approvazione: Date.new(2024, 2, 20),
  stato: "approvato",
  importo_entrate: 25000.00,
  importo_uscite: 18500.00,
  note: "Rendiconto 2023 approvato senza rilievi."
)

proc1.rendiconti.create!(
  anno: 2024,
  stato: "bozza",
  importo_entrate: 8000.00,
  importo_uscite: 4200.00
)

proc2.rendiconti.create!(
  anno: 2023,
  data_presentazione: Date.new(2024, 3, 1),
  stato: "presentato",
  importo_entrate: 15000.00,
  importo_uscite: 12000.00
)

# Attività
proc1.attivita.create!(
  titolo: "Apertura conto corrente dedicato",
  descrizione: "Apertura conto corrente intestato al beneficiario presso Banca X.",
  data_attivita: 3.months.ago,
  tipo: "finanziaria",
  completata: true
)

proc1.attivita.create!(
  titolo: "Visita medica di controllo",
  descrizione: "Visita neurologica di controllo presso ASL Roma 1.",
  data_attivita: 1.month.from_now,
  tipo: "sanitaria",
  completata: false
)

proc2.attivita.create!(
  titolo: "Consulenza legale",
  descrizione: "Consulenza con avvocato per pratiche immobiliari.",
  data_attivita: 1.week.ago,
  tipo: "legale",
  completata: true
)

puts "Dati di esempio creati con successo!"
puts "  - #{Beneficiario.count} beneficiari"
puts "  - #{Procedimento.count} procedimenti"
puts "  - #{Udienza.count} udienze"
puts "  - #{Scadenza.count} scadenze"
puts "  - #{Rendiconto.count} rendiconti"
puts "  - #{Attivita.count} attività"
