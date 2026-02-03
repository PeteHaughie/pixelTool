class ColorTool extends Tool {
  ColorTool() {
    super("Colors");
  }

  // Show the current fg/bg as a small overlay in canvas logical coords when active
  void drawOverlay(PGraphics pg) {
    // assume caller has begun the overlay
    pg.pushStyle();
    // simplified: fixed larger overlapped swatches
    int sw = 20; // swatch size in logical pixels
    int pad = 4; // padding from top-left
    int off = 6; // overlap offset between back and top swatch

    int xTop = pad;
    int yTop = pad;
    int xBack = xTop + off;
    int yBack = yTop + off;

    pg.noStroke();
    // back swatch (background color)
    pg.fill(bgColor);
    pg.rect(xBack, yBack, sw, sw);
    // top swatch (foreground color) — drawn last so it appears on top
    pg.fill(fgColor);
    pg.rect(xTop, yTop, sw, sw);

    pg.popStyle();
  }

  // Create a small pixel-icon: left square = fg, right = bg
  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> out = new ArrayList<PixelSpec>();
    // simplified discrete layout: bg drawn first, fg on top
    // use a larger swatch based on icon size so we don't get a tiny ~10px cap
    int sw = max(2, size - 4);
    int pad = 1;
    int y0 = (size - sw) / 2;
    int xTop = pad;
    int off = max(1, sw / 4);
    int xBack = xTop + off;
    // background square (drawn first)
    for (int xx = 0; xx < sw; xx++) {
      for (int yy = 0; yy < sw; yy++) {
        out.add(new PixelSpec(xBack + xx, y0 + yy, bgColor));
      }
    }
    // foreground square (drawn on top)
    for (int xx = 0; xx < sw; xx++) {
      for (int yy = 0; yy < sw; yy++) {
        out.add(new PixelSpec(xTop + xx, y0 + yy, fgColor));
      }
    }
    return out;
  }
}
