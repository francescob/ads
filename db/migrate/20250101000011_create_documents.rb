class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :beneficiary, null: false, foreign_key: true

      t.string :title, null: false
      t.integer :document_type, default: 0, null: false
      t.date :document_date
      t.date :expiry_date
      t.text :notes

      t.timestamps
    end
  end
end