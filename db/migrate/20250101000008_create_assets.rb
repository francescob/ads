class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.references :beneficiary, null: false, foreign_key: true

      t.integer :asset_type, default: 0, null: false
      t.string :description, null: false
      t.string :institution_or_location
      t.decimal :initial_value, precision: 12, scale: 2
      t.decimal :current_value, precision: 12, scale: 2
      t.date :valuation_date
      t.text :notes

      t.timestamps
    end
  end
end
