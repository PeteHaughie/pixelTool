

class SquareMarqueeTool extends Tool {
  float startX, startY;
  boolean dragging = false;
  // selection is now stored in StateManager (persistent across tools)

  SquareMarqueeTool() {
    super("Marquee");
  }

  void onMousePressed(float x, float y) {
    startX = x;
    startY = y;
    dragging = true;
    // initialize selection in the global state so it shows immediately
    int sx = floor(startX);
    int sy = floor(startY);
    state.setSelection(sx, sy, 0, 0);
  }

  void onMouseDragged(float x, float y) {
    if (!dragging) return;
    // compute rectangular selection from start -> current
    float x0 = min(startX, x);
    float y0 = min(startY, y);
    float w = abs(x - startX);
    float h = abs(y - startY);

    int sx = floor(x0);
    int sy = floor(y0);
    int sw = max(0, ceil(w));
    int sh = max(0, ceil(h));
    state.setSelection(sx, sy, sw, sh);
  }

  void onMouseReleased(float x, float y) {
    if (!dragging) return;
    onMouseDragged(x, y);
    dragging = false;
    // selection persists until cleared or replaced
  }

  void drawOverlay(PGraphics pg) {
    // Selection rendering moved to global overlay so it persists across tools.
    return;
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
