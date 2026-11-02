class AssetCalculator
  def initialize(beneficiary)
    @beneficiary = beneficiary
  end

  def net_total
    @beneficiary.assets.sum(:current_value)
  end

  def by_type
    @beneficiary.assets.group(:asset_type).sum(:current_value)
  end

  def total_initial_value
    @beneficiary.assets.sum(:initial_value)
  end

  def value_change
    net_total - total_initial_value
  end
end
