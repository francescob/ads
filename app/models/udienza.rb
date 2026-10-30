class Udienza < ApplicationRecord
  include Tracciabile

  TIPI = [ "prima udienza", "verifica", "rendiconto", "altra" ].freeze

  belongs_to :procedimento

  validates :data_udienza, presence: true
  validates :tipo, inclusion: { in: TIPI }, allow_blank: true

  scope :future, -> { where(data_udienza: Time.current..).order(:data_udienza) }
end
