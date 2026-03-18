class Scadenza < ApplicationRecord
  belongs_to :procedimento
  
  validates :titolo, :data_scadenza, presence: true
  
  TIPI = %w[rendiconto udienza adempimento altro].freeze
  
  scope :in_scadenza, -> { where(completata: false).where("data_scadenza <= ?", 30.days.from_now).order(:data_scadenza) }
  scope :scadute, -> { where(completata: false).where("data_scadenza < ?", Date.today) }
end
