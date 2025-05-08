# .goosehints

## Project Overview

- **Type:** Elixir/Phoenix Web Application
- **Location:** This file resides in the project root directory. Run commands from here.
- **Note:** This project uses git worktrees; the specific root directory path might vary (e.g., `/var/home/david/Boxes/chr/some-branch`).

## Development Guidelines

- **Planning:** **Always outline your plan** (files to modify, commands to run, etc.) and **wait for explicit approval** before taking action.
- **CRITICAL - NO CODE COMMENTS:** **ABSOLUTELY NO comments** of any kind (Elixir `#`, Heex `<%#`, HTML `<!--`, etc.) should be added to generated or modified code. Rely *only* on self-explanatory code and context. This is a strict requirement.
- **Commit Messages:** **Do not use prefixes** like `feat:`, `chore:`, `fix:`, etc. Use clear, descriptive messages.
- **`get_in` Syntax:** Prefer `get_in(record.property.other)` over `get_in(record, [:property, :other])` for accessing nested data.
- **Safe Navigation:** Prefer `get_in(data.a.b)` over `data.a && data.a.b` for safely accessing potentially nil nested map/struct data. Avoid manual short-circuit checks.
- **Context Boundaries:** **Strictly keep Ecto Repo interactions within context modules.** Do not call `Repo` functions directly from controllers, LiveViews, components, **schema modules**, or other non-context modules. Contexts should provide the sole interface for database operations.

## Key Directories & Files (relative to project root)

- `mix.exs`: Project definition, dependencies. **Check this to see available libraries/APIs.**
- `mix.lock`: Exact dependency versions.
- `lib/`: Core application code (Elixir).
  - `lib/your_app_web/components/`: Often contains reusable UI components (`*_components.ex`) for Eex/Heex templates. (Verify exact path based on app name).
- `test/`: Tests (ExUnit).
- `config/`: Configurations.
- `priv/`: Static files, migrations, templates.
- `assets/`: Frontend assets.

## Common Commands (run from project root)

- `mix setup`: Install deps, setup DB, run migrations.
- `mix phx.server`: Start dev server.
- `mix test`: Run tests.
- `mix format`: Format code.
- `mix deps.get`: Fetch dependencies.
- `mix phx.routes`: List routes.
- `mix ecto.migrate`: Run DB migrations.
- `iex -S mix`: Start interactive console.

## Tools

- **Build:** Mix
- **Framework:** Phoenix
- **Database:** Ecto (check `config/`)
- **Testing:** ExUnit
- **UI Components:** Defined in `*_components.ex` modules (often in `lib/your_app_web/components/`).
