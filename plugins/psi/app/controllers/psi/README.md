# Controllers

API controllers for the PSI plugin, mounted under the `/psi` namespace via `Psi::Engine`.

## Files

- **slider_controller.rb** - Handles slider vote CRUD operations: casting a vote (`PUT /psi/vote`), removing a vote-only vote (`DELETE /psi/vote`), and fetching vote distribution (`GET /psi/votes/:topic_id`). Enforces authentication, topic visibility, and valid slider positions.
