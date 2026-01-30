class EraseTool extends Tool {
  ArrayList<PVector> stroke;
  int eraseColor;

  EraseTool() {
    super("Erase");
    stroke = new ArrayList<PVector>();
    // transparent fill (white with 0 alpha) to represent erasing to transparent
    eraseColor = color(255, 255, 255, 0);
  }

  int getCursorSize() {
    return 1;
  }

  String getCursorShape() {
    return "rect";
  }

  int getCursorColor() {
    return color(200, 0, 0);
  }

  void onMousePressed(float x, float y) {
    stroke.clear();
    stroke.add(new PVector(x, y));
  }

  void onMouseDragged(float x, float y) {
    stroke.add(new PVector(x, y));
  }

  void onMouseReleased(float x, float y) {
    if (stroke.size() > 0) {
      if (state != null) {
        state.commitStroke(stroke, eraseColor);
      }
      stroke.clear();
    }
  }

  void drawOverlay(PGraphics pg) {
    pg.pushStyle();
    pg.noFill();
    pg.stroke(getCursorColor());
    pg.strokeWeight(1);
    pg.beginShape();
    for (PVector p : stroke) pg.vertex(p.x, p.y);
    pg.endShape();
    pg.popStyle();
  }

  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> out = new ArrayList<PixelSpec>();
    // simple rounded eraser shape: fill a small rectangle with a highlight
    int w = max(4, size-4);
    int h = max(3, size/3);
    int ox = (size - w) / 2;
    int oy = (size - h) / 2;
    int baseCol = color(200, 120, 140);
    int rim = color(230, 200, 200);
    for (int yy = 0; yy < h; yy++) {
      for (int xx = 0; xx < w; xx++) {
        int cx = ox + xx;
        int cy = oy + yy;
        out.add(new PixelSpec(cx, cy, baseCol));
      }
    }
    // highlight pixels
    out.add(new PixelSpec(ox, oy, rim));
    out.add(new PixelSpec(ox+1, oy, rim));
    return out;
  }
}
