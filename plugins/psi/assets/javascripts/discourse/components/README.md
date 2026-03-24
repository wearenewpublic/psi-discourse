# Components

Glimmer components for the PSI slider UI.

## Files

- **psi-discrete-slider.gjs** - A draggable 5-position slider input. Handles mouse/touch drag gestures, snapping to discrete positions, and displays a pulsing thumb animation when idle. Emits an `onSelect` callback with the chosen position (1-5).

- **psi-slider-widget.gjs** - The main slider widget displayed above topic posts. Orchestrates the full voting flow: shows the discrete slider for new votes, submits votes via AJAX to `/psi/vote`, and switches to the vote results view after voting. Also handles opening the composer for reply-with-stance.

- **psi-stance-badge.gjs** - A small badge component that displays a user's slider position label (e.g., "Yes with reservations") next to their post. Used as a standalone component (the initializer renders a similar inline version via `renderInOutlet`).

- **psi-vote-results.gjs** - Displays vote results as a vertical bar chart with percentage labels, a track showing the user's position, and optionally the user's response excerpt. Includes an "Update your response" link.
