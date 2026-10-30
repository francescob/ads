require "test_helper"

class RegistroRicercaTest < ActionDispatch::IntegrationTest
  test "le modifiche vengono registrate con l'utente" do
    admin = accedi(crea_utente(ruolo: "admin"))
    post beneficiari_path, params: { beneficiario: { nome: "Luigi", cognome: "Verdi" } }
    beneficiario = Beneficiario.last
    patch beneficiario_path(beneficiario), params: { beneficiario: { telefono: "06 123" } }

    modifiche = Modifica.where(beneficiario_id: beneficiario.id).order(:id)
    assert_equal %w[create update], modifiche.map(&:azione)
    assert_equal admin, modifiche.last.user
    assert_equal [ nil, "06 123" ], modifiche.last.cambiamenti["telefono"]

    get modifiche_path(beneficiario_id: beneficiario.id)
    assert_response :success
    assert_select "td", text: /Verdi Luigi/
  end

  test "modifiche di oggetti annidati riportano il beneficiario" do
    procedimento = crea_procedimento
    scadenza = procedimento.scadenze.create!(titolo: "X", data_scadenza: Date.current)
    scadenza.destroy
    assert_equal %w[create destroy], Modifica.where(record_type: "Scadenza").order(:id).pluck(:azione)
    assert Modifica.where(record_type: "Scadenza").all? { |m| m.beneficiario_id == procedimento.beneficiario_id }
  end

  test "registro riservato agli admin" do
    accedi
    get modifiche_path
    assert_redirected_to root_path
  end

  test "ricerca globale" do
    accedi
    procedimento = crea_procedimento
    procedimento.istanze.create!(oggetto: "Vendita appartamento Via Po")
    get ricerca_path(q: "appartamento")
    assert_response :success
    assert_select "p", text: "Vendita appartamento Via Po"
  end

  test "paginazione e filtri scadenze" do
    accedi
    procedimento = crea_procedimento
    30.times { |i| procedimento.scadenze.create!(titolo: "S#{i}", data_scadenza: Date.current + i) }
    get scadenze_path(filtro: "aperte")
    assert_select "tbody tr", 25
    get scadenze_path(filtro: "aperte", pagina: 2)
    assert_select "tbody tr", 5
    get scadenze_path(filtro: "completate")
    assert_select "tbody tr", 0
  end
end
