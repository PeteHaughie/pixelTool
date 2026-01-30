class ColorTool extends Tool {
  ColorTool() {
    super("Colors");
  }

  // Show the current fg/bg as a small overlay in canvas logical coords when active
  void drawOverlay(PGraphics pg) {
    // assume caller has begun the overlay
    pg.pushStyle();
    int sw = 6; // swatch size in logical pixels
    int pad = 2;
    int x = pad;
    int y = pad;

    pg.noStroke();
    pg.fill(fgColor);
    pg.rect(x, y, sw, sw);
    pg.fill(bgColor);
    pg.rect(x + sw + pad, y, sw, sw);

    // highlight which is active (based on toolbar selection)
    if (toolbar != null && toolbar.getActive() == this) {
      pg.noFill();
      pg.stroke(255, 0, 0);
      pg.strokeWeight(1);
      // highlight the fg swatch
      pg.rect(x - 1, y - 1, sw + 2, sw + 2);
    }

    pg.popStyle();
  }

  // Create a small pixel-icon: left square = fg, right = bg
  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> out = new ArrayList<PixelSpec>();
    int sw = max(2, size/3);
    int pad = max(1, (size - (sw*2)) / 3);
    int y0 = (size - sw) / 2;
    int x0 = pad;
    // left square
    for (int xx = 0; xx < sw; xx++) {
      for (int yy = 0; yy < sw; yy++) {
        out.add(new PixelSpec(x0 + xx, y0 + yy, fgColor));
      }
    }
    // right square
    int x1 = x0 + sw + pad;
    for (int xx = 0; xx < sw; xx++) {
      for (int yy = 0; yy < sw; yy++) {
        out.add(new PixelSpec(x1 + xx, y0 + yy, bgColor));
      }
    }
    return out;
  }
}
