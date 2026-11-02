class CreateCommunications < ActiveRecord::Migration[8.0]
  def change
    create_table :communications do |t|
      t.references :beneficiary, null: false, foreign_key: true

      t.string :subject, null: false
      t.text :body
      t.string :counterpart
      t.integer :channel, default: 0, null: false
      t.date :sent_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
