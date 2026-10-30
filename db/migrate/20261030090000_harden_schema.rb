class HardenSchema < ActiveRecord::Migration[7.2]
  def change
    # Booleani: NULL rompe gli scope `where(completata: false)`
    change_column_null :scadenze, :completata, false, false
    change_column_default :scadenze, :completata, from: nil, to: false
    change_column_null :attivita, :completata, false, false
    change_column_default :attivita, :completata, from: nil, to: false

    # Il controller permetteva :note ma la colonna non esisteva
    add_column :attivita, :note, :text

    # Importi monetari con precisione fissa
    change_column :rendiconti, :importo_entrate, :decimal, precision: 12, scale: 2
    change_column :rendiconti, :importo_uscite, :decimal, precision: 12, scale: 2

    change_column_default :procedimenti, :stato, from: nil, to: "attivo"
    change_column_default :rendiconti, :stato, from: nil, to: "bozza"

    # Indici per le query di dashboard/scadenzario
    add_index :scadenze, [ :completata, :data_scadenza ]
    add_index :udienze, :data_udienza
    add_index :procedimenti, :stato
    add_index :rendiconti, [ :procedimento_id, :anno ], unique: true
    add_index :beneficiari, :codice_fiscale, unique: true, where: "codice_fiscale IS NOT NULL AND codice_fiscale <> ''"
    add_index :beneficiari, [ :cognome, :nome ]
  end
end
