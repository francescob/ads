class CreateProcedimentos < ActiveRecord::Migration[7.2]
  def change
    create_table :procedimentos do |t|
      t.references :beneficiario, null: false, foreign_key: true
      t.string :numero_rg
      t.string :tribunale
      t.string :giudice_tutelare
      t.date :data_apertura
      t.date :data_chiusura
      t.string :stato
      t.text :note

      t.timestamps
    end
  end
end
