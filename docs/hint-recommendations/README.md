# Hint recommendations — for review, not live

The lab ships **only the hints you originally authored** (Challenge 2 and
Challenge 3). Challenges 1 and 4 had no author-written player hints in the
source, so they ship with none.

This folder holds a **proposed fuller hint ladder for all four challenges** so
you can decide what (if anything) to promote into the live lab. Nothing here is
live until you move it.

## Where the live hints come from

- Live hints live in `browser-lab/workbench.html`, in the `CH` array, as a
  `hints:[ { cost, body, spoiler? } ]` list per challenge (plus a `base` point
  value). They render as priced buttons in the challenge column, revealed one at
  a time; `spoiler:true` adds a confirm before revealing.
- Source of the live originals: `CTF Stego.md` ("Player Hints", "Warehouse
  Mapping", "Extra Hint").

## About the point costs

No per-hint point values survived in the repo — in the original CTFd they were
each hint's **Value** field (your screenshot shows one at `50`). The costs in
the live lab and in `proposed-hints.md` are **placeholders** scaled to each
challenge's base (100 / 200 / 300 / 500 from `PLAN.md`) and to how much each
hint gives away. Drop in your real numbers when you have them.

## How to promote a proposed ladder

Copy a challenge's `hints:[…]` block from `proposed-hints.md` into that
challenge's entry in the `CH` array in `browser-lab/workbench.html`, adjust the
costs, then re-stage and deploy (`browser-lab/stage-deploy.sh` → push
`gh-pages`). No other wiring needed — the UI reads whatever is in `hints`.
