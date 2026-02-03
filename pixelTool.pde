// Minimal skeleton for pixelTool — wires new modular classes.

CanvasBuffer canvasBuf;
Toolbar toolbar;
Preview preview;
PGraphics overlay;
StateManager state;
float canvasScale = 3.0;
float previewScale = 0.5;
int fgColor;
int bgColor;
PGraphics checkPattern;
int checkSize = 4;
int toolSize = 1;
String toolShape = "rect"; // future: support other shapes

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
  // add the swatch tool last so it's at the bottom of the list
  toolbar.addTool(new ColorTool());
  // default to the Pencil tool so drawing works immediately
  toolbar.setActiveByName("Pencil");

  // initial canvas clear
  canvasBuf.clear(color(255, 255, 255, 0));

  // foreground/background colors
  fgColor = color(0);
  bgColor = color(255);

  // State manager owns commit/undo and references the canvas
  state = new StateManager(canvasBuf);
}

void draw() {
  background(32);

  // draw canvas area (scaled) with checkerboard behind
  pushStyle();
  noSmooth();
  image(checkPattern, 100, 10, canvasBuf.w * canvasScale, canvasBuf.h * canvasScale);
  popStyle();
  canvasBuf.drawTo(100, 10, canvasScale);

  // draw tool overlay (draw in logical canvas coords into overlay, then composite scaled)
  overlay.beginDraw();
  overlay.clear();
  Tool active = toolbar.getActive();
  if (active != null) {
    active.drawOverlay(overlay);
  }
  // draw tool cursor at mouse position (in logical canvas coords)
  // hide system cursor while over canvas
  float canvasX = 100;
  float canvasY = 10;
  float canvasW = canvasBuf.w * canvasScale;
  float canvasH = canvasBuf.h * canvasScale;
  if (mouseX >= canvasX && mouseX <= canvasX + canvasW && mouseY >= canvasY && mouseY <= canvasY + canvasH) {
    noCursor();
    PVector c = screenToCanvas(mouseX, mouseY, canvasScale);
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
  image(overlay, 100, 10, canvasBuf.w * canvasScale, canvasBuf.h * canvasScale);
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
PVector screenToCanvas(float sx, float sy, float scale) {
  float cx = (sx - 100) / scale;
  float cy = (sy - 10) / scale;
  return new PVector(cx, cy);
}

void mousePressed() {
  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY, 3.0);
    t.onMousePressed(c.x, c.y);
  }
}

void mouseDragged() {
  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY, 3.0);
    t.onMouseDragged(c.x, c.y);
  }
}

void mouseReleased() {
  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY, 3.0);
    t.onMouseReleased(c.x, c.y);
  }
}

