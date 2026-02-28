///|
pub enum MrtreeOrderWeighting {
  MODEL_ORDER
  DESCENDANTS
  FAN
  CONSTRAINT
}

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
    MrtreeOrderWeighting::MODEL_ORDER
  }
}
