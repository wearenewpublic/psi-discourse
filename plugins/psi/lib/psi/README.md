# Lib (Ruby)

Ruby library modules for the PSI plugin.

## Files

- **engine.rb** - Defines `Psi::Engine`, the Rails engine that provides namespaced routing and controller isolation for the plugin's API endpoints.

- **guardian_extension.rb** - Extends Discourse's `Guardian` with `can_create_psi_topic?`, which checks whether the current user is staff or belongs to an allowed group.

- **post_extension.rb** - Extends the `Post` model with a `has_one :psi_slider_vote` association, so deleting a post nullifies the vote's post reference.

- **topic_extension.rb** - Extends the `Topic` model with `has_many :psi_slider_votes` and a `psi_slider_enabled?` helper that checks the topic's custom field.
