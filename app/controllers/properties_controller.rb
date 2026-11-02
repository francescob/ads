class PropertiesController < ApplicationController
  before_action :set_beneficiary, only: [ :index, :new, :create ]
  before_action :set_property, only: [ :show, :edit, :update, :destroy ]

  def index
    @properties = @beneficiary.properties.ordered
  end

  def show; end

  def new
    @property = @beneficiary.properties.build
  end

  def create
    @property = @beneficiary.properties.build(property_params)
    if @property.save
      redirect_to @property, notice: "Immobile creato con successo."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @property.update(property_params)
      redirect_to @property, notice: "Immobile aggiornato con successo."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @property.beneficiary
    @property.destroy
    redirect_to beneficiary_properties_path(beneficiary), notice: "Immobile eliminato con successo."
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_property
    @property = Property.owned_by(current_user)
                        .find(params[:id])
    @beneficiary = @property.beneficiary
  end

  def property_params
    params.require(:property).permit(
      :property_type,
      :description,
      :address,
      :city,
      :province,
      :zip_code,
      :cadastral_sheet,
      :cadastral_particle,
      :cadastral_sub,
      :cadastral_category,
      :cadastral_class,
      :cadastral_consistency,
      :cadastral_income,
      :ownership_numerator,
      :ownership_denominator,
      :initial_value,
      :current_value,
      :valuation_date,
      :notes
    )
  end
end
