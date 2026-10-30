require "test_helper"

class ProcedimentoTest < ActiveSupport::TestCase
  test "stato attivo di default" do
    assert_equal "attivo", crea_procedimento.stato
  end

  test "data chiusura non precedente all'apertura" do
    p = crea_procedimento
    p.assign_attributes(data_apertura: Date.new(2026, 5, 1), data_chiusura: Date.new(2026, 4, 1))
    assert_not p.valid?
    assert p.errors.key?(:data_chiusura)
  end
end
