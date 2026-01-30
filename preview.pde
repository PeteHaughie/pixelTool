class Preview {
  PGraphics preview;
  int w, h;

  Preview(int w, int h) {
    this.w = w;
    this.h = h;
    preview = createGraphics(w, h, JAVA2D);
  }

  // Update preview from a source canvas buffer and optional overlay (copy scaled)
  void updateFrom(CanvasBuffer canvas, PGraphics overlay) {
    preview.beginDraw();
    // keep preview transparent; checkerboard is drawn by the caller
    preview.clear();
    // Use a PImage snapshot of the source buffers to avoid cross-PGraphics draw issues
    PImage snap = canvas.getBuffer().get();
    preview.image(snap, 0, 0, w, h);
    if (overlay != null) {
      PImage oSnap = overlay.get();
      preview.image(oSnap, 0, 0, w, h);
    }
    preview.endDraw();
  }

  void draw(float x, float y, float drawScale) {
    image(preview, x, y, preview.width * drawScale, preview.height * drawScale);
  }
}
