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

  // Persistent selection model (logical canvas coordinates)
  int selX = 0;
  int selY = 0;
  int selW = 0;
  int selH = 0;
  boolean hasSelection = false;

  StateManager(CanvasBuffer canvas) {
    this.canvas = canvas;
    this.undoStack = new ArrayList<UndoEntry>();
    this.redoStack = new ArrayList<UndoEntry>();
  }

  // Selection API
  void setSelection(int x, int y, int w, int h) {
    selX = x;
    selY = y;
    selW = max(0, w);
    selH = max(0, h);
    hasSelection = (selW > 0 && selH > 0);
  }

  void clearSelection() {
    selX = selY = selW = selH = 0;
    hasSelection = false;
  }

  // Helper to return selection as an int array [x,y,w,h]
  int[] getSelection() {
    int[] s = { selX, selY, selW, selH };
    return s;
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

  // Push an undo entry and clear redo stack in a single, encapsulated API.
  // Tools and other callers should use this instead of manipulating stacks
  // directly to preserve invariants.
  void pushUndoEntry(UndoEntry entry) {
    if (entry == null || entry.changes == null || entry.changes.size() == 0) return;
    undoStack.add(entry);
    redoStack.clear();
  }

  // Zoom the canvas display by a multiplicative factor, keeping the logical
  // Set the zoom/display transform state. This stores values in StateManager
  // so callers can treat state as the source of truth. It also updates the
  // legacy globals used by the drawing code to minimize refactoring.
  float zoomScale = 3.0;
  float zoomOffsetX = 100;
  float zoomOffsetY = 10;
  float minZoom = 1.0;
  float maxZoom = 32.0;

  void setZoomState(float scale, float offsetX, float offsetY) {
    zoomScale = scale;
    zoomOffsetX = offsetX;
    zoomOffsetY = offsetY;
  }

  float getZoomScale() { return zoomScale; }
  float getZoomOffsetX() { return zoomOffsetX; }
  float getZoomOffsetY() { return zoomOffsetY; }
  float getMinZoom() { return minZoom; }
  float getMaxZoom() { return maxZoom; }
  // Panning state: whether panning is active, and whether it's sticky (via 'h')
  boolean panning = false;
  boolean panSticky = false;

  void setPanning(boolean v) { panning = v; }
  boolean isPanning() { return panning; }

  void setPanSticky(boolean v) { panSticky = v; }
  boolean isPanSticky() { return panSticky; }
}
