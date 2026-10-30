require "csv"

class MovimentiCsv
  INTESTAZIONE = %w[Data Conto Descrizione Categoria Entrata Uscita Note].freeze

  def initialize(movimenti)
    @movimenti = movimenti
  end

  def to_csv
    CSV.generate(col_sep: ";") do |csv|
      csv << INTESTAZIONE
      @movimenti.includes(:conto).each do |m|
        csv << [ I18n.l(m.data), m.conto.nome, m.descrizione, m.categoria&.humanize,
                 (importo(m) if m.entrata?), (importo(m) unless m.entrata?), m.note ]
      end
    end
  end

  private

  # Formato numerico italiano, così Excel lo legge come numero
  def importo(movimento)
    format("%.2f", movimento.importo).tr(".", ",")
  end
end
