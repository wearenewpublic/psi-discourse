# PSI Plugin — Visual QA Issues

Tracking user-reported issues. Remove items when confirmed fixed.

## Open Issues

### Composer
- [ ] **Composer popup looks broken** — The Discourse default composer pops up from the bottom and looks different from the Figma designs. Should match the PSI composer Figma (full-screen-ish with slider above text area, byline, and clean layout). Reference: PSI Stage 2, node 179:10479.
- [ ] **"Share your thoughts" when not logged in** — Should redirect to login. Fix applied, needs user verification.

### Posts / Comments
- [ ] **Poster byline layout** — Time should be below the name, not on the right. Closer to Figma: "Name (bold)" then "2 hours ago" below.
- [ ] **Comment action buttons** — Should be left-aligned with labels (Reply, React) like Figma.
- [ ] **Poster names in pale grey** — User reported names looking too light. CSS fix applied, needs verification.

### Slider
- [ ] **Pulse animation** — Changed to purple glow border. Needs user verification against PSI product.
- [ ] **Smooth dragging** — Changed to track raw mouse %. Needs user verification.

### Layout
- [ ] **Floating icons on left side** — Hamburger menu icon and small sidebar icons still visible on left edge.
- [ ] **Share/Bookmark/Reply buttons at bottom** — Still showing on some views. Should be hidden.
- [ ] **Hide any non-Figma UI elements** — General principle.

## Fixed Issues
- [x] Left/right sidebar navigation — hidden via CSS
- [x] "This is the first time X has posted" banners — hidden
- [x] Letter avatar "A" on slider thumb — removed
- [x] Bar chart flat instead of vertical — fixed
- [x] Suggested topics / "New & Unread" — hidden
- [x] "Want to read more?" section — hidden
- [x] Poster names missing — fixed (was broken outlet connector replacing names)
- [x] Stance badges missing — fixed (switched to __after outlet)
- [x] Post stream crashing — fixed (removed broken DAG transformer)
- [x] Names showing handles instead of display names — enabled display_name_on_posts
