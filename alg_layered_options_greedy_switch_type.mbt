///|
pub enum GreedySwitchType {
  OneSided
  TwoSided
  Off
}

///|
pub fn greedy_switch_type_values() -> Array[GreedySwitchType] {
  [
    GreedySwitchType::OneSided,
    GreedySwitchType::TwoSided,
    GreedySwitchType::Off,
  ]
}
