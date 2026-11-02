class ContactsController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @contacts = @beneficiary.contacts.order(:last_name)
  end

  def show; end

  def new
    @contact = @beneficiary.contacts.build
  end

  def create
    @contact = @beneficiary.contacts.build(contact_params)
    if @contact.save
      redirect_to beneficiary_path(@beneficiary), notice: t('contacts.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to beneficiary_path(@contact.beneficiary), notice: t('contacts.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @contact.beneficiary
    @contact.destroy
    redirect_to beneficiary_path(beneficiary), notice: t('contacts.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_contact
    @contact = Contact.joins(:beneficiary)
                      .where(beneficiaries: { user_id: current_user.id })
                      .find(params[:id])
    @beneficiary = @contact.beneficiary
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :relationship, :phone, :email, :notes)
  end
end