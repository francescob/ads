class CreateBeneficiaries < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiaries do |t|
      t.references :user, null: false, foreign_key: true

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :tax_code
      t.date :date_of_birth
      t.string :place_of_birth
      t.integer :gender, default: 0, null: false

      t.string :street_address
      t.string :city
      t.string :province
      t.string :zip_code
      t.text :health_condition
      t.text :diagnosis
      t.string :referring_doctor
      t.string :doctor_contact
      t.text :notes
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :beneficiaries, :tax_code
    add_index :beneficiaries, :status
  end
end
