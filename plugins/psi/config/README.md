# Config

Plugin configuration files.

## Files

- **routes.rb** - Defines the PSI engine routes: `PUT /vote`, `DELETE /vote`, and `GET /votes/:topic_id`, all handled by `SliderController`.

- **settings.yml** - Declares site settings: `psi_enabled` (master toggle) and `psi_topic_creation_allowed_groups` (which groups can create topics).

- **locales/client.en.yml** - Client-side English translation strings for slider labels, composer UI text, and badge labels.

- **locales/server.en.yml** - Server-side English translation strings for site setting descriptions and error messages.
