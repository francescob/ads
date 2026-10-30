class Movimento < ApplicationRecord
  include Tracciabile

  VERSI = %w[entrata uscita].freeze
  CATEGORIE_ENTRATA = %w[pensione indennita_accompagnamento stipendio affitti_attivi rimborsi interessi altre_entrate].freeze
  CATEGORIE_USCITA = %w[retta_struttura affitto utenze spese_sanitarie spese_alimentari spese_personali assistenza_badante
                        imposte_tasse spese_bancarie spese_legali altre_uscite].freeze
  CATEGORIE = (CATEGORIE_ENTRATA + CATEGORIE_USCITA).freeze
  IMPORTO_CON_SEGNO = Arel.sql("CASE WHEN movimenti.verso = 'entrata' THEN movimenti.importo ELSE -movimenti.importo END")

  belongs_to :conto

  validates :data, :descrizione, presence: true
  validates :verso, inclusion: { in: VERSI }
  validates :importo, numericality: { greater_than: 0 }
  validates :categoria, inclusion: { in: CATEGORIE }, allow_blank: true

  scope :entrate, -> { where(verso: "entrata") }
  scope :uscite, -> { where(verso: "uscita") }
  scope :nell_anno, ->(anno) { where(data: Date.new(anno).all_year) }
  scope :cronologici, -> { order(:data, :id) }

  def entrata?
    verso == "entrata"
  end

  def importo_con_segno
    entrata? ? importo : -importo
  end
end
