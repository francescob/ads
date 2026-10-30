require "test_helper"

class RendicontoTest < ActiveSupport::TestCase
  setup { @procedimento = crea_procedimento }

  test "saldo" do
    r = @procedimento.rendiconti.build(anno: 2025, importo_entrate: 1000, importo_uscite: 400.5)
    assert_equal BigDecimal("599.5"), r.saldo
  end

  test "un solo rendiconto per anno e procedimento" do
    @procedimento.rendiconti.create!(anno: 2025)
    assert_not @procedimento.rendiconti.build(anno: 2025).valid?
  end

  test "importi non negativi" do
    assert_not @procedimento.rendiconti.build(anno: 2025, importo_uscite: -1).valid?
  end
end
