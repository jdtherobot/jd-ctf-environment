# JD CTF — Environment

The **runnable environment** for the Steganography CTF: an in-browser 32-bit Linux lab where players
solve the challenges without installing anything, plus the playable warehouse game used in
Challenge 4. This is the companion to the challenge/content repo:

**→ Challenges, briefings, writeups, and answers: [`jdtherobot/steganography-ctf`](https://github.com/jdtherobot/steganography-ctf)**

Keep the two straight:
- **`steganography-ctf`** = the CTF itself (what you play, and how it works).
- **this repo** = the environment it runs *in* (the browser lab + the warehouse game + hosting configs).

## What's here

```
browser-lab/         In-browser 32-bit Linux lab (v86 + xterm). Chooser landing, terminal,
                     the disk-image build recipe, and the i386 toolchain feasibility proof.
warehouse-game/      The top-down warehouse (Challenge 4's clue delivery). Self-contained static site.
deploy/lab/          Hosting configs for the lab (COOP/COEP headers for CheerpX; v86 needs none).
participant/         ⚠ Lab INPUTS ONLY — the sanitized player files the lab image bakes in
build/               (challenge files + briefs + trimmed wordlist + the secret-scan gate).
                     These are copies; the authoritative originals live in steganography-ctf.
```

> `participant/` and `build/` here are **not** the full CTF — they are only the sanitized inputs the
> lab image needs, placed at the paths the build scripts expect. Nothing here contains a flag or a
> creator-only secret (enforced by `build/secret-scan/scan.sh`).

## Run it locally

**The browser lab** (a real 32-bit Linux terminal in your browser):
```bash
cd browser-lab
python3 -m http.server 8001      # → http://localhost:8001  (index.html = chooser; terminal.html = shell)
```

**The warehouse game:**
```bash
python3 -m http.server 8002      # from the repo root → http://localhost:8002/warehouse-game/
```

Use a real server, not `file://` — both rely on browser APIs that `file://` blocks. The lab also
needs internet (it loads v86/xterm from a CDN and fetches the boot image).

## Building the lab disk image

`browser-lab/image/` has the reproducible recipe (Dockerfile + `build-image.sh`) that bakes the
toolkit (`steghide`, `openssl`, `binwalk`, `python3`, `exiftool`, …) and the sanitized player files
into a bootable image. See `browser-lab/image/README.md`. The toolchain is proven — it solves
Challenges 2 and 3 inside a real 32-bit container (`browser-lab/feasibility/i386-toolchain-proof.md`).

## Hosting

`browser-lab/ENGINE_DECISION.md` recommends **v86 + GitHub Pages** (no special headers) now, with
**CheerpX + Cloudflare Pages** (`deploy/lab/_headers`) as the GUI upgrade path. See `deploy/lab/README.md`.

## Roadmap

The near-term goal is to launch the warehouse game **from inside** the browser environment, so a
player does all of Challenge 4 in one place. For now the game is a standalone site the CTF links to.

## Academic use

An authorized, self-contained educational environment operating only on supplied local files — no
third-party systems, live services, or real credentials. Full statement in the
[content repo](https://github.com/jdtherobot/steganography-ctf/blob/main/facilitator/ACADEMIC_USE.md).
