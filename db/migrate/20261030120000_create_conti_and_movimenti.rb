class CreateContiAndMovimenti < ActiveRecord::Migration[7.2]
  def change
    create_table :conti do |t|
      t.references :beneficiario, null: false, foreign_key: true
      t.string :nome, null: false
      t.string :tipo
      t.string :istituto
      t.string :iban
      t.decimal :saldo_iniziale, precision: 12, scale: 2, null: false, default: 0
      t.date :data_saldo_iniziale
      t.boolean :attivo, null: false, default: true
      t.text :note
      t.timestamps
    end

    create_table :movimenti do |t|
      t.references :conto, null: false, foreign_key: true
      t.date :data, null: false
      t.string :descrizione, null: false
      t.string :verso, null: false
      t.decimal :importo, precision: 12, scale: 2, null: false
      t.string :categoria
      t.text :note
      t.timestamps
    end
    add_index :movimenti, [ :conto_id, :data ]
  end
end
