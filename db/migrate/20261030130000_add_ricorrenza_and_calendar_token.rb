class AddRicorrenzaAndCalendarToken < ActiveRecord::Migration[7.2]
  def change
    add_column :scadenze, :ricorrenza, :string
    add_column :users, :calendar_token, :string
    add_column :users, :riceve_promemoria, :boolean, null: false, default: true
    add_index :users, :calendar_token, unique: true

    reversible do |dir|
      dir.up do
        User.reset_column_information
        User.find_each { |u| u.update_columns(calendar_token: SecureRandom.base58(24)) }
      end
    end
  end
end
