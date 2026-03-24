# Database Migrations

ActiveRecord migrations for the PSI plugin.

## Files

- **20250323000001_create_psi_slider_votes.rb** - Creates the `psi_slider_votes` table with columns for topic, user, position (1-5), and optional post reference. Adds a unique index on (topic_id, user_id) and a composite index on (topic_id, position) for efficient vote counting.
