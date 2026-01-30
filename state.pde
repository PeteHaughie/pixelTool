// Record of a single pixel change (old -> new)
class PixelChange {
  int x, y;
  int oldCol, newCol;
  PixelChange(int x, int y, int oldCol, int newCol) {
    this.x = x;
    this.y = y;
    this.oldCol = oldCol;
    this.newCol = newCol;
  }
}

// An undoable entry consists of a list of pixel changes applied together
class UndoEntry {
  ArrayList<PixelChange> changes;
  UndoEntry() {
    changes = new ArrayList<PixelChange>();
  }
  void add(PixelChange c) { changes.add(c); }
}

class StateManager {
  CanvasBuffer canvas;
  ArrayList<UndoEntry> undoStack;
  ArrayList<UndoEntry> redoStack;

  StateManager(CanvasBuffer canvas) {
    this.canvas = canvas;
    this.undoStack = new ArrayList<UndoEntry>();
    this.redoStack = new ArrayList<UndoEntry>();
  }

  // Helper to apply a list of PixelChange entries to the canvas buffer.
  // If `useNew` is true, apply `newCol`, otherwise apply `oldCol`.
  void applyChanges(ArrayList<PixelChange> changes, boolean useNew) {
    if (changes == null || changes.size() == 0) return;
    int w = canvas.w;
    int h = canvas.h;
    int[] logical = canvas.getLogicalPixels();
    PGraphics buf = canvas.getBuffer();
    buf.beginDraw();
    buf.pushStyle();
    buf.blendMode(REPLACE);
    buf.noStroke();
    for (PixelChange pc : changes) {
      if (pc.x < 0 || pc.x >= w || pc.y < 0 || pc.y >= h) continue;
      int idx = pc.y * w + pc.x;
      int v = useNew ? pc.newCol : pc.oldCol;
      logical[idx] = v;
      buf.fill(v);
      buf.rect(pc.x, pc.y, 1, 1);
    }
    buf.blendMode(BLEND);
    buf.popStyle();
    buf.endDraw();
  }

  // Commit a stroke (list of logical coordinates) into the canvas buffer
  // Records previous pixel values and pushes an UndoEntry.
  void commitStroke(ArrayList<PVector> stroke, int col) {
    if (stroke == null || stroke.size() == 0) return;
    int w = canvas.w;
    int h = canvas.h;
    int[] logical = canvas.getLogicalPixels();

    UndoEntry entry = new UndoEntry();

    // Rasterize stroke into pixel coordinates and collect changes (avoid duplicates)
    HashMap<Integer, PixelChange> changesMap = new HashMap<Integer, PixelChange>();

    PVector prev = null;
    for (PVector p : stroke) {
      int px = (int)round(p.x - 0.5);
      int py = (int)round(p.y - 0.5);
      if (prev == null) {
        addLinePoint(px, py, col, changesMap, logical, w, h);
      } else {
        int ppx = (int)round(prev.x - 0.5);
        int ppy = (int)round(prev.y - 0.5);
        rasterLineCollect(ppx, ppy, px, py, col, changesMap, logical, w, h);
      }
      prev = p;
    }

    // move collected map into the UndoEntry (preserves arbitrary order)
    for (PixelChange pc : changesMap.values()) entry.add(pc);

    if (entry.changes.size() == 0) return;

    // Apply the new colors to the canvas and push to undo stack
    applyChanges(entry.changes, true);
    undoStack.add(entry);
    // New action invalidates redo history
    redoStack.clear();
  }

  // helper to add a single raster point into map keyed by index to avoid dupes
  void addLinePoint(int x, int y, int col, HashMap<Integer, PixelChange> map, int[] logical, int w, int h) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    int idx = y * w + x;
    if (map.containsKey(idx)) return;
    int oldv = logical[idx];
    if (oldv == col) return; // no-op change
    map.put(idx, new PixelChange(x, y, oldv, col));
  }

  // Bresenham-like rasterization that collects pixel changes into map
  void rasterLineCollect(int x0, int y0, int x1, int y1, int col, HashMap<Integer, PixelChange> map, int[] logical, int w, int h) {
    int dx = abs(x1 - x0);
    int dy = abs(y1 - y0);
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    while (true) {
      addLinePoint(x0, y0, col, map, logical, w, h);
      if (x0 == x1 && y0 == y1) break;
      int e2 = 2 * err;
      if (e2 > -dy) { err -= dy; x0 += sx; }
      if (e2 < dx) { err += dx; y0 += sy; }
    }
  }

  // Undo the last entry
  void undo() {
    if (undoStack.size() == 0) return;
    UndoEntry e = undoStack.remove(undoStack.size() - 1);
    // apply old colors
    applyChanges(e.changes, false);
    redoStack.add(e);
  }

  // Redo the last undone entry
  void redo() {
    if (redoStack.size() == 0) return;
    UndoEntry e = redoStack.remove(redoStack.size() - 1);
    // apply new colors
    applyChanges(e.changes, true);
    undoStack.add(e);
  }

  // Flood fill starting at logical pixel coordinates x,y with color col
  void floodFill(int x, int y, int col) {
    if (x < 0 || x >= canvas.w || y < 0 || y >= canvas.h) return;
    int w = canvas.w;
    int h = canvas.h;
    int size = w * h;
    int idx = y * w + x;
    int[] pixels = canvas.getLogicalPixels();
    int target = pixels[idx];

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

    // Build an UndoEntry for the flood fill so it can be undone/redone
    UndoEntry entry = new UndoEntry();
    for (int i = 0; i < filledCount; i++) {
      int cur = filledList[i];
      int px = cur % w;
      int py = cur / w;
      int oldv = pixels[cur];
      // oldv already set to col above — we need the original value
      // to compute old color we should have captured it; to keep this simple,
      // we reconstruct by using the stored 'target' as the old color.
      entry.add(new PixelChange(px, py, target, col));
    }

    // Apply draw to PGraphics (logical pixels already updated above)
    PGraphics buf = canvas.getBuffer();
    buf.beginDraw();
    buf.pushStyle();
    buf.blendMode(REPLACE);
    buf.noStroke();
    for (int i = 0; i < filledCount; i++) {
      int cur = filledList[i];
      int px = cur % w;
      int py = cur / w;
      buf.fill(col);
      buf.rect(px, py, 1, 1);
    }
    buf.blendMode(BLEND);
    buf.popStyle();
    buf.endDraw();

    // push undo entry and clear redo
    if (entry.changes.size() > 0) {
      undoStack.add(entry);
      redoStack.clear();
    }
    println("floodFill result: filled=", filledCount, " bbox= [", minX, ",", minY, "] - [", maxX, ",", maxY, "]");
  }
}
