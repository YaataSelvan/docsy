# Docsy

> Smart Docs for Smart Minds.

Documentation site for the **Purdue CYAN Lab**, built with [Sphinx](https://www.sphinx-doc.org/)
and the [Read the Docs theme](https://sphinx-rtd-theme.readthedocs.io/). Python
dependencies are managed with [uv](https://docs.astral.sh/uv/). Building the project
produces a self-contained static HTML site that can be served by any web server or
published to Read the Docs.

## Prerequisites

| Tool                              | Version    | Purpose                                                                  |
| --------------------------------- | ---------- | ------------------------------------------------------------------------ |
| [Python](https://www.python.org/) | **3.13+**  | Runtime for Sphinx (see `pyproject.toml`)                                |
| [uv](https://docs.astral.sh/uv/)  | latest     | Creates the virtual environment and installs pinned dependencies         |
| [Git](https://git-scm.com/)       | any recent | Required at build time — the `sphinx_git` extension reads commit history |
| [Graphviz](https://graphviz.org/) | any recent | Provides the `dot` binary used by `sphinx.ext.graphviz` diagrams         |

Install the system dependencies (Python is handled by uv):

```bash
# macOS (Homebrew)
brew install uv git graphviz

# Debian / Ubuntu
sudo apt-get update && sudo apt-get install -y git graphviz
curl -LsSf https://astral.sh/uv/install.sh | sh   # installs uv
```

> **Note:** uv will automatically download and manage Python 3.13 if it is not
> already on your system, so you do not need to install Python separately.

## Getting started

Clone the repository **with full history** (the changelog page uses `sphinx_git`
directives that read past commits, so a shallow clone renders an incomplete
changelog):

```bash
git clone https://github.com/purduecyan/docsy.git
cd docsy
```

### Install the packages

```bash
uv sync
```

This creates a `.venv/` in the project root and installs the exact dependency
versions pinned in `uv.lock`, including:

- `sphinx` — the documentation engine
- `sphinx-rtd-theme` — the Read the Docs HTML theme
- `sphinx-autoapi`, `sphinx-git`, `sphinx-prompt`, `sphinx-copybutton`,
  `sphinx-design`, `sphinx-code-tabs`, `sphinxcontrib-jquery` — extensions
- `sphinx-autobuild` — live-reloading preview server

<details>
<summary>Prefer plain <code>pip</code> instead of uv?</summary>

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install .
```

This installs the project and its dependencies from `pyproject.toml`. (This is the
same method Read the Docs uses — see `docs/.readthedocs.yaml`.)

</details>

## Building the documentation

The Sphinx project lives in `docs/`, with source files under `docs/source/`, and is
built with `make`. First activate the environment created by `uv sync` so that `make`
can find `sphinx-build`:

```bash
source .venv/bin/activate        # Windows: .venv\Scripts\activate
```

Then build the HTML site from the `docs/` directory:

```bash
cd docs
make html
```

The rendered site is written to **`build/html/`** (i.e. `docs/build/html/`). Open it
in a browser:

```bash
# macOS
open build/html/index.html
# Linux
xdg-open build/html/index.html
```

Other useful targets:

```bash
make help     # list all available output formats (singlehtml, latexpdf, epub, …)
make clean    # remove previous build artifacts
```

> **Windows:** if `make` is not available, use the bundled `make.bat` (e.g.
> `.\make.bat html`) or run `sphinx-build -b html source build/html` from `docs/`.

### Live preview while writing

`sphinx-autobuild` rebuilds the site and refreshes your browser automatically each
time you save a source file. With the environment activated, run it from `docs/`:

```bash
cd docs
sphinx-autobuild source build/html
```

Then browse to <http://127.0.0.1:8000>.

## Project layout

```
docsy/
├── code/                    # Source code documented by the site
├── docs/
│   ├── Makefile             # `make html`, `make clean`, …
│   ├── make.bat             # Windows equivalent
│   ├── .readthedocs.yaml    # Read the Docs build configuration
│   └── source/
│       ├── conf.py          # Sphinx configuration (theme, extensions)
│       ├── index.rst        # Documentation home / root toctree
│       ├── _static/         # Images and other static assets
│       ├── _templates/      # Theme template overrides
│       └── main/            # Content pages
│           ├── get-started.rst
│           ├── add-code.rst
│           ├── authors.rst
│           └── changelog.rst
├── pyproject.toml           # Project metadata and dependencies
├── uv.lock                  # Pinned, reproducible dependency versions
└── README.md
```

## Writing documentation

- Content is authored in **reStructuredText** (`.rst`) under `docs/source/`.
- Add a new page by creating a `.rst` file (e.g. under `docs/source/main/`) and
  linking it from the `toctree` in `docs/source/index.rst`.
- Site-wide settings — theme, enabled extensions, project name — live in
  `docs/source/conf.py`.
- Preview your changes locally with the live-preview command above before pushing.

## Deployment (Read the Docs)

The repository is configured for [Read the Docs](https://readthedocs.org/) via
`docs/.readthedocs.yaml`, which installs the project with pip and builds
`docs/source/conf.py`. Pushing to the default branch triggers a rebuild on the
connected Read the Docs project.

## Troubleshooting

| Symptom                                                 | Fix                                                                                 |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `dot: command not found` / graphviz errors during build | Install Graphviz so the `dot` binary is on your `PATH` (see Prerequisites).         |
| Changelog page is empty or missing entries              | Build from a **full** clone; `sphinx_git` needs commit history (avoid `--depth 1`). |
| `sphinx-build` not found when running `make` directly   | Activate the environment first, or prefix commands with `uv run`.                   |
| Python version errors                                   | This project requires Python **3.13+**; let `uv` provision it with `uv sync`.       |

## License

This project is licensed under the **GNU General Public License v3.0**. See
[`LICENSE`](LICENSE) for details.


## Docker Compose Lab

### Prerequisites

- Docker Engine and Docker Compose supporting `!override`
- Git and GNU Make
- Run all commands from the repository root.

### Environment configuration

Create a local `.env` file:

```dotenv
DOCS_PORT=8080
PROJECT_NAME=Docsy
SPHINX_THEME=sphinx_rtd_theme
```

The `.env` file is ignored by Git and must not be committed.

### Services and storage

- `builder`: builds Sphinx HTML into the `site` volume and remains running
  for its health check.
- `web`: serves the generated HTML with Nginx after builder becomes healthy.
- `dev`: provides live reload through the `dev` profile.
- `dozzle`: displays container console logs through the `obs` profile.
- `cadvisor`: displays container metrics through the `obs` profile.

The repository is mounted read-only at `/work`.
Nginx configuration is bind-mounted read-only.
Named volumes store generated HTML (`site`), Nginx cache (`ops`),
and Nginx logs (`weblogs`, enabled by the override).

### Commands

| Command | Behavior |
|---|---|
| `make up` | Build and start the base services |
| `make prod` | Activate the prod profile and start the base services |
| `make dev` | Start the base services and live-reload service |
| `make obs` | Start the base services and observability services |
| `make down` | Remove containers and network, retaining volumes |
| `make logs` | Follow service logs; Ctrl+C exits log viewing |
| `make clean` | Remove containers, network, and named volumes |

Builder and web are unprofiled and always start.
Optional services already running remain running when another profile
is started. For a base-only production session, run `make down`
followed by `make prod`.

### Access URLs

On the Docker host:

- Documentation: http://localhost:8081
- Live reload: http://localhost:8000
- Dozzle: http://localhost:9000
- cAdvisor: http://localhost:9100

Dozzle and cAdvisor bind to host loopback only.
For remote access, run this on your own computer, replacing USER and HOST:

```bash
ssh -N \
  -L 8081:127.0.0.1:8081 \
  -L 8000:127.0.0.1:8000 \
  -L 9000:127.0.0.1:9000 \
  -L 9100:127.0.0.1:9100 \
  USER@HOST
```

### Override behavior

`docker-compose.override.yml` is loaded automatically.
It replaces the web port with 8081 and adds persistent Nginx logs.

To use DOCS_PORT from `.env` without the override:

```bash
docker compose -f docker-compose.yml up -d
```

To restore the override:

```bash
docker compose up -d
```

### Validation

```bash
docker compose --profile "*" config --quiet
docker compose --profile "*" ps
curl -fsS http://localhost:8081/
docker compose exec web tail /var/log/nginx/docsy-access.log
```

Builder checks for `/site/index.html`.
Web checks HTTP on container port 80.
Nginx listens on IPv4 and IPv6 so its localhost health check works.

Edit a documentation page while `make dev` is active and confirm
the browser updates automatically.

Dozzle displays container console output. Custom Nginx access logs
are stored at `/var/log/nginx/docsy-access.log`.

### Added documentation

- Docker Compose Overview
- Documentation Development Workflow
