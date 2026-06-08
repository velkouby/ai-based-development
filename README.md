# AI-Native Software Engineering Notes

A bilingual MkDocs publication for articles and technical notes about AI-native software development, agent-based coding, and software engineering practices.

## Local setup

Install the dependencies:

```bash
pip install -r requirements.txt
```

Run the site locally:

```bash
mkdocs serve
```

Build the static site:

```bash
mkdocs build --strict
```

## Deployment

GitHub Actions deploys the site automatically when changes are pushed to `main`. The workflow installs the Python dependencies, validates the site with `mkdocs build --strict`, then publishes it to GitHub Pages with `mkdocs gh-deploy`.

To validate locally and trigger deployment from `main`:

```bash
./scripts/deploy.sh
```
