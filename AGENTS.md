# Chatwoot Development Guidelines

## Fork & Upstream Sync

This repo is a customized fork (二次开发) of upstream `chatwoot/chatwoot`. Local customizations live on top of upstream code and must be preserved across syncs.

- **Remotes**:
  - `origin` (`deluxebear/chatwoot`) — our fork; all pushes and PRs go here
  - `upstream` (`chatwoot/chatwoot`) — official repo, fetch-only; its push URL is intentionally set to `DISABLED_NO_PUSH`. NEVER push to upstream, never re-enable its push URL, never open PRs against `chatwoot/chatwoot`
- **Sync requirement**: keep `develop` up to date with the latest `upstream/develop`. Sync via merge (not rebase) to preserve local commit history:
  ```bash
  git fetch upstream
  git merge upstream/develop
  ```
- **Conflict resolution**: when a sync produces conflicts, the agent must intelligently resolve them — do not abort the merge and do not blindly pick one side:
  1. For each conflicted file, understand both sides: what upstream changed and what our customization does
  2. Default to upstream's version for code we never customized; preserve our local customizations and re-apply them on top of upstream's new structure when the surrounding code changed
  3. If upstream refactored/moved code that we customized, port our customization to the new location/API rather than keeping the stale structure
  4. Never silently drop a local feature; if upstream made a local customization obsolete or fundamentally incompatible, stop and ask the user instead of deciding alone
  5. After resolving, verify: `bundle exec rubocop` on touched Ruby files, `pnpm eslint` on touched JS/Vue files, and run the test suites related to conflicted areas
- **Local customizations so far**: enterprise feature mocking tooling (`lib/tasks/mock_enterprise.rake`, `mock_enterprise_features.rb`, `test_enterprise_mock.rb`, `ENTERPRISE_SETUP.md`) — purely additive files

## Build / Test / Lint

- **Setup**: `bundle install && pnpm install`
- **Run Dev**: `pnpm dev` or `overmind start -f ./Procfile.dev`
- **Lint JS/Vue**: `pnpm eslint` / `pnpm eslint:fix`
- **Lint Ruby**: `bundle exec rubocop -a`
- **Test JS**: `pnpm test` or `pnpm test:watch`
- **Test Ruby**: `bundle exec rspec spec/path/to/file_spec.rb`
- **Single Test**: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- **Run Project**: `overmind start -f Procfile.dev`

## Code Style

- **Ruby**: Follow RuboCop rules (150 character max line length)
- **Vue/JS**: Use ESLint (Airbnb base + Vue 3 recommended)
- **Vue Components**: Use PascalCase
- **Events**: Use camelCase
- **I18n**: No bare strings in templates; use i18n
- **Error Handling**: Use custom exceptions (`lib/custom_exceptions/`)
- **Models**: Validate presence/uniqueness, add proper indexes
- **Type Safety**: Use PropTypes in Vue, strong params in Rails
- **Naming**: Use clear, descriptive names with consistent casing
- **Vue API**: Always use Composition API with `<script setup>` at the top

## Styling

- **Tailwind Only**:  
  - Do not write custom CSS  
  - Do not use scoped CSS  
  - Do not use inline styles  
  - Always use Tailwind utility classes  
- **Colors**: Refer to `tailwind.config.js` for color definitions

## General Guidelines

- MVP focus: Least code change, happy-path only
- No unnecessary defensive programming
- Break down complex tasks into small, testable units
- Iterate after confirmation
- Avoid writing specs unless explicitly asked
- Remove dead/unreachable/unused code
- Don’t write multiple versions or backups for the same logic — pick the best approach and implement it
- Don't reference Claude in commit messages

## Project-Specific

- **Translations**:
  - Only update `en.yml` and `en.json`
  - Other languages are handled by the community
  - Backend i18n → `en.yml`, Frontend i18n → `en.json`
- **Frontend**:
  - Use `components-next/` for message bubbles (the rest is being deprecated)

## Ruby Best Practices

- Use compact `module/class` definitions; avoid nested styles