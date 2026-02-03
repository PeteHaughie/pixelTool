
# Actionable TODOs derived from README features

This file records concrete, implementable tasks converted from the `README.md` features list so we don't lose them.

- [ ] Layers: implement layer model and layer panel (create/add/delete/reorder/merge, opacity, visibility, rename).
- [ ] Export: add export dialog supporting PNG, GIF, BMP (single-frame and animated GIF). Ensure exports preserve transparency/alpha.
- [ ] Onion skinning: add onion-skin controls for preview/animation (opacity, frames before/after).
- [ ] Selection tools: implement Rectangle and Lasso selection tools and `select all`/`deselect` actions with marching-ants outline.
- [ ] Tools: implement and polish Pencil, Eraser, Fill, Color Picker, Color Eyedropper; add brush size and basic brush shapes (circle, square).
- [ ] Animation timeline: add timeline panel for frame management (add/delete/reorder/duplicate frames, rename frames).
- [ ] Preview panel: finalize preview panel UI and ensure it updates in real-time; add play/pause controls and frame list UI.
- [ ] Color picker: implement advanced color picker dialog (HSV/Hex input, recent colors) and palette management (create/save/load palettes, edit swatches).
- [ ] Export settings: add export options dialog (canvas size, background color, frame delay for GIFs, looping).
- [ ] Zoom & pan: implement zoom in/out and pan canvas with mouse and keyboard shortcuts; implement temporary hand tool when holding Spacebar.
- [ ] Grid/snapping: add grid overlay toggle and snapping options for pixel-perfect drawing; allow grid color/spacing configuration.
- [ ] Canvas size & config: add canvas-size dialog and persistent document configuration (bg color, grid size).
- [ ] File operations: implement New, Open, Save, Save As functionality with project file format (save/load layers, frames, palette, metadata).
- [ ] Image import: implement image import/placement for tracing (scale, opacity, snap-to-grid, position).
- [ ] Undo/Redo: verify unlimited undo/redo across operations and composite actions (flood fill, imports).
- [ ] Keyboard shortcuts: implement and document full mapping from `README.md` (tool keys, modified keys, navigation keys, mouse controls).
- [ ] Save file confirmation: add confirmation dialog when closing with unsaved changes.
- [ ] Floating UI: allow dragging/docking of toolbars and panels; consider detachable/floating canvas window option.
- [ ] Custom brushes: add support for custom brush shapes and sizes (import brush images).
- [ ] Animation export: ensure animated GIF export works correctly with frame delays and looping.
- [ ] Metadata: add project metadata support (title, author, description) and save/load with project files.
- [ ] Shift-straight drawing: implement Shift-click/drag to draw straight lines and constrained shapes for drawing tools.
- [ ] Toolbar/panels: allow show/hide and reorder of toolbar/panels; persist layout preferences.
- [ ] Transparency grid: implement toggle for transparency grid (T) and ensure proper compositing in exports.
- [ ] Diagnostics: expand `d` dump to include frame metadata and optionally write debug JSON.

Notes:
- Start with the core editor UX (layers, tools, undo/redo, save/load) before export/animation polishing.
- Each task should include a small acceptance criterion (e.g., "Export PNG preserves transparency and alpha").

