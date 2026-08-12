///|
pub struct NodeMicroLayout {
  adapter : @core.ElkGraphAdapter
}

///|
pub fn node_micro_layout_for_graph(graph : @graph.ElkNode) -> NodeMicroLayout {
  node_micro_layout_for_adapter(@core.adapt(graph))
}

///|
pub fn node_micro_layout_for_adapter(
  adapter : @core.ElkGraphAdapter,
) -> NodeMicroLayout {
  { adapter, }
}

///|
pub fn NodeMicroLayout::execute(self : NodeMicroLayout) -> Unit raise {
  // Capture once so the complete micro-layout pipeline runs on concrete data.
  // Graph handles and property lookup stay outside all node-spacing hot loops.
  let input = capture_elk_node_spacing_input(self.adapter)
  ignore(node_dimension_calculation_sort_port_lists_for_input(input))
  ignore(
    node_dimension_calculation_calculate_label_and_node_sizes_for_input(input),
  )
  ignore(node_dimension_calculation_calculate_node_margins_for_input(input))
  apply_elk_node_spacing_output(self.adapter, input.output())
}
