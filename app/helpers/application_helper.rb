module ApplicationHelper
  # Formatta date/orari in formato italiano, "—" se assenti.
  def data_it(value, format: :default)
    value ? l(value, format: format) : "—"
  end

  # "servizi_sociali" -> "Servizi sociali"
  def etichetta(value)
    value.present? ? value.to_s.humanize : "—"
  end

  def opzioni(valori)
    valori.map { |v| [ etichetta(v), v ] }
  end

  def euro(importo)
    number_to_currency(importo || 0, unit: "€", separator: ",", delimiter: ".", format: "%u %n")
  end

  # Breadcrumb + titolo per le pagine new/edit delle risorse di un procedimento
  def intestazione_procedimento(titolo)
    content_for :title, "#{titolo} - ADS"
    safe_join([
      tag.nav(class: "text-sm text-gray-500 mb-6") do
        safe_join([
          link_to("Beneficiari", beneficiari_path, class: "hover:underline"),
          link_to(@beneficiario.nome_completo, @beneficiario, class: "hover:underline"),
          link_to("Procedimento #{@procedimento.titolo}", beneficiario_procedimento_path(@beneficiario, @procedimento), class: "hover:underline"),
          titolo
        ], " / ")
      end,
      tag.h1(titolo, class: "text-2xl font-bold text-gray-900 mb-6")
    ])
  end
end
