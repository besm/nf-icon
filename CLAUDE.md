# CLAUDE.md

Nerd Font glyphs packaged as a coloured freedesktop icon theme. See
[README.md](README.md) for usage.

## Layout

- `flake.nix` — `lib.mkNerdIconTheme` and `packages.default` (the same
  function with the default palette).
- `build.py` — run inside the derivation: reads the font, writes the SVGs.

## Rules

- The whole theme is built in the derivation, from the Symbols Nerd Font in
  `pkgs`. Never commit generated SVGs, and never add a step that has to be run
  by hand or writes into the checkout.
- Glyph names come from the font itself. Do not add a separate name table.
- `mkNerdIconTheme` uses only the `pkgs` it is given; the flake's own nixpkgs
  is for `packages.default`.
- Icon names end in the colour (`nf-fa-book-red`). Icon lookup is by name
  alone, so the same glyph in two colours needs two names.

## Checking a change

```bash
nix build
nix flake check
```

Format Nix with `alejandra` and Python with `black`.
