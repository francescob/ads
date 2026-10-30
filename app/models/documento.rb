class Documento < ApplicationRecord
  CATEGORIE = %w[decreto istanza ricorso verbale certificato_medico contabile identita altro].freeze
  DIMENSIONE_MASSIMA = 25.megabytes

  belongs_to :procedimento
  has_one_attached :file

  validates :titolo, presence: true
  validates :categoria, inclusion: { in: CATEGORIE }, allow_blank: true
  validate :file_presente_e_non_troppo_grande

  private

  def file_presente_e_non_troppo_grande
    if !file.attached?
      errors.add(:file, :blank)
    elsif file.blob.byte_size > DIMENSIONE_MASSIMA
      errors.add(:file, "supera i #{DIMENSIONE_MASSIMA / 1.megabyte} MB")
    end
  end
end
