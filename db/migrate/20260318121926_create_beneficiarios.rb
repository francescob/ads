class CreateBeneficiarios < ActiveRecord::Migration[7.2]
  def change
    create_table :beneficiarios do |t|
      t.string :nome
      t.string :cognome
      t.string :codice_fiscale
      t.date :data_nascita
      t.string :luogo_nascita
      t.string :indirizzo
      t.string :telefono
      t.string :email
      t.text :note

      t.timestamps
    end
  end
end
