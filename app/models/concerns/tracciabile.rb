# Registra in Modifica ogni create/update/destroy, con l'utente corrente.
module Tracciabile
  extend ActiveSupport::Concern

  CAMPI_ESCLUSI = %w[id created_at updated_at password_digest calendar_token].freeze

  included do
    after_create_commit -> { traccia("create", saved_changes) }
    after_update_commit -> { traccia("update", saved_changes) }
    after_destroy_commit -> { traccia("destroy", attributes.transform_values { |v| [ v, nil ] }) }
  end

  def descrizione_per_registro
    %i[nome_completo titolo oggetto descrizione nome].each do |m|
      return public_send(m).to_s if respond_to?(m) && public_send(m).present?
    end
    "##{id}"
  end

  private

  def traccia(azione, cambiamenti)
    cambiamenti = cambiamenti.except(*CAMPI_ESCLUSI)
    return if azione == "update" && cambiamenti.empty?

    Modifica.create!(
      user: Current.user,
      beneficiario_id: beneficiario_id_per_registro,
      record_type: self.class.name,
      record_id: id,
      descrizione_record: descrizione_per_registro.truncate(120),
      azione: azione,
      cambiamenti: cambiamenti.transform_values { |(prima, dopo)| [ prima, dopo ].map { |v| v.respond_to?(:iso8601) ? v.iso8601 : v } }
    )
  end

  def beneficiario_id_per_registro
    return id if is_a?(Beneficiario)
    return beneficiario_id if respond_to?(:beneficiario_id)
    return procedimento&.beneficiario_id if respond_to?(:procedimento)

    conto&.beneficiario_id if respond_to?(:conto)
  end
end
