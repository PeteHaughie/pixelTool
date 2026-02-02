class FloodFillTool extends Tool {
  FloodFillTool() {
    super("FloodFill");
  }

  void onMousePressed(float x, float y) {
    int px = (int)round(x - 0.5);
    int py = (int)round(y - 0.5);
    // tool owns the flood-fill algorithm now — it still records undo entries
    floodFill(px, py, fgColor);
  }

  // Flood-fill implementation moved from `StateManager` so the Tool can
  // perform the operation as its action. It updates `canvasBuf.logicalPixels`,
  // writes to the PGraphics and pushes an UndoEntry onto `state.undoStack`.
  void floodFill(int x, int y, int col) {
    if (canvasBuf == null) return;
    if (x < 0 || x >= canvasBuf.w || y < 0 || y >= canvasBuf.h) return;
    int w = canvasBuf.w;
    int h = canvasBuf.h;
    int size = w * h;
    int idx = y * w + x;
    int[] pixels = canvasBuf.getLogicalPixels();
    int target = pixels[idx];

    if (target == col) return;

    boolean[] visited = new boolean[size];
    int[] stack = new int[size];
    int sp = 0;
    visited[idx] = true;
    stack[sp++] = idx;

    int filledCount = 0;
    int[] filledList = new int[size];
    while (sp > 0) {
      int cur = stack[--sp];
      if (cur < 0 || cur >= size) continue;

      int px = cur % w;
      int py = cur / w;

      if (pixels[cur] != target) continue;

      pixels[cur] = col;
      filledList[filledCount++] = cur;

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
      entry.add(new PixelChange(px, py, target, col));
    }

    // Apply draw to PGraphics (logical pixels already updated above)
    PGraphics buf = canvasBuf.getBuffer();
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

    // push undo entry and clear redo via encapsulated API
    if (state != null && entry.changes.size() > 0) {
      state.pushUndoEntry(entry);
    }
  }

  // simple icon: a filled square with a dot
  ArrayList<PixelSpec> getIconPixels(int size) {
    ArrayList<PixelSpec> out = new ArrayList<PixelSpec>();
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (x == size/2 && y == size/2) out.add(new PixelSpec(x, y, color(255, 255, 255)));
        else out.add(new PixelSpec(x, y, color(180, 180, 220)));
      }
    }
    return out;
  }
}
