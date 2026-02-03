class PanTool extends Tool {
  PanTool() {
    super("Pan");
  }

  void onActivate() {
    if (state != null) {
      // sticky pan enabled when Pan tool is activated
      state.setPanSticky(true);
      state.setPanning(true);
    }
  }

  void onDeactivate() {
    if (state != null) {
      // clearing sticky pan when tool is deactivated
      state.setPanSticky(false);
      state.setPanning(false);
    }
  }

  void onMousePressed(float x, float y) {
    // pan interaction is handled globally in pixelTool via state
  }

  void onMouseDragged(float x, float y) {
  }

  void onMouseReleased(float x, float y) {
  }

  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> pxs = new ArrayList<PixelSpec>();
    int cx = size/2;
    int cy = size/2;
    // simple hand/drag icon — a small filled square
    for (int y = -1; y <= 1; y++) {
      for (int x = -1; x <= 1; x++) {
        pxs.add(new PixelSpec(cx + x, cy + y, color(0)));
      }
    }
    return pxs;
  }

  int getCursorSize() { return 1; }
  String getCursorShape() { return "rect"; }
}
