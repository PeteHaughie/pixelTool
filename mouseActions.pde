// mouse actions

void mousePressed() {
  // support panning via middle mouse, right mouse, holding space, or sticky 'h'
  boolean sticky = (state != null) ? state.isPanSticky() : false;
  if (mouseButton == CENTER || mouseButton == RIGHT || (keyPressed && key == ' ') || sticky) {
    if (state != null) state.setPanning(true);
    return;
  }

  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY);
    t.onMousePressed(c.x, c.y);
  }
}

void mouseDragged() {
  // handle panning when active
  boolean isPanning = (state != null) ? state.isPanning() : false;
  if (isPanning) {
    float curScale = state.getZoomScale();
    float curOffsetX = state.getZoomOffsetX();
    float curOffsetY = state.getZoomOffsetY();
    float newOffsetX = curOffsetX + mouseX - pmouseX;
    float newOffsetY = curOffsetY + mouseY - pmouseY;
    if (state != null) {
      state.setZoomState(curScale, newOffsetX, newOffsetY);
    }
    return;
  }

  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY);
    t.onMouseDragged(c.x, c.y);
  }
}

void mouseReleased() {
  boolean isPanning2 = (state != null) ? state.isPanning() : false;
  if (isPanning2) {
    // if panning was initiated via 'h' (sticky), do not disable on mouse release
    boolean sticky2 = (state != null) ? state.isPanSticky() : false;
    if (!sticky2) state.setPanning(false);
    return;
  }

  Tool t = toolbar.getActive();
  if (t != null) {
    PVector c = screenToCanvas(mouseX, mouseY);
    t.onMouseReleased(c.x, c.y);
  }
}

// Zoom with mouse wheel, keeping the cursor focused point stable
void mouseWheel(processing.event.MouseEvent event) {
  float count = event.getCount();
  if (count == 0) return;
  float factor = pow(1.1, -count);

  // delegate to state manager for zoom; no local math needed here
  // delegate to ZoomTool so state remains a storage layer
  Tool t = toolbar.getToolByNameInstance("Zoom");
  if (t != null && t instanceof ZoomTool) {
    ((ZoomTool)t).zoomBy(factor, mouseX, mouseY);
  }
}
