require "test_helper"

class BeneficiarioTest < ActiveSupport::TestCase
  test "richiede nome e cognome" do
    b = Beneficiario.new
    assert_not b.valid?
    assert b.errors.added?(:nome, :blank)
    assert b.errors.added?(:cognome, :blank)
  end

  test "normalizza e valida il codice fiscale" do
    b = Beneficiario.new(nome: "Mario", cognome: "Rossi", codice_fiscale: " rssmra80a01h501z ")
    assert b.valid?
    assert_equal "RSSMRA80A01H501Z", b.codice_fiscale

    b.codice_fiscale = "NONVALIDO"
    assert_not b.valid?
  end

  test "codice fiscale vuoto diventa nil e non viola l'unicità" do
    Beneficiario.create!(nome: "A", cognome: "B", codice_fiscale: "")
    assert Beneficiario.create!(nome: "C", cognome: "D", codice_fiscale: " ").persisted?
  end

  test "cerca per cognome o codice fiscale" do
    rossi = Beneficiario.create!(nome: "Mario", cognome: "Rossi", codice_fiscale: "RSSMRA80A01H501Z")
    Beneficiario.create!(nome: "Lucia", cognome: "Bianchi")
    assert_equal [ rossi ], Beneficiario.cerca("ross").to_a
    assert_equal [ rossi ], Beneficiario.cerca("H501").to_a
    assert_equal 2, Beneficiario.cerca("").count
  end
end
