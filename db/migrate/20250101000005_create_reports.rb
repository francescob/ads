class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true

      t.integer :reference_year, null: false
      t.date :period_from, null: false
      t.date :period_to, null: false
      t.integer :status, default: 0, null: false
      t.date :filing_date
      t.text :court_notes

      t.timestamps
    end

    add_index :reports, [:beneficiary_id, :reference_year]
  end
end