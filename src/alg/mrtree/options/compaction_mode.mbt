///|
pub(all) enum MrtreeCompactionMode {
  NONE
  LEVEL_PRESERVING
  AGGRESSIVE
}

///|
pub fn mrtree_compaction_mode_from_string(
  value : String,
) -> MrtreeCompactionMode {
  if value == "NONE" {
    NONE
  } else if value == "LEVEL_PRESERVING" {
    LEVEL_PRESERVING
  } else {
    AGGRESSIVE
  }
}
