class AssetsController < ApplicationController
  before_action :set_beneficiary, only: [ :index, :new, :create ]
  before_action :set_asset, only: [ :show, :edit, :update, :destroy ]

  # The list lives in the beneficiary page, in the "assets" tab.
  def index
    redirect_to beneficiary_path(@beneficiary, tab: "assets")
  end

  def show; end

  def new
    @asset = @beneficiary.assets.build
  end

  def create
    @asset = @beneficiary.assets.build(asset_params)
    if @asset.save
      redirect_to @asset, notice: t("assets.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @asset.update(asset_params)
      redirect_to @asset, notice: t("assets.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @asset.beneficiary
    @asset.destroy
    redirect_to beneficiary_path(beneficiary, tab: "assets"), status: :see_other, notice: t("assets.deleted")
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_asset
    @asset = Asset.owned_by(current_user)
                  .find(params[:id])
    @beneficiary = @asset.beneficiary
  end

  def asset_params
    params.require(:asset).permit(
      :asset_type, :description, :institution_or_location,
      :initial_value, :current_value, :valuation_date, :notes
    )
  end
end
