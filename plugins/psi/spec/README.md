# Specs

RSpec tests for the PSI plugin.

## Files and Directories

- **models/psi_slider_vote_spec.rb** - Unit tests for the `PsiSliderVote` model: validates position range and user uniqueness per topic, tests `counts_for_topic` aggregation, `upsert_vote!` create/update behavior, and `position_label` mapping.

- **requests/slider_controller_spec.rb** - Request specs for the PSI API endpoints: tests authentication, vote creation/update, vote removal (preserving post-linked votes), vote distribution retrieval, and error cases for invalid positions and non-slider topics.

- **system/psi_slider_spec.rb** - System (browser) tests for the full slider flow: slider visibility on enabled/disabled topics, position selection and label display, vote-only submission, bar chart percentages, one-reply-per-user enforcement, nested reply allowance, and stance badge rendering.

- **system/page_objects/pages/psi_topic.rb** - Page object for system tests providing helpers to visit slider topics, check for UI elements (slider, results, badges), click positions, and read bar chart percentages.
