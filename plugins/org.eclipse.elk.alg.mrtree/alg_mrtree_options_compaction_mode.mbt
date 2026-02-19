///|
pub enum MrtreeCompactionMode {
  NONE
  LEVEL_PRESERVING
  AGGRESSIVE
}

///|
pub fn mrtree_compaction_mode_from_string(
  value : String,
) -> MrtreeCompactionMode {
  if value == "NONE" {
    MrtreeCompactionMode::NONE
  } else if value == "LEVEL_PRESERVING" {
    MrtreeCompactionMode::LEVEL_PRESERVING
  } else {
    MrtreeCompactionMode::AGGRESSIVE
  }
}
