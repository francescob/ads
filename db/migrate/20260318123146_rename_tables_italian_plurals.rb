class RenameTablesItalianPlurals < ActiveRecord::Migration[7.2]
  def change
    rename_table :beneficiarios, :beneficiari
    rename_table :procedimentos, :procedimenti
    rename_table :udienzas, :udienze
    rename_table :scadenzas, :scadenze
    rename_table :rendicontos, :rendiconti
  end
end
