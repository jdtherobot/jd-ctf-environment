# Proposed hint ladders (all four challenges)

Graduated mild → near-solution. Costs are **placeholders** (see README). Paste a
block into the matching `CH` entry in `browser-lab/workbench.html` to promote it.
`spoiler:true` gates a hint behind a confirm.

Live today: **C2** and **C3** ship the two originals each. **C1** and **C4** ship
no hints. Everything below is a proposal.

---

## Challenge 1 — Photo Day (base 100) — *currently no live hints*

```js
hints:[
  { cost:15, body:"Read the whole email, not just the picture — an email carries its attachment, and the sender protests a little too much about one “definitely not the password” line." },
  { cost:25, body:"The photo’s metadata carries more than camera settings. List every field and look for one that doesn’t belong." },
  { cost:40, spoiler:true, body:"That odd Comment field is base64 that decodes to a “Salted__” OpenSSL blob. Decrypt it with AES-256-CBC + PBKDF2, using the password from the email body." }
]
```

## Challenge 2 — Stegosaurus 1 (base 200) — *live: the two originals*

```js
hints:[
  { cost:25, body:"WE WILL, WE WILL…" },
  { cost:50, body:"Try common password lists / stego tools." },
  { cost:80, spoiler:true, body:"The data is embedded with steghide behind a weak passphrase. Finish the lyric (rockyou), crack it (stegcracker/stegseek against rockyou), then read line 1 of the extracted file — that’s the flag. Keep the whole file; it matters later." }
]
```

## Challenge 3 — The Memory Warehouse (base 300) — *live: the two originals*

```js
hints:[
  { cost:50, body:"Each level of the walk is one warehouse coordinate — L1 = row (1–10); L2 = shelf level (bottom = 1 → top = 3); L3 = bay depth (front = 1, back = 2); L4 = sub-section of that bay’s grate; and the offset = the box number." },
  { cost:75, spoiler:true, body:"Split the low 48 bits of the VA into [L1 9][L2 9][L3 9][L4 9][OFFSET 12]. Walk level by level (L1 → L4), then use the offset to pick the exact box." },
  { cost:120, spoiler:true, body:"It resolves to row 2, shelf level 1 (bottom), back bay (2), sub-section 1, box 5. The note there is a four-square cipher keyed by its four corner words; the ciphertext is line 9 of the document Challenge 2 gave you." }
]
```

## Challenge 4 — Stegosaurus 3 (base 500) — *currently no live hints*

```js
hints:[
  { cost:40, body:"One file can be many files stacked together. Start by scanning it for other file signatures." },
  { cost:80, body:"Carve out every embedded file and expect at least one decoy. The bundle you can crack with an easy password holds a helper script, an IV, and an encrypted password list." },
  { cost:150, spoiler:true, body:"Use the helper script’s quantization-table stego plus the recovered key to pull the passwords out of the carved inner image, then use those to decrypt the real payload → the flag. Every layer protects the next." }
]
```
