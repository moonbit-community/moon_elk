///|
pub type LayeredISpacingsHandler = ISpacingsHandler

///|
pub fn layered_default_spacing_handler() -> LayeredISpacingsHandler {
  default_spacing_handler()
}

///|
pub fn new_layered_spacings_handler(
  get_horizontal_spacing : (LayeredCNode, LayeredCNode) -> Double,
  get_vertical_spacing : (LayeredCNode, LayeredCNode) -> Double,
) -> LayeredISpacingsHandler {
  new_spacings_handler(get_horizontal_spacing, get_vertical_spacing)
}
