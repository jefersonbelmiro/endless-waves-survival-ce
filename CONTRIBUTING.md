# Contributing

Thanks for wanting to help out with Endless Waves Survival.

## Code of conduct

Please read and follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## What you need

- [Godot 3.5.3](https://godotengine.org/download/archive/3.5.3-stable/) (standard build).

## How to contribute

1. Fork the repo.
2. Create a branch from `main` with a short name that says what it does, like
   `fix/dash-out-of-bounds`.
3. Make your changes.
4. Open the project in Godot and make sure it still runs.
5. Commit using the style below.
6. Push your branch and open a pull request against `main`.

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/). Start the
subject with a type:

- `feat:` a new feature
- `fix:` a bug fix
- `docs:` documentation changes
- `refactor:` code changes that don't fix a bug or add a feature
- `chore:` maintenance tasks

Example:

```
fix: prevent dash from leaving the map
```

## Pull requests

- Fill in the pull request template.
- Keep the change focused on one problem.
- Link any related issue.
- Update the [CHANGELOG.md](CHANGELOG.md) if the change matters to players.

## Project conventions

- GDScript code lives under `src/`.
- Game data (cards, enemies, maps, characters) is defined in JSON files next to
  their scene or script.
- Don't commit secrets or settings that are specific to your machine. If you
  need a secret, copy the `.example` file and keep the real one gitignored. See
  the [README](README.md#configuration).

## Questions

Open an
[issue](https://github.com/jefersonbelmiro/endless-waves-survival-ce/issues) if
you have questions.
