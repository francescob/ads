# App Specs — Guardianship Management (Amministrazione di Sostegno)

> **Convention**: all file names, model names, column names, routes and code identifiers are in **English**.
> Italian is used only for UI labels, translations (`config/locales/it.yml`) and user-facing content.

---

## Tech Stack

- **Backend**: Ruby on Rails 8.0
- **Database**: SQLite 3
- **CSS**: Tailwind CSS 3.x
- **Frontend**: Hotwire (Turbo + Stimulus) via `importmap-rails`
- **Auth**: Devise
- **PDF**: Prawn + prawn-table
- **Background jobs**: solid_queue (with built-in recurring jobs)
- **Test**: RSpec + FactoryBot

---

## 1. Overview

Multi-user web application for guardians (professionals or private individuals) managing one or more protected persons (*beneficiaries*). The app covers the full lifecycle: from court appointment through closure, automating deadlines, financial reports, documents and communications.

---

## 2. Data Model (ActiveRecord Schema)

### `users`
```
id
email, encrypted_password
first_name, last_name, tax_code
address, phone
role              enum: user / admin
account_type      enum: private / professional / organization
timestamps
```

### `beneficiaries`
```
id
user_id           FK → users

first_name, last_name, tax_code
date_of_birth, place_of_birth
gender            enum: male / female

street_address, city, province, zip_code
health_condition  text
diagnosis         text
referring_doctor, doctor_contact
notes             text
status            enum: active / suspended / closed
timestamps
```

### `contacts`  *(parenti / referenti del beneficiario)*
```
id
beneficiary_id    FK → beneficiaries

first_name, last_name
relationship      string   (es. "figlia", "fratello")
phone, email, notes
timestamps
```

### `appointments`  *(decreti di nomina)*
```
id
beneficiary_id    FK → beneficiaries

decree_number, decree_date
court, court_section
judge
appointment_date, mandate_expiry_date
appointment_type  enum: provisional / definitive / urgent

financial_powers  text
personal_powers   text
ordinary_expense_limit     decimal
extraordinary_expense_limit decimal

document          attachment  (Active Storage)
notes             text
timestamps
```

### `reports`  *(rendiconti periodici)*
```
id
beneficiary_id    FK → beneficiaries
appointment_id    FK → appointments

reference_year    integer
period_from       date
period_to         date
status            enum: draft / completed / filed / approved
filing_date       date
court_notes       text
generated_pdf     attachment
timestamps
```

### `income_entries`  *(voci di entrata)*
```
id
report_id         FK → reports

entry_date        date
description       string
amount            decimal
category          enum: pension / allowance / annuity / other
source            string
timestamps
```

### `expense_entries`  *(voci di uscita)*
```
id
report_id         FK → reports

entry_date        date
description       string
amount            decimal
category          enum: medical / food / housing / clothing /
                        taxes / ordinary / extraordinary / other
supplier          string
receipt_number    string
receipt_file      attachment
timestamps
```

### `assets`  *(beni patrimoniali)*
```
id
beneficiary_id    FK → beneficiaries

asset_type        enum: bank_account / real_estate / vehicle /
                        securities / cash / other
description       string
institution_or_location string
initial_value     decimal
current_value     decimal
valuation_date    date
notes             text
timestamps
```

### `deadlines`  *(scadenze)*
```
id
beneficiary_id    FK → beneficiaries

title             string
description       text
due_date          date
reminder_date     date
deadline_type     enum: report / hearing / renewal /
                        administrative / medical / other
status            enum: open / completed / overdue
priority          enum: high / medium / low
timestamps
```

### `hearings`  *(udienze)*
```
id
beneficiary_id    FK → beneficiaries
appointment_id    FK → appointments

hearing_date      datetime
court, courtroom
subject           string
outcome           text
next_hearing_date date
notes             text
timestamps
```

### `documents`
```
id
beneficiary_id    FK → beneficiaries

title             string
document_type     enum: identity / medical / legal /
                        financial / correspondence / other
file              attachment
document_date     date
expiry_date       date
notes             text
timestamps
```

### `communications`
```
id
beneficiary_id    FK → beneficiaries

subject           string
body              text
counterpart       string   (mittente o destinatario)
channel           enum: pec / email / registered_mail / fax
sent_at           date
status            enum: draft / sent / received
attachment        attachment
timestamps
```

---

## 3. Features by Module

### 3.1 Authentication & Profile
- Registration / login with Devise (email + password)
- User profile with personal data and signature image upload
- Password change, account deletion
- Roles: `admin` (superadmin), `user`

### 3.2 Dashboard
- KPI summary: active beneficiaries, upcoming deadlines (7 / 30 days), draft reports
- Monthly deadline calendar widget
- Recent activity log
- Visual alerts for critical deadlines and overdue reports
- Quick-access shortcuts to most-used sections

### 3.3 Beneficiaries
- Full CRUD with validations
- Detail view with tabs: Profile | Appointments | Reports | Assets | Documents | Deadlines | Hearings | Communications
- Archive (status change: active → closed)
- Search & filter by name, tax code, status, court (Ransack)

### 3.4 Appointments *(decreti)*
- Full form with all legal fields
- PDF upload (Active Storage)
- Mandate expiry tracking with automatic alert deadline creation
- History of appointments per beneficiary

### 3.5 Reports *(rendiconti)* — core module
- Create report for a period (annual / semi-annual)
- Inline add/edit of income and expense entries
- Receipt/justification upload per expense entry
- Auto-calculated: opening balance, total income, total expenses, closing balance
- Consistency check: opening balance = previous report's closing balance
- **PDF generation** formatted for court submission (Prawn)
- Status workflow: draft → completed → filed → approved
- Year-over-year comparison view

### 3.6 Assets *(patrimonio)*
- Asset inventory (accounts, real estate, vehicles, securities)
- Value updates over time with history
- Net asset total calculation
- PDF asset inventory export

### 3.7 Deadlines & Calendar
- Monthly / weekly calendar view (Stimulus controller)
- Manual and automatic deadline creation (e.g. annual report — generated from appointment)
- Email reminders N days before due date (background job)
- Color-coded priority: high=red, medium=orange, low=green
- Mark as completed

### 3.8 Hearings
- Hearing register with outcome and link to appointment
- Pre-hearing email reminder
- Notes and next scheduled hearing

### 3.9 Documents
- Document repository per beneficiary, categorized
- Alerts for expiring documents (e.g. ID card)
- Single download and multi-file ZIP

### 3.10 Communications
- Correspondence log (PEC, email, registered mail)
- Draft templates
- Delivery receipt upload

### 3.11 Reporting & Export
- CSV export of income/expenses by period
- Beneficiary profile sheet in PDF
- Asset report in PDF
- Annual statistics by category (bar chart via Stimulus + CSS)

---

## 4. UI / UX

### Layout
- Fixed **left sidebar** with main navigation and logo
- **Topbar** with breadcrumb, notification badge, user avatar dropdown
- **Content area** with contextual action buttons (top-right)
- Style: professional and sober — Tailwind `slate` / `zinc` neutrals with `blue-700` institutional accent
- Fully **responsive** (collapsible sidebar on mobile)

### Tailwind Components
- Status badges: draft=gray, completed=blue, filed=indigo, approved=green, overdue=red
- Striped tables with hover states and sortable columns
- Modals for delete confirmation and quick forms (`<dialog>` + Turbo Frame)
- Tab navigation on beneficiary detail view
- Report completion progress indicator
- Toast notifications (Turbo Stream) for CRUD feedback
- 3-step stepper for guided report creation: Info → Entries → Summary

### Hotwire Interactivity
- In-place status updates without page reload (Turbo Streams)
- Inline append form for income/expense entries inside report page (Turbo Frame)
- Live beneficiary search with debounce (Stimulus)
- Report totals updated in real-time on each entry save (Turbo Stream targeting `#report-summary`)

---

## 5. Folder Structure

```
app/
  controllers/
    application_controller.rb
    dashboard_controller.rb
    beneficiaries_controller.rb
    appointments_controller.rb
    reports_controller.rb
    income_entries_controller.rb
    expense_entries_controller.rb
    assets_controller.rb
    deadlines_controller.rb
    hearings_controller.rb
    documents_controller.rb
    communications_controller.rb
    contacts_controller.rb
    exports_controller.rb

  models/
    user.rb
    beneficiary.rb
    appointment.rb
    report.rb
    income_entry.rb
    expense_entry.rb
    asset.rb
    deadline.rb
    hearing.rb
    document.rb
    communication.rb
    contact.rb

  views/
    layouts/
      application.html.erb
    shared/
      _sidebar.html.erb
      _topbar.html.erb
      _flash.html.erb
      _empty_state.html.erb
      _breadcrumb.html.erb
    dashboard/
      index.html.erb
    beneficiaries/
      index.html.erb
      show.html.erb         # tabbed detail view
      new.html.erb
      edit.html.erb
      _form.html.erb
    reports/
      show.html.erb         # inline entry forms
      _summary.html.erb     # Turbo Frame: totals
      _income_form.html.erb
      _expense_form.html.erb
    deadlines/
      index.html.erb        # global calendar view
      calendar.html.erb
    ...

  jobs/
    deadline_reminder_job.rb
    hearing_reminder_job.rb
    generate_report_pdf_job.rb

  mailers/
    deadline_mailer.rb
    hearing_mailer.rb

  services/
    report_pdf_generator.rb
    asset_pdf_generator.rb
    asset_calculator.rb

  javascript/
    controllers/
      tabs_controller.js
      search_controller.js
      confirm_controller.js
      calendar_controller.js
      inline_form_controller.js
```

---

## 6. Routes

```ruby
Rails.application.routes.draw do
  devise_for :users

  root to: 'dashboard#index'

  resources :beneficiaries do
    resources :appointments,   shallow: true
    resources :reports,        shallow: true do
      resources :income_entries,  shallow: true
      resources :expense_entries, shallow: true
      member do
        post  :generate_pdf
        patch :update_status
      end
    end
    resources :assets,         shallow: true
    resources :deadlines,      shallow: true
    resources :hearings,       shallow: true
    resources :documents,      shallow: true
    resources :communications, shallow: true
    resources :contacts,       shallow: true
  end

  resources :deadlines, only: [:index]  # global view across all beneficiaries

  get  'calendar',        to: 'deadlines#calendar'

  namespace :exports do
    get :report_pdf,    defaults: { format: :pdf }
    get :asset_pdf,     defaults: { format: :pdf }
    get :entries_csv,   defaults: { format: :csv }
  end
end
```

---

## 7. Critical Business Logic

### Report balance calculation (`Report` model)
```ruby
def opening_balance
  previous = beneficiary.reports
                         .where('period_to < ?', period_from)
                         .order(period_to: :desc)
                         .first
  previous&.closing_balance || 0
end

def total_income
  income_entries.sum(:amount)
end

def total_expenses
  expense_entries.sum(:amount)
end

def closing_balance
  opening_balance + total_income - total_expenses
end
```

### Auto-create annual report deadlines on appointment creation
```ruby
# app/models/appointment.rb
after_create :create_annual_report_deadlines

private

def create_annual_report_deadlines
  return unless appointment_date && mandate_expiry_date

  (appointment_date.year...mandate_expiry_date.year).each do |year|
    beneficiary.deadlines.create!(
      title:          "Annual report #{year}",
      description:    "Report for year #{year} — to be filed at #{court}",
      due_date:       Date.new(year + 1, 3, 31),
      reminder_date:  Date.new(year + 1, 2, 1),
      deadline_type:  :report,
      status:         :open,
      priority:       :high
    )
  end
end
```

### Extraordinary expense limit validation (`ExpenseEntry` model)
```ruby
validate :within_extraordinary_limit, if: -> { category == 'extraordinary' }

private

def within_extraordinary_limit
  limit = report.beneficiary
                .appointments
                .order(appointment_date: :desc)
                .first
                &.extraordinary_expense_limit
  return unless limit

  if amount > limit
    errors.add(:amount,
      "exceeds the extraordinary expense limit (#{limit} €) " \
      "set by appointment decree")
  end
end
```

### Daily reminder job (scheduled with solid_queue recurring jobs)

```ruby
# app/jobs/deadline_reminder_job.rb
class DeadlineReminderJob < ApplicationJob
  queue_as :default

  def perform
    Deadline.open.where(reminder_date: Date.today)
            .includes(beneficiary: :user)
            .each { |d| DeadlineMailer.reminder(d).deliver_later }

    Deadline.open.where('due_date < ?', Date.today)
            .update_all(status: :overdue)
  end
end
```

Scheduling is handled natively by solid_queue via `config/recurring.yml` — no external gem needed:

```yaml
# config/recurring.yml
deadline_reminders:
  class: DeadlineReminderJob
  schedule: every day at 8am
  queue: default

hearing_reminders:
  class: HearingReminderJob
  schedule: every day at 8am
  queue: default
```

solid_queue picks up this file automatically when configured as the Active Job adapter. Enable it in `config/application.rb`:

```ruby
config.active_job.queue_adapter = :solid_queue
```

And ensure the solid_queue process is started alongside the Rails server (e.g. via `Procfile.dev`):

```
web:     bin/rails server
worker:  bin/jobs start
```

---

## 8. Report PDF Structure (`ReportPdfGenerator` service)

Generate with `Prawn` + `prawn-table`. Sections in order:

1. **Header** — guardian name, tax code, address, PEC
2. **Beneficiary data** — name, tax code, date of birth
3. **Appointment details** — decree number, date, court, judge
4. **Report period** — from / to
5. **Income table** — columns: Date | Description | Category | Source | Amount
6. **Income subtotal** (bold)
7. **Expense table** — columns: Date | Description | Category | Supplier | Receipt No. | Amount
8. **Expense subtotal** (bold)
9. **Financial summary** — Opening balance | + Income | − Expenses | = **Closing balance**
10. **Asset snapshot** — inventory at period close date
11. **Declaration** — standard legal statement
12. **Signature block** — place, date, signature line
13. **Exhibit index** — numbered list of attached receipts

---

## 9. Model Scopes

```ruby
# app/models/deadline.rb
scope :open,      -> { where(status: :open) }
scope :overdue,   -> { where(status: :overdue) }
scope :upcoming,  -> { open.where(due_date: Date.today..7.days.from_now) }
scope :by_priority, -> { order(priority: :asc) }  # high < medium < low

# app/models/beneficiary.rb
scope :active,    -> { where(status: :active) }
scope :closed,    -> { where(status: :closed) }
scope :search_by_name, ->(q) { where('first_name ILIKE ? OR last_name ILIKE ?', "%#{q}%", "%#{q}%") }

# app/models/report.rb
scope :drafts,    -> { where(status: :draft) }
scope :for_year,  ->(year) { where(reference_year: year) }
```

---

## 10. Gemfile

```ruby
source 'https://rubygems.org'
ruby '3.3.x'

gem 'rails',             '~> 8.0'
gem 'sqlite3',           '~> 1.4'
gem 'puma',              '>= 5.0'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'image_processing',  '~> 1.2'

# Auth
gem 'devise'
gem 'rails-i18n'

# PDF
gem 'prawn'
gem 'prawn-table'

# Jobs & scheduling
gem 'solid_queue'

# Pagination & search
gem 'kaminari'
gem 'ransack'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
end

group :development do
  gem 'web-console'
end
```

### Rails 8 defaults — what you get for free

When generating the app with `rails new guardianship_app --css tailwind --database sqlite3`, Rails 8 already sets up the following out of the box — **do not add these manually to the Gemfile**:

| Built-in | Notes |
|---|---|
| `solid_queue` | Default Active Job adapter; just configure `config/recurring.yml` |
| `solid_cache` | Default cache store backed by SQLite |
| `turbo-rails` | Included via Hotwire by default |
| `stimulus-rails` | Included via Hotwire by default |
| `importmap-rails` | Default JS bundling strategy |
| `tailwindcss-rails` | Included when passing `--css tailwind` |
| `propshaft` | Default asset pipeline (replaces Sprockets) |
| `kamal` | Deployment tooling (can be ignored for local dev) |
| `thruster` | HTTP asset caching proxy (can be ignored for local dev) |

The gems you **do** still need to add explicitly are: `devise`, `rails-i18n`, `prawn`, `prawn-table`, `kaminari`, `ransack`, `image_processing`, and the test group gems.

---

## 11. i18n Setup

- Default locale: `it` — `config.i18n.default_locale = :it`
- Date format: `dd/mm/yyyy` — configure in `config/initializers/formats.rb`
- Currency: `number_to_currency(amount, unit: '€', separator: ',', delimiter: '.')`
- All UI strings, enum labels, validation messages and mailer subjects in `config/locales/it.yml`
- Use `rails-i18n` gem for Rails / Devise base translations

---

## 12. Seeds (`db/seeds.rb`)

```ruby
user = User.create!(
  email:        'demo@example.com',
  password:     'password123',
  first_name:   'Mario',
  last_name:    'Rossi',
  tax_code:     'RSSMRA80A01L219K',
  address:      'Via Roma 1, Torino',
  phone:        '0112345678',
  account_type: :professional,
  role:         :user
)

beneficiary = user.beneficiaries.create!(
  first_name:       'Giovanni',
  last_name:        'Bianchi',
  tax_code:         'BNCGNN45B10F205X',
  date_of_birth:    Date.new(1945, 2, 10),
  place_of_birth:   'Torino',
  gender:           :male,
  street_address:   'Via Po 10',
  city:             'Torino',
  province:         'TO',
  zip_code:         '10100',
  health_condition: 'Mild cognitive decline (diagnosed 2022)',
  status:           :active
)

appointment = beneficiary.appointments.create!(
  decree_number:                '123/2023',
  decree_date:                  Date.new(2023, 3, 15),
  court:                        'Tribunale di Torino',
  court_section:                'Prima Civile',
  judge:                        'Dott.ssa Verdi',
  appointment_date:             Date.new(2023, 3, 20),
  mandate_expiry_date:          Date.new(2026, 3, 20),
  appointment_type:             :definitive,
  financial_powers:             'Ordinary account management. Extraordinary expenses require court authorisation.',
  personal_powers:              'Healthcare representation.',
  ordinary_expense_limit:       2_000.00,
  extraordinary_expense_limit:  5_000.00
)

report = beneficiary.reports.create!(
  appointment:    appointment,
  reference_year: 2023,
  period_from:    Date.new(2023, 3, 20),
  period_to:      Date.new(2023, 12, 31),
  status:         :draft
)

report.income_entries.create!([
  { entry_date: Date.new(2023, 4, 1),  description: 'INPS pension – April', amount: 1_200.00, category: :pension,   source: 'INPS' },
  { entry_date: Date.new(2023, 5, 1),  description: 'INPS pension – May',   amount: 1_200.00, category: :pension,   source: 'INPS' }
])

report.expense_entries.create!([
  { entry_date: Date.new(2023, 4, 10), description: 'Medicines – April', amount: 150.00, category: :medical,  supplier: 'Farmacia S. Anna' },
  { entry_date: Date.new(2023, 4, 30), description: 'Rent',             amount: 600.00, category: :housing,  supplier: 'Immobiliare Torino Srl' }
])

puts 'Seed done. Login: demo@example.com / password123'
```

---

## 13. Implementation Checklist for Copilot

1. Generate migrations **in FK order**: users → beneficiaries → appointments → reports → income_entries / expense_entries
2. Use Rails `enum` for all fixed-value fields; prefix with model name to avoid clashes (e.g. `enum status: { active: 0, ... }`)
3. Configure Active Storage with MIME type validation (PDF + images only for receipts)
4. Use `turbo_frame_tag` for inline entry forms inside the report show page
5. Broadcast `turbo_stream` targeting `#report-summary` after every `IncomeEntry` / `ExpenseEntry` create/update/destroy
6. One Stimulus controller per file (`tabs_controller.js`, `search_controller.js`, etc.)
7. `before_action :authenticate_user!` on all application controllers
8. **Always scope data to current user**: start every query from `current_user.beneficiaries` or nested associations — never query a model directly
9. Dynamic breadcrumb helper: `Beneficiary > Report > Entry`
10. PDF generation runs in a background job (`GenerateReportPdfJob`); the report show page polls every 3s via Turbo to reveal the download link once the attachment is ready
11. Configure recurring jobs in `config/recurring.yml` (solid_queue native scheduler): `DeadlineReminderJob` and `HearingReminderJob` daily at 08:00. Start the worker process via `bin/jobs start` (add to `Procfile.dev`).
12. Add model scopes: `Deadline.open`, `.overdue`, `.upcoming`; `Beneficiary.active`; `Report.drafts`
