class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.integer :property_type, default: 0, null: false
      t.string :description, null: false
      t.string :address
      t.string :city
      t.string :province
      t.string :zip_code
      t.string :cadastral_sheet
      t.string :cadastral_particle
      t.string :cadastral_sub
      t.string :cadastral_category
      t.string :cadastral_class
      t.string :cadastral_consistency
      t.decimal :cadastral_income, precision: 10, scale: 2
      t.decimal :ownership_percentage, precision: 5, scale: 2
      t.decimal :current_value, precision: 12, scale: 2
      t.decimal :initial_value, precision: 12, scale: 2
      t.date :valuation_date
      t.text :notes

      t.timestamps
    end
  end
end