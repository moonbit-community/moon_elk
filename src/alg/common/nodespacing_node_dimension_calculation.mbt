///|
pub fn node_dimension_calculation_calculate_label_and_node_sizes_for_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit {
  node_dimension_calculation_calculate_label_and_node_sizes(
    @core.adapt(layered_graph),
  )
}

///|
pub fn node_dimension_calculation_calculate_label_and_node_sizes(
  adapter : @core.ElkGraphAdapter,
) -> Unit {
  node_label_and_size_calculator_process_layered_graph(adapter.get_graph())
}

///|
pub fn node_dimension_calculation_calculate_node_margins_for_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit {
  node_dimension_calculation_calculate_node_margins(
    @core.adapt(layered_graph),
  )
}

///|
pub fn node_dimension_calculation_calculate_node_margins(
  adapter : @core.ElkGraphAdapter,
) -> Unit {
  let calculator = new_node_margin_calculator(adapter)
  calculator.process()
}

///|
pub fn node_dimension_calculation_get_node_margin_calculator(
  adapter : @core.ElkGraphAdapter,
) -> NodeMarginCalculator {
  new_node_margin_calculator(adapter)
}

///|
pub fn node_dimension_calculation_sort_port_lists_for_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit {
  node_dimension_calculation_sort_port_lists(@core.adapt(layered_graph))
}

///|
pub fn node_dimension_calculation_sort_port_lists(
  adapter : @core.ElkGraphAdapter,
) -> Unit {
  for node in adapter.get_nodes() {
    node.sort_port_list()
  }
}
