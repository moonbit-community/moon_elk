///|
pub enum LayerConstraint {
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
    "FIRST" => LayerConstraint::First
    "FIRST_SEPARATE" => LayerConstraint::FirstSeparate
    "LAST" => LayerConstraint::Last
    "LAST_SEPARATE" => LayerConstraint::LastSeparate
    _ => LayerConstraint::NoneType
  }
}

///|
pub fn layer_constraint_is_first_or_last_separate(
  value : LayerConstraint,
) -> Bool {
  match value {
    LayerConstraint::FirstSeparate => true
    LayerConstraint::LastSeparate => true
    _ => false
  }
}

///|
pub fn layer_constraint_values() -> Array[String] {
  [
    layer_constraint_to_string(LayerConstraint::NoneType),
    layer_constraint_to_string(LayerConstraint::First),
    layer_constraint_to_string(LayerConstraint::FirstSeparate),
    layer_constraint_to_string(LayerConstraint::Last),
    layer_constraint_to_string(LayerConstraint::LastSeparate),
  ]
}
