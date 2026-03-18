class CreateRendicontos < ActiveRecord::Migration[7.2]
  def change
    create_table :rendicontos do |t|
      t.references :procedimento, null: false, foreign_key: true
      t.integer :anno
      t.date :data_presentazione
      t.date :data_approvazione
      t.string :stato
      t.text :note
      t.decimal :importo_entrate
      t.decimal :importo_uscite

      t.timestamps
    end
  end
end
