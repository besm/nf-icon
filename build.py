"""Write every glyph of a Nerd Font as an SVG icon, once per palette colour.

Called by flake.nix inside the theme derivation:

    build.py FONT PALETTE_JSON OUT_DIR

PALETTE_JSON maps colour name → "#rrggbb". Icons land at
OUT_DIR/<colour>/nf-<glyph>-<colour>.svg, named by the font's own glyph names.
"""

import json
import re
import sys
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

# Nerd Fonts names its glyphs `<set>-<glyph>` (fa-book, md-cat). The handful
# without such a name are generic `uniXXXX` symbols, not icons.
ICON_NAME = re.compile(r"[a-z]+-[a-z0-9_-]+")

# Blank border on each side, as a fraction of the icon's edge.
MARGIN = 0.0625

# Font outlines are y-up, SVG is y-down.
FLIP_Y = (1, 0, 0, -1, 0, 0)


def num(value: float) -> str:
    return f"{round(value, 1):g}"


def outline(glyph_set, glyph_name: str) -> tuple[str, str] | None:
    """Return (viewBox, path data) for one glyph, or None if it draws nothing."""
    bounds_pen = BoundsPen(glyph_set)
    glyph_set[glyph_name].draw(bounds_pen)
    if bounds_pen.bounds is None:
        return None
    x_min, y_min, x_max, y_max = bounds_pen.bounds

    path_pen = SVGPathPen(glyph_set, ntos=num)
    glyph_set[glyph_name].draw(TransformPen(path_pen, FLIP_Y))

    # Each glyph is framed by its own outline rather than the font's em box,
    # so a small glyph fills its icon instead of floating in an empty square.
    edge = max(x_max - x_min, y_max - y_min) / (1 - 2 * MARGIN)
    left = (x_min + x_max) / 2 - edge / 2
    top = -(y_min + y_max) / 2 - edge / 2
    view_box = " ".join(num(v) for v in (left, top, edge, edge))
    return view_box, path_pen.getCommands()


def main() -> int:
    font_path, palette_path, out = sys.argv[1], sys.argv[2], Path(sys.argv[3])
    palette = json.loads(Path(palette_path).read_text())

    font = TTFont(font_path)
    glyph_set = font.getGlyphSet()
    names = sorted(set((font.getBestCmap() or {}).values()))

    for colour in palette:
        (out / colour).mkdir(parents=True)

    written = 0
    for name in names:
        if not ICON_NAME.fullmatch(name):
            continue
        drawn = outline(glyph_set, name)
        if drawn is None:
            continue
        view_box, path = drawn
        for colour, fill in palette.items():
            (out / colour / f"nf-{name}-{colour}.svg").write_text(
                f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view_box}">'
                f'<path fill="{fill}" d="{path}"/></svg>\n'
            )
        written += 1

    print(f"{written} glyphs × {len(palette)} colours → {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
