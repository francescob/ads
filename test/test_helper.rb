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

    def crea_utente(ruolo: "operatore", email: "#{ruolo}@example.com")
      User.create!(nome: ruolo.capitalize, email_address: email, password: "password-sicura", ruolo: ruolo)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    def accedi(user = crea_utente)
      post session_path, params: { email_address: user.email_address, password: "password-sicura" }
      user
    end
  end
end
