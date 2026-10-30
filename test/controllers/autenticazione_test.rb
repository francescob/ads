require "test_helper"

class AutenticazioneTest < ActionDispatch::IntegrationTest
  test "le pagine richiedono il login" do
    get beneficiari_path
    assert_redirected_to new_session_path
  end

  test "login, ritorno alla pagina richiesta e logout" do
    user = crea_utente
    get beneficiari_path
    post session_path, params: { email_address: user.email_address.upcase, password: "password-sicura" }
    assert_redirected_to beneficiari_url

    delete session_path
    get root_path
    assert_redirected_to new_session_path
  end

  test "password errata" do
    user = crea_utente
    post session_path, params: { email_address: user.email_address, password: "sbagliata" }
    assert_redirected_to new_session_path
    get root_path
    assert_redirected_to new_session_path
  end

  test "utente disattivato non accede e perde la sessione" do
    user = accedi
    user.update!(attivo: false)
    get root_path
    assert_redirected_to new_session_path
  end

  test "cambio password" do
    user = accedi
    patch password_path, params: { password_attuale: "password-sicura", password: "nuova-password-1", password_confirmation: "nuova-password-1" }
    assert_redirected_to root_path
    assert user.reload.authenticate("nuova-password-1")
  end

  test "gestione utenti riservata agli admin" do
    accedi
    get users_path
    assert_redirected_to root_path
  end

  test "admin crea utenti e non può disattivare se stesso" do
    admin = accedi(crea_utente(ruolo: "admin"))
    assert_difference -> { User.count } do
      post users_path, params: { user: { nome: "Anna", email_address: "anna@example.com", ruolo: "operatore", password: "password-anna", password_confirmation: "password-anna" } }
    end
    patch user_path(admin), params: { user: { attivo: "0" } }
    assert_response :unprocessable_entity
    assert admin.reload.attivo?
  end
end
