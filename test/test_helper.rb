ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    def crea_procedimento(**attrs)
      beneficiario = Beneficiario.create!(nome: "Mario", cognome: "Rossi")
      beneficiario.procedimenti.create!(numero_rg: "123/2026", **attrs)
    end
  end
end
