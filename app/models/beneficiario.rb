class Beneficiario < ApplicationRecord
  has_many :procedimenti, dependent: :destroy
  
  validates :nome, :cognome, presence: true
  
  def nome_completo
    "#{cognome} #{nome}"
  end
end
