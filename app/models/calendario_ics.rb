# Feed iCalendar (RFC 5545) di scadenze aperte e udienze, da sottoscrivere
# in Google Calendar / Outlook / Apple Calendario.
class CalendarioIcs
  def initialize(host:)
    @host = host
  end

  def to_ics
    righe = [ "BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//ADS//Amministrazione di Sostegno//IT",
              "CALSCALE:GREGORIAN", "X-WR-CALNAME:ADS", "X-WR-TIMEZONE:Europe/Rome" ]
    scadenze.each { |s| righe.concat(evento_scadenza(s)) }
    udienze.each { |u| righe.concat(evento_udienza(u)) }
    righe << "END:VCALENDAR"
    righe.map { |r| piega(r) }.join("\r\n") + "\r\n"
  end

  private

  def scadenze
    Scadenza.aperte.where(data_scadenza: 90.days.ago.to_date..).includes(procedimento: :beneficiario)
  end

  def udienze
    Udienza.where(data_udienza: 90.days.ago..).includes(procedimento: :beneficiario)
  end

  def evento_scadenza(s)
    [ "BEGIN:VEVENT", "UID:scadenza-#{s.id}@#{@host}", "DTSTAMP:#{utc(s.updated_at)}",
      "DTSTART;VALUE=DATE:#{s.data_scadenza.strftime('%Y%m%d')}",
      "DTEND;VALUE=DATE:#{(s.data_scadenza + 1).strftime('%Y%m%d')}",
      "SUMMARY:#{testo("Scadenza: #{s.titolo} — #{s.procedimento.beneficiario.nome_completo}")}",
      "DESCRIPTION:#{testo(s.descrizione.to_s)}",
      "BEGIN:VALARM", "ACTION:DISPLAY", "DESCRIPTION:#{testo(s.titolo)}", "TRIGGER:-P3D", "END:VALARM",
      "END:VEVENT" ]
  end

  def evento_udienza(u)
    [ "BEGIN:VEVENT", "UID:udienza-#{u.id}@#{@host}", "DTSTAMP:#{utc(u.updated_at)}",
      "DTSTART:#{utc(u.data_udienza)}", "DTEND:#{utc(u.data_udienza + 1.hour)}",
      "SUMMARY:#{testo("Udienza #{u.tipo} — #{u.procedimento.beneficiario.nome_completo}")}",
      "LOCATION:#{testo(u.luogo.to_s)}",
      "BEGIN:VALARM", "ACTION:DISPLAY", "DESCRIPTION:Udienza", "TRIGGER:-P1D", "END:VALARM",
      "END:VEVENT" ]
  end

  def utc(time)
    time.utc.strftime("%Y%m%dT%H%M%SZ")
  end

  def testo(valore)
    valore.gsub("\\", "\\\\\\\\").gsub(/\r?\n/, "\\n").gsub(/([,;])/) { "\\#{$1}" }
  end

  # Le righe oltre 75 ottetti vanno spezzate (RFC 5545 §3.1)
  def piega(riga)
    parti = []
    corrente = +""
    riga.each_char do |c|
      if (corrente + c).bytesize > 75
        parti << corrente
        corrente = +" "
      end
      corrente << c
    end
    (parti << corrente).join("\r\n")
  end
end
