class UndoEntry {
  // minimal placeholder for undo entries
}

class StateManager {
  CanvasBuffer canvas;
  ArrayList<UndoEntry> undoStack;

  StateManager(CanvasBuffer canvas) {
    this.canvas = canvas;
    this.undoStack = new ArrayList<UndoEntry>();
  }

  // Commit a stroke (list of logical coordinates) into the canvas buffer
  void commitStroke(ArrayList<PVector> stroke, int col) {
    // rasterize the stroke into pixel coords and write to canvas
    if (stroke == null || stroke.size() == 0) return;

    // simple Bresenham-like between consecutive points
    PVector prev = null;
    for (PVector p : stroke) {
      // apply half-unit offset so pixels align with preview overlay
      int px = (int)round(p.x - 0.5);
      int py = (int)round(p.y - 0.5);
      if (prev == null) {
        canvas.setPixel(px, py, col);
      } else {
        int ppx = (int)round(prev.x - 0.5);
        int ppy = (int)round(prev.y - 0.5);
        drawLinePixels(ppx, ppy, px, py, col);
      }
      prev = p;
    }
  }

  void drawLinePixels(int x0, int y0, int x1, int y1, int col) {
    int dx = abs(x1 - x0);
    int dy = abs(y1 - y0);
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    while (true) {
      canvas.setPixel(x0, y0, col);
      if (x0 == x1 && y0 == y1) break;
      int e2 = 2 * err;
      if (e2 > -dy) { err -= dy; x0 += sx; }
      if (e2 < dx) { err += dx; y0 += sy; }
    }
  }

  // Flood fill starting at logical pixel coordinates x,y with color col
  void floodFill(int x, int y, int col) {
    if (x < 0 || x >= canvas.w || y < 0 || y >= canvas.h) return;
    // Use the canvas logical pixel array (maintained by CanvasBuffer) so we
    // never rely on PGraphics internal pixel stride/density.
    int w = canvas.w;
    int h = canvas.h;
    int size = w * h;
    int idx = y * w + x;
    int[] pixels = canvas.getLogicalPixels();
    int target = pixels[idx];

    // Debug information to help diagnose fill behavior
    println("floodFill start: x=", x, " y=", y, " idx=", idx, " w=", w, " h=", h, " size=", size);
    println("target=", hex(target), " fill=", hex(col));
    if (target == col) return;

    boolean[] visited = new boolean[size];
    int[] stack = new int[size];
    int sp = 0;
    visited[idx] = true;
    stack[sp++] = idx;

    int filledCount = 0;
    int minX = w, minY = h, maxX = 0, maxY = 0;
    int[] filledList = new int[size];
    while (sp > 0) {
      int cur = stack[--sp];
      if (cur < 0 || cur >= size) continue;

      int px = cur % w;
      int py = cur / w;

      if (pixels[cur] != target) continue;

      pixels[cur] = col;
      filledList[filledCount++] = cur;
      if (px < minX) minX = px;
      if (py < minY) minY = py;
      if (px > maxX) maxX = px;
      if (py > maxY) maxY = py;

      if (px + 1 < w) {
        int n = cur + 1;
        if (!visited[n] && sp < size) { visited[n] = true; stack[sp++] = n; }
      }
      if (px - 1 >= 0) {
        int n = cur - 1;
        if (!visited[n] && sp < size) { visited[n] = true; stack[sp++] = n; }
      }
      if (py + 1 < h) {
        int n = cur + w;
        if (!visited[n] && sp < size) { visited[n] = true; stack[sp++] = n; }
      }
      if (py - 1 >= 0) {
        int n = cur - w;
        if (!visited[n] && sp < size) { visited[n] = true; stack[sp++] = n; }
      }
    }

    // Draw filled pixels directly into the canvas PGraphics so rendering
    // honors the underlying buffer layout (pixel density / stride). Also
    // update the logical pixel array which is the authoritative source.
    PGraphics buf = canvas.getBuffer();
    buf.beginDraw();
    buf.noStroke();
    buf.fill(col);
    int[] logical = canvas.getLogicalPixels();
    for (int i = 0; i < filledCount; i++) {
      int cur = filledList[i];
      int px = cur % w;
      int py = cur / w;
      logical[cur] = col;
      buf.rect(px, py, 1, 1);
    }
    buf.endDraw();
    println("floodFill result: filled=", filledCount, " bbox= [", minX, ",", minY, "] - [", maxX, ",", maxY, "]");
  }
}
