# nf-icon

Nerd Font glyphs as a freedesktop icon theme, in whatever colours you give it.

Every glyph is built once per colour in your palette, so GTK icon choosers
(and anything else that looks icons up by name) can use `nf-fa-book-red`,
`nf-md-cat-blue`, and so on. Each colour shows up as its own category.

## Use

Build it as-is, with a default eight-colour palette:

```bash
nix build github:besm/nf-icon
```

Or call `lib.mkNerdIconTheme` with your own palette:

```nix
{
  inputs.nf-icon = {
    url = "github:besm/nf-icon";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nf-icon, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    theme = nf-icon.lib.mkNerdIconTheme {
      inherit pkgs;
      palette = {
        red = "#e06c75";
        green = "#98c379";
        blue = "#61afef";
      };
    };
  in {
    # install `theme`, then select the icon theme named "NerdIcons"
  };
}
```

| Argument | Default | |
|---|---|---|
| `pkgs` | required | your nixpkgs |
| `palette` | eight colours | colour name → 6-digit hex, with or without `#` |
| `name` | `"NerdIcons"` | the icon theme's name |
| `inherits` | `"hicolor"` | theme to fall back to for every other icon |

The result installs to `share/icons/<name>`. Icons are named
`nf-<set>-<glyph>-<colour>`, using the names from the
[Nerd Fonts cheat sheet](https://www.nerdfonts.com/cheat-sheet).

With Home Manager, keeping your usual theme for everything else:

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

The theme is one derivation. It reads the Symbols Nerd Font from `pkgs`, takes
each glyph's outline and name straight from the font, and writes one SVG per
glyph per colour. Nothing is vendored or downloaded, so the glyphs always match
the Nerd Fonts release in the nixpkgs you build with.

There are about 10,500 glyphs, so each palette colour adds that many icons.

## Licence

Same terms as [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts): a built
theme is under the SIL Open Font License 1.1, the code here is MIT, and the
individual icon sets keep their own licences. See [LICENSE](LICENSE).
