class CreateRecurringExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_expenses do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.integer :expense_type
      t.string :description
      t.decimal :amount, precision: 10, scale: 2
      t.integer :frequency
      t.date :start_date
      t.date :end_date
      t.text :notes
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
