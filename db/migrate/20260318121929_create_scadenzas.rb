class CreateScadenzas < ActiveRecord::Migration[7.2]
  def change
    create_table :scadenzas do |t|
      t.references :procedimento, null: false, foreign_key: true
      t.string :titolo
      t.text :descrizione
      t.date :data_scadenza
      t.boolean :completata
      t.string :tipo
      t.text :note

      t.timestamps
    end
  end
end
