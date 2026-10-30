class Attivita < ApplicationRecord
  include Tracciabile

  TIPI = %w[legale sanitaria finanziaria personale altra].freeze

  belongs_to :procedimento

  validates :titolo, presence: true
  validates :tipo, inclusion: { in: TIPI }, allow_blank: true
end
