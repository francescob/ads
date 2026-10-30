require "test_helper"

class ScadenzaRicorrenteTest < ActiveSupport::TestCase
  test "completare una scadenza ricorrente crea la successiva" do
    procedimento = crea_procedimento
    s = procedimento.scadenze.create!(titolo: "Rendiconto", data_scadenza: Date.new(2026, 3, 31), ricorrenza: "annuale")
    s.update!(completata: true)
    assert procedimento.scadenze.exists?(titolo: "Rendiconto", data_scadenza: Date.new(2027, 3, 31), completata: false)

    # idempotente: ri-completare non duplica
    s.update!(completata: false)
    s.update!(completata: true)
    assert_equal 1, procedimento.scadenze.where(data_scadenza: Date.new(2027, 3, 31)).count
  end

  test "un nuovo procedimento con data apertura mette in scadenzario il rendiconto" do
    procedimento = crea_procedimento(data_apertura: Date.new(2026, 2, 10))
    scadenza = procedimento.scadenze.sole
    assert_equal Date.new(2027, 2, 10), scadenza.data_scadenza
    assert_equal "annuale", scadenza.ricorrenza
  end

  test "per procedimenti aperti da anni la scadenza è il prossimo anniversario" do
    travel_to Date.new(2026, 10, 30) do
      procedimento = crea_procedimento(data_apertura: Date.new(2020, 3, 15))
      assert_equal Date.new(2027, 3, 15), procedimento.scadenze.sole.data_scadenza
    end
  end
end
