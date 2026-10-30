require "test_helper"

class NavigazioneTest < ActionDispatch::IntegrationTest
  setup do
    accedi
    @procedimento = crea_procedimento
    @beneficiario = @procedimento.beneficiario
    @procedimento.scadenze.create!(titolo: "Rendiconto annuale", data_scadenza: 5.days.from_now.to_date)
    @procedimento.udienze.create!(data_udienza: 3.days.from_now)
  end

  test "pagine principali" do
    [ root_path, beneficiari_path, scadenze_path, udienze_path, beneficiario_path(@beneficiario),
      beneficiario_procedimento_path(@beneficiario, @procedimento),
      new_beneficiario_procedimento_attivita_path(@beneficiario, @procedimento) ].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "ricerca beneficiari" do
    get beneficiari_path(q: "nessuno")
    assert_response :success
    assert_select "td", text: /Rossi/, count: 0
  end

  test "crea attività con note" do
    assert_difference -> { @procedimento.attivita.count } do
      post beneficiario_procedimento_attivita_index_path(@beneficiario, @procedimento),
           params: { attivita: { titolo: "Visita", tipo: "sanitaria", note: "ok" } }
    end
    assert_redirected_to beneficiario_procedimento_path(@beneficiario, @procedimento)
    assert_equal "ok", Attivita.last.note
  end

  test "segna scadenza completata" do
    scadenza = @procedimento.scadenze.first
    patch beneficiario_procedimento_scadenza_path(@beneficiario, @procedimento, scadenza),
          params: { scadenza: { completata: true } }
    assert scadenza.reload.completata
  end

  test "rendiconto non valido mostra errori" do
    post beneficiario_procedimento_rendiconti_path(@beneficiario, @procedimento), params: { rendiconto: { anno: "" } }
    assert_response :unprocessable_entity
  end

  test "eliminando un procedimento si torna al beneficiario" do
    delete beneficiario_procedimento_path(@beneficiario, @procedimento)
    assert_redirected_to beneficiario_path(@beneficiario)
  end
end
