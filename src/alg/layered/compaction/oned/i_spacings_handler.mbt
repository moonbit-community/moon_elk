///|
pub type LayeredISpacingsHandler = @compaction.ISpacingsHandler

///|
pub fn layered_default_spacing_handler() -> LayeredISpacingsHandler {
  @compaction.default_spacing_handler()
}

///|
pub fn new_layered_spacings_handler(
  get_horizontal_spacing : (LayeredCNode, LayeredCNode) -> Double raise,
  get_vertical_spacing : (LayeredCNode, LayeredCNode) -> Double raise,
) -> LayeredISpacingsHandler {
  @compaction.new_spacings_handler(get_horizontal_spacing, get_vertical_spacing)
}
