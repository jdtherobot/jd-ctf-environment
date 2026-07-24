# Deploying the challenge environment to britt.gg

This repo is what the **"Launch challenges"** button on
[britt.gg](https://github.com/jdtherobot/jdtherobot.github.io) should open: the in-browser Linux lab
and the warehouse game. This guide takes it from "in the repo" to "live on the site."

> **Status (live):** the environment ships from an **orphan `gh-pages` branch** built by
> `browser-lab/stage-deploy.sh` (bundle = root `index.html` + `warehouse-game/` + `browser-lab/` with
> the built `image/dist/`), so `main` stays free of the ~460 MB image. The primary entry is the
> **Guided Workbench** (`browser-lab/workbench.html`): challenge picker, verbatim briefs, the files,
> the live 32-bit Linux terminal, and a facilitator Help menu (nudges + a hidden-until-asked toolbox).
> The lab image is Debian **bookworm** i386 booted root-over-9p in v86 via a custom `init=/sbin/lab-init`
> (see `browser-lab/image/README.md`). To re-deploy: rebuild the image, run `stage-deploy.sh`, and push
> the bundle to `gh-pages`. The manual steps below remain valid for a from-scratch setup.

britt.gg is served by the `jdtherobot.github.io` Pages site (user pages + `CNAME`). A separate repo
published with GitHub Pages lands at a **project-pages subpath under the same domain** —
`https://britt.gg/jd-ctf-environment/`. That is the natural home for this environment.

## What's ready vs. what needs a build

| Piece | State | Notes |
|---|---|---|
| **Warehouse game** (`warehouse-game/index.html`) | **Ready to ship** | Fully self-contained; no build, no headers. |
| **Browser lab — terminal** (`browser-lab/`) | **Needs the disk image built first** | v86 needs `image/dist/fs.json` + `flat/` (built per [`browser-lab/image/README.md`](browser-lab/image/README.md)) and the boot kernel. The chooser/landing works now; the terminal only boots once the image is present. |

**v86 needs no cross-origin-isolation headers**, so plain GitHub Pages is enough — no Cloudflare or
`coi-serviceworker` required (that's only for the CheerpX upgrade path; see
[`browser-lab/ENGINE_DECISION.md`](browser-lab/ENGINE_DECISION.md)).

## Step 1 — Add a root landing (the page "Launch challenges" opens)

This repo has no root `index.html` yet. Add one that offers the two surfaces. Minimal version:

```html
<!doctype html>
<meta charset="utf-8">
<title>Steganography CTF — Challenges</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{margin:0;background:#12140f;color:#e7e9df;font:16px/1.6 system-ui,sans-serif}
  .wrap{max-width:760px;margin:0 auto;padding:3rem 1.25rem}
  a.card{display:block;border:1px solid #2c3126;border-radius:10px;padding:1.2rem 1.4rem;
    margin:1rem 0;color:inherit;text-decoration:none}
  a.card:hover{border-color:#e0a83a}
  h1{font-size:1.9rem} .k{font-family:ui-monospace,monospace;color:#e0a83a;letter-spacing:.15em}
</style>
<div class="wrap">
  <div class="k">STEGANOGRAPHY CTF</div>
  <h1>Launch the challenges</h1>
  <a class="card" href="./warehouse-game/"><b>Warehouse game →</b><br>Walk the memory warehouse (Challenge&nbsp;4).</a>
  <a class="card" href="./browser-lab/"><b>Browser lab →</b><br>A 32-bit Linux terminal in your browser — solve every challenge, no install.</a>
</div>
```

(Long-term, the goal is to launch the warehouse game **from inside** the lab environment; for now the
landing is the simplest bridge.)

## Step 2 — Build the lab disk image (for the terminal)

Follow [`browser-lab/image/README.md`](browser-lab/image/README.md): `build-image.sh` bakes the
sanitized player files + toolchain into a Debian-i386 rootfs and emits `image/dist/{fs.json,flat/}`.
The boot kernel is fetched into `vendor/` (both are gitignored by size). For hosting you have two options:
- **Commit the built artifacts** (`image/dist/` + `vendor/*.bin`) so Pages serves them directly, or
- Keep them out of git and add a build step that produces them into `dist/` before publish.

Until this is done, ship Step 1's landing with the **warehouse game live** and the lab as "coming
online" — the game alone is a complete, self-contained Challenge 4 experience.

## Step 3 — Publish with GitHub Pages

Repo **Settings → Pages → Build and deployment → Deploy from a branch**, branch `main`, folder `/`
(root). Save. Pages builds and serves at `https://britt.gg/jd-ctf-environment/`.

(If you'd rather keep the repo tidy, move the publishable set — `index.html`, `warehouse-game/`,
`browser-lab/`, built `image/dist/` — into a `/docs` folder and point Pages at `/docs`.)

## Step 4 — Point the site's button at the live page

In `jdtherobot.github.io/src/content/projects.ts`, the `steganography-ctf` project currently has a
placeholder `liveUrl` (this repo). Swap it for the deployed URL — one line:

```ts
// liveUrl: 'https://github.com/jdtherobot/jd-ctf-environment',   // placeholder
liveUrl: 'https://britt.gg/jd-ctf-environment/',                  // live environment
```

That updates **both** the flagship "Launch challenges" button and the persistent one on every writeup
page (they read the same field). Commit + push the site to deploy.

## Verify
- `https://britt.gg/jd-ctf-environment/` loads the landing.
- Warehouse game plays; the correct box (row 2 · shelf 1 · bay 2 · subsection 1 · box 5) reveals the note.
- Once the image is built, the lab terminal boots a 32-bit shell with the challenge files under
  `~/challenges/`.
- On britt.gg, "Launch challenges" (flagship + every writeup tab) opens the environment.
