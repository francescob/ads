# ADS - Amministrazione di Sostegno

A Ruby on Rails 8.1 application for managing Italian legal guardianship cases (*Amministrazione di Sostegno*).

## Features

- **Beneficiari** (Beneficiaries): Manage protected persons with personal details
- **Procedimenti** (Proceedings): Track court cases per beneficiary (tribunal, judge, status)
- **Udienze** (Hearings): Schedule and record court hearings
- **Scadenze** (Deadlines): Track upcoming and overdue deadlines with alerts
- **Rendiconti** (Financial Reports): Manage annual financial accountings
- **Attività** (Activities): Log legal, medical, financial, and personal activities
- **Istanze** (Petitions): Requests to the giudice tutelare with status and outcome
- **Documenti**: Uploaded files per proceeding, downloadable only after login
- **Contatti**: Network of family, social services, doctors, bank for each beneficiary
- **Conti e movimenti**: Accounts, balances at any date, income/expense entries, CSV export
- **Rendiconto stampabile**: Annual statement computed from movements, print/PDF from the browser
- **Promemoria**: Daily email digest, recurring deadlines, personal iCal feed
- **Utenti e registro**: Login, admin/operatore roles, audit log of every change, global search

## Requirements

- Ruby 4.0
- Rails 8.1
- SQLite3

## Setup

```bash
bundle install
rails db:migrate
rails db:seed        # Sample data + admin user (ADMIN_EMAIL / ADMIN_PASSWORD,
                     # default admin@example.com / cambiami-subito)
rails tailwindcss:build
rails server
```

## Development

```bash
bin/dev              # Starts server with Tailwind watcher
bin/rails test       # Test suite
bin/rubocop          # Lint
bin/brakeman         # Security scan
```

`config/master.key` is not versioned: generate your own with
`EDITOR=true bin/rails credentials:edit` (or set `RAILS_MASTER_KEY`).

## Tech Stack

- Rails 8.1 with Hotwire (Turbo + Stimulus), Propshaft
- Tailwind CSS v4
- SQLite3
- Importmap

## Promemoria email

Schedule the daily digest with cron (or any scheduler):

```cron
0 7 * * * cd /app && bin/rails ads:promemoria
```

Production environment variables: `APP_HOST`, `MAIL_FROM`, `SMTP_ADDRESS`,
`SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`.
