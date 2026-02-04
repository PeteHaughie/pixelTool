// Helpers for stroke rasterization and UndoEntry construction.
// These are shared utilities used by multiple tools; they do not
// mutate StateManager's stacks directly — they only build an
// UndoEntry that callers (typically StateManager or tools) can apply.

UndoEntry buildStrokeUndoEntry(CanvasBuffer canvas, ArrayList<PVector> stroke, int col) {
  UndoEntry entry = new UndoEntry();
  if (canvas == null || stroke == null || stroke.size() == 0) return entry;

  int w = canvas.w;
  int h = canvas.h;
  int[] logical = canvas.getLogicalPixels();

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

  for (PixelChange pc : changesMap.values()) entry.add(pc);
  return entry;
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
