///|
pub enum OverlapMode {
  OverlapNone
  OverlapScale
  OverlapScalexy
  OverlapPrism
  OverlapCompress
}

///|
pub fn overlap_mode_parse(string : String) -> OverlapMode {
  let normalized_lower = string.to_lower()
  if normalized_lower == "true" {
    return OverlapNone
  }
  let normalized = string.to_upper()
  if normalized == "NONE" {
    OverlapNone
  } else if normalized == "SCALE" {
    OverlapScale
  } else if normalized == "SCALEXY" {
    OverlapScalexy
  } else if normalized == "PRISM" {
    OverlapPrism
  } else if normalized == "COMPRESS" {
    OverlapCompress
  } else {
    abort("invalid overlap mode")
  }
}

///|
pub fn overlap_mode_to_string(mode : OverlapMode) -> String {
  match mode {
    OverlapNone => "none"
    OverlapScale => "scale"
    OverlapScalexy => "scalexy"
    OverlapPrism => "prism"
    OverlapCompress => "compress"
  }
}

///|
pub fn overlap_mode_literal(mode : OverlapMode) -> String {
  match mode {
    OverlapNone => "true"
    _ => overlap_mode_to_string(mode)
  }
}
