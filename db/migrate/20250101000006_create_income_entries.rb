class CreateIncomeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :income_entries do |t|
      t.references :report, null: false, foreign_key: true

      t.date :entry_date, null: false
      t.string :description, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :category, default: 0, null: false
      t.string :source

      t.timestamps
    end
  end
end
