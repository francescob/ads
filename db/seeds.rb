# Seed file per GuardianshipApp - Dati Reali Giovanni Brunetti
# Basato su inventario patrimoniale del 07/04/2026

# Amministratore di Sostegno
user = User.create!(
  email:        'francesco.brunetti@example.com',
  password:     'password123',
  first_name:   'Francesco',
  last_name:    'Brunetti',
  tax_code:     'BRNFNC70A01L781K',
  address:      'Via Roma 1, Verona',
  phone:        '0458901234',
  account_type: :professional,
  role:         :user
)

# Beneficiario: Giovanni Brunetti
beneficiary = user.beneficiaries.create!(
  first_name:       'Giovanni',
  last_name:        'Brunetti',
  tax_code:         'BRNGNN40A01L781M',
  date_of_birth:    Date.new(1940, 1, 1),
  place_of_birth:   'Verona',
  gender:           :male,
  street_address:   'Caprino Veronese',
  city:             'Caprino Veronese',
  province:         'VR',
  zip_code:         '37013',
  health_condition: 'Ospite presso RSA Villa Spada',
  status:           :active
)

# Nomina/Decreto
appointment = beneficiary.appointments.create!(
  decree_number:                '001/2025',
  decree_date:                  Date.new(2025, 1, 15),
  court:                        'Tribunale di Verona',
  court_section:                'Sezione Civile',
  judge:                        'Dott. Mario Rossi',
  appointment_date:             Date.new(2025, 2, 1),
  mandate_expiry_date:          Date.new(2028, 2, 1),
  appointment_type:             :definitive,
  financial_powers:             'Gestione ordinaria e straordinaria del patrimonio',
  personal_powers:              'Rappresentanza sanitaria e assistenziale',
  ordinary_expense_limit:       3_000.00,
  extraordinary_expense_limit:  10_000.00
)

# Report annuale 2026
report = beneficiary.reports.create!(
  appointment:    appointment,
  reference_year: 2026,
  period_from:    Date.new(2026, 1, 1),
  period_to:      Date.new(2026, 12, 31),
  status:         :draft
)

# ATTIVITÀ (Assets - Conti Correnti)
beneficiary.assets.create!([
  {
    asset_type: :bank_account,
    description: 'Conto Corrente Unicredit',
    institution_or_location: 'Unicredit - Verona',
    initial_value: 111.63,
    current_value: 111.63,
    valuation_date: Date.new(2026, 4, 7),
    notes: 'Fido disponibile: 3.000,00 €'
  },
  {
    asset_type: :bank_account,
    description: 'Conto Corrente Cointestato',
    institution_or_location: 'Banca (cointestato)',
    initial_value: 766.78,
    current_value: 766.78,
    valuation_date: Date.new(2026, 4, 7),
    notes: 'Saldo contabile 6.437,74 € comprensivo di importo bloccato per decesso della cointestataria. Disponibile: 766,78 €'
  }
])

# IMMOBILI (Properties)
beneficiary.properties.create!([
  {
    property_type: :residential,
    description: 'Abitazione principale - Caprino Veronese',
    address: 'Indirizzo non specificato',
    city: 'Caprino Veronese',
    province: 'VR',
    zip_code: '37013',
    cadastral_sheet: '41',
    cadastral_particle: '1048',
    cadastral_sub: '4',
    cadastral_category: 'A/2',
    cadastral_class: nil,
    cadastral_consistency: nil,
    cadastral_income: nil,
    ownership_numerator: 3,
    ownership_denominator: 4,
    initial_value: nil,
    current_value: nil,
    valuation_date: Date.new(2026, 4, 7),
    notes: 'Possesso di 3/4 dell\'immobile'
  },
  {
    property_type: :residential,
    description: 'Immobile via 28 Gennaio 37 - Verona',
    address: 'Via 28 Gennaio 37',
    city: 'Verona',
    province: 'VR',
    zip_code: '37100',
    cadastral_sheet: nil,
    cadastral_particle: nil,
    cadastral_sub: nil,
    cadastral_category: nil,
    cadastral_class: nil,
    cadastral_consistency: nil,
    cadastral_income: nil,
    ownership_numerator: 1,
    ownership_denominator: 16,
    initial_value: nil,
    current_value: nil,
    valuation_date: Date.new(2026, 4, 7),
    notes: 'Possesso di 1/16 dell\'immobile a seguito di successione'
  }
])

# PASSIVITÀ (Liabilities)
beneficiary.liabilities.create!([
  {
    liability_type: :mortgage,
    description: 'Mutuo Ipotecario',
    creditor: 'Credit Agricole',
    initial_amount: 50_000.00,
    remaining_balance: 9_153.48,
    interest_rate: 2.5,
    monthly_payment: 189.00,
    start_date: Date.new(2015, 1, 1),
    end_date: Date.new(2035, 1, 1),
    notes: 'Mutuo ipotecario per abitazione principale'
  },
  {
    liability_type: :personal_loan,
    description: 'Prestito Personale - Finanziamento moglie per figlio',
    creditor: 'Istituto Finanziario',
    initial_amount: 10_000.00,
    remaining_balance: 6_702.30,
    interest_rate: 5.0,
    monthly_payment: 223.41,
    start_date: Date.new(2023, 6, 1),
    end_date: Date.new(2026, 6, 1),
    notes: 'Ultima rata pagata: n. 30'
  },
  {
    liability_type: :personal_loan,
    description: 'Prestito Personale - Anticipo caparra RSA Villa Spada',
    creditor: 'Francesco Brunetti',
    initial_amount: 2_910.00,
    remaining_balance: 2_910.00,
    interest_rate: 0.0,
    monthly_payment: nil,
    start_date: Date.new(2025, 1, 1),
    notes: 'Prestito personale da Francesco Brunetti per anticipo caparra RSA Villa Spada'
  },
  {
    liability_type: :personal_loan,
    description: 'Prestito Personale - Prestiti vari (RSA, mutuo, spese)',
    creditor: 'Francesco Brunetti',
    initial_amount: 5_600.00,
    remaining_balance: 5_600.00,
    interest_rate: 0.0,
    monthly_payment: nil,
    start_date: Date.new(2025, 1, 1),
    notes: 'Prestito personale da Francesco Brunetti per RSA, mutuo e spese varie'
  },
  {
    liability_type: :other,
    description: 'Assicurazione vita mutuo',
    creditor: 'Credit Agricole',
    initial_amount: 1_500.00,
    remaining_balance: 0.00,
    interest_rate: 0.0,
    monthly_payment: 52.00,
    start_date: Date.new(2015, 1, 1),
    end_date: Date.new(2035, 1, 1),
    notes: 'Assicurazione vita collegata al mutuo ipotecario. Saldo residuo: 0,00 €. Rata mensile: 52,00 €'
  }
])

# ENTRATE RICORRENTI (Recurring Incomes)
beneficiary.recurring_incomes.create!([
  {
    income_type: :pension,
    description: 'Pensione + Accompagnamento + Reversibilità',
    amount: 3_020.00,
    frequency: :monthly,
    start_date: Date.new(2020, 1, 1),
    active: true,
    notes: 'Comprende: pensione, indennità di accompagnamento e pensione di reversibilità'
  }
])

# USCITE RICORRENTI (Recurring Expenses)
beneficiary.recurring_expenses.create!([
  {
    expense_type: :care_services,
    description: 'Retta RSA Villa Spada',
    amount: 3_070.00,
    frequency: :monthly,
    start_date: Date.new(2025, 1, 1),
    active: true,
    notes: 'Retta mensile presso RSA Villa Spada'
  },
  {
    expense_type: :loan_payment,
    description: 'Rata mutuo ipotecario',
    amount: 189.00,
    frequency: :monthly,
    start_date: Date.new(2015, 1, 1),
    active: true,
    notes: 'Rata mensile mutuo Credit Agricole'
  },
  {
    expense_type: :loan_payment,
    description: 'Rata prestito personale (finanziamento moglie)',
    amount: 223.41,
    frequency: :monthly,
    start_date: Date.new(2023, 6, 1),
    active: true,
    notes: 'Rata mensile prestito - ultima rata n. 30'
  },
  {
    expense_type: :insurance,
    description: 'Assicurazione vita mutuo',
    amount: 52.00,
    frequency: :monthly,
    start_date: Date.new(2015, 1, 1),
    active: true,
    notes: 'Premio assicurazione vita collegata al mutuo'
  }
])

# Contatti (familiari/referenti)
beneficiary.contacts.create!([
  {
    first_name: 'Francesco',
    last_name: 'Brunetti',
    relationship: 'Figlio e Amministratore di Sostegno',
    phone: '3331234567',
    email: 'francesco.brunetti@example.com',
    notes: 'Amministratore di Sostegno nominato dal Tribunale di Verona'
  }
])

# Scadenze importanti
beneficiary.deadlines.create!([
  {
    title: 'Presentazione Rendiconto Annuale',
    description: 'Rendiconto annuale da presentare al Giudice Tutelare',
    due_date: Date.new(2027, 3, 31),
    deadline_type: :report,
    status: :open,
    priority: :high,
    reminder_date: Date.new(2027, 3, 1)
  },
  {
    title: 'Scadenza mutuo Credit Agricole',
    description: 'Scadenza finale del mutuo ipotecario',
    due_date: Date.new(2035, 1, 1),
    deadline_type: :administrative,
    status: :open,
    priority: :medium
  }
])

puts "\n✅ Database ripristinato con i dati reali di Giovanni Brunetti"
puts "\nRiepilogo:"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "👤 Beneficiario: #{beneficiary.full_name}"
puts "👨‍⚖️ Amministratore: #{user.full_name}"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "💰 Attività (Conti): #{beneficiary.assets.count} - Totale: #{beneficiary.total_assets.round(2)} €"
puts "🏠 Immobili: #{beneficiary.properties.count}"
puts "💳 Passività: #{beneficiary.liabilities.count} - Totale: #{beneficiary.total_liabilities.round(2)} €"
puts "📈 Entrate Ricorrenti: #{beneficiary.recurring_incomes.count} - Annuale: #{beneficiary.total_annual_recurring_income.round(2)} €"
puts "📉 Uscite Ricorrenti: #{beneficiary.recurring_expenses.count} - Annuale: #{beneficiary.total_annual_recurring_expense.round(2)} €"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "💼 Patrimonio Netto: #{beneficiary.net_worth.round(2)} €"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "\n🔐 Login: francesco.brunetti@example.com / password123"
