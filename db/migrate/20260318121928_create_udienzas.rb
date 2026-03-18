class CreateUdienzas < ActiveRecord::Migration[7.2]
  def change
    create_table :udienzas do |t|
      t.references :procedimento, null: false, foreign_key: true
      t.datetime :data_udienza
      t.string :tipo
      t.string :luogo
      t.text :note
      t.text :esito

      t.timestamps
    end
  end
end
