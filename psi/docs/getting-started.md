# Getting Started with the PSI Discourse Plugin

## Prerequisites

You need these installed on your Mac:

- **Ruby 3.4+** (via rbenv or similar)
- **Node.js 20+** (via nvm or similar)
- **pnpm 10+** (`npm install -g pnpm`)
- **PostgreSQL 13+** (via Homebrew: `brew install postgresql@15`)
- **Redis 7+** (via Homebrew: `brew install redis`)

## Step 1: Install system dependencies

```bash
# Install via Homebrew if you don't have them
brew install rbenv ruby-build postgresql@15 redis node pnpm

# Start Postgres and Redis
brew services start postgresql@15
brew services start redis
```

## Step 2: Install Ruby

```bash
# Install Ruby 3.4 (check Gemfile for exact version if needed)
rbenv install 3.4.1
rbenv local 3.4.1

# Verify
ruby --version
```

## Step 3: Install dependencies

From the repo root (`meta/plan/` — the Discourse root):

```bash
# Ruby dependencies
bundle install

# JavaScript dependencies
pnpm install
```

## Step 4: Set up the database

```bash
# Create and migrate the development database
bin/rails db:create db:migrate

# This also runs migrations for all plugins, including our PSI plugin
# (creates the psi_slider_votes table)

# Seed with sample data (admin user, categories, etc.)
bin/rails db:seed
```

## Step 5: Start the dev server

You need two terminals:

**Terminal 1 — Rails backend:**
```bash
bin/rails s
```

**Terminal 2 — Ember frontend:**
```bash
bin/ember-cli
```

The site will be available at **http://localhost:4200** (proxied through ember-cli) or **http://localhost:3000** (Rails direct).

## Step 6: Initial Discourse setup

1. Visit http://localhost:4200
2. You'll see the Discourse setup wizard on first run
3. Create your admin account
4. Complete the wizard

## Step 7: Enable and configure PSI

1. Go to **Admin > Settings** (http://localhost:4200/admin/site_settings)
2. Search for "psi"
3. Ensure **psi_enabled** is checked (should be on by default)
4. Optionally configure **psi_topic_creation_allowed_groups**

## Step 8: Set up editorial badging

1. Go to **Admin > Groups** (http://localhost:4200/admin/groups)
2. Create a group called "editorial" (or "journalists")
3. Set the group's **Title** to "Journalist" (this appears as flair text)
4. Upload a flair icon or pick an SVG icon
5. Add editorial staff users to this group
6. Set "Journalist" as their **primary group** so the flair shows on posts

## Step 9: Try the comment slider

1. Click **New Topic** (you need to be an admin)
2. Enter a question-style title (e.g., "Is Europe prepared for an aging population?")
3. Check the **Enable comment slider** checkbox below the category/tag selectors
4. Write the topic body and create it
5. Open the topic — you should see the "Slide to respond:" slider above the posts
6. Drag the slider to a position and try:
   - **"Share your thoughts..."** to open the composer and write a reply with your stance
   - **"Skip and submit vote"** to record a vote without commenting
7. After voting, the slider is replaced by the bar chart showing vote distribution

## Running Tests

### Ruby model/request specs
```bash
# All PSI specs
bin/rspec plugins/psi/spec/

# Just model specs
bin/rspec plugins/psi/spec/models/

# Just API specs
bin/rspec plugins/psi/spec/requests/

# A specific file
bin/rspec plugins/psi/spec/models/psi_slider_vote_spec.rb
```

### System tests (browser-based)
```bash
# Requires Chrome/Chromium installed
bin/rspec plugins/psi/spec/system/
```

### JavaScript tests
```bash
bin/qunit plugins/psi/test/javascripts/
```

### Linting
```bash
# Lint all PSI plugin files
bin/lint plugins/psi/
```

## Troubleshooting

### "Plugin not loading"
- Check that `plugins/psi/plugin.rb` exists and has the correct header
- Check the Rails server logs for plugin loading errors
- Try `bin/rails plugin:list` to see if "psi" appears

### "Migration error"
- Run `bin/rails db:migrate` to ensure the `psi_slider_votes` table is created
- Check `bin/rails db:migrate:status` for pending migrations

### "Slider not showing on topic"
- Verify `psi_enabled` is true in Admin > Settings
- Verify the topic has `psi_slider_enabled` custom field set to true
- Check browser console for JavaScript errors

### "Can't create topics"
- Check `psi_topic_creation_allowed_groups` setting — by default only staff/admins can create topics
- Make sure your user is in one of the allowed groups

## File Structure

```
plugins/psi/
├── plugin.rb                      # Main plugin — hooks, serializers, validators
├── config/
│   ├── routes.rb                  # API routes (PUT/DELETE/GET /psi/vote)
│   ├── settings.yml               # Site settings (psi_enabled, allowed groups)
│   └── locales/                   # English translations
├── app/
│   ├── models/psi_slider_vote.rb  # Vote model (position 1-5, topic, user, post)
│   ├── controllers/psi/           # Slider API controller
│   └── serializers/               # Vote serializer
├── db/migrate/                    # psi_slider_votes table migration
├── lib/psi/                       # Extensions (Topic, Post, Guardian, Engine)
├── assets/
│   ├── javascripts/discourse/
│   │   ├── components/            # Slider, bar chart, widget, stance badge
│   │   ├── connectors/            # Topic page, composer integrations
│   │   ├── initializers/          # Plugin API setup
│   │   └── lib/                   # Constants (position labels)
│   └── stylesheets/               # PSI theme (common, desktop, mobile)
└── spec/                          # Model, request, and system specs
```

## What's working

- **Comment Slider**: 5-position discrete slider with vote recording, bar chart results
- **Vote without comment**: Submit vote only, shown in distribution
- **One reply per user**: Enforced on top-level replies to slider topics
- **Stance badges**: Each voter's position shown as a pill on their post
- **PSI theming**: IBM Plex Sans typography, purple/salmon color scheme
- **Editorial badging**: Via Discourse group flair (configured in admin)
- **Restricted topic creation**: Via site setting for allowed groups

## What's not yet implemented

- AI moderation (future phase)
- Article linking / "From:" source references
- Sort by "Most relevant"
- Emoji reactions (may use discourse-reactions plugin)
- Semi-anonymous posting
