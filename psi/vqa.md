# PSI Plugin — Visual QA Issues

Tracking user-reported issues. Remove items when confirmed fixed.

## Open Issues

### Posts / Comments
- [ ] **No poster names visible** — Names (e.g., "Francesca Mao") not showing. Fixed approach: switched from outlet connector to DAG transformer. Needs recompile + verification.
- [ ] **Poster byline layout** — Should match Figma: Name (bold) on first line, "2 hours ago" below. Currently time is on the right.
- [ ] **Comment action buttons** — Should be left-aligned with labels (Reply, React) like Figma. Reactions on right.

### Slider
- [ ] **Slider should drag smoothly** — Should follow finger/mouse smoothly along the track and snap to nearest position on release. PSI product code is the reference. Currently snaps between discrete positions during drag.
- [ ] **Pulse animation wrong** — PSI product has a pulsing purple shadow/border effect, not the current expanding ring. Should be a subtle purple glow that pulses on the thumb border.
- [ ] **"Share your thoughts" when not logged in** — Should redirect to login instead of crashing. Fix applied (requireLogin check), needs recompile.

### Bar Chart / Vote Results
- [ ] (none currently — vertical bars are working)

### Layout
- [ ] **Floating icons on mobile** — Some Discourse admin icons still visible on left edge.
- [ ] **"Want to read more?" section** — Should be hidden. CSS added, needs verification.
- [ ] **Hide any non-Figma UI elements** — General principle.

## Fixed Issues
- [x] Left/right sidebar navigation bars — hidden via CSS
- [x] "This is the first time X has posted" banners — hidden via CSS (.post-notice.new-user)
- [x] Letter avatar "A" on slider thumb — removed avatar from pre-vote state
- [x] Bar chart showing flat instead of vertical bars — fixed with proper flex layout
- [x] Suggested topics / "New & Unread Topics" section — hidden via CSS
