require "test_helper"

class ScadenzaTest < ActiveSupport::TestCase
  setup { @procedimento = crea_procedimento }

  test "completata è false di default" do
    s = @procedimento.scadenze.create!(titolo: "Rendiconto", data_scadenza: Date.current)
    assert_equal false, s.completata
  end

  test "scope in_scadenza e scadute" do
    scaduta = @procedimento.scadenze.create!(titolo: "A", data_scadenza: 2.days.ago.to_date)
    imminente = @procedimento.scadenze.create!(titolo: "B", data_scadenza: 10.days.from_now.to_date)
    @procedimento.scadenze.create!(titolo: "C", data_scadenza: 90.days.from_now.to_date)
    @procedimento.scadenze.create!(titolo: "D", data_scadenza: 1.day.ago.to_date, completata: true)

    assert_equal [ scaduta, imminente ], Scadenza.in_scadenza.to_a
    assert_equal [ scaduta ], Scadenza.scadute.to_a
    assert scaduta.scaduta?
    assert_not imminente.scaduta?
  end

  test "tipo deve essere tra quelli previsti" do
    s = @procedimento.scadenze.build(titolo: "X", data_scadenza: Date.current, tipo: "boh")
    assert_not s.valid?
  end
end
