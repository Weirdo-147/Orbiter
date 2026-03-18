# Contributing to Orbiter

Thanks for contributing to Orbiter.

## Branching Conventions

- Create a dedicated branch for each change.
- Use descriptive branch names:
  - `feat/<short-description>`
  - `fix/<short-description>`
  - `docs/<short-description>`
  - `chore/<short-description>`
- Keep branches focused on a single concern.

## Commit Conventions

- Make small, logical commits that are easy to review.
- Prefer Conventional Commit prefixes:
  - `feat:` for new functionality
  - `fix:` for bug fixes
  - `docs:` for documentation changes
  - `refactor:` for code restructuring
  - `test:` for tests
  - `chore:` for tooling or maintenance
- Write commit messages in imperative mood (for example: `feat: add worker heartbeat handler`).

## Pull Request Conventions

- Open PRs early as draft when the design is still in progress.
- Keep PR scope narrow and aligned to one objective.
- Include the following in each PR description:
  - Summary of what changed
  - Why the change is needed
  - Testing performed
  - Follow-up work (if any)
- Link related issues/design docs when available.
- Ensure CI is passing before requesting review.

## Development Expectations

- Prefer clear interfaces and small packages.
- Add or update tests with behavior changes.
- Update docs (`README`, architecture notes) when structure or behavior changes.
