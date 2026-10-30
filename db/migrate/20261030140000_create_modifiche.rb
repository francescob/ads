class CreateModifiche < ActiveRecord::Migration[7.2]
  def change
    create_table :modifiche do |t|
      t.references :user, foreign_key: { on_delete: :nullify }
      t.references :beneficiario, index: true # niente FK: la traccia resta anche se il beneficiario viene eliminato
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.string :descrizione_record
      t.string :azione, null: false
      t.json :cambiamenti, null: false, default: {}
      t.datetime :created_at, null: false
    end
    add_index :modifiche, [ :record_type, :record_id ]
    add_index :modifiche, :created_at
  end
end
