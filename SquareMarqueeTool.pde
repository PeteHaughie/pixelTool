class SquareMarqueeTool extends Tool {
  float startX, startY;
  boolean dragging = false;
  float selX = 0, selY = 0, selW = 0, selH = 0;

  SquareMarqueeTool() {
    super("Marquee");
  }

  void onMousePressed(float x, float y) {
    startX = x;
    startY = y;
    dragging = true;
    selW = selH = 0;
    selX = floor(startX);
    selY = floor(startY);
  }

  void onMouseDragged(float x, float y) {
    if (!dragging) return;
    // compute rectangular selection from start -> current
    float x0 = min(startX, x);
    float y0 = min(startY, y);
    float w = abs(x - startX);
    float h = abs(y - startY);

    selX = floor(x0);
    selY = floor(y0);
    selW = max(0, ceil(w));
    selH = max(0, ceil(h));
  }

  void onMouseReleased(float x, float y) {
    if (!dragging) return;
    onMouseDragged(x, y);
    dragging = false;
    // selection persists until cleared or replaced
  }

  void drawOverlay(PGraphics pg) {
    if (selW <= 0 || selH <= 0) return;
    pg.pushStyle();
    // translucent fill
    pg.noStroke();
    pg.fill(0, 120);
    pg.rect(selX, selY, selW, selH);

    // outline
    pg.noFill();
    pg.stroke(255);
    pg.strokeWeight(1);
    pg.rect(selX, selY, selW, selH);
    pg.popStyle();
  }

  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> p = new ArrayList<PixelSpec>();
    int margin = max(1, size/6);
    int s = size - margin*2;
    for (int y = 0; y < s; y++) {
      for (int x = 0; x < s; x++) {
        if (y == 0 || y == s-1 || x == 0 || x == s-1) {
          p.add(new PixelSpec(x+margin, y+margin, color(0)));
        }
      }
    }
    return p;
  }
}
