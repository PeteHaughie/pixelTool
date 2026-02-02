void keyPressed() {
  if (key == 'd' || key == 'D') {
    // dump preview for debugging at displayed sizes, composed with checkerboard
    int outPW = int(preview.w * previewScale);
    int outPH = int(preview.h * previewScale);
    PGraphics pd = createGraphics(outPW, outPH);
    pd.beginDraw();
    pd.noSmooth();
    pd.image(preview.preview.get(), 0, 0, outPW, outPH);
    pd.endDraw();
    pd.save("preview_dump.png");

    // also dump the raw canvas buffer scaled to the displayed canvas size, composed
    int outCW = int(canvasBuf.w * canvasScale);
    int outCH = int(canvasBuf.h * canvasScale);
    PGraphics cd = createGraphics(outCW, outCH);
    cd.beginDraw();
    cd.noSmooth();
    cd.image(canvasBuf.getBuffer().get(), 0, 0, outCW, outCH);
    cd.endDraw();
    cd.save("canvas_dump.png");

    int outExpW = int(canvasBuf.w);
    int outExpH = int(canvasBuf.h);
    PGraphics ce = createGraphics(outExpW, outExpH);
    ce.beginDraw();
    ce.noSmooth();
    ce.image(canvasBuf.getBuffer().get(), 0, 0, outExpW, outExpH);
    ce.endDraw();
    ce.save("canvas_dump_exact.png"); // this is what we'll probably use for export
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
  if (key == 'm' || key == 'M') {
    println("Square Marquee Tool Selected");
    // switch to Square Marquee tool by name
    toolbar.setActiveByName("Marquee");
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