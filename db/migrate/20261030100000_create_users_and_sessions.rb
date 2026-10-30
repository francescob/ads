class CreateUsersAndSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :nome, null: false
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :ruolo, null: false, default: "operatore"
      t.boolean :attivo, null: false, default: true
      t.timestamps
    end
    add_index :users, :email_address, unique: true

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end
  end
end
