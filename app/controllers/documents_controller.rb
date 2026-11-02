class DocumentsController < ApplicationController
  before_action :set_beneficiary, only: [:index, :new, :create]
  before_action :set_document, only: [:show, :edit, :update, :destroy]

  def index
    @documents = @beneficiary.documents.order(created_at: :desc)
  end

  def show; end

  def new
    @document = @beneficiary.documents.build
  end

  def create
    @document = @beneficiary.documents.build(document_params)
    if @document.save
      redirect_to @document, notice: t('documents.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @document.update(document_params)
      redirect_to @document, notice: t('documents.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    beneficiary = @document.beneficiary
    @document.destroy
    redirect_to beneficiary_documents_path(beneficiary), notice: t('documents.deleted')
  end

  private

  def set_beneficiary
    @beneficiary = user_beneficiaries.find(params[:beneficiary_id])
  end

  def set_document
    @document = Document.joins(:beneficiary)
                        .where(beneficiaries: { user_id: current_user.id })
                        .find(params[:id])
    @beneficiary = @document.beneficiary
  end

  def document_params
    params.require(:document).permit(
      :title, :document_type, :file, :document_date, :expiry_date, :notes
    )
  end
end