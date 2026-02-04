// Global input key state flags and accessors
// These are simple globals with explicit setter/getter functions so
// other modules can read/update keyboard modifier state centrally.

boolean shiftKeyPressed = false;
boolean ctrlKeyPressed = false;
boolean altKeyPressed = false;
boolean metaKeyPressed = false;

void setIsShiftKeyPressed(boolean v) {
  shiftKeyPressed = v;
}

boolean isShiftKeyPressed() {
  return shiftKeyPressed;
}

void setIsCtrlKeyPressed(boolean v) {
  ctrlKeyPressed = v;
}

boolean isCtrlKeyPressed() {
  return ctrlKeyPressed;
}

void setIsAltKeyPressed(boolean v) {
  altKeyPressed = v;
}

boolean isAltKeyPressed() {
  return altKeyPressed;
}

void setIsMetaKeyPressed(boolean v) {
  metaKeyPressed = v;
}

boolean isMetaKeyPressed() {
  return metaKeyPressed;
}
