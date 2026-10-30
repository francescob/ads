module ApplicationHelper
  # Formatta date/orari in formato italiano, "—" se assenti.
  def data_it(value, format: :default)
    value ? l(value, format: format) : "—"
  end
end
