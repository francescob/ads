class CreateDocumentiContattiIstanze < ActiveRecord::Migration[7.2]
  def change
    create_table :documenti do |t|
      t.references :procedimento, null: false, foreign_key: true
      t.string :titolo, null: false
      t.string :categoria
      t.date :data_documento
      t.text :note
      t.timestamps
    end

    create_table :contatti do |t|
      t.references :beneficiario, null: false, foreign_key: true
      t.string :nome, null: false
      t.string :tipo
      t.string :ruolo
      t.string :telefono
      t.string :email
      t.string :indirizzo
      t.text :note
      t.timestamps
    end

    create_table :istanze do |t|
      t.references :procedimento, null: false, foreign_key: true
      t.string :oggetto, null: false
      t.string :tipo
      t.string :stato, null: false, default: "bozza"
      t.date :data_deposito
      t.date :data_decisione
      t.decimal :importo, precision: 12, scale: 2
      t.text :esito
      t.text :note
      t.timestamps
    end
    add_index :istanze, :stato
  end
end
