require "csv"

class ExportsController < ApplicationController
  def report_pdf
    report = Report.owned_by(current_user)
                   .find(params[:report_id])

    pdf = ReportPdfGenerator.new(report).generate
    send_data pdf.render, filename: "report_#{report.reference_year}_#{report.beneficiary.last_name}.pdf",
              type: "application/pdf", disposition: "inline"
  end

  def asset_pdf
    beneficiary = user_beneficiaries.find(params[:beneficiary_id])
    pdf = AssetPdfGenerator.new(beneficiary).generate
    send_data pdf.render, filename: "assets_#{beneficiary.last_name}.pdf",
              type: "application/pdf", disposition: "inline"
  end

  def entries_csv
    report = Report.owned_by(current_user)
                   .find(params[:report_id])

    csv_data = CSV.generate(col_sep: ";") do |csv|
      csv << [ "Tipo", "Data", "Descrizione", "Categoria", "Importo", "Fornitore/Fonte" ]

      report.income_entries.order(:entry_date).each do |entry|
        csv << [ "Entrata", entry.entry_date, entry.description, entry.category, entry.amount, entry.source ]
      end

      report.expense_entries.order(:entry_date).each do |entry|
        csv << [ "Uscita", entry.entry_date, entry.description, entry.category, entry.amount, entry.supplier ]
      end
    end

    send_data csv_data, filename: "entries_#{report.reference_year}.csv",
              type: "text/csv", disposition: "attachment"
  end
end
