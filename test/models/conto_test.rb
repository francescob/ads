require "test_helper"

class ContoTest < ActiveSupport::TestCase
  setup do
    @procedimento = crea_procedimento
    @beneficiario = @procedimento.beneficiario
    @conto = @beneficiario.conti.create!(nome: "CC", saldo_iniziale: 1000, iban: "it60 x054 2811 1010 0000 0123 456")
    @conto.movimenti.create!(data: Date.new(2025, 3, 1), descrizione: "Pensione", verso: "entrata", importo: 800, categoria: "pensione")
    @conto.movimenti.create!(data: Date.new(2025, 3, 5), descrizione: "Retta", verso: "uscita", importo: 1200, categoria: "retta_struttura")
    @conto.movimenti.create!(data: Date.new(2026, 1, 10), descrizione: "Farmaci", verso: "uscita", importo: 50, categoria: "spese_sanitarie")
  end

  test "normalizza IBAN" do
    assert_equal "IT60X0542811101000000123456", @conto.iban
  end

  test "saldo a una data" do
    assert_equal 1000, @conto.saldo(al: Date.new(2024, 12, 31))
    assert_equal 600, @conto.saldo(al: Date.new(2025, 12, 31))
    assert_equal 550, @conto.saldo(al: Date.new(2026, 12, 31))
  end

  test "importo deve essere positivo" do
    assert_not @conto.movimenti.build(data: Date.current, descrizione: "x", verso: "uscita", importo: -5).valid?
  end

  test "rendiconto ricalcolato dai movimenti dell'anno" do
    rendiconto = @procedimento.rendiconti.create!(anno: 2025)
    rendiconto.ricalcola_da_movimenti!
    assert_equal 800, rendiconto.importo_entrate
    assert_equal 1200, rendiconto.importo_uscite
    assert_equal({ [ "entrata", "pensione" ] => 800, [ "uscita", "retta_struttura" ] => 1200 }, rendiconto.totali_per_categoria)
  end
end
