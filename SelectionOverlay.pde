class SelectionOverlay {
  int antsOffset = 0;
  int antsDash = 4; // length of dash in pixels
  int antsSpeedMs = 60; // milliseconds per step (higher = slower)
  int antsLastTick = 0;

  SelectionOverlay() {
  }

  void draw(PGraphics overlay, StateManager state) {
    if (overlay == null || state == null) return;
    overlay.pushStyle();
    // translucent fill
    overlay.noStroke();
    if (state.hasSelection) {
      overlay.fill(0, 120);
      overlay.rect(state.selX, state.selY, state.selW, state.selH);
    }

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

    if (state.hasSelection) {
      int sw = state.selW;
      int sh = state.selH;
      int perimeter = 2 * (sw + sh) - 4;
      if (perimeter > 0) {
        int idx = 0;
        overlay.noStroke();
        for (int i = 0; i < sw; i++) {
          int t = idx++;
          int phase = (t + antsOffset) % (antsDash * 2);
          int col = (phase < antsDash) ? color(255) : color(0);
          overlay.fill(col);
          overlay.rect(state.selX + i, state.selY, 1, 1);
        }
        for (int j = 1; j < sh-1; j++) {
          int t = idx++;
          int phase = (t + antsOffset) % (antsDash * 2);
          int col = (phase < antsDash) ? color(255) : color(0);
          int px = state.selX + sw - 1;
          int py = state.selY + j;
          overlay.fill(col);
          overlay.rect(px, py, 1, 1);
          if (py + 1 < overlay.height) overlay.rect(px, py + 1, 1, 1);
        }
        for (int i = sw - 1; i >= 0; i--) {
          int t = idx++;
          int phase = (t + antsOffset) % (antsDash * 2);
          int col = (phase < antsDash) ? color(255) : color(0);
          overlay.fill(col);
          overlay.rect(state.selX + i, state.selY + sh - 1, 1, 1);
        }
        for (int j = sh - 2; j >= 1; j--) {
          int t = idx++;
          int phase = (t + antsOffset) % (antsDash * 2);
          int col = (phase < antsDash) ? color(255) : color(0);
          int px = state.selX;
          int py = state.selY + j;
          overlay.fill(col);
          overlay.rect(px, py, 1, 1);
          if (py + 1 < overlay.height) overlay.rect(px, py + 1, 1, 1);
        }
      }
    }
    overlay.popStyle();
  }
}
