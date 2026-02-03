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
// Pan/zoom state (canvas displayed at an offset and scale)
float canvasOffsetX = 100;
float canvasOffsetY = 10;
float minCanvasScale = 1.0;
float maxCanvasScale = 32.0;
boolean panning = false;
boolean panStickyByH = false; // true when panning was toggled on via 'h'

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
}

void draw() {
  background(32);

  // draw canvas area (scaled) with checkerboard behind
  pushStyle();
  noSmooth();
  image(checkPattern, canvasOffsetX, canvasOffsetY, canvasBuf.w * canvasScale, canvasBuf.h * canvasScale);
  popStyle();
  canvasBuf.drawTo(canvasOffsetX, canvasOffsetY, canvasScale);

  // draw tool overlay (draw in logical canvas coords into overlay, then composite scaled)
  overlay.beginDraw();
  overlay.clear();
  // draw persistent selection (marching ants) from global state so selection
  // remains visible when other tools are active
  if (state != null && state.hasSelection) {
    overlay.pushStyle();
    // translucent fill
    overlay.noStroke();
    overlay.fill(0, 120);
    overlay.rect(state.selX, state.selY, state.selW, state.selH);

    // marching ants outline
    overlay.noFill();
    overlay.strokeWeight(1);
    overlay.noSmooth();

    // advance animation offset on a timer
    int now = millis();
    if (now - antsLastTick >= antsSpeedMs) {
      antsOffset = (antsOffset + 1) % (antsDash * 2);
      antsLastTick = now;
    }

    int sw = state.selW;
    int sh = state.selH;
    int perimeter = 2 * (sw + sh) - 4;
    if (perimeter > 0) {
      int idx = 0;
      for (int i = 0; i < sw; i++) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) overlay.stroke(255); else overlay.stroke(0);
        overlay.point(state.selX + i, state.selY);
      }
      for (int j = 1; j < sh-1; j++) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) overlay.stroke(255); else overlay.stroke(0);
        overlay.point(state.selX + sw - 1, state.selY + j);
      }
      for (int i = sw - 1; i >= 0; i--) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) overlay.stroke(255); else overlay.stroke(0);
        overlay.point(state.selX + i, state.selY + sh - 1);
      }
      for (int j = sh - 2; j >= 1; j--) {
        int t = idx++;
        int phase = (t + antsOffset) % (antsDash * 2);
        if (phase < antsDash) overlay.stroke(255); else overlay.stroke(0);
        overlay.point(state.selX, state.selY + j);
      }
    }
    overlay.popStyle();
  }
  Tool active = toolbar.getActive();
  if (active != null) {
    active.drawOverlay(overlay);
  }
  // draw tool cursor at mouse position (in logical canvas coords)
  // hide system cursor while over canvas
  float canvasX = canvasOffsetX;
  float canvasY = canvasOffsetY;
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
  image(overlay, canvasOffsetX, canvasOffsetY, canvasBuf.w * canvasScale, canvasBuf.h * canvasScale);
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
  float cx = (sx - canvasOffsetX) / scale;
  float cy = (sy - canvasOffsetY) / scale;
  return new PVector(cx, cy);
}

void mousePressed() {
  // support panning via middle mouse, right mouse, holding space, or sticky 'h'
  if (mouseButton == CENTER || mouseButton == RIGHT || (keyPressed && key == ' ') || panStickyByH) {
    panning = true;
    return;
  }

  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY, canvasScale);
    t.onMousePressed(c.x, c.y);
  }
}

void mouseDragged() {
  // handle panning when active
  if (panning) {
    canvasOffsetX += mouseX - pmouseX;
    canvasOffsetY += mouseY - pmouseY;
    return;
  }

  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY, canvasScale);
    t.onMouseDragged(c.x, c.y);
  }
}

void mouseReleased() {
  if (panning) {
    // if panning was initiated via 'h' (sticky), do not disable on mouse release
    if (!panStickyByH) {
      panning = false;
    }
    return;
  }

  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY, canvasScale);
    t.onMouseReleased(c.x, c.y);
  }
}

// Zoom with mouse wheel, keeping the cursor focused point stable
void mouseWheel(processing.event.MouseEvent event) {
  float count = event.getCount();
  if (count == 0) return;
  float factor = pow(1.1, -count);

  // logical coordinates under cursor before zoom
  float ux = (mouseX - canvasOffsetX) / canvasScale;
  float uy = (mouseY - canvasOffsetY) / canvasScale;

  canvasScale *= factor;
  canvasScale = constrain(canvasScale, minCanvasScale, maxCanvasScale);

  // adjust offset so the same logical point remains under the cursor
  canvasOffsetX = mouseX - ux * canvasScale;
  canvasOffsetY = mouseY - uy * canvasScale;
}

