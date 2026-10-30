require "test_helper"

class ContabilitaTest < ActionDispatch::IntegrationTest
  setup do
    accedi
    @procedimento = crea_procedimento
    @beneficiario = @procedimento.beneficiario
    @conto = @beneficiario.conti.create!(nome: "Conto pensione", saldo_iniziale: 500)
  end

  test "registra movimenti e mostra il conto" do
    post beneficiario_conto_movimenti_path(@beneficiario, @conto),
         params: { movimento: { data: "2025-02-01", descrizione: "Pensione febbraio", verso: "entrata", importo: "750,00".tr(",", "."), categoria: "pensione" } }
    assert_redirected_to beneficiario_conto_path(@beneficiario, @conto, anno: 2025)
    follow_redirect!
    assert_select "td", text: "Pensione febbraio"

    get beneficiario_conto_path(@beneficiario, @conto, anno: 2025, format: :csv)
    assert_equal "text/csv", response.media_type
    assert_includes response.body, "01/02/2025;Conto pensione;Pensione febbraio;Pensione;750,00;;"
  end

  test "rendiconto stampabile e ricalcolo" do
    @conto.movimenti.create!(data: Date.new(2025, 6, 1), descrizione: "Utenze", verso: "uscita", importo: 120, categoria: "utenze")
    rendiconto = @procedimento.rendiconti.create!(anno: 2025)

    post ricalcola_beneficiario_procedimento_rendiconto_path(@beneficiario, @procedimento, rendiconto)
    assert_equal 120, rendiconto.reload.importo_uscite

    get beneficiario_procedimento_rendiconto_path(@beneficiario, @procedimento, rendiconto)
    assert_response :success
    assert_select "h1", text: "Rendiconto annuale 2025"
    assert_select "td", text: "Utenze"
  end

  test "beneficiario mostra conti con saldo" do
    get beneficiario_path(@beneficiario)
    assert_select "a", text: "Conto pensione"
  end
end
