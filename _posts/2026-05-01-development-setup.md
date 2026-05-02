---
title: "My Development Setup"
date: 2026-05-02 00:22
categories:
  - Developer
tags:
  - Developer
  - Python
  - Poetry
  - React
  - Tooling
image: https://i.pinimg.com/originals/92/98/b8/9298b8aa90e9bc71a6162878ee24cbeb.gif
---

<div style="text-align: justify;" markdown="1">
# Introduction

This post is my personal development setup guide.

I am writing it because having a consistent environment matters a lot for my workflow as a full-stack developer. Lately I have been working with Python, Django, FastAPI, React, and ML/AI-related tools, so I want one place to document how I like to configure my machine, projects, dependencies, editors, and automation.

>The goal is simple: make this post useful as a reference and a setup checklist I can reuse whenever I start a new project.

# Daily Tools

These are the main tools I use or want to keep close in my development workflow:

- Python version management: [`pyenv`](https://github.com/pyenv/pyenv)
- Isolated Python CLI tools: [`pipx`](https://pipx.pypa.io/)
- Python dependency and packaging management: [`Poetry`](https://python-poetry.org/)
- Frontend development: [`React`](https://react.dev/)
- Main IDE: [`VSCode`](https://code.visualstudio.com/)
- Terminal editor: `Neovim`
- Task automation: `Taskipy`
- Python linting and formatting: `Ruff`
- Testing: `Pytest`

----

# 1. Pyenv

`pyenv` is a tool for installing and managing multiple Python versions on the same machine.

This is useful because different projects may require different Python versions.

For example, one project may run on Python 3.11, while another may need Python 3.12 or 3.13.

## Installation

On Linux, the common installation flow is:

```bash
curl https://pyenv.run | bash
```

After installing, add the required initialization to your shell configuration.
For `zsh`, this usually goes into `~/.zshrc`:

```bash
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

Then reload the shell:

```bash
source ~/.zshrc
```

## Installing Python Versions

List available versions:

```bash
pyenv install --list
```

Install one version:

```bash
pyenv install 3.12.8
```

Check installed versions:

```bash
pyenv versions
```

## Choosing Python Versions

Set a global Python version:

```bash
pyenv global 3.12.8
```

Set a local version for one project:

```bash
pyenv local 3.12.8
```

This creates a `.python-version` file in the project directory.

## Pyenv Checklist

- [ ] Install `pyenv`
- [ ] Configure shell initialization
- [ ] Install the Python version needed by the project
- [ ] Use `pyenv local` inside each project
- [ ] Commit `.python-version` when the project depends on a specific Python version

----

# 2. Pipx

`pipx` is a tool for installing and running Python command-line applications in
isolated environments.

I use it for global Python CLI tools such as Poetry. This keeps those tools away
from my project virtual environments and avoids mixing application dependencies
with development tooling.

In practice, this means:

- Poetry is installed globally, but isolated;
- project dependencies stay inside the project environment;
- I do not need to use `pip install poetry` inside random projects;
- upgrading CLI tools is cleaner.

## Installation on Arch Linux

Install `pipx` on Arch Linux:

```sh
sudo pacman -S python-pipx
pipx ensurepath
```

Reload the shell:

```bash
source ~/.zshrc
```

## Useful Pipx Commands

Install a Python CLI tool:

```bash
pipx install poetry
```

Upgrade a tool:

```bash
pipx upgrade poetry
```

List installed tools:

```bash
pipx list
```

Uninstall a tool:

```bash
pipx uninstall poetry
```

## Pipx Checklist

- [ ] Install `pipx`
- [ ] Run `pipx ensurepath`
- [ ] Use `pipx` for global Python CLI tools
- [ ] Avoid installing global CLI tools inside project virtual environments

----

# 3. Poetry

Poetry is a modern tool for Python dependency management and packaging.

It replaces a lot of manual project setup:

- `pip`
- `virtualenv` / `venv`
- `requirements.txt`
- `setup.py`
- `setup.cfg`

With Poetry, project metadata, dependencies, scripts, and tool configuration can live in one main file:

```text
pyproject.toml
```

## What Poetry Does

Poetry helps with:

- creating virtual environments automatically;
- resolving dependencies in a deterministic way with `poetry.lock`;
- separating production and development dependencies;
- running commands inside the project environment;
- building and publishing packages;
- keeping project configuration centralized.

## Installation

After `pipx` is installed as part of the development environment, I use it to
install Poetry:

```bash
pipx install poetry
```

Check the installation:

```sh
poetry --version
```

Update Poetry:

```sh
pipx upgrade poetry
```

**Alternative official installer:**

```sh
curl -sSL https://install.python-poetry.org | python3 -
```

Check the installation:

```sh
poetry --version
```

If Poetry is not found, add it to your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:

```bash
source ~/.zshrc
```

If Poetry was installed with the official installer, update it with:

```sh
poetry self update
```

or update with pipx:

```sh
pipx upgrade poetry
```

## Creating Projects

Create a project using the recommended `src/` layout:

```bash
poetry new my_project
```

Generated structure:

```text
my_project/
├── pyproject.toml
├── README.md
├── src/
│   └── my_project/
│       └── __init__.py
└── tests/
```

>Use this layout for professional projects, libraries, APIs, and code that may grow over time.

## Creating a Simple Project Without Packaging

In older Poetry versions, some people used `poetry new` with a flag to avoid the
`src/` layout. In current Poetry versions, I do not rely on that flow anymore.

For studies, scripts, notebooks, class exercises, and folders that are not meant
to be installable Python packages, I prefer this workflow:

```bash
mkdir my_project
cd my_project
poetry init
poetry install --no-root
```

>`poetry init` creates only the `pyproject.toml`.
>
>`poetry install --no-root` installs dependencies without trying to install the current directory as a package. This avoids the common error:

```text
The current project could not be installed:
No file/folder found for package <project-name>
```

Use this mode when the project is only for dependency management and command execution, not packaging.

Another valid option is disabling package mode in `pyproject.toml`:

```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.14,<4.0"
dependencies = []

[tool.poetry]
package-mode = false
```

With `package-mode = false`, Poetry understands that the project is not meant to be installed as a package.

Initialize Poetry inside an existing project:

```bash
poetry init
```

## Virtual Environment Workflow

Install dependencies:

```bash
poetry install
```

For non-package projects, use:

```bash
poetry install --no-root
```

Print the activation command:

```bash
poetry env activate
```

Example output:

```bash
source /path/to/project/.venv/bin/activate
```

Then activate it manually:

```bash
source .venv/bin/activate
```

If you use `pyenv`, you can explicitly tell Poetry which Python interpreter to
use:

```bash
poetry env use $(pyenv which python)
```

Run a command without activating the shell:

```bash
poetry run python main.py
```

## Dependency Management

Add a production dependency:

```bash
poetry add requests
```

Add a development dependency:

```bash
poetry add pytest --group dev
```

Remove a dependency:

```bash
poetry remove requests
```

Update dependencies:

```bash
poetry update
```

Show installed dependencies:

```bash
poetry show
```

Show the dependency tree:

```bash
poetry show --tree
```

Validate the project configuration:

```bash
poetry check
```

## `pyproject.toml` Example

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "A professional Python project"
authors = [
    { name = "Your Name", email = "you@example.com" }
]
readme = "README.md"
requires-python = ">=3.12,<4.0"
dependencies = []

[dependency-groups]
dev = [
    "pytest>=8.0.0,<9.0.0",
    "ruff>=0.9.0,<1.0.0",
    "taskipy>=1.14.0,<2.0.0"
]

[build-system]
requires = ["poetry-core>=2.0.0,<3.0.0"]
build-backend = "poetry.core.masonry.api"
```

## Ruff

Ruff is a fast Python linter and formatter.

Example configuration:

```toml
[tool.ruff]
line-length = 79

[tool.ruff.lint]
select = ["E", "F", "W", "I", "PL"]

[tool.ruff.format]
quote-style = "double"
```

Run Ruff:

```bash
poetry run ruff check .
poetry run ruff format .
```

## Pytest

Example configuration:

```toml
[tool.pytest.ini_options]
addopts = "-p no:warnings -vv"
pythonpath = "."
```

Run tests:

```bash
poetry run pytest
```

## Taskipy

Taskipy lets you create project commands inside `pyproject.toml`.

It can replace small Makefiles, loose shell scripts, and repeated command
typing.

Example:

```toml
[tool.taskipy.tasks]
lint = "ruff check ."
format = "ruff check . --fix && ruff format ."
test = "pytest -s -x -vv"
run = "python -m my_project"
```

Run tasks:

```bash
poetry run task lint
poetry run task format
poetry run task test
poetry run task run
```

If you already activated the environment with `poetry env activate` and
`source`, you can use:

```bash
task lint
task test
```

## Build and Publish

Build the package:

```bash
poetry build
```

Publish:

```bash
poetry publish
```

## Poetry Checklist

Project:

- [ ] Clean `pyproject.toml`
- [ ] Correct Python version range
- [ ] Clear project structure
- [ ] `poetry.lock` committed

Quality:

- [ ] Ruff configured
- [ ] Pytest configured
- [ ] Taskipy configured
- [ ] Tests passing

Good practices:

- [ ] Avoid `pip install` inside Poetry projects
- [ ] Use `pipx` for global Python CLI tools such as Poetry
- [ ] Do not commit `.venv`
- [ ] Use `poetry run` for one-off commands
- [ ] Use `poetry env activate` in Poetry 2.x when you want an active shell
- [ ] Keep dependencies explicit
- [ ] Keep development dependencies separated

----

# 4. React

React is a JavaScript library for building user interfaces.

For modern frontend projects, I usually prefer using Vite because it is fast,
simple, and widely used.

## Create a React Project

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install
npm run dev
```

Open:

```text
http://127.0.0.1:5173
```

## Useful Scripts

Typical `package.json` scripts:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint ."
  }
}
```

## React Checklist

- [ ] Use TypeScript when possible
- [ ] Keep components small
- [ ] Separate UI, hooks, services, and types
- [ ] Use environment variables for API URLs
- [ ] Run build before deploying

----

# 5. VSCode

VSCode is my main IDE for larger projects.

## Extension Strategy

I keep VSCode configured by capability:

- Python development;
- linting and formatting;
- notebooks and data exploration;
- frontend development;
- container workflows;
- markdown writing;
- git integration.

>The important part is that the project should not depend on my editor. A good project should still be understandable, runnable, and testable from the terminal.

## Suggested Settings

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit",
    "source.organizeImports": "explicit"
  },
  "python.analysis.typeCheckingMode": "basic",
  "ruff.enable": true
}
```

## VSCode Checklist

- [ ] Python interpreter selected correctly
- [ ] Formatter configured
- [ ] Linter configured
- [ ] Integrated terminal uses the expected shell
- [ ] Workspace settings committed only when useful for the project

----

# 6. Neovim

Neovim is useful when I want a fast terminal editor.

I do not need it to replace everything, but I like having it configured well
enough for quick edits, Git work, and remote environments.

## What I Want From Neovim

- fast startup;
- good syntax highlighting;
- LSP support;
- fuzzy file search;
- Git integration;
- comfortable keybindings;
- Markdown editing.

I do not publish the full plugin list. For a public post, it is enough to
describe the capabilities I expect from the editor without exposing the exact
shape of my local setup.

## Neovim Checklist

- [ ] Language support configured
- [ ] LSP configured
- [ ] Markdown support configured
- [ ] Git integration working
- [ ] Keybindings documented

----

# 7. Project Template

For backend/API projects, a structure like this is a good starting point:

```text
project/
├── pyproject.toml
├── README.md
├── .gitignore
├── src/
│   └── app/
│       ├── __init__.py
│       └── main.py
├── tests/
│   └── test_app.py
└── docs/
```

For small studies or scripts:

```text
project/
├── pyproject.toml
├── README.md
├── main.py
├── notebooks/
└── data/
```

----

# 8. Mental Workflow

```text
Create project -> choose Python -> install dependencies
Configure tools -> Ruff / Pytest / Taskipy
Write code -> run tasks -> test -> commit
```

The goal is not to make the setup complex. The goal is to make it repeatable.

----

# 9. Final Checklist

- [ ] Python version managed with `pyenv`
- [ ] Global Python CLI tools managed with `pipx`
- [ ] Dependencies managed with Poetry
- [ ] Development tasks automated with Taskipy
- [ ] Code quality handled by Ruff
- [ ] Tests handled by Pytest
- [ ] Editor configured for the project
- [ ] Generated files ignored correctly
- [ ] Project commands documented

This is my base development setup. I can extend it depending on the project, but this gives me a solid starting point for Python, backend, frontend, and MLOps-related work.

----

<img src="/assets/img/posts/Written-By-a-Human-Not-By-AI-Badge-white.png" alt="Written By A Human Not By AI">
<img src="/assets/img/posts/Written-By-a-Human-Not-By-AI-Badge-black.png" alt="Written By A Human Not By AI">

</div>
