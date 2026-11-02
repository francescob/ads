class AssetPdfGenerator
  def initialize(beneficiary)
    @beneficiary = beneficiary
    @user = beneficiary.user
    @appointment = beneficiary.appointments.order(decree_date: :desc).first
  end

  def generate
    # Suppress UTF-8 font warning
    Prawn::Fonts::AFM.hide_m17n_warning = true
    
    pdf = Prawn::Document.new(page_size: 'A4', margin: [40, 50, 40, 50])

    # Header
    pdf.text "INVENTARIO PATRIMONIALE", size: 18, style: :bold, align: :center
    pdf.move_down 15
    pdf.text "Beneficiario: #{@beneficiary.full_name}", size: 12, style: :bold
    pdf.text "C.F.: #{@beneficiary.tax_code}", size: 10
    pdf.text "Amministratore: #{@user.full_name}", size: 10
    
    # Decreto di nomina
    if @appointment
      pdf.text "Decreto n. #{@appointment.decree_number} del #{@appointment.decree_date.strftime('%d/%m/%Y')}", size: 10
      pdf.text "Tribunale: #{@appointment.court}", size: 10
    end
    
    pdf.text "Data inventario: #{Date.current.strftime('%d/%m/%Y')}", size: 10
    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # BENI MOBILI (Assets)
    pdf.start_new_page if pdf.cursor < 200
    pdf.text "BENI MOBILI", size: 14, style: :bold
    pdf.move_down 10

    if @beneficiary.assets.any?
      asset_data = [["Tipo", "Descrizione", "Istituto/Luogo", "Val. Attuale", "Data Val.", "Note"]]
      @beneficiary.assets.order(:asset_type).each do |asset|
        asset_data << [
          I18n.t("activerecord.enums.asset.asset_type.#{asset.asset_type}", default: asset.asset_type),
          asset.description || '-',
          asset.institution_or_location || '-',
          number_to_currency(asset.current_value),
          asset.valuation_date&.strftime('%d/%m/%Y') || '-',
          asset.notes || '-'
        ]
      end

      pdf.table(asset_data, header: true,
                cell_style: { size: 8, padding: [4, 5] },
                column_widths: { 0 => 75, 1 => 90, 2 => 75, 3 => 60, 4 => 50, 5 => 115 }) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        row(0).size = 9
        column(3).align = :right
        column(4).align = :center
      end
    else
      pdf.text "Nessun bene mobile registrato.", size: 10, style: :italic
    end

    total_assets = @beneficiary.total_assets
    pdf.move_down 10
    pdf.text "TOTALE BENI MOBILI: #{number_to_currency(total_assets)}", 
             size: 11, style: :bold, align: :right

    pdf.move_down 30

    # IMMOBILI (Properties)
    pdf.start_new_page if pdf.cursor < 200
    pdf.text "IMMOBILI", size: 14, style: :bold
    pdf.move_down 10

    if @beneficiary.properties.any?
      property_data = [["Tipo", "Descrizione", "Indirizzo", "Dati Catastali", "Rendita Cat.", "Quota", "Valore"]]
      @beneficiary.properties.ordered.each do |property|
        cadastral_info = []
        cadastral_info << "F.#{property.cadastral_sheet}" if property.cadastral_sheet.present?
        cadastral_info << "P.#{property.cadastral_particle}" if property.cadastral_particle.present?
        cadastral_info << "S.#{property.cadastral_sub}" if property.cadastral_sub.present?
        cadastral_info << "Cat.#{property.cadastral_category}" if property.cadastral_category.present?
        cadastral_text = cadastral_info.join(" ")
        
        address_parts = []
        address_parts << property.city if property.city.present?
        address_parts << "(#{property.province})" if property.province.present?
        address_text = address_parts.join(" ")
        
        property_data << [
          I18n.t("activerecord.enums.property.property_type.#{property.property_type}", default: property.property_type.humanize),
          property.description || '-',
          address_text.presence || '-',
          cadastral_text.presence || '-',
          property.cadastral_income ? number_to_currency(property.cadastral_income) : '-',
          property.ownership_fraction || '-',
          property.current_value ? number_to_currency(property.current_value) : '-'
        ]
      end

      pdf.table(property_data, header: true,
                cell_style: { size: 8, padding: [4, 5] },
                column_widths: { 0 => 55, 1 => 85, 2 => 75, 3 => 85, 4 => 50, 5 => 35, 6 => 60 }) do
        row(0).font_style = :bold
        row(0).background_color = 'E8F4F8'
        row(0).size = 9
        column(4).align = :right
        column(5).align = :center
        column(6).align = :right
      end
    else
      pdf.text "Nessun immobile registrato.", size: 10, style: :italic
    end

    total_properties = @beneficiary.total_properties_value
    pdf.move_down 10
    pdf.text "TOTALE IMMOBILI: #{number_to_currency(total_properties)}", 
             size: 11, style: :bold, align: :right

    pdf.move_down 30

    # PASSIVITÀ (Liabilities)
    pdf.start_new_page if pdf.cursor < 200
    pdf.text "PASSIVITÀ", size: 14, style: :bold
    pdf.move_down 10

    if @beneficiary.liabilities.any?
      liability_data = [["Tipo", "Descrizione", "Creditore", "Saldo Residuo", "Rata Mens.", "Note"]]
      @beneficiary.liabilities.order(:liability_type).each do |liability|
        liability_data << [
          I18n.t("activerecord.enums.liability.liability_type.#{liability.liability_type}", default: liability.liability_type),
          liability.description || '-',
          liability.creditor || '-',
          number_to_currency(liability.remaining_balance),
          liability.monthly_payment ? number_to_currency(liability.monthly_payment) : '-',
          liability.notes || '-'
        ]
      end

      pdf.table(liability_data, header: true,
                cell_style: { size: 8, padding: [4, 5] },
                column_widths: { 0 => 75, 1 => 90, 2 => 70, 3 => 60, 4 => 55, 5 => 115 }) do
        row(0).font_style = :bold
        row(0).background_color = 'FFDDDD'
        row(0).size = 9
        column(3).align = :right
        column(4).align = :right
      end
    else
      pdf.text "Nessuna passività registrata.", size: 10, style: :italic
    end

    total_liabilities = @beneficiary.total_liabilities
    pdf.move_down 10
    pdf.text "TOTALE PASSIVITÀ: #{number_to_currency(total_liabilities)}", 
             size: 11, style: :bold, align: :right, color: 'CC0000'

    pdf.move_down 30

    # ENTRATE RICORRENTI (Recurring Incomes)
    pdf.start_new_page if pdf.cursor < 200
    pdf.text "ENTRATE RICORRENTI", size: 14, style: :bold
    pdf.move_down 10

    if @beneficiary.recurring_incomes.active_incomes.any?
      income_data = [["Tipo", "Descrizione", "Frequenza", "Importo", "Importo Annuale", "Note"]]
      @beneficiary.recurring_incomes.active_incomes.order(:income_type).each do |income|
        income_data << [
          I18n.t("activerecord.enums.recurring_income.income_type.#{income.income_type}", default: income.income_type),
          income.description || '-',
          I18n.t("activerecord.enums.recurring_income.frequency.#{income.frequency}", default: income.frequency),
          "~ #{number_to_currency(income.amount)}",
          "~ #{number_to_currency(income.annual_amount)}",
          income.notes || '-'
        ]
      end

      pdf.table(income_data, header: true,
                cell_style: { size: 8, padding: [4, 5] },
                column_widths: { 0 => 75, 1 => 90, 2 => 70, 3 => 55, 4 => 65, 5 => 110 }) do
        row(0).font_style = :bold
        row(0).background_color = 'DDFFDD'
        row(0).size = 9
        column(3).align = :right
        column(4).align = :right
      end
    else
      pdf.text "Nessuna entrata ricorrente attiva.", size: 10, style: :italic
    end

    total_annual_income = @beneficiary.total_annual_recurring_income
    pdf.move_down 10
    pdf.text "TOTALE ENTRATE ANNUALI: ~ #{number_to_currency(total_annual_income)}", 
             size: 11, style: :bold, align: :right, color: '006600'

    pdf.move_down 30

    # USCITE RICORRENTI (Recurring Expenses)
    pdf.start_new_page if pdf.cursor < 200
    pdf.text "USCITE RICORRENTI", size: 14, style: :bold
    pdf.move_down 10

    if @beneficiary.recurring_expenses.active_expenses.any?
      expense_data = [["Tipo", "Descrizione", "Frequenza", "Importo", "Importo Annuale", "Note"]]
      @beneficiary.recurring_expenses.active_expenses.order(:expense_type).each do |expense|
        expense_data << [
          I18n.t("activerecord.enums.recurring_expense.expense_type.#{expense.expense_type}", default: expense.expense_type),
          expense.description || '-',
          I18n.t("activerecord.enums.recurring_expense.frequency.#{expense.frequency}", default: expense.frequency),
          "~ #{number_to_currency(expense.amount)}",
          "~ #{number_to_currency(expense.annual_amount)}",
          expense.notes || '-'
        ]
      end

      pdf.table(expense_data, header: true,
                cell_style: { size: 8, padding: [4, 5] },
                column_widths: { 0 => 75, 1 => 90, 2 => 70, 3 => 55, 4 => 65, 5 => 110 }) do
        row(0).font_style = :bold
        row(0).background_color = 'FFDDDD'
        row(0).size = 9
        column(3).align = :right
        column(4).align = :right
      end
    else
      pdf.text "Nessuna uscita ricorrente attiva.", size: 10, style: :italic
    end

    total_annual_expense = @beneficiary.total_annual_recurring_expense
    pdf.move_down 10
    pdf.text "TOTALE USCITE ANNUALI: ~ #{number_to_currency(total_annual_expense)}", 
             size: 11, style: :bold, align: :right, color: 'CC0000'

    pdf.move_down 30
    pdf.stroke_horizontal_rule
    pdf.move_down 15

    # RIEPILOGO
    pdf.start_new_page if pdf.cursor < 150
    net_worth = @beneficiary.net_worth
    net_worth_color = net_worth >= 0 ? '006600' : 'CC0000'

    summary_data = [
      ["TOTALE BENI MOBILI", number_to_currency(total_assets)],
      ["TOTALE IMMOBILI", number_to_currency(total_properties)],
      ["TOTALE PATRIMONIO", number_to_currency(total_assets + total_properties)],
      ["TOTALE PASSIVITÀ", number_to_currency(total_liabilities)],
      ["PATRIMONIO NETTO", number_to_currency(net_worth)]
    ]

    pdf.table(summary_data, width: pdf.bounds.width / 2, position: :right) do
      cells.border_width = 0
      column(0).font_style = :bold
      column(0).align = :left
      column(1).align = :right
      column(1).font_style = :bold
      row(0).size = 10
      row(1).size = 10
      row(2).size = 11
      row(2).font_style = :bold
      row(2).borders = [:bottom]
      row(2).border_width = 1
      row(3).size = 11
      row(3).text_color = 'CC0000'
      row(4).size = 13
      row(4).text_color = net_worth_color
      row(4).borders = [:top]
      row(4).border_width = 2
      row(4).padding_top = 8
    end

    pdf.move_down 40

    # Firma
    pdf.text "Firma dell'Amministratore di Sostegno:", size: 10
    pdf.move_down 30
    pdf.text "_" * 50, size: 10

    pdf
  end

  private

  def number_to_currency(amount)
    return "-" if amount.nil?
    formatted = format("%.2f", amount).gsub('.', ',')
    "#{formatted} €"
  end
end