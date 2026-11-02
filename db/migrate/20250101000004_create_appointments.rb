class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :beneficiary, null: false, foreign_key: true

      t.string :decree_number
      t.date :decree_date
      t.string :court
      t.string :court_section
      t.string :judge
      t.date :appointment_date
      t.date :mandate_expiry_date
      t.integer :appointment_type, default: 0, null: false

      t.text :financial_powers
      t.text :personal_powers
      t.decimal :ordinary_expense_limit, precision: 12, scale: 2
      t.decimal :extraordinary_expense_limit, precision: 12, scale: 2

      t.text :notes

      t.timestamps
    end
  end
end
