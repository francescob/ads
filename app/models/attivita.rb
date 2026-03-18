class Attivita < ApplicationRecord
  belongs_to :procedimento
  
  validates :titolo, presence: true
  
  TIPI = %w[legale sanitaria finanziaria personale altra].freeze
end
