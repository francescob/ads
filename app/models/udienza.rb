class Udienza < ApplicationRecord
  belongs_to :procedimento
  
  validates :data_udienza, presence: true
  
  TIPI = ["prima udienza", "verifica", "rendiconto", "altra"].freeze
end
