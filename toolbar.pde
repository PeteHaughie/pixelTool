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
    if (idx >= 0 && idx < tools.size()) {
      // call deactivate on previous tool
      Tool prev = getActive();
      if (prev != null) prev.onDeactivate();
      activeIndex = idx;
      Tool now = getActive();
      if (now != null) now.onActivate();
    }
  }

  // Select the active tool by its `Tool.name` value. Safe when callers don't
  // know the numeric index (helps avoid off-by-one / 1-based indexing errors).
  void setActiveByName(String name) {
    for (int i = 0; i < tools.size(); i++) {
      Tool t = tools.get(i);
      if (t != null && t.name != null && t.name.equals(name)) {
        setActive(i);
        return;
      }
    }
  }

  // Get the tool at the given index.
  Tool getToolByIndex(int idx) {
    if (idx >= 0 && idx < tools.size()) {
      return tools.get(idx);
    }
    return null;
  }

  // Get the tool name at the given index.
  String getToolByName(int idx) {
    Tool t = getToolByIndex(idx);
    if (t != null) {
      return t.name;
    }
    return null;
  }

  // Select the active tool by its concrete class simple name (e.g. "EraseTool").
  void setActiveByClassName(String className) {
    for (int i = 0; i < tools.size(); i++) {
      Tool t = tools.get(i);
      if (t != null && t.getClass().getSimpleName().equals(className)) {
        setActive(i);
        return;
      }
    }
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
      ty += iconSize + pad*2 + 8;
      popMatrix();
    }
    popStyle();
  }
}
