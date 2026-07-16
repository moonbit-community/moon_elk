///|
pub(all) enum LayerConstraint {
  NoneType
  First
  FirstSeparate
  Last
  LastSeparate
}

///|
pub fn layer_constraint_to_string(value : LayerConstraint) -> String {
  match value {
    NoneType => "NONE"
    First => "FIRST"
    FirstSeparate => "FIRST_SEPARATE"
    Last => "LAST"
    LastSeparate => "LAST_SEPARATE"
  }
}

///|
pub fn layer_constraint_from_string(value : String) -> LayerConstraint {
  match value {
    "FIRST" => First
    "FIRST_SEPARATE" => FirstSeparate
    "LAST" => Last
    "LAST_SEPARATE" => LastSeparate
    _ => NoneType
  }
}

///|
pub fn layer_constraint_is_first_or_last_separate(
  value : LayerConstraint,
) -> Bool {
  match value {
    FirstSeparate => true
    LastSeparate => true
    _ => false
  }
}

///|
pub fn layer_constraint_values() -> Array[String] {
  [
    layer_constraint_to_string(NoneType),
    layer_constraint_to_string(First),
    layer_constraint_to_string(FirstSeparate),
    layer_constraint_to_string(Last),
    layer_constraint_to_string(LastSeparate),
  ]
}
