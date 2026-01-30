class CanvasBuffer {
  PGraphics buf;
  int w, h;
  int[] logicalPixels;

  CanvasBuffer(int w, int h) {
    this.w = w;
    this.h = h;
    buf = createGraphics(w, h, JAVA2D);
    logicalPixels = new int[w * h];
    // Configure buffer rendering options before beginDraw (global noSmooth in settings())
    buf.beginDraw();
    buf.background(0, 0);
    buf.endDraw();
  }

  void clear(int bg) {
    // clear logical pixels and the buffer
    for (int i = 0; i < logicalPixels.length; i++) logicalPixels[i] = bg;
    buf.beginDraw();
    buf.noStroke();
    buf.background(bg);
    buf.endDraw();
  }

  // Set a single pixel within the canvas buffer
  void setPixel(int x, int y, int col) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    int idx = y * w + x;
    logicalPixels[idx] = col;
    buf.beginDraw();
    buf.noStroke();
    buf.fill(col);
    buf.rect(x, y, 1, 1);
    buf.endDraw();
  }

  // Draw the buffer to the main canvas at position x,y with a scale
  void drawTo(float x, float y, float scale) {
    pushStyle();
    // Use a PImage snapshot to avoid renderer/backing-store mismatches when
    // drawing the PGraphics directly.
    PImage snap = buf.get();
    image(snap, x, y, w * scale, h * scale);
    popStyle();
  }

  PGraphics getBuffer() {
    return buf;
  }

  int[] getLogicalPixels() {
    return logicalPixels;
  }
}
