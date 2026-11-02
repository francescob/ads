class ReportPdfGenerator
  def initialize(report)
    @report = report
    @beneficiary = report.beneficiary
    @appointment = report.appointment
    @user = @beneficiary.user
  end

  def generate
    # Suppress UTF-8 font warning
    Prawn::Fonts::AFM.hide_m17n_warning = true
    
    pdf = Prawn::Document.new(page_size: 'A4', margin: [40, 50, 40, 50])

    header(pdf)
    beneficiary_data(pdf)
    appointment_details(pdf)
    report_period(pdf)
    income_table(pdf)
    expense_table(pdf)
    financial_summary(pdf)
    asset_snapshot(pdf)
    declaration(pdf)
    signature_block(pdf)
    exhibit_index(pdf)

    pdf
  end

  private

  def header(pdf)
    pdf.text "RENDICONTO PERIODICO", size: 16, style: :bold, align: :center
    pdf.move_down 10
    pdf.text "Amministratore di Sostegno: #{@user.full_name}", size: 10
    pdf.text "C.F.: #{@user.tax_code}", size: 10
    pdf.text "Indirizzo: #{@user.address}", size: 10
    pdf.text "Tel: #{@user.phone}", size: 10
    pdf.move_down 15
    pdf.stroke_horizontal_rule
    pdf.move_down 15
  end

  def beneficiary_data(pdf)
    pdf.text "DATI DEL BENEFICIARIO", size: 12, style: :bold
    pdf.move_down 5
    pdf.text "Nome: #{@beneficiary.full_name}", size: 10
    pdf.text "C.F.: #{@beneficiary.tax_code}", size: 10
    pdf.text "Data di nascita: #{@beneficiary.date_of_birth&.strftime('%d/%m/%Y')}", size: 10
    pdf.text "Luogo di nascita: #{@beneficiary.place_of_birth}", size: 10
    pdf.text "Residenza: #{[@beneficiary.street_address, @beneficiary.city, @beneficiary.province].compact.join(', ')}", size: 10
    pdf.move_down 15
  end

  def appointment_details(pdf)
    pdf.text "DECRETO DI NOMINA", size: 12, style: :bold
    pdf.move_down 5
    pdf.text "Decreto n.: #{@appointment.decree_number} del #{@appointment.decree_date&.strftime('%d/%m/%Y')}", size: 10
    pdf.text "Tribunale: #{@appointment.court} - #{@appointment.court_section}", size: 10
    pdf.text "Giudice Tutelare: #{@appointment.judge}", size: 10
    pdf.move_down 15
  end

  def report_period(pdf)
    pdf.text "PERIODO DI RIFERIMENTO", size: 12, style: :bold
    pdf.move_down 5
    pdf.text "Dal #{@report.period_from&.strftime('%d/%m/%Y')} al #{@report.period_to&.strftime('%d/%m/%Y')}", size: 10
    pdf.text "Anno: #{@report.reference_year}", size: 10
    pdf.move_down 15
  end

  def income_table(pdf)
    pdf.text "ENTRATE", size: 12, style: :bold
    pdf.move_down 5

    income_data = [["Data", "Descrizione", "Categoria", "Fonte", "Importo"]]
    @report.income_entries.order(:entry_date).each do |entry|
      income_data << [
        entry.entry_date&.strftime('%d/%m/%Y'),
        entry.description,
        I18n.t("activerecord.enums.income_entry.category.#{entry.category}", default: entry.category),
        entry.source,
        number_to_currency(entry.amount)
      ]
    end
    income_data << ["", "", "", { content: "TOTALE ENTRATE", font_style: :bold }, { content: number_to_currency(@report.total_income), font_style: :bold }]

    if income_data.length > 1
      pdf.table(income_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        column(4).align = :right
      end
    else
      pdf.text "Nessuna entrata registrata.", size: 10, style: :italic
    end
    pdf.move_down 15
  end

  def expense_table(pdf)
    pdf.text "USCITE", size: 12, style: :bold
    pdf.move_down 5

    expense_data = [["Data", "Descrizione", "Categoria", "Fornitore", "N. Ricevuta", "Importo"]]
    @report.expense_entries.order(:entry_date).each do |entry|
      expense_data << [
        entry.entry_date&.strftime('%d/%m/%Y'),
        entry.description,
        I18n.t("activerecord.enums.expense_entry.category.#{entry.category}", default: entry.category),
        entry.supplier,
        entry.receipt_number,
        number_to_currency(entry.amount)
      ]
    end
    expense_data << ["", "", "", "", { content: "TOTALE USCITE", font_style: :bold }, { content: number_to_currency(@report.total_expenses), font_style: :bold }]

    if expense_data.length > 1
      pdf.table(expense_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        column(5).align = :right
      end
    else
      pdf.text "Nessuna uscita registrata.", size: 10, style: :italic
    end
    pdf.move_down 15
  end

  def financial_summary(pdf)
    pdf.text "RIEPILOGO FINANZIARIO", size: 12, style: :bold
    pdf.move_down 5

    summary_data = [
      ["Saldo iniziale", number_to_currency(@report.opening_balance)],
      ["+ Totale entrate", number_to_currency(@report.total_income)],
      ["- Totale uscite", number_to_currency(@report.total_expenses)],
      [{ content: "= SALDO FINALE", font_style: :bold }, { content: number_to_currency(@report.closing_balance), font_style: :bold }]
    ]

    pdf.table(summary_data, width: 300, position: :center) do
      column(1).align = :right
      row(-1).background_color = 'EEEEEE'
    end
    pdf.move_down 20
  end

  def asset_snapshot(pdf)
    assets = @beneficiary.assets
    return if assets.empty?

    pdf.text "SITUAZIONE PATRIMONIALE", size: 12, style: :bold
    pdf.move_down 5

    asset_data = [["Tipo", "Descrizione", "Istituto/Luogo", "Valore"]]
    assets.each do |asset|
      asset_data << [
        I18n.t("activerecord.enums.asset.asset_type.#{asset.asset_type}", default: asset.asset_type),
        asset.description,
        asset.institution_or_location,
        number_to_currency(asset.current_value)
      ]
    end
    asset_data << ["", "", { content: "TOTALE", font_style: :bold }, { content: number_to_currency(assets.sum(:current_value)), font_style: :bold }]

    pdf.table(asset_data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      column(3).align = :right
    end
    pdf.move_down 15
  end

  def declaration(pdf)
    pdf.text "DICHIARAZIONE", size: 12, style: :bold
    pdf.move_down 5
    pdf.text "Il/La sottoscritto/a #{@user.full_name}, in qualita' di Amministratore di Sostegno " \
             "di #{@beneficiary.full_name}, dichiara che il presente rendiconto e' veritiero e completo, " \
             "e che tutte le spese sono state effettuate nell'interesse esclusivo del beneficiario.", size: 10
    pdf.move_down 15
  end

  def signature_block(pdf)
    pdf.text "Luogo e data: _________________________", size: 10
    pdf.move_down 20
    pdf.text "Firma dell'Amministratore di Sostegno", size: 10
    pdf.move_down 5
    pdf.text "_________________________", size: 10
    pdf.move_down 15
  end

  def exhibit_index(pdf)
    receipts = @report.expense_entries.where.not(receipt_number: [nil, '']).order(:entry_date)
    return if receipts.empty?

    pdf.text "INDICE DEGLI ALLEGATI", size: 12, style: :bold
    pdf.move_down 5

    receipts.each_with_index do |entry, index|
      pdf.text "#{index + 1}. Ricevuta n. #{entry.receipt_number} - #{entry.description} (#{entry.entry_date&.strftime('%d/%m/%Y')})", size: 10
    end
  end

  def number_to_currency(amount)
    return "0,00 EUR" if amount.nil?
    formatted = format("%.2f", amount).gsub('.', ',')
    "#{formatted} EUR"
  end
end