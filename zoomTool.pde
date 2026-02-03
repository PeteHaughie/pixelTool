class ZoomTool extends Tool {
  float startScale;
  float startMouseY;
  float focalUx, focalUy; // logical focal point under cursor when drag begins
  boolean dragging = false;

  ZoomTool() {
    super("Zoom");
  }

  void onMousePressed(float x, float y) {
    // x,y are logical canvas coords under the pointer
    startScale = state.getZoomScale();
    startMouseY = mouseY;
    focalUx = x;
    focalUy = y;
    dragging = true;
  }

  void onMouseDragged(float x, float y) {
    if (!dragging) return;
    // vertical drag -> exponential zoom: drag up = zoom in, drag down = zoom out
    float dy = startMouseY - mouseY;
    float factor = pow(1.005, dy);
    // compute screen position of focal logical point
    float curScale = state.getZoomScale();
    float curOffsetX = state.getZoomOffsetX();
    float curOffsetY = state.getZoomOffsetY();
    float sx = curOffsetX + focalUx * curScale;
    float sy = curOffsetY + focalUy * curScale;
    zoomBy(factor, sx, sy);
  }

  void onMouseReleased(float x, float y) {
    dragging = false;
  }

  void drawOverlay(PGraphics pg) {
    // draw a tiny '+' at focal point when active
    pg.pushStyle();
    pg.noFill();
    pg.stroke(0, 200);
    pg.strokeWeight(1);
    pg.rect(1, 1, 1, 1);
    pg.popStyle();
  }

  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> pxs = new ArrayList<PixelSpec>();
    int cx = size/2;
    int cy = size/2;
    int r = max(2, size/4);
    // draw simple circle ring
    for (int dy = -r; dy <= r; dy++) {
      for (int dx = -r; dx <= r; dx++) {
        int dist = dx*dx + dy*dy;
        if (dist <= r*r && dist >= (r-1)*(r-1)) {
          pxs.add(new PixelSpec(cx+dx, cy+dy, color(0)));
        }
      }
    }
    // handle (diagonal) line for magnifier handle
    int hx = cx + r;
    int hy = cy + r;
    for (int i = 0; i < max(2, size/6); i++) {
      pxs.add(new PixelSpec(hx + i, hy + i, color(0)));
    }
    return pxs;
  }

  int getCursorSize() {
    return 1;
  }

  String getCursorShape() {
    return "rect";
  }

  // Zoom by a multiplicative factor, keeping logical point under (screenX,screenY)
  void zoomBy(float factor, float screenX, float screenY) {
    if (state == null) return;

    float prev = state.getZoomScale();
    float curOffsetX = state.getZoomOffsetX();
    float curOffsetY = state.getZoomOffsetY();

    // If the provided screen coords are outside the canvas, use the canvas center
    if (!(screenX >= curOffsetX && screenX <= curOffsetX + canvasBuf.w * prev && screenY >= curOffsetY && screenY <= curOffsetY + canvasBuf.h * prev)) {
      float ux = canvasBuf.w/2.0;
      float uy = canvasBuf.h/2.0;
      screenX = curOffsetX + ux * prev;
      screenY = curOffsetY + uy * prev;
    }
    float ux = (screenX - curOffsetX) / prev;
    float uy = (screenY - curOffsetY) / prev;

    float newScale = constrain(prev * factor, state.getMinZoom(), state.getMaxZoom());
    float newOffsetX = screenX - ux * newScale;
    float newOffsetY = screenY - uy * newScale;

    state.setZoomState(newScale, newOffsetX, newOffsetY);
  }
}
