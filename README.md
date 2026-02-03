# pixelTool

A Processing application for pixel art creation and editing. pixelTool is heavily inspired by MacPaint and other classic pixel art editors, aiming to provide a simple yet powerful toolset for artists and enthusiasts.

## Features

- Create and edit pixel art with a simple and intuitive interface.
- Support for layers, allowing for complex designs.
- Various tools including pencil, eraser, fill, and color picker.
- Export artwork in multiple formats (PNG, GIF, BMP).
- Onion skinning for animation creation.
- Select all, select rectangle, and lasso selection tools.
- Customizable canvas size and grid options.
- Customizable pallette management.
- Load and position images for tracing.
- Unlimited undo and redo functionality.

## UI

The user interface is designed to be user-friendly, with a toolbar for selecting tools, a color palette for choosing colors, and a layer panel for managing layers. The canvas area is where the pixel art is created and edited.
There is a preview window to see the artwork in real-time. Under the preview you can add new frames for animation. The toolbars and panels can be shown, hidden, or rearranged according to user preference. All currently selected options are easily visible.

## UX

The user experience focuses on ease of use and efficiency. Commonly understood keyboard shortcuts are available for actions which are frequently used, such as undo, redo, copy, paste, and tool selection. The interface is designed to minimize the number of clicks and provide immediate feedback to the user. There is a shift-click feature to draw straight lines, and a click-and-drag feature for filling areas with color.

## Keyboard Shortcuts

The kayboard controls are split between unmodified keys for easy and intuitive access to commonly used tools, and modified keys (CTRL/CMD, SHIFT, ALT) for actions that are less frequently used, more complex, potentially destructive, or application control.

### Unmodified Keys
- P: Pencil Tool 
- M: Rectangle Selection Tool
- L: Lasso Selection Tool
- V: Move Tool
- E: Eraser Tool
- F: Fill Tool 
- T: Toggle Transparency Grid
- C: Color Picker Tool 
- I: Color Eyedropper Tool
- X: Swap Foreground/Background Colors
- D: Reset Foreground/Background Colors to Default (Black/White)
- R: Rectangle Shape Tool
- O: Oval Shape Tool
- Z: Zoom Tool
- H: Hand Tool (Pan Canvas)
- Spacebar: Temporary Hand Tool (Pan Canvas while held)
- Cursor Keys: Nudge Selection/Layer/Brush Position by 1 Pixel
- Shift + Cursor Keys: Nudge Selection/Layer/Brush Position by 10 Pixels

### Modified Keys
- CTRL/CMD + A: Select All
- CTRL/CMD + D: Deselect
- Shift + CTRL/CMD + F: Fullscreen Mode
- CTRL/CMD + X: Cut
- CTRL/CMD + C: Copy
- CTRL/CMD + V: Paste
- CTRL/CMD + Z: Undo 
- CTRL/CMD + Y: Redo
- CTRL/CMD + S: Save
- CTRL/CMD + R: Show/Hide Rulers
- CTRL/CMD + G: Group Selection (Non-Destructive)
- CTRL/CMD + U: Ungroup Selection
- CTRL/CMD + M: Merge Layers (Destructive)
- SHIFT + CTRL/CMD + S: Save As/Save a Copy
- CTRL/CMD + O: Open
- CTRL/CMD + W: Close Canvas (user will be prompted to save current work if unsaved changes exist)
- CTRL/CMD + N: New Canvas (user will be prompted to save current work if unsaved changes exist)
- CTRL/CMD + Plus (+): Zoom In
- CTRL/CMD + Minus (-): Zoom Out
- CTRL/CMD + 0: Reset Zoom to 100%
- CTRL/CMD + 1: Set Zoom to 200%

### Navigation Keys
- Tab: Switch between tools
- Alt + Tab: Switch between layers
- Ctrl + Tab: Switch between brushes
- Alt + Left/Right Arrow: Previous/Next Frame

### Mouse Controls
- Left Click: Draw/Select/Erase/Fill (depending on selected tool)
- Right Click: Open Color Picker
- Scroll Wheel: Zoom In/Out
- Middle Click + Drag: Pan Canvas