class PixelSpec {
  int x, y;
  int col;
  PixelSpec(int x, int y, int col) {
    this.x = x;
    this.y = y;
    this.col = col;
  }
}

abstract class Tool {
  String name;

  Tool(String name) {
    this.name = name;
  }

  void onMousePressed(float x, float y) {}
  void onMouseDragged(float x, float y) {}
  void onMouseReleased(float x, float y) {}

  // Draw overlays (cursor, preview) onto the supplied PGraphics or the main canvas.
  void drawOverlay(PGraphics pg) {}

  // Return a list of pixel specs describing an icon at given logical size (e.g. 16)
  ArrayList<PixelSpec> getIconPixels(int size) {
    return new ArrayList<PixelSpec>();
  }

  // Cursor/customization API (defaults can be overridden per-tool)
  int getCursorSize() {
    return 1;
  }

  String getCursorShape() {
    return "rect";
  }

  int getCursorColor() {
    return color(0);
  }
}
