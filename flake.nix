{
  description = "Nerd Font glyphs as a coloured freedesktop icon theme";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;

    forAllSystems = lib.genAttrs ["x86_64-linux" "aarch64-linux"];

    defaultPalette = {
      red = "#e06c75";
      orange = "#d19a66";
      yellow = "#e5c07b";
      green = "#98c379";
      cyan = "#56b6c2";
      blue = "#61afef";
      purple = "#c678dd";
      white = "#abb2bf";
    };

    # Build an icon theme holding every Nerd Font glyph once per palette colour.
    #
    #   palette   { red = "#f7768e"; blue = "7aa2f7"; ... } — colour name → hex
    #   name      theme name, i.e. the value for gtk-icon-theme-name
    #   inherits  theme to fall through to for everything that is not a glyph
    #
    # The glyphs and their names both come from the Symbols Nerd Font in
    # `pkgs`, so the theme always matches that nixpkgs' Nerd Fonts release.
    # Each colour becomes its own context, so an icon chooser lists "Nerd red",
    # "Nerd blue", ... as separate categories, and the icon `nf-fa-book-red`
    # lives in the first of them. Names carry the colour because lookup is by
    # name alone — the directory only decides the category.
    mkNerdIconTheme = {
      pkgs,
      palette ? defaultPalette,
      name ? "NerdIcons",
      inherits ? "hicolor",
    }: let
      hex = colour: value:
        if builtins.match "#?[0-9a-fA-F]{6}" value == null
        then throw "nf-icon: palette.${colour} = \"${value}\" is not a 6-digit hex colour"
        else "#" + lib.removePrefix "#" value;

      colours = lib.attrNames palette;
      dir = colour: "scalable/${colour}";

      indexTheme = lib.generators.toINI {} (
        {
          "Icon Theme" = {
            Name = name;
            Comment = "Nerd Font glyphs in ${toString (lib.length colours)} colours";
            Inherits = inherits;
            Directories = lib.concatMapStringsSep "," dir colours;
          };
        }
        // lib.listToAttrs (map (colour:
          lib.nameValuePair (dir colour) {
            Context = "Nerd ${colour}";
            Type = "Scalable";
            Size = 48;
            MinSize = 8;
            MaxSize = 512;
          })
        colours)
      );
    in
      pkgs.runCommand "nf-icon-theme-${name}" {
        nativeBuildInputs = [(pkgs.python3.withPackages (ps: [ps.fonttools]))];
        inherit indexTheme;
        palette = builtins.toJSON (lib.mapAttrs hex palette);
        passAsFile = ["indexTheme" "palette"];
        # The non-Mono face: Mono rescales every glyph into one cell width.
        font = "${pkgs.nerd-fonts.symbols-only}/share/fonts/truetype/NerdFonts/Symbols/SymbolsNerdFont-Regular.ttf";
      } ''
        theme="$out/share/icons/${name}"
        mkdir -p "$theme"
        cp "$indexThemePath" "$theme/index.theme"
        python3 ${./build.py} "$font" "$palettePath" "$theme/scalable"
      '';
  in {
    lib = {inherit mkNerdIconTheme;};

    packages = forAllSystems (system: {
      default = mkNerdIconTheme {pkgs = nixpkgs.legacyPackages.${system};};
    });
  };
}
