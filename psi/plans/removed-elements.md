# Removed / Hidden Discourse UI Elements

These Discourse UI elements are hidden via CSS in the PSI plugin (`psi.scss`).
They were removed because they don't appear in the PSI Figma designs.

If we want to bring any back, remove the corresponding CSS rule.

## Navigation
- **Left sidebar** (`.sidebar-wrapper`, `#d-sidebar`) — Discourse's main navigation sidebar
- **Timeline/progress bar** (`.timeline-container`, `#topic-progress-wrapper`) — Right-side scroll progress indicator

## Topic Page
- **Topic map** (`.topic-map`) — Summary box showing participants, links, frequent posters
- **Suggested topics** (`#suggested-topics`) — "New & Unread Topics" section at bottom
- **Topic footer buttons** (`.topic-footer-buttons`) — Share, Bookmark, Reply buttons at topic bottom
- **Watching selector** (`.topic-notifications-button`) — Notification level dropdown

## Posts
- **"First time posted" banners** (`.post-notice.new-user`) — Yellow "This is the first time X has posted" notices
- **Small action posts** (`.topic-post.small-action`) — "X joined the topic" type posts
- **Post date on right** (`.post-info.post-date`) — Date/time shown on the far right of the post meta area
- **Read/like counts** (`.post-info.likes`, `.post-info.reads`) — Per-post engagement stats

## Mobile
- **Topic admin menu button** (`.topic-admin-menu-button-container`) — Floating admin tools on mobile
- **Sidebar footer** (`.sidebar-footer-wrapper`) — Mobile sidebar footer
