void keyPressed() {
  if (key == 'd' || key == 'D') {
    // dump preview for debugging at displayed sizes, composed with checkerboard
    PGraphics pd = createGraphics(preview.w, preview.h);
    pd.beginDraw();
    pd.image(checkPattern, 0, 0, preview.w, preview.h);
    pd.image(preview.preview.get(), 0, 0);
    pd.endDraw();
    PImage pSnap = pd.get();
    pSnap.resize(int(preview.w * previewScale), int(preview.h * previewScale));
    pSnap.save("preview_dump.png");

    // also dump the raw canvas buffer scaled to the displayed canvas size, composed
    PGraphics cd = createGraphics(canvasBuf.w, canvasBuf.h);
    cd.beginDraw();
    cd.image(checkPattern, 0, 0, canvasBuf.w, canvasBuf.h);
    cd.image(canvasBuf.getBuffer().get(), 0, 0);
    cd.endDraw();
    PImage cSnap = cd.get();
    cSnap.resize(int(canvasBuf.w * canvasScale), int(canvasBuf.h * canvasScale));
    cSnap.save("canvas_dump.png");
  }
  if (key == 'p' || key == 'P') {
    println("Pencil Tool Selected");
    // switch to Pencil tool by name (avoids numeric index mistakes)
    toolbar.setActiveByName("Pencil");
  }
  if (key == 'e' || key == 'E') {
    println("Erase Tool Selected");
    // switch to Erase tool by name
    toolbar.setActiveByName("Erase");
  }
  if (key == 'x' || key == 'X') {
    println("Swap Foreground/Background Colors");
    // swap foreground and background
    int tmp = fgColor;
    fgColor = bgColor;
    bgColor = tmp;
  }
  if (key == 'z' || key == 'Z') {
    println("Undo Last Action");
    // undo last action
    if (state != null) {
      state.undo();
    }
  }
  if (key == 'y' || key == 'Y') {
    println("Redo Last Action");
    // redo last undone action
    if (state != null) {
      state.redo();
    }
  }
  if (key == 'f' || key == 'F') {
      println("Flood Fill Tool Selected");
      // flood fill at cursor using foreground color
      toolbar.setActiveByName("FloodFill");
  }
  if (key == 's' || key == 'S') {
    println("Save Canvas to PNG");
    // save whole app canvas to PNG for debug or reporting
    save("canvas_image.png");
  }
}