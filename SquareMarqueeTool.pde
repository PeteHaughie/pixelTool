// marching ants settings (global for this tool file)
int antsOffset = 0;
int antsDash = 4; // length of dash in pixels
int antsSpeedMs = 60; // milliseconds per step (higher = slower)
int antsLastTick = 0;

class SquareMarqueeTool extends Tool {
  float startX, startY;
  boolean dragging = false;
  float selX = 0, selY = 0, selW = 0, selH = 0;

  SquareMarqueeTool() {
    super("Marquee");
  }

  // Clear selection when the tool becomes active so previous coords aren't reused
  void onActivate() {
    selW = selH = 0;
    selX = selY = 0;
    dragging = false;
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

    // marching ants outline
    pg.noFill();
    pg.strokeWeight(1);
    pg.noSmooth();

    // advance animation offset on a timer to slow down animation
    int now = millis();
    if (now - antsLastTick >= antsSpeedMs) {
      antsOffset = (antsOffset + 1) % (antsDash * 2);
      antsLastTick = now;
    }

    // Draw perimeter in clockwise order using a single perimeter index
    int sw = (int)selW;
    int sh = (int)selH;
    int perimeter = 2 * (sw + sh) - 4;
    if (perimeter > 0) {
      int idx = 0;
      // top edge (left -> right)
      for (int i = 0; i < sw; i++) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) pg.stroke(255); else pg.stroke(0);
        pg.point(selX + i, selY);
      }
      // right edge (top+1 -> bottom-1)
      for (int j = 1; j < sh-1; j++) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) pg.stroke(255); else pg.stroke(0);
        pg.point(selX + sw - 1, selY + j);
      }
      // bottom edge (right -> left)
      for (int i = sw - 1; i >= 0; i--) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) pg.stroke(255); else pg.stroke(0);
        pg.point(selX + i, selY + sh - 1);
      }
      // left edge (bottom-1 -> top+1)
      for (int j = sh - 2; j >= 1; j--) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) pg.stroke(255); else pg.stroke(0);
        pg.point(selX, selY + j);
      }
    }
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
