///|
pub fn register_node_spacing_processors(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  registry.register_stateful_intermediate_processor(LabelAndNodeSizeProcessor, state => {
    new_label_and_node_size_processor_layout_processor(state~)
  })
  registry.register_intermediate_processor(InnermostNodeMarginCalculator, () => {
    new_innermost_node_margin_calculator_layout_processor()
  })
}
