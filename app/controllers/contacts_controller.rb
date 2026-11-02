class ContactsController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # The list lives in the beneficiary page, in the "contacts" tab.
  def index
    redirect_to beneficiary_path(@beneficiary, tab: "contacts")
  end

  def show; end

  def new
    @contact = @beneficiary.contacts.build
  end

  def create
    @contact = @beneficiary.contacts.build(contact_params)
    if @contact.save
      redirect_to beneficiary_path(@beneficiary, tab: "contacts"), notice: t("contacts.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to beneficiary_path(@contact.beneficiary, tab: "contacts"), notice: t("contacts.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    beneficiary = @contact.beneficiary
    @contact.destroy
    redirect_to beneficiary_path(beneficiary, tab: "contacts"), status: :see_other, notice: t('contacts.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_contact
    @contact = Contact.owned_by(current_user)
                      .find(params[:id])
    @beneficiary = @contact.beneficiary
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :relationship, :phone, :email, :notes)
  end
end