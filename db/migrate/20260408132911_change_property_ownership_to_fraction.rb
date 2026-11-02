class ChangePropertyOwnershipToFraction < ActiveRecord::Migration[8.1]
  def change
    # Rimuovi il campo ownership_percentage
    remove_column :properties, :ownership_percentage, :decimal, precision: 5, scale: 2
    
    # Aggiungi i campi per la frazione
    add_column :properties, :ownership_numerator, :integer
    add_column :properties, :ownership_denominator, :integer
  end
end