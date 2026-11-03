class CreateSignatures < ActiveRecord::Migration[8.1]
  def change
    create_table :signatures do |t|
      t.references :signable, polymorphic: true, null: false, index: { unique: true } # one signed version per record
      t.references :uploaded_by, foreign_key: { to_table: :users }
      t.string :format
      t.integer :status, null: false, default: 0
      t.string :signer_name
      t.string :signer_tax_code
      t.string :issuer
      t.string :certificate_serial
      t.datetime :certificate_valid_until
      t.datetime :signed_at
      t.boolean :timestamped, null: false, default: false
      t.boolean :qualified, null: false, default: false
      t.boolean :matches_original
      t.json :details, null: false, default: {}
      t.datetime :verified_at
      t.timestamps
    end

    add_column :reports, :generated_pdf_digest, :string
  end
end
