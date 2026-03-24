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
brew install rbenv ruby-build postgresql@15 redis node pnpm imagemagick

# Start Postgres and Redis
brew services start postgresql@15
brew services start redis
```

## Step 2: Install Ruby

```bash
# Install Ruby 3.4 (check Gemfile for exact version if needed)
rbenv install 3.4.9
rbenv local 3.4.9

# IMPORTANT: Add rbenv to your shell. Add this to ~/.zshrc:
#   eval "$(rbenv init - zsh)"
# Then restart your terminal or run:
eval "$(rbenv init - zsh)"

# Also add PostgreSQL to your PATH. Add to ~/.zshrc:
#   export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# Verify
ruby --version   # Should say 3.4.x
psql --version   # Should say 15.x
```

## Step 3: Install dependencies

From the repo root (`meta/plan/` — the Discourse root):

```bash
# Ruby dependencies
bundle install

# JavaScript dependencies
pnpm install
```

**Troubleshooting:** If you get "You must use Bundler 2 or greater with this lockfile",
make sure you're using the rbenv Ruby (not the system Ruby). Run `which ruby` — it should
point to `~/.rbenv/versions/3.4.x/bin/ruby`, not `/usr/bin/ruby`. If not, run
`eval "$(rbenv init - zsh)"` and try again.

## Step 4: Set up the database

```bash
# Create and migrate the development database
bin/rails db:create db:migrate

# This also runs migrations for all plugins, including our PSI plugin
# (creates the psi_slider_votes table)

# Seed with sample data (admin user, categories, etc.)
bin/rails db:seed
```

## Step 4b: Compile plugin JavaScript

Modern Discourse compiles plugin JS via a rollup-based compiler on the Rails side.
When using `bin/rails s` (not the full pitchfork server), you need to trigger this manually:

```bash
bin/rails runner "Discourse.plugins.each { |p| Plugin::JsManager.new.send(:compile_js_bundle, p) }"
```

This creates compiled JS bundles in `app/assets/generated/psi/`. You only need to re-run
this when you change the plugin's JavaScript files.

**Note:** The `discourse-ai` plugin requires the `pgvector` PostgreSQL extension. If you
see errors about pgvector during migration, you can either install it (`brew install pgvector`)
or temporarily rename the plugin directory to disable it.

## Step 5: Start the dev server

You need two terminals:

**Terminal 1 — Rails backend:**
```bash
# The DISCOURSE_DEV_ALLOW_ANON_TO_IMPERSONATE=1 env var lets you
# switch users easily via /session/<username>/become
DISCOURSE_DEV_ALLOW_ANON_TO_IMPERSONATE=1 bin/rails s
```

**Terminal 2 — Ember frontend:**
```bash
bin/ember-cli
```

The site will be available at **http://localhost:4200** (proxied through ember-cli) or **http://localhost:3000** (Rails direct).

## Step 5b: Logging in during development

Discourse normally requires email confirmation to log in. For local development,
skip this entirely using the **impersonation endpoint**.

**Prerequisite**: You must start Rails with this env var (already shown above):
```bash
DISCOURSE_DEV_ALLOW_ANON_TO_IMPERSONATE=1 bin/rails s
```

**To log in**: Visit this URL in your browser (replace `<port>` with your ember-cli port,
e.g., 4200):
```
http://localhost:<port>/session/admin/become
```

This instantly logs you in as the `admin` user — no password or email needed.

**Other users you can impersonate** (if you've run the seed script):
- `http://localhost:<port>/session/testuser/become`
- `http://localhost:<port>/session/francesca/become`
- `http://localhost:<port>/session/michael_h/become`
- `http://localhost:<port>/session/sofia_f/become`

**If you want actual email-based login** (e.g., for testing the signup flow):
```bash
# Option 1: Skip email confirmation entirely
bin/rails runner "SiteSetting.skip_email_confirmation = true"

# Option 2: Use MailHog for local email capture
brew install mailhog
mailhog  # Runs SMTP on localhost:1025, web UI on localhost:8025
# Then set SMTP host to localhost, port 1025 in Discourse admin settings
```

**For production email** (DigitalOcean deployment): You'll need a transactional email
service. Cheapest options: Mailgun (free tier: 100 emails/day), SendGrid, or Postmark.

## Step 6: Initial Discourse setup

1. Visit http://localhost:4200 (or whatever port ember-cli shows)
2. You'll see the Discourse setup wizard on first run
3. Create your admin account
4. Complete the wizard

## Step 7: Enable and configure PSI

1. Go to **Admin > Settings** (http://localhost:4200/admin/site_settings)
2. Search for "psi" — ensure **psi_enabled** is checked (should be on by default)
3. Optionally configure **psi_topic_creation_allowed_groups**
4. Also configure these Discourse settings for PSI-style display:
   - Search for "enable names" → set to **true**
   - Search for "display name on posts" → set to **true**
   - Search for "prioritize username in ux" → set to **false**

   These ensure poster names show as "Francesca Mao" instead of "francesca".

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
