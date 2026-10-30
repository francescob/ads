class DocumentiController < ApplicationController
  include ProcedimentoScoped

  before_action :set_procedimento
  before_action :set_documento, only: %i[show edit update destroy]

  # Scarica il file: passa sempre dal login, mai da URL pubblici di ActiveStorage.
  def show
    send_data @documento.file.download,
              filename: @documento.file.filename.to_s,
              type: @documento.file.content_type,
              disposition: params[:download] ? :attachment : :inline
  end

  def new
    @documento = @procedimento.documenti.build
  end

  def edit
  end

  def create
    @documento = @procedimento.documenti.build(documento_params)
    if @documento.save
      redirect_to_procedimento "Documento caricato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    attrs = documento_params
    attrs = attrs.except(:file) if attrs[:file].blank?
    if @documento.update(attrs)
      redirect_to_procedimento "Documento aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @documento.destroy
    redirect_to_procedimento "Documento eliminato.", status: :see_other
  end

  private

  def set_documento
    @documento = @procedimento.documenti.find(params[:id])
  end

  def documento_params
    params.expect(documento: [ :titolo, :categoria, :data_documento, :note, :file ])
  end
end
