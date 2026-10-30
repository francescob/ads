require "test_helper"

class CalendariTest < ActionDispatch::IntegrationTest
  test "feed ics con token valido, 404 altrimenti" do
    user = crea_utente
    procedimento = crea_procedimento
    procedimento.scadenze.create!(titolo: "Rendiconto, annuale", data_scadenza: Date.new(2099, 1, 31))
    procedimento.udienze.create!(data_udienza: Time.zone.local(2099, 2, 1, 10, 30), tipo: "verifica", luogo: "Aula 3")

    get calendario_path(user.calendar_token)
    assert_response :success
    assert_equal "text/calendar", response.media_type
    assert_includes response.body, "DTSTART;VALUE=DATE:20990131"
    assert_includes response.body, "SUMMARY:Scadenza: Rendiconto\\, annuale"
    assert_includes response.body, "DTSTART:20990201T093000Z"
    assert response.body.split("\r\n").all? { |r| r.bytesize <= 75 }

    get calendario_path("sbagliato")
    assert_response :not_found
  end

  test "rigenera token" do
    user = accedi
    vecchio = user.calendar_token
    post rigenera_calendario_path
    assert_not_equal vecchio, user.reload.calendar_token
  end
end
