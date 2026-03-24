# PSI Discourse Plugin

A Discourse plugin for civic engagement, providing a **comment slider** that lets users express their stance on a topic (from "Strongly no" to "Strongly yes") before or alongside posting a reply.

## Features

- **Comment Slider**: A 5-position opinion slider displayed above topic posts. Users select a position before replying, and their stance is shown as a badge on their post.
- **Vote-Only Mode**: Users can submit a slider vote without writing a reply.
- **Vote Results**: A bar chart showing the distribution of votes across all 5 positions.
- **One Reply Per User**: Slider-enabled topics enforce a single top-level reply per user (nested replies are allowed).
- **Custom Theming**: IBM Plex Sans typography, PSI purple/salmon color palette, and simplified Discourse UI to match PSI Figma designs.
- **Composer Integration**: The slider appears inside the Discourse composer when replying to slider-enabled topics.

## Directory Structure

- `app/controllers/psi/` - API endpoints for voting
- `app/models/` - ActiveRecord model for slider votes
- `app/serializers/` - JSON serialization for vote data
- `assets/javascripts/discourse/` - Ember/Glimmer frontend components, connectors, and initializers
- `assets/stylesheets/` - SCSS styles (common, desktop, mobile)
- `config/` - Routes, site settings, and locale strings
- `db/migrate/` - Database migration for the votes table
- `lib/psi/` - Rails engine, Guardian/Topic/Post extensions
- `spec/` - RSpec unit, request, and system tests

## Configuration

- `psi_enabled` (boolean, default: true) - Master toggle for the plugin
- `psi_topic_creation_allowed_groups` (group list) - Groups allowed to create new topics

## API Endpoints

All mounted at `/psi`:

- `PUT /psi/vote` - Cast or update a slider vote (requires login)
- `DELETE /psi/vote` - Remove a vote-only vote (requires login)
- `GET /psi/votes/:topic_id` - Get vote distribution for a topic
