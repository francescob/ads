class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.references :beneficiary, null: false, foreign_key: true

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :relationship
      t.string :phone
      t.string :email
      t.text :notes

      t.timestamps
    end
  end
end
