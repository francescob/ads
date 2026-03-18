# ADS - Amministrazione di Sostegno

A Ruby on Rails 7.2 application for managing Italian legal guardianship cases (*Amministrazione di Sostegno*).

## Features

- **Beneficiari** (Beneficiaries): Manage protected persons with personal details
- **Procedimenti** (Proceedings): Track court cases per beneficiary (tribunal, judge, status)
- **Udienze** (Hearings): Schedule and record court hearings
- **Scadenze** (Deadlines): Track upcoming and overdue deadlines with alerts
- **Rendiconti** (Financial Reports): Manage annual financial accountings
- **Attività** (Activities): Log legal, medical, financial, and personal activities

## Requirements

- Ruby 3.2+
- Rails 7.2
- SQLite3

## Setup

```bash
bundle install
rails db:migrate
rails db:seed        # Load sample data
rails tailwindcss:build
rails server
```

## Development

```bash
bin/dev              # Starts server with Tailwind watcher
```

## Tech Stack

- Rails 7.2 with Hotwire (Turbo + Stimulus)
- Tailwind CSS v4
- SQLite3
- Importmap
