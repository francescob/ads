class CreateHearings < ActiveRecord::Migration[8.0]
  def change
    create_table :hearings do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.references :appointment, foreign_key: true

      t.datetime :hearing_date, null: false
      t.string :court
      t.string :courtroom
      t.string :subject
      t.text :outcome
      t.date :next_hearing_date
      t.text :notes

      t.timestamps
    end
  end
end