# Gestione Immobili (Properties Feature)

## Panoramica

La funzionalità **Immobili** è stata implementata per gestire separatamente i beni immobili dal resto del patrimonio mobiliare. Questo permette di registrare informazioni specifiche del catasto italiano e dati dettagliati sulla proprietà.

## Motivazione

In precedenza, gli immobili erano gestiti come un tipo di `Asset` (`asset_type: real_estate`). Tuttavia, gli immobili richiedono informazioni aggiuntive specifiche come:

- **Dati catastali** (foglio, particella, subalterno)
- **Categoria catastale** e classe
- **Rendita catastale**
- **Quota di proprietà** (percentuale)
- **Indirizzo completo** strutturato

Questa complessità giustifica un modello dedicato separato.

## Struttura Dati

### Modello: `Property`

#### Campi Principali

**Informazioni Generali:**
- `property_type` (enum): Tipo di immobile
  - `residential` - Residenziale (appartamento, casa)
  - `commercial` - Commerciale (negozio, ufficio)
  - `agricultural` - Agricolo (terreno agricolo, rustico)
  - `land` - Terreno edificabile
  - `industrial` - Industriale (capannone, magazzino)
  - `garage` - Box/Garage/Posto auto
  - `other` - Altro
- `description` (string, required): Descrizione dell'immobile

**Indirizzo:**
- `address` (string): Via/Piazza e numero civico
- `city` (string): Comune
- `province` (string): Sigla provincia (es. TO, MI, RM)
- `zip_code` (string): CAP

**Dati Catastali:**
- `cadastral_sheet` (string): Foglio
- `cadastral_particle` (string): Particella
- `cadastral_sub` (string): Subalterno
- `cadastral_category` (string): Categoria (es. A/2, C/6, T)
- `cadastral_class` (string): Classe
- `cadastral_consistency` (string): Consistenza (es. "5,5 vani")
- `cadastral_income` (decimal): Rendita catastale in euro

**Valore e Proprietà:**
- `ownership_percentage` (decimal): Quota di proprietà (0-100%)
- `initial_value` (decimal): Valore iniziale in euro
- `current_value` (decimal): Valore attuale in euro
- `valuation_date` (date): Data di valutazione
- `notes` (text): Note aggiuntive

#### Metodi Helper

```ruby
# Indirizzo completo formattato
property.full_address
# => "Via Po 10, 10100, Torino, TO"

# Riferimento catastale formattato
property.cadastral_reference
# => "Foglio 123, Part. 456, Sub 12"

# Classificazione catastale formattata
property.cadastral_classification
# => "Cat. A/2, Cl. 3, Cons. 5,5 vani"

# Valore della quota di proprietà
property.owned_value
# => 62500.0 (se current_value = 125000 e ownership_percentage = 50)
```

## Utilizzo

### Routes

```ruby
# Nested sotto beneficiary
beneficiary_properties_path(@beneficiary)     # GET  /beneficiaries/:id/properties
new_beneficiary_property_path(@beneficiary)   # GET  /beneficiaries/:id/properties/new

# Shallow routes per azioni singole
property_path(@property)                      # GET    /properties/:id
edit_property_path(@property)                 # GET    /properties/:id/edit
# PATCH/PUT /properties/:id
# DELETE     /properties/:id
```

### Controller

Il `PropertiesController` segue lo stesso pattern degli altri controller nested:

- Verifica autenticazione utente
- Accesso limitato ai beneficiari dell'utente corrente
- CRUD completo con validazioni

### Views

**Index** (`/beneficiaries/:id/properties`):
- Tabella riepilogativa con tutti gli immobili
- Card riassuntive: numero immobili, valore totale, valore quote di proprietà
- Colonne: tipo, descrizione, indirizzo, dati catastali, rendita, quota %, valore

**Show** (`/properties/:id`):
- Dettaglio completo dell'immobile
- Sezioni: Informazioni Generali, Indirizzo, Dati Catastali, Valore e Proprietà
- Visualizzazione formattata di tutti i campi

**New/Edit**:
- Form organizzato in 4 sezioni:
  1. Informazioni Generali (tipo, descrizione)
  2. Indirizzo (via, comune, provincia, CAP)
  3. Dati Catastali (tutti i campi catastali)
  4. Valore e Proprietà (quota %, valori, date)

### Tab nel Beneficiario

Nella vista `beneficiaries#show`, è stato aggiunto un nuovo tab **"Immobili"** dopo il tab "Patrimonio" (Assets):

```erb
<button data-tab="properties" ...>
  Immobili (<%= @properties.count %>)
</button>
```

Il pannello mostra:
- Totale valore immobili
- Tabella con tutti gli immobili del beneficiario
- Link per creare nuovo immobile

## Generazione PDF

Il servizio `AssetPdfGenerator` è stato aggiornato per includere una nuova sezione **IMMOBILI** nel PDF dell'inventario patrimoniale.

### Contenuto Sezione Immobili

Tabella con colonne:
- **Tipo**: Tipo di immobile
- **Descrizione**: Descrizione breve
- **Indirizzo**: Comune (Provincia)
- **Dati Catastali**: F., P., S., Cat. (formato compatto)
- **Rendita Cat.**: Rendita catastale in euro
- **Quota %**: Percentuale di proprietà
- **Valore**: Valore attuale in euro

### Riepilogo Finale Aggiornato

Il riepilogo finale del PDF ora include:

```
TOTALE ATTIVITÀ (Beni Mobili)    XX.XXX,XX €
TOTALE IMMOBILI                  XX.XXX,XX €
─────────────────────────────────────────────
TOTALE PATRIMONIO               XXX.XXX,XX €
TOTALE PASSIVITÀ                 XX.XXX,XX €
─────────────────────────────────────────────
PATRIMONIO NETTO                XXX.XXX,XX €
```

## Metodi Beneficiary Aggiornati

```ruby
# Valore totale immobili
beneficiary.total_properties_value
# => somma di tutti i current_value degli immobili

# Valore totale quote di proprietà
beneficiary.total_owned_properties_value
# => somma di owned_value di ogni immobile

# Patrimonio totale (mobiliare + immobiliare)
beneficiary.total_patrimony
# => total_assets + total_properties_value

# Patrimonio netto (aggiornato)
beneficiary.net_worth
# => total_patrimony - total_liabilities
```

## Validazioni

- `property_type`: obbligatorio
- `description`: obbligatorio
- `ownership_percentage`: deve essere tra 0 e 100 (se presente)
- `cadastral_income`: deve essere >= 0 (se presente)
- `current_value`: deve essere >= 0 (se presente)
- `initial_value`: deve essere >= 0 (se presente)

## Esempio Dati

```ruby
beneficiary.properties.create!(
  property_type: :residential,
  description: 'Appartamento Via Po 10, Torino',
  address: 'Via Po 10',
  city: 'Torino',
  province: 'TO',
  zip_code: '10100',
  cadastral_sheet: '123',
  cadastral_particle: '456',
  cadastral_sub: '12',
  cadastral_category: 'A/2',
  cadastral_class: '3',
  cadastral_consistency: '5,5 vani',
  cadastral_income: 650.00,
  ownership_percentage: 100.00,
  initial_value: 120_000,
  current_value: 125_000,
  valuation_date: Date.today,
  notes: 'Abitazione principale del beneficiario.'
)
```

## Migrazione da Assets

Se hai immobili già registrati come `Asset` con `asset_type: :real_estate`, puoi migrarli al nuovo modello con:

```ruby
Asset.where(asset_type: :real_estate).find_each do |asset|
  Property.create!(
    beneficiary: asset.beneficiary,
    property_type: :residential, # o altro tipo appropriato
    description: asset.description,
    current_value: asset.current_value,
    initial_value: asset.initial_value,
    valuation_date: asset.valuation_date,
    notes: asset.notes
    # Completare manualmente i dati catastali
  )
end
```

## Testing

```ruby
# spec/models/property_spec.rb
RSpec.describe Property, type: :model do
  it { should belong_to(:beneficiary) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:property_type) }
  # ... altre validazioni
end

# spec/controllers/properties_controller_spec.rb
# spec/views/properties/...
```

## Note Tecniche

- **Database**: Tabella `properties` creata con migration `20260408104114_create_properties.rb`
- **Association**: `has_many :properties` su `Beneficiary` con `dependent: :destroy`
- **Scope**: `ordered` (ordina per `created_at DESC`)
- **I18n**: Utilizzare chiavi `activerecord.attributes.property.*` per localizzazione

## Future Enhancements

Possibili miglioramenti futuri:

1. **Upload documenti catastali**: Allegare visure, planimetrie, atti di proprietà
2. **Storico valori**: Tracciare l'evoluzione del valore dell'immobile nel tempo
3. **IMU/TASI calculator**: Calcolo automatico imposte in base a rendita catastale
4. **Mappa**: Integrazione con Google Maps per visualizzare posizione
5. **Comproprietari**: Gestire dettagli di altri comproprietari
6. **Ipoteche**: Collegare eventuali mutui ipotecari (liabilities) agli immobili

---

**Versione**: 1.0  
**Data**: Aprile 2026  
**Autore**: Francesco / AI Assistant