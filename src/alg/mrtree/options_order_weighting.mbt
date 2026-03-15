///|
pub enum MrtreeOrderWeighting {
  MODEL_ORDER
  DESCENDANTS
  FAN
  CONSTRAINT
}

///|
let _mrtree_order_weighting_reserved : Array[MrtreeOrderWeighting] = [
  MrtreeOrderWeighting::MODEL_ORDER,
]

///|
pub fn mrtree_order_weighting_from_string(
  value : String,
) -> MrtreeOrderWeighting {
  if value == "DESCENDANTS" {
    MrtreeOrderWeighting::DESCENDANTS
  } else if value == "FAN" {
    MrtreeOrderWeighting::FAN
  } else if value == "CONSTRAINT" {
    MrtreeOrderWeighting::CONSTRAINT
  } else {
    MrtreeOrderWeighting::DESCENDANTS
  }
}
