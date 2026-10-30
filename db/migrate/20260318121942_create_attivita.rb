class CreateAttivita < ActiveRecord::Migration[7.2]
  def change
    create_table :attivita do |t|
      t.references :procedimento, null: false, foreign_key: true
      t.string :titolo
      t.text :descrizione
      t.datetime :data_attivita
      t.string :tipo
      t.boolean :completata

      t.timestamps
    end
  end
end
