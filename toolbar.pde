class Toolbar {
  ArrayList<Tool> tools;
  int activeIndex = 0;
  int iconSize = 16;

  Toolbar() {
    tools = new ArrayList<Tool>();
  }

  void addTool(Tool t) {
    tools.add(t);
  }

  Tool getActive() {
    if (tools.size() == 0) return null;
    return tools.get(activeIndex);
  }

  void setActive(int idx) {
    if (idx >= 0 && idx < tools.size()) activeIndex = idx;
  }

  // Draw a simple vertical toolbar at x,y
  void draw(float x, float y) {
    pushStyle();
    int pad = 6;
    float ty = y;
    for (int i = 0; i < tools.size(); i++) {
      Tool t = tools.get(i);
      // background
      fill(i == activeIndex ? 200 : 240);
      stroke(120);
      rect(x, ty, iconSize + pad*2, iconSize + pad*2);

      // draw icon pixels scaled to iconSize
      ArrayList<PixelSpec> pixels = t.getIconPixels(iconSize);
      pushMatrix();
      translate(x + pad, ty + pad);
      for (PixelSpec p : pixels) {
        noStroke();
        fill(p.col);
        rect(p.x, p.y, 1, 1);
      }
      // draw a small highlight on ColorTool icons to show active (fg) color
      if (t instanceof ColorTool) {
        int sz = iconSize;
        int sw = max(2, sz/3);
        int padInside = max(1, (sz - (sw*2)) / 3);
        int y0 = (sz - sw) / 2;
        int x0 = padInside;
        // compute screen coords for the highlight rect
        float hx = x + pad + x0;
        float hy = ty + pad + y0;
        popMatrix();
        pushStyle();
        noFill();
        stroke(255, 0, 0);
        strokeWeight(1);
        rect(hx - 0.5, hy - 0.5, sw + 1, sw + 1);
        popStyle();
      } else {
        popMatrix();
      }

      ty += iconSize + pad*2 + 8;
    }
    popStyle();
  }
}
