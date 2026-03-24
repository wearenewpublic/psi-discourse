# PSI Discourse Plugin — Implementation Plan

## Summary

Build a single Discourse plugin (`plugins/psi`) that replicates the core PSI product features:
1. **Comment Slider** — 5-point opinion scale on topics, with bar chart results
2. **PSI Theming** — IBM Plex Sans typography, purple/salmon brand colors, cleaned-up conversation layout
3. **Editorial Badging** — "Journalist" (or similar) labels on editorial staff via Discourse group flair
4. **Restricted Topic Creation** — Only staff/designated group can create topics
5. **Local dev setup, E2E tests, and DigitalOcean deployment**

AI moderation is explicitly out of scope for this plan.

---

## Phase 0: Local Development Environment

### 0.1 Discourse Dev Setup
- Clone the Discourse repo (we already have it at the project root)
- Follow the [Discourse development guide](https://meta.discourse.org/t/install-discourse-on-macos-for-development/15772) for macOS:
  - Install PostgreSQL 15+, Redis, Node.js, Ruby (via rbenv)
  - `bundle install`, `pnpm install`
  - `bin/rails db:create db:migrate`
  - `bin/ember-cli` (frontend) + `bin/rails s` (backend)
- Create the plugin skeleton at `plugins/psi/`
- Verify the empty plugin loads without errors

### 0.2 Plugin Skeleton
Create the standard Discourse plugin directory structure:

```
plugins/psi/
├── plugin.rb                          # Main plugin file
├── about.json                         # Plugin metadata
├── package.json                       # Frontend dependencies
├── config/
│   ├── routes.rb                      # Plugin API routes
│   ├── settings.yml                   # Site settings
│   └── locales/
│       └── server.en.yml              # Translations
│       └── client.en.yml              # Frontend translations
├── app/
│   ├── models/                        # ActiveRecord models
│   ├── controllers/                   # API controllers
│   └── serializers/                   # JSON serializers
├── db/
│   └── migrate/                       # Database migrations
├── lib/
│   └── psi/                           # Ruby library code
├── assets/
│   ├── javascripts/
│   │   └── discourse/
│   │       ├── components/            # Glimmer components (.gjs)
│   │       ├── initializers/          # Plugin API initializers
│   │       └── lib/                   # JS utilities
│   └── stylesheets/
│       ├── common/                    # Shared styles
│       ├── desktop/                   # Desktop overrides
│       └── mobile/                    # Mobile overrides
├── spec/
│   ├── models/                        # Model specs
│   ├── requests/                      # API specs
│   └── system/                        # System/E2E specs
│       └── page_objects/
│           └── pages/                 # Page objects for system tests
└── test/
    └── javascripts/                   # QUnit tests
```

`plugin.rb` header:
```ruby
# name: psi
# about: PSI civic engagement features for Discourse
# version: 0.1.0
# authors: PSI Team
# url: https://github.com/wearenewpublic/psi-discourse
# required_version: 2.7.0
# enabled_site_setting: psi_enabled
```

### 0.3 Seed Data
Create a rake task or seed script that sets up:
- A "PSI Conversations" category
- An admin user and a few test users
- A group called "editorial" with the "Journalist" flair
- A sample topic with comment slider enabled

---

## Phase 1: E2E Testing Infrastructure

### 1.1 System Test Setup
Discourse uses RSpec + Capybara + Playwright for system tests. The plugin's tests go in `plugins/psi/spec/system/`.

Create page objects:
- `PsiTopicPage` — wraps the topic view, exposes slider interaction, comment list, bar chart
- `PsiComposerPage` — wraps the reply composer with slider widget
- `PsiTopicListPage` — wraps the topic list for verifying restricted creation

### 1.2 Smoke Tests (build incrementally alongside features)
Each phase below includes its own test specifications. The tests serve as acceptance criteria.

### 1.3 Screenshot Tests
Use Capybara's `page.save_screenshot` at key points for visual verification. Store in `tmp/screenshots/` for manual review. We won't do pixel-perfect comparison initially, but having screenshots makes it easy to verify theming progress.

---

## Phase 2: PSI Theming

The goal is to make Discourse conversations *look like* the PSI designs without fighting Discourse's layout system. We use Discourse's CSS variable system and SCSS overrides.

### 2.1 Typography
The PSI design uses **IBM Plex Sans** as the primary font and **IBM Plex Mono** for data visualization.

Implementation:
- Add IBM Plex Sans via Google Fonts `@import` in the plugin's SCSS
- Override Discourse's CSS custom properties for font families:
  ```scss
  :root {
    --font-family: "IBM Plex Sans", system-ui, sans-serif;
    --heading-font-family: "IBM Plex Sans", system-ui, sans-serif;
  }
  ```
- Type scale (from Figma):
  - Heading large: Medium 24px/125%
  - Heading small: Semibold 16px/125%
  - Paragraph large: Regular 16px/150%
  - Paragraph small: Regular 14px/150%
  - Utility: Regular/Medium 12-14px/125%
  - Card heading large: Medium 28px/125%

### 2.2 Color Scheme
Create a Discourse color scheme (via seed or admin UI) that maps PSI brand colors:

Key colors from the Figma design system:
- **Purple (accent)**: #5A1EF5 — used for selected slider thumb, links, active states
- **Salmon**: #FD6570 — used for banner backgrounds, highlights
- **Purple tint**: light purple for slider track highlights
- **Dark text**: #0D1118 (near-black)
- **Gray scale**: follows the Figma gray tokens

Map to Discourse color variables:
```scss
:root {
  --primary: #0D1118;           // Main text
  --secondary: #FFFFFF;          // Background
  --tertiary: #5A1EF5;          // Links, accent (purple)
  --quaternary: #FD6570;        // Highlight (salmon)
  --highlight: #ECECFF;         // Purple tint for highlights
  --header_background: #FFFFFF; // Clean white header
  --header_primary: #0D1118;    // Header text
}
```

### 2.3 Topic/Conversation Styling
Apply SCSS overrides to make the topic view cleaner and closer to the PSI design:

- **Topic header**: Larger title text (28px medium), show participant count, clean layout
- **Post/comment styling**: Clean card-like appearance for each post, with:
  - Round avatar (already Discourse default)
  - Author name + time
  - Stance badge (e.g., "Strongly yes") shown as a pill below the author line
  - Reply/React actions row
  - Reaction counts on the right
- **Banner**: Salmon/pink dismissible banner at top ("ZDFspaces are different — Learn how" in the designs, but we'll make this configurable text)
- **Separator lines** between posts

### 2.4 Header/Nav Styling
The PSI design has a simpler top navigation than Discourse's default:
- **Mobile**: Logo on left, user avatar + name on right, X (close) button
- **Desktop**: Brand logo on left, user info on right, simple footer with Privacy/Terms links

For phase 1, we'll simplify Discourse's header via CSS:
- Hide elements we don't need (search icon, hamburger in some contexts, etc.)
- Style the remaining elements to match PSI's cleaner look
- This is purely CSS — no structural changes to the header component

### 2.5 Desktop Layout
- Mobile breakpoint: 540px (from Figma)
- Desktop: Content centered with max-width, same components but wider
- The standalone page structure from Figma: sticky top nav, page content, simple footer

### 2.6 Tests
```
System test: PSI theming
  - Visit a topic page
  - Verify IBM Plex Sans is loaded (check computed font-family)
  - Verify PSI color scheme is active
  - Screenshot for manual review
```

---

## Phase 3: Comment Slider

This is the core PSI feature. It consists of:
1. A **discrete 5-position slider** on the topic page for voting
2. A **bar chart** showing vote distribution (replaces slider after voting)
3. A **composer integration** where the slider appears when replying
4. **One top-level reply per user** enforcement
5. **Vote-without-comment** option

### 3.1 Data Model

Create a migration for the slider vote data:

```ruby
# db/migrate/XXXXXX_create_psi_slider_votes.rb
create_table :psi_slider_votes do |t|
  t.references :topic, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.integer :position, null: false  # 1-5 mapping to the scale
  t.references :post, foreign_key: true  # nil if vote-only (no comment)
  t.timestamps
end

add_index :psi_slider_votes, [:topic_id, :user_id], unique: true
```

Also use a **topic custom field** to store whether comment slider is enabled:
```ruby
register_topic_custom_field_type("psi_slider_enabled", :boolean)
```

The 5 positions are fixed constants:
```ruby
module Psi
  SLIDER_POSITIONS = {
    1 => "Strongly no",
    2 => "No with reservations",
    3 => "It's complicated",
    4 => "Yes with reservations",
    5 => "Strongly yes"
  }.freeze
end
```

### 3.2 Backend: Models & Validations

**PsiSliderVote model** (`app/models/psi_slider_vote.rb`):
- `belongs_to :topic`, `belongs_to :user`, `belongs_to :post` (optional)
- Validates position is 1-5
- Validates uniqueness of `[topic_id, user_id]`
- Scope: `by_position` — groups votes by position for the bar chart

**Topic extension**:
- `topic.psi_slider_enabled?` — reads custom field
- `topic.psi_slider_votes` — association
- `topic.psi_slider_vote_counts` — returns `{ 1 => count, 2 => count, ... }`
- `topic.psi_user_vote(user)` — returns the user's vote or nil

**Post extension**:
- Enforce one top-level reply per user when slider is enabled:
  - In `after_initialize`, add a validator that checks if the user already has a top-level post in this topic
  - Top-level = `reply_to_post_number.nil?` and not the OP
  - Allow nested replies (reply to another post) without restriction

### 3.3 Backend: API

**Controller** (`app/controllers/psi/slider_controller.rb`):

```
PUT  /psi/vote          # Create or update vote (with or without post)
GET  /psi/votes/:topic_id  # Get vote distribution + current user's vote
```

**PUT /psi/vote** params:
- `topic_id` (required)
- `position` (required, 1-5)

Response: Updated vote counts + user's vote.

The vote endpoint just records/updates the vote. If the user also wants to comment, they use the normal Discourse reply flow — the composer sends the slider position alongside the reply, and the plugin hooks into post creation to record the vote.

**Serializer additions**:
- Add `psi_slider_enabled`, `psi_slider_vote_counts`, `psi_slider_user_vote` to the topic serializer
- Add `psi_slider_position` to the post serializer (shows each commenter's stance)

### 3.4 Backend: Post Creation Hook

When a user creates a top-level reply on a slider-enabled topic:
1. Read the `psi_slider_position` param from the post creation params
2. Create or update `PsiSliderVote` for this user+topic, linking to the new post
3. If the user already has a vote (vote-only), update it to link to the post

When a user edits their top-level reply:
1. Allow updating `psi_slider_position` — updates the vote record

### 3.5 Frontend: Slider Component

**`psi-discrete-slider.gjs`** — The 5-position slider widget

States (from Figma):
- **Default**: Gray track with 5 dot positions, draggable thumb at center, "Slide to respond:" label
- **Hover**: Thumb scales to 1.1x
- **Press/Drag**: Thumb scales to 0.9x, moves along track, snaps to nearest position
- **Selected**: Thumb turns purple (#5A1EF5), position label shown below (e.g., "Yes with reservations"), "You" badge below
- **Spring animations**: Use CSS transitions — `transition: transform 0.45s cubic-bezier(0.34, 1.56, 0.64, 1)` for the bounce effect

Track: 5 positions evenly spaced, small gray dots at each position.

### 3.6 Frontend: Vote Results Bar Chart

**`psi-vote-results.gjs`** — Shown after the user has voted

From the Figma:
- "100 responses" heading (total vote count)
- 5 vertical bars, one per position, with percentage labels above each
- A horizontal slider track below the bars with the user's avatar positioned at their vote
- "Update your response" link at bottom

Below the bar chart, if the user has a comment:
- "Your response" card showing their comment preview with reply/reaction counts

### 3.7 Frontend: Topic Page Integration

Use the Plugin API to inject the slider/results widget into the topic page:

```javascript
api.renderInOutlet("topic-above-posts", PsiSliderWidget);
```

The component (`psi-slider-widget.gjs`) decides what to show:
- If slider not enabled on this topic → render nothing
- If user hasn't voted → show the discrete slider with "Slide to respond:" prompt
- If user has voted → show the vote results bar chart with their position highlighted

### 3.8 Frontend: Composer Integration

When replying to a slider-enabled topic (top-level only):

1. After the user selects a slider position, show a "Share your thoughts..." input that opens the Discourse composer
2. In the composer, show the slider widget above the text area (using a composer outlet)
3. Add a "Skip and submit vote" link that submits vote-only (no comment)
4. On post, include `psi_slider_position` as a custom field in the post creation request

Use plugin API:
```javascript
api.serializeOnCreate("psi_slider_position");
api.serializeOnUpdate("psi_slider_position");
```

### 3.9 Frontend: Post Stance Badge

Each top-level post shows the author's stance as a pill badge:
- Positioned below the author name/date line
- Styled as a rounded pill with light background
- Text is the position label (e.g., "Strongly yes", "It's complicated")

Use the Plugin API to add this to the post stream:
```javascript
api.renderInOutlet("post-after-user-name", PsiStanceBadge);
```

### 3.10 One Reply Per User Enforcement

Backend:
- Validator on Post that rejects top-level replies when user already has one in this slider-enabled topic
- Return a clear error message: "You've already responded to this conversation. Edit your existing response to change it."

Frontend:
- When user has already posted a top-level reply, hide/disable the "Reply" button at the topic level
- Show "Update your response" link in the bar chart section which navigates to their existing post for editing
- Nested replies (reply to someone else's post) remain unrestricted

### 3.11 Topic Creation with Slider Toggle

When an admin creates a new topic:
- Add a toggle/checkbox in the composer: "Enable comment slider"
- This sets the `psi_slider_enabled` custom field on the topic
- Use the composer outlet or topic creation hook

### 3.12 Tests

```
System test: Comment Slider — voting flow
  - Admin creates a topic with slider enabled
  - User visits topic, sees "Slide to respond:" slider
  - User drags to "Yes with reservations"
  - User sees position label + "You" badge
  - User clicks "Share your thoughts...", types a comment, posts
  - Slider section now shows bar chart with 1 vote at position 4
  - User's response card shown below chart
  - Screenshot

System test: Comment Slider — vote without comment
  - User visits slider topic
  - User selects a position
  - User clicks "Skip and submit vote"
  - Bar chart shows with 1 vote, no "Your response" card
  - User's avatar shown on the slider track

System test: Comment Slider — one reply per user
  - User posts a top-level reply
  - User tries to post another top-level reply → blocked
  - User can still reply to another user's post (nested reply)
  - User clicks "Update your response" → edits existing post

System test: Comment Slider — bar chart accuracy
  - 3 users vote at different positions
  - Visit topic as 4th user
  - After voting, bar chart shows correct distribution

Request spec: POST /psi/vote
  - Valid vote → 200, vote recorded
  - Invalid position → 422
  - Duplicate vote → updates existing
  - Not logged in → 403

Request spec: GET /psi/votes/:topic_id
  - Returns vote counts and current user's vote
  - Non-slider topic → 404

Model spec: PsiSliderVote
  - Validates position range
  - Validates uniqueness
  - Correct counts by position
```

---

## Phase 4: Editorial Badging

### 4.1 Approach
Use Discourse's existing **group flair** system. This is the simplest approach and is already built into Discourse.

Steps:
1. Create a group called "editorial" (or "journalists")
2. Upload a flair icon/image for the group (or use an SVG icon)
3. Assign the group to editorial staff users
4. The flair automatically appears next to their username

### 4.2 Styling
Override the default flair styling to match the PSI design:
- Small rounded pill with the label text (e.g., "Journalist")
- Positioned right below the username
- Use the group's `title` field for the display text

The Figma shows: round avatar, then name, then a small colored badge with "Journalist" text and a checkmark icon. We'll style Discourse's existing flair to match this:

```scss
.avatar-flair {
  // Style to look like PSI badge pill
  border-radius: 4px;
  font-size: 12px;
  padding: 2px 8px;
  background-color: var(--tertiary);  // Purple
  color: white;
}
```

### 4.3 Tests
```
System test: Editorial badging
  - User in "editorial" group posts a reply
  - Verify flair badge appears next to username
  - Screenshot for visual review
```

---

## Phase 5: Restricted Topic Creation

### 5.1 Approach
Discourse already has granular topic creation permissions via category settings. The simplest approach:

1. Create a PSI category (or configure the default)
2. Set category security so that only staff (or a specific group) can create topics
3. All users can reply (subject to slider one-reply-per-user rules)

This requires **zero custom code** — it's just a configuration change. The plugin's seed/setup script should configure this.

### 5.2 Alternative: Site Setting
If we want a plugin-level setting instead of per-category configuration:

```yaml
# config/settings.yml
psi:
  psi_enabled:
    default: true
    client: true
  psi_topic_creation_allowed_groups:
    default: "1|3"  # staff + admins
    type: group_list
    client: true
```

Then extend the Guardian to check this setting. But the category-level approach is simpler and recommended.

### 5.3 Tests
```
System test: Topic creation restriction
  - Regular user visits category → no "New Topic" button
  - Admin visits category → "New Topic" button visible
  - Admin creates topic successfully
```

---

## Phase 6: DigitalOcean Deployment

### 6.1 Approach
Use Discourse's official Docker-based installation, which is the recommended production deployment method.

### 6.2 Steps

1. **Create a DigitalOcean Droplet**:
   - Minimum: 2GB RAM, 1 vCPU (smallest viable for Discourse)
   - Ubuntu 22.04 LTS
   - Recommended: 2GB+ RAM to handle Discourse + PostgreSQL + Redis in one box

2. **Install Discourse via Docker**:
   - Follow [official install guide](https://github.com/discourse/discourse/blob/main/docs/INSTALL-cloud.md)
   - `discourse-setup` script handles Docker, Let's Encrypt, email config
   - Point a domain/subdomain at the droplet (e.g., `psi-demo.example.com`)

3. **Install the PSI Plugin**:
   - Add the plugin's git repo URL to `app.yml` in the `hooks` section:
     ```yaml
     hooks:
       after_code:
         - exec:
             cd: $home/plugins
             cmd:
               - git clone https://github.com/wearenewpublic/psi-discourse.git psi
     ```
   - Rebuild: `./launcher rebuild app`

4. **Email Configuration**:
   - For a minimal internal demo, use a transactional email service (Mailgun, SendGrid, or Postmark free tier)
   - Or use `discourse_dev_emails` + MailHog for development/demo

5. **Initial Configuration**:
   - Run the setup wizard
   - Enable the PSI plugin
   - Create the editorial group
   - Set category permissions
   - Apply the PSI color scheme/theme

### 6.3 Infrastructure as Code (Optional)
For reproducibility, create:
- A `deploy/` directory with the `app.yml` template
- A setup script that configures the droplet from scratch
- This is nice-to-have — manual setup is fine for an internal demo

### 6.4 Tests
Deployment verification:
- Site loads and is accessible
- PSI plugin is active (check admin panel)
- Can create a slider topic
- Can vote and comment

---

## Implementation Order & Dependencies

```
Phase 0: Local Dev Setup              (prerequisite for everything)
  ↓
Phase 1: E2E Test Infrastructure       (parallel with Phase 2)
  ↓
Phase 2: PSI Theming                   (no backend dependencies)
  ↓
Phase 3: Comment Slider                (core feature, depends on 0+1)
  ├─ 3.1-3.4: Backend (model, API, hooks)
  ├─ 3.5-3.6: Frontend (slider, bar chart components)
  ├─ 3.7-3.9: Integration (topic page, composer, stance badge)
  ├─ 3.10: One reply enforcement
  ├─ 3.11: Topic creation toggle
  └─ 3.12: Tests
  ↓
Phase 4: Editorial Badging             (independent, can parallel with 3)
  ↓
Phase 5: Restricted Topic Creation     (config only, can parallel with 3)
  ↓
Phase 6: DigitalOcean Deployment       (after 2-5 are working locally)
```

Phases 2, 4, and 5 can run in parallel with Phase 3 since they are largely independent.

---

## Key Design Decisions

### Why a single plugin?
All PSI features are tightly related and share theming/configuration. One plugin is simpler to manage, deploy, and test.

### Why not use the existing Poll plugin?
The Poll plugin is designed for inline polls within post content (Markdown-based). The PSI comment slider is fundamentally different:
- It's a **topic-level** feature, not per-post
- It's tightly coupled with the reply flow (vote + comment together)
- It enforces one-reply-per-user
- The UI (slider + bar chart) is custom

Building on the Poll plugin would require more code to disable/override its behavior than writing a clean implementation.

### Why topic custom fields for slider_enabled?
Discourse's custom field system is the standard way plugins store per-topic metadata. It's well-supported, automatically included in serializers when registered, and doesn't require schema changes to the topics table.

### Why a separate psi_slider_votes table?
Vote data needs efficient aggregation (group by position, count) and uniqueness constraints. Custom fields are key-value and not suited for this. A dedicated table with proper indexes is the right approach — similar to how the Poll plugin uses `poll_votes`.

---

## Figma Design References

| Feature | Figma URL | Key Details |
|---------|-----------|-------------|
| Thread view (mobile) | PSI Stage 2, node 5279:126329 | Post layout, reply flow |
| Component library | PSI Stage 2, node 7533:84469 | Full topic with slider, badges |
| Slider flows | PSI Stage 2, node 40:16961 | All slider states, composer |
| Slider pre-vote | PSI Design System, node 1309:25299 | "Slide to respond" prompt |
| Slider selected | PSI Design System, node 1309:25648 | Selected state + "Share your thoughts" |
| Post-vote bar chart | PSI Design System, node 3348:10165 | Vote results + "Update your response" |
| Post-vote with response | PSI Design System, node 17612:27451 | Bar chart + user's response card |
| Slider states/transitions | PSI Stage 2, node 3150:34592 | Hover, press, drag, pulse animations |
| Desktop layout | PSI Design System, node 24309:38076 | Standalone page structure |
| Colors & typography | PSI Design System, node 3:32 | Full design system tokens |
| Composer with slider | PSI Stage 2, node 179:10479 | Reply composer + slider + moderation |

---

## Open Questions / Future Work

1. **Sort order**: The designs show "Most relevant" sort. How should this work? By vote count? By recency? Defer to Phase 2.
2. **Reactions**: The designs show emoji reactions (heart, +, speech bubble, lightbulb, count). Discourse has a reactions plugin — should we enable it or build custom? Defer for now.
3. **AI Moderation**: Explicitly deferred. The composer shows an "AI moderation" banner — this will be a future phase.
4. **Article linking**: The designs show "From: An Italian Town..." linking to a source article. Should topics be linkable to external articles? Defer.
5. **Anonymous posting**: PSI has semi-anonymous features. Not in scope for v1.
