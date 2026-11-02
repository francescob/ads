# Sistema di Notifiche In-App

## Panoramica

Il sistema di notifiche in-app utilizza la gemma **[Noticed](https://github.com/excid3/noticed)** per gestire notifiche persistenti e real-time. Le notifiche vengono mostrate come "toast" temporanei tramite **Turbo Streams** e salvate nel database per consultazione successiva.

## Caratteristiche

- ✅ **Notifiche real-time** via Turbo Streams
- ✅ **Toast animati** con auto-dismiss
- ✅ **Persistenza** nel database
- ✅ **Badge contatore** nella topbar
- ✅ **Pagina notifiche** con storico completo
- ✅ **Stato letto/non letto**
- ✅ **Link diretti** alle risorse correlate

## Architettura

### Componenti Principali

```
┌─────────────────────────────────────────────────────────────┐
│                      Background Job                          │
│              (GenerateAssetPdfJob, ecc.)                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  PdfGeneratedNotifier                        │
│         (Notifier class con delivery methods)                │
└────────────┬────────────────────┬───────────────────────────┘
             │                    │
             ▼                    ▼
    ┌────────────────┐   ┌───────────────────┐
    │   Database     │   │  Turbo Stream     │
    │   (Persistenza)│   │  (Real-time UI)   │
    └────────────────┘   └───────────────────┘
             │                    │
             ▼                    ▼
    ┌────────────────┐   ┌───────────────────┐
    │ Notifications  │   │  Toast Popup      │
    │     Page       │   │  (Auto-dismiss)   │
    └────────────────┘   └───────────────────┘
```

### File Struttura

```
app/
├── notifiers/
│   ├── application_notifier.rb           # Base notifier
│   ├── pdf_generated_notifier.rb         # Notifica PDF generato
│   └── delivery_methods/
│       └── turbo_stream.rb               # Custom delivery method
├── controllers/
│   └── notifications_controller.rb       # Gestione notifiche
├── views/
│   ├── notifications/
│   │   ├── index.html.erb                # Lista notifiche
│   │   └── _toast.html.erb               # Template toast
│   └── layouts/
│       └── application.html.erb          # Turbo Stream subscriber
└── javascript/
    └── controllers/
        └── notification_controller.js    # Stimulus per animazioni

config/
└── initializers/
    └── noticed.rb                        # Configurazione Noticed

db/migrate/
├── xxxxx_create_noticed_tables.rb        # Tabelle noticed
└── xxxxx_add_notifications_count_to_noticed_event.rb
```

## Utilizzo

### 1. Creare un Notifier

```ruby
# app/notifiers/my_notification_notifier.rb
class MyNotificationNotifier < ApplicationNotifier
  # Salva nel database
  deliver_by :database
  
  # Invia via Turbo Stream (toast real-time)
  deliver_by :turbo_stream do |config|
    config.channel = ->(recipient) { "notifications_#{recipient.id}" }
    config.stream = "notifications"
    config.action = :append
    config.template = "notifications/toast"
  end

  # Parametri obbligatori
  required_param :beneficiary
  required_param :action_type

  # Metodi per personalizzare la notifica
  notification_methods do
    def message
      "Il beneficiario #{params[:beneficiary].full_name} ha completato l'azione."
    end

    def title
      "Azione Completata"
    end

    def url
      Rails.application.routes.url_helpers.beneficiary_path(params[:beneficiary])
    end

    def icon
      "✅"
    end
  end
end
```

### 2. Inviare una Notifica

**Da un Job:**

```ruby
class MyBackgroundJob < ApplicationJob
  def perform(beneficiary_id, user_id)
    beneficiary = Beneficiary.find(beneficiary_id)
    user = User.find(user_id)
    
    # ... esegui il lavoro ...
    
    # Invia notifica
    MyNotificationNotifier.with(
      beneficiary: beneficiary,
      action_type: "pdf_generation"
    ).deliver(user)
  end
end
```

**Da un Controller:**

```ruby
class MyController < ApplicationController
  def some_action
    # ... esegui l'azione ...
    
    MyNotificationNotifier.with(
      beneficiary: @beneficiary,
      action_type: "status_change"
    ).deliver(current_user)
    
    redirect_to @beneficiary, notice: "Azione completata!"
  end
end
```

### 3. Mostrare le Notifiche

**Badge con contatore (già implementato in topbar):**

```erb
<% unread_count = current_user.notifications.unread.count %>
<%= link_to notifications_path do %>
  <svg><!-- bell icon --></svg>
  <% if unread_count > 0 %>
    <span class="badge"><%= unread_count %></span>
  <% end %>
<% end %>
```

**Lista notifiche:**

```ruby
# Controller
@notifications = current_user.notifications
                             .includes(:event)
                             .order(created_at: :desc)
                             .page(params[:page])
```

### 4. Gestire le Notifiche

**Segnare come letta:**

```ruby
notification = current_user.notifications.find(params[:id])
notification.mark_as_read!
```

**Segnare tutte come lette:**

```ruby
current_user.notifications.unread.mark_as_read!
```

**Eliminare:**

```ruby
notification.destroy
```

## Parametri Notifica

Ogni notifica può avere i seguenti parametri:

| Parametro | Tipo | Descrizione | Obbligatorio |
|-----------|------|-------------|--------------|
| `title` | String | Titolo della notifica | No (usa type.humanize) |
| `message` | String | Messaggio descrittivo | No |
| `url` | String | Link alla risorsa | No |
| `icon` | String | Emoji o carattere icona | No (default: 📬) |
| `notification_type` | String | Tipo: success, error, warning, info | No (default: success) |

## Toast Real-time

### Funzionalità Toast

- **Auto-dismiss**: Scompare automaticamente dopo 8 secondi
- **Pause on hover**: Si ferma quando il mouse è sopra
- **Progress bar**: Barra di avanzamento visiva
- **Animazioni**: Slide-in da destra, fade out
- **Click to dismiss**: Chiusura manuale con pulsante X
- **Link rapido**: Link "Visualizza" se c'è un URL

### Personalizzare il Toast

Modifica `app/views/notifications/_toast.html.erb`:

```erb
<%
  # Cambia colori per tipo
  colors = case notification_type
  when 'success'
    { bg: 'bg-green-50', border: 'border-green-200', ... }
  when 'error'
    { bg: 'bg-red-50', border: 'border-red-200', ... }
  # ...
  end
%>
```

Modifica durata auto-dismiss in `notification_controller.js`:

```javascript
static values = {
  autoDismiss: { type: Boolean, default: true },
  dismissAfter: { type: Number, default: 8000 }, // millisecondi
}
```

## Esempi Pratici

### Notifica PDF Generato (Esistente)

```ruby
# app/jobs/generate_asset_pdf_job.rb
PdfGeneratedNotifier.with(
  beneficiary: beneficiary,
  pdf_type: "asset_inventory"
).deliver(user)
```

### Notifica Scadenza Imminente

```ruby
# app/notifiers/deadline_reminder_notifier.rb
class DeadlineReminderNotifier < ApplicationNotifier
  deliver_by :database
  deliver_by :turbo_stream do |config|
    config.channel = ->(recipient) { "notifications_#{recipient.id}" }
    config.stream = "notifications"
    config.action = :append
    config.template = "notifications/toast"
  end

  required_param :deadline

  notification_methods do
    def message
      "La scadenza '#{params[:deadline].title}' è in scadenza il #{I18n.l(params[:deadline].due_date, format: :short)}"
    end

    def title
      "Scadenza Imminente"
    end

    def url
      Rails.application.routes.url_helpers.deadline_path(params[:deadline])
    end

    def icon
      "⏰"
    end
    
    def notification_type
      'warning'
    end
  end
end
```

### Notifica Errore

```ruby
# app/notifiers/error_notifier.rb
class ErrorNotifier < ApplicationNotifier
  deliver_by :database
  deliver_by :turbo_stream do |config|
    config.channel = ->(recipient) { "notifications_#{recipient.id}" }
    config.stream = "notifications"
    config.action = :append
    config.template = "notifications/toast"
  end

  required_param :error_message

  notification_methods do
    def message
      params[:error_message]
    end

    def title
      "Si è verificato un errore"
    end

    def icon
      "❌"
    end
    
    def notification_type
      'error'
    end
  end
end
```

## Query Utili

```ruby
# Tutte le notifiche non lette
current_user.notifications.unread

# Notifiche degli ultimi 7 giorni
current_user.notifications.where(created_at: 7.days.ago..Time.current)

# Notifiche di un certo tipo
current_user.notifications.where(type: 'PdfGeneratedNotifier')

# Conta notifiche non lette
current_user.notifications.unread.count

# Elimina notifiche vecchie (puoi usare in rake task)
Noticed::Notification.where('created_at < ?', 30.days.ago).destroy_all
```

## Testing

### RSpec Example

```ruby
# spec/notifiers/pdf_generated_notifier_spec.rb
require 'rails_helper'

RSpec.describe PdfGeneratedNotifier do
  let(:user) { create(:user) }
  let(:beneficiary) { create(:beneficiary) }

  describe '.deliver' do
    it 'creates a notification in database' do
      expect {
        described_class.with(
          beneficiary: beneficiary,
          pdf_type: 'asset_inventory'
        ).deliver(user)
      }.to change { user.notifications.count }.by(1)
    end

    it 'sets correct message' do
      described_class.with(
        beneficiary: beneficiary,
        pdf_type: 'asset_inventory'
      ).deliver(user)
      
      notification = user.notifications.last
      expect(notification.event.params[:message]).to include(beneficiary.full_name)
    end
  end
end
```

### System Test Example

```ruby
# spec/system/notifications_spec.rb
require 'rails_helper'

RSpec.describe 'Notifications', type: :system do
  let(:user) { create(:user) }
  
  before { sign_in user }

  it 'shows toast notification when PDF is generated' do
    beneficiary = create(:beneficiary, user: user)
    
    visit beneficiary_path(beneficiary)
    click_button 'Genera PDF'
    
    # Simula completamento job (in test usa perform_now invece di perform_later)
    GenerateAssetPdfJob.perform_now(beneficiary.id, user.id)
    
    expect(page).to have_css('[data-controller="notification"]')
    expect(page).to have_content('Inventario Patrimoniale Generato')
  end
end
```

## Troubleshooting

### Le notifiche toast non appaiono

**Problema**: I toast non vengono mostrati in tempo reale.

**Soluzioni**:
1. Verifica che Turbo Streams sia abilitato nel layout:
   ```erb
   <%= turbo_stream_from "notifications_#{current_user.id}" %>
   ```

2. Controlla che il custom delivery method sia caricato:
   ```bash
   rails runner "p Noticed::DeliveryMethods::TurboStream"
   ```

3. Verifica che il job includa `user_id`:
   ```ruby
   GenerateAssetPdfJob.perform_later(beneficiary.id, current_user.id)
   ```

### Le notifiche non vengono salvate nel database

**Problema**: `deliver_by :database` non funziona.

**Soluzioni**:
1. Verifica migrations:
   ```bash
   rails db:migrate:status | grep noticed
   ```

2. Controlla che il recipient sia un User:
   ```ruby
   notification.deliver(User.find(1)) # OK
   notification.deliver(@beneficiary) # NO!
   ```

### Badge contatore non si aggiorna

**Problema**: Il badge con il numero di notifiche non lette non cambia.

**Soluzione**: Aggiungi un Turbo Frame per aggiornare il badge:
```erb
<%= turbo_frame_tag "notification_badge" do %>
  <% count = current_user.notifications.unread.count %>
  <% if count > 0 %>
    <span class="badge"><%= count %></span>
  <% end %>
<% end %>
```

### Errore "undefined method 'notifications'"

**Problema**: User non ha relazione con notifications.

**Soluzione**: Assicurati che Noticed abbia aggiunto l'associazione automaticamente. Se no, aggiungi manualmente:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
end
```

## Best Practices

1. **Sempre passare user_id ai job**: I job in background hanno bisogno dell'user_id per sapere a chi inviare la notifica.

2. **Usa icon emoji**: Gli emoji sono universali e non richiedono asset aggiuntivi.

3. **Messaggi chiari**: Il messaggio deve essere auto-esplicativo senza bisogno di contesto.

4. **Link utili**: Aggiungi sempre un URL se la notifica si riferisce a una risorsa specifica.

5. **Cleanup periodico**: Crea un rake task per eliminare notifiche vecchie:
   ```ruby
   # lib/tasks/notifications.rake
   namespace :notifications do
     desc "Delete old notifications"
     task cleanup: :environment do
       Noticed::Notification.where('created_at < ?', 60.days.ago).destroy_all
     end
   end
   ```

6. **Testing**: Testa sempre che le notifiche vengano create e mostrate correttamente.

## Estensioni Future

Possibili miglioramenti:

- **Email notifications**: Aggiungere `deliver_by :email` per inviare anche via email
- **SMS notifications**: Integrare con Twilio per SMS urgenti
- **Push notifications**: Notifiche browser/mobile via web push
- **Raggruppamento**: Raggruppare notifiche simili ("3 PDF generati")
- **Preferenze utente**: Permettere all'utente di scegliere quali notifiche ricevere
- **Suoni**: Aggiungere suoni per notifiche importanti

---

**Versione**: 1.0  
**Data**: Aprile 2026  
**Autore**: Francesco / AI Assistant