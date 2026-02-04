// Minimal skeleton for pixelTool — wires new modular classes.

CanvasBuffer canvasBuf;
Toolbar toolbar;
Preview preview;
PGraphics overlay;
StateManager state;
SelectionOverlay selectionOverlay;
float previewScale = 0.5;
int fgColor;
int bgColor;
PGraphics checkPattern;
int checkSize = 4;
int toolSize = 1;
String toolShape = "rect"; // future: support other shapes
// panning state is managed in `state` (StateManager)

void settings() {
  size(800, 620);
  noSmooth();
}

void setup() {
  frameRate(60);

  // Create a canvas buffer at logical pixel size (e.g., 128x128)
  canvasBuf = new CanvasBuffer(128, 128);

  // Preview and toolbar
  preview = new Preview(128, 128);
  toolbar = new Toolbar();

  // Overlay layer (same logical size as canvas)
  overlay = createGraphics(128, 128, JAVA2D);

  // Checkerboard pattern (one-time generated)
  checkPattern = createGraphics(canvasBuf.w, canvasBuf.h);
  checkPattern.beginDraw();
  checkPattern.noStroke();
  int c1 = color(254, 197, 180);
  int c2 = color(246, 138, 152);
  for (int y = 0; y < canvasBuf.h; y += checkSize) {
    for (int x = 0; x < canvasBuf.w; x += checkSize) {
      int ix = (x / checkSize);
      int iy = (y / checkSize);
      if ((ix + iy) % 2 == 0) checkPattern.fill(c1); else checkPattern.fill(c2);
      checkPattern.rect(x, y, checkSize, checkSize);
    }
  }
  checkPattern.endDraw();

  // Register tools
  toolbar.addTool(new PencilTool());
  toolbar.addTool(new FloodFillTool());
  toolbar.addTool(new EraseTool());
  toolbar.addTool(new SquareMarqueeTool());
  toolbar.addTool(new PanTool());
  toolbar.addTool(new ZoomTool());
  // add the swatch tool last so it's at the bottom of the list
  toolbar.addTool(new ColorTool());
  // NOTE: no tool is active by default — user must select one explicitly

  // initial canvas clear
  canvasBuf.clear(color(255, 255, 255, 0));

  // foreground/background colors
  fgColor = color(0);
  bgColor = color(255);

  // State manager owns commit/undo and references the canvas
  state = new StateManager(canvasBuf);
  // selection overlay helper
  selectionOverlay = new SelectionOverlay();
}

void draw() {
  background(32);

  // draw canvas area (scaled) with checkerboard behind
  float drawScale = state.getZoomScale();
  float drawOffsetX = state.getZoomOffsetX();
  float drawOffsetY = state.getZoomOffsetY();
  pushStyle();
  noSmooth();
  image(checkPattern, drawOffsetX, drawOffsetY, canvasBuf.w * drawScale, canvasBuf.h * drawScale);
  popStyle();
  canvasBuf.drawTo(drawOffsetX, drawOffsetY, drawScale);

  // draw tool overlay (draw in logical canvas coords into overlay, then composite scaled)
  overlay.beginDraw();
  overlay.clear();
  // delegate selection drawing to helper
  selectionOverlay.draw(overlay, state);
  Tool active = toolbar.getActive();
  if (active != null) {
    active.drawOverlay(overlay);
  }
  // draw tool cursor at mouse position (in logical canvas coords)
  // hide system cursor while over canvas
  float canvasX = drawOffsetX;
  float canvasY = drawOffsetY;
  float canvasW = canvasBuf.w * drawScale;
  float canvasH = canvasBuf.h * drawScale;
  if (mouseX >= canvasX && mouseX <= canvasX + canvasW && mouseY >= canvasY && mouseY <= canvasY + canvasH) {
    noCursor();
    PVector c = screenToCanvas(mouseX, mouseY);
    int px = (int)round(c.x - 0.5);
    int py = (int)round(c.y - 0.5);
    int cs = (active != null) ? active.getCursorSize() : toolSize;
    String shape = (active != null) ? active.getCursorShape() : toolShape;
    int cc = (active != null) ? active.getCursorColor() : fgColor;
    overlay.pushStyle();
    overlay.noStroke();
    overlay.fill(cc, 160);
    if (shape.equals("rect")) {
      overlay.rect(px, py, cs, cs);
    } else {
      overlay.ellipse(px + cs/2.0, py + cs/2.0, cs, cs);
    }
    overlay.popStyle();
  } else {
    cursor();
  }
  overlay.endDraw();

  // composite overlay on top of the canvas (scaled to match canvas draw)
  pushStyle();
  image(overlay, drawOffsetX, drawOffsetY, canvasBuf.w * drawScale, canvasBuf.h * drawScale);
  popStyle();

  // update & draw preview (preview reflects committed canvas + overlay)
  preview.updateFrom(canvasBuf, overlay);
  // draw checkerboard behind preview and then the preview itself
  pushStyle();
  noSmooth();
  image(checkPattern, 700, 10, preview.w * previewScale, preview.h * previewScale);
  popStyle();
  preview.draw(700, 10, previewScale);

  // draw toolbar
  toolbar.draw(10, 10);

  // overlays are handled above and drawn to `overlay`
}

// Input dispatch — translate screen -> canvas coords
PVector screenToCanvas(float sx, float sy) {
  float useScale = state.getZoomScale();
  float useOffsetX = state.getZoomOffsetX();
  float useOffsetY = state.getZoomOffsetY();
  float cx = (sx - useOffsetX) / useScale;
  float cy = (sy - useOffsetY) / useScale;
  return new PVector(cx, cy);
}

