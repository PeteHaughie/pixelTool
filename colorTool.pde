class ColorTool extends Tool {
  ColorTool() {
    super("Colors");
  }

  // Swap the global foreground/background colors
  void swapColors() {
    int tmp = fgColor;
    fgColor = bgColor;
    bgColor = tmp;
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

    // Draw fills and outlines in order so background outline is covered
    // by the foreground fill where they overlap.
    // Back swatch: draw fill then its stroke
    pg.pushStyle();
    pg.noStroke();
    pg.fill(bgColor);
    pg.rect(xBack, yBack, sw, sw);
    pg.stroke(0);
    pg.strokeWeight(1);
    pg.noFill();
    pg.rect(xBack, yBack, sw, sw);
    // Foreground swatch: draw fill then its stroke (on top)
    pg.noStroke();
    pg.fill(fgColor);
    pg.rect(xTop, yTop, sw, sw);
    pg.stroke(0);
    pg.noFill();
    pg.rect(xTop, yTop, sw, sw);
    pg.popStyle();

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
    int yTop = y0;
    int yBack = y0 + off;
    // background square (drawn first)
    for (int xx = 0; xx < sw; xx++) {
      for (int yy = 0; yy < sw; yy++) {
        out.add(new PixelSpec(xBack + xx, yBack + yy, bgColor));
      }
    }
    // background outline (so it can be covered by the foreground fill)
    for (int dx = -1; dx <= sw; dx++) {
      int xb = xBack + dx;
      int ybTop = yBack - 1;
      int ybBottom = yBack + sw;
      if (xb >= 0 && xb < size) {
        if (ybTop >= 0) out.add(new PixelSpec(xb, ybTop, 0));
        if (ybBottom < size) out.add(new PixelSpec(xb, ybBottom, 0));
      }
    }
    for (int dy = 0; dy < sw; dy++) {
      int yb = yBack + dy;
      int xl = xBack - 1;
      int xr = xBack + sw;
      if (yb >= 0 && yb < size) {
        if (xl >= 0) out.add(new PixelSpec(xl, yb, 0));
        if (xr < size) out.add(new PixelSpec(xr, yb, 0));
      }
    }
    // foreground square (drawn on top)
    for (int xx = 0; xx < sw; xx++) {
      for (int yy = 0; yy < sw; yy++) {
        out.add(new PixelSpec(xTop + xx, yTop + yy, fgColor));
      }
    }
    // foreground outline (drawn last)
    for (int dx = -1; dx <= sw; dx++) {
      int xf = xTop + dx;
      int yfTop = yTop - 1;
      int yfBottom = yTop + sw;
      if (xf >= 0 && xf < size) {
        if (yfTop >= 0) out.add(new PixelSpec(xf, yfTop, 0));
        if (yfBottom < size) out.add(new PixelSpec(xf, yfBottom, 0));
      }
    }
    for (int dy = 0; dy < sw; dy++) {
      int yf = yTop + dy;
      int xl2 = xTop - 1;
      int xr2 = xTop + sw;
      if (yf >= 0 && yf < size) {
        if (xl2 >= 0) out.add(new PixelSpec(xl2, yf, 0));
        if (xr2 < size) out.add(new PixelSpec(xr2, yf, 0));
      }
    }
    return out;
  }
}
