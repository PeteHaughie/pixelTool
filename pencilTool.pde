class PencilTool extends Tool {
  ArrayList<PVector> stroke;

  PencilTool() {
    super("Pencil");
    stroke = new ArrayList<PVector>();
  }

  // expose cursor preferences for this tool
  int getCursorSize() {
    return 1;
  }

  String getCursorShape() {
    return "rect";
  }

  int getCursorColor() {
    return fgColor;
  }

  void onMousePressed(float x, float y) {
    stroke.clear();
    stroke.add(new PVector(x, y));
  }

  void onMouseDragged(float x, float y) {
    stroke.add(new PVector(x, y));
  }

  void onMouseReleased(float x, float y) {
    // commit into canvas via global state manager if present
    if (stroke.size() > 0) {
      if (state != null) {
        state.commitStroke(stroke, fgColor);
      }
      stroke.clear();
    }
  }

  void drawOverlay(PGraphics pg) {
    // draw a simple preview of the stroke (assumes caller opened beginDraw)
    pg.pushStyle();
    pg.noFill();
    pg.stroke(fgColor);
    pg.strokeWeight(1);
    pg.beginShape();
    for (PVector p : stroke) pg.vertex(p.x, p.y);
    pg.endShape();
    pg.popStyle();
  }

  // Return a tiny pixel description of a pencil-like icon.
  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> out = new ArrayList<PixelSpec>();
    // simple diagonal line with a highlight - coordinates are 0..size-1
    for (int i = 0; i < size; i++) {
      int px = i;
      int py = size - 1 - i;
      out.add(new PixelSpec(px, py, color(30, 30, 30)));
    }
    // add a small tip color
    out.add(new PixelSpec(size-1, 0, color(200, 150, 60)));
    return out;
  }
}
