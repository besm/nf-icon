# nf-icon

nf-icon builds a freedesktop icon theme from the Nerd Fonts glyphs, in colours
you choose.

The theme contains every glyph once per palette colour, under names such as
`nf-fa-book-red` and `nf-md-cat-blue`. Each colour appears as its own category
in a GTK icon chooser.

## Usage

This command builds the theme with the default palette of eight colours:

```bash
nix build github:besm/nf-icon
```

To choose the colours, add the flake as an input and call
`lib.mkNerdIconTheme`:

```nix
inputs.nf-icon = {
  url = "github:besm/nf-icon";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
theme = nf-icon.lib.mkNerdIconTheme {
  inherit pkgs;
  palette = {
    red = "#e06c75";
    green = "#98c379";
    blue = "#61afef";
  };
};
```

| Argument | Default | Meaning |
|---|---|---|
| `pkgs` | required | The nixpkgs to build with. |
| `palette` | eight colours | Colour names mapped to 6-digit hex values. |
| `name` | `"NerdIcons"` | The name of the icon theme. |
| `inherits` | `"hicolor"` | The theme that supplies all other icons. |

The package installs the theme to `share/icons/<name>`. Icons are named
`nf-<set>-<glyph>-<colour>`, and the
[Nerd Fonts cheat sheet](https://www.nerdfonts.com/cheat-sheet) lists every
set and glyph.

With Home Manager, set `inherits` to the icon theme you already use, so that
it keeps supplying ordinary icons.

```nix
gtk.iconTheme = {
  name = "NerdIcons";
  package = nf-icon.lib.mkNerdIconTheme {
    inherit pkgs;
    inherits = "Papirus-Dark";
  };
};
```

## How it works

The theme is a single derivation. It reads the Symbols Nerd Font from `pkgs`,
takes each glyph's outline and name from the font, and writes one SVG per glyph
per colour. Nothing is vendored or downloaded, so the glyphs always match the
Nerd Fonts release in your nixpkgs.

The font has about 10,500 glyphs, so each palette colour adds that many icons.

## Licence

nf-icon uses the same terms as
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts). A built theme is under
the SIL Open Font License 1.1, the code is under the MIT License, and the
individual icon sets keep their own licences. [LICENSE](LICENSE) has the full
text.
