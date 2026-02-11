///|
pub struct ISpacingsHandler {
  get_horizontal_spacing : (CNode, CNode) -> Double
  get_vertical_spacing : (CNode, CNode) -> Double
}

///|
pub fn default_spacing_handler() -> ISpacingsHandler {
  { get_horizontal_spacing: (_, _) => 0.0, get_vertical_spacing: (_, _) => 0.0 }
}

///|
pub fn new_spacings_handler(
  get_horizontal_spacing : (CNode, CNode) -> Double,
  get_vertical_spacing : (CNode, CNode) -> Double,
) -> ISpacingsHandler {
  { get_horizontal_spacing, get_vertical_spacing }
}
