class CreateLiabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :liabilities do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.integer :liability_type
      t.string :description
      t.string :creditor
      t.decimal :initial_amount, precision: 15, scale: 2
      t.decimal :remaining_balance, precision: 15, scale: 2
      t.decimal :interest_rate, precision: 5, scale: 2
      t.decimal :monthly_payment, precision: 10, scale: 2
      t.date :start_date
      t.date :end_date
      t.text :notes

      t.timestamps
    end
  end
end
