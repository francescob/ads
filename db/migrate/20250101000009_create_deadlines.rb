class CreateDeadlines < ActiveRecord::Migration[8.0]
  def change
    create_table :deadlines do |t|
      t.references :beneficiary, null: false, foreign_key: true

      t.string :title, null: false
      t.text :description
      t.date :due_date, null: false
      t.date :reminder_date
      t.integer :deadline_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false

      t.timestamps
    end

    add_index :deadlines, :due_date
    add_index :deadlines, :status
  end
end