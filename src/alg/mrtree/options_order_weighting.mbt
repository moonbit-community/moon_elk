///|
pub enum MrtreeOrderWeighting {
  MODEL_ORDER
  DESCENDANTS
  FAN
  CONSTRAINT
}

///|
let _mrtree_order_weighting_reserved : Array[MrtreeOrderWeighting] = [
  MODEL_ORDER,
]

///|
pub fn mrtree_order_weighting_from_string(
  value : String,
) -> MrtreeOrderWeighting {
  if value == "DESCENDANTS" {
    DESCENDANTS
  } else if value == "FAN" {
    FAN
  } else if value == "CONSTRAINT" {
    CONSTRAINT
  } else {
    DESCENDANTS
  }
}
