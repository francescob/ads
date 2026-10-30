require "test_helper"

class DocumentiIstanzeContattiTest < ActionDispatch::IntegrationTest
  setup do
    accedi
    @procedimento = crea_procedimento
    @beneficiario = @procedimento.beneficiario
  end

  test "carica, scarica ed elimina un documento" do
    assert_difference -> { @procedimento.documenti.count } do
      post beneficiario_procedimento_documenti_path(@beneficiario, @procedimento), params: {
        documento: { titolo: "Decreto di nomina", categoria: "decreto", file: fixture_file_upload("decreto.pdf", "application/pdf") }
      }
    end
    documento = @procedimento.documenti.last
    get beneficiario_procedimento_documento_path(@beneficiario, @procedimento, documento)
    assert_response :success
    assert_equal "%PDF-1.4 test", response.body

    get beneficiario_procedimento_path(@beneficiario, @procedimento)
    assert_select "a", text: "Decreto di nomina"

    delete beneficiario_procedimento_documento_path(@beneficiario, @procedimento, documento)
    assert_equal 0, @procedimento.documenti.count
  end

  test "documento senza file non è valido" do
    post beneficiario_procedimento_documenti_path(@beneficiario, @procedimento), params: { documento: { titolo: "X" } }
    assert_response :unprocessable_entity
  end

  test "documento non accessibile senza login" do
    documento = @procedimento.documenti.create!(titolo: "X", file: fixture_file_upload("decreto.pdf", "application/pdf"))
    delete session_path
    get beneficiario_procedimento_documento_path(@beneficiario, @procedimento, documento)
    assert_redirected_to new_session_path
  end

  test "crea istanza" do
    post beneficiario_procedimento_istanze_path(@beneficiario, @procedimento),
         params: { istanza: { oggetto: "Acquisto carrozzina", tipo: "autorizzazione_spesa", stato: "depositata", importo: "850" } }
    assert_redirected_to beneficiario_procedimento_path(@beneficiario, @procedimento)
    assert_equal 1, Istanza.in_attesa.count
    get beneficiario_procedimento_path(@beneficiario, @procedimento)
    assert_select "p", text: "Acquisto carrozzina"
  end

  test "crea contatto" do
    post beneficiario_contatti_path(@beneficiario), params: { contatto: { nome: "Anna Rossi", tipo: "familiare", ruolo: "figlia", email: "ANNA@example.com " } }
    assert_redirected_to beneficiario_path(@beneficiario)
    assert_equal "anna@example.com", @beneficiario.contatti.last.email
  end
end
