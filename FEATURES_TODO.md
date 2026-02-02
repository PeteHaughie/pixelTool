# Actionable TODOs derived from README features

This file records concrete, implementable tasks converted from the `README.md` features list so we don't lose them.

- [ ] Layers: implement layer model and layer panel (create/add/delete/reorder/merge).
- [ ] Export: add export dialog supporting PNG, GIF, BMP (single-frame and animated GIF).
- [ ] Onion skinning: add onion-skin controls for preview/animation (opacity, frames before/after).
- [ ] Selection tools: implement Rectangle and Lasso selection tools and `select all`/`deselect` actions. Marching ants outline.
- [ ] Tools: verify and polish Pencil, Eraser, Fill, Color Picker; add brush size UI and shape options.
- [ ] Animation timeline: add timeline panel for frame management (add/delete/reorder frames).
- [ ] Color picker: implement advanced color picker dialog (HSV/Hex input, recent colors).
- [ ] Export settings: add export options dialog (canvas size, bg color, frame delay for GIFs).
- [ ] Zoom & pan: implement zoom in/out and pan canvas with mouse and keyboard shortcuts.
- [ ] Grid/snapping: add grid overlay toggle and snapping options for pixel-perfect drawing.
- [ ] Canvas size & grid: add canvas-size dialog and grid toggles (grid color/spacing).
- [ ] File operations: implement New, Open, Save, Save As functionality with project file format.
- [ ] Animation playback: add play/pause controls for previewing animations in the preview panel.
- [ ] Image import: implement image import dialog with scaling and positioning options.
- [ ] Brush shapes: add different brush shapes (circle, square) and size options for drawing tools.
- [ ] Preview panel: finalize preview panel UI and ensure it updates in real-time with canvas changes.
- [ ] Keyboard shortcuts: implement and document keyboard shortcuts for common actions (undo, redo, tool switch).
- [ ] Save file confirmation: add confirmation dialog when closing with unsaved changes.
- [ ] Floating toolbars: allow dragging and docking of toolbars and panels within the main window.
- [ ] Floating canvas: implement floating/detachable canvas window option.
- [ ] Custom brushes: add support for custom brush shapes and sizes (import brush images).
- [ ] Animation export: ensure animated GIF export works correctly with frame delays and looping.
- [ ] Metadata: add project metadata support (title, author, description) and save/load with project files.
- [ ] Shift-drag: implement shift-drag for straight lines and constrained shapes with drawing tools.
- [ ] Document configuration: create a configuration dialog for canvas settings (bg color, grid size).
- [ ] Layer opacity: add layer opacity slider in the layer panel.
- [ ] Layer visibility: implement layer visibility toggles in the layer panel.
- [ ] Layer renaming: allow renaming layers in the layer panel.
- [ ] Frame duplication: add duplicate frame action in the timeline panel.
- [ ] Frame renaming: allow renaming frames in the timeline panel.
- [ ] Enxure export respects transparency and alpha channel correctly.
- [ ] Palette management: add palette panel (create/save/load palettes, edit swatches).
- [ ] Image import: allow loading/positioning images for tracing (scale, opacity, snap-to-grid).
- [ ] Preview & frames: finalize preview window frame list UI, add add/remove/duplicate frame actions.
- [ ] Undo/Redo: verify unlimited undo/redo across operations and composite actions (flood fill, imports).
- [ ] Save/load project format: add project file save/load (keep layers, frames, palette, metadata).
- [ ] Toolbar/panels: allow show/hide and reorder of toolbar/panels; persist layout preferences.
- [ ] Keyboard shortcuts: ensure listed shortcuts are implemented and documented (README-DEV).
- [ ] Transparency checker: toggle transparency grid and ensure correct compositing in exports.
- [ ] Diagnostics: expand `d` dump to include frame metadata and optionally write debug JSON.

Notes:
- Start with the core editor UX (layers, tools, undo/redo, save/load) before export/animation polishing.
- Each task should include a small acceptance criterion (e.g., "Export PNG preserves transparency and alpha").

