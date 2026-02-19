///|
pub enum MrtreeGraphProperty {
  SELF_LOOPS
}

///|
pub fn mrtree_graph_property_from_string(value : String) -> MrtreeGraphProperty {
  ignore(value)
  MrtreeGraphProperty::SELF_LOOPS
}
