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
  node_dimension_calculation_calculate_label_and_node_sizes_for_adapter(adapter)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_calculate_label_and_node_sizes_for_adapter(
  adapter : &NodeSpacingGraph,
) -> Unit {
  node_label_and_size_calculator_process_graph(adapter)
}

///|
pub fn node_dimension_calculation_calculate_node_margins_for_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit {
  node_dimension_calculation_calculate_node_margins(@core.adapt(layered_graph))
}

///|
pub fn node_dimension_calculation_calculate_node_margins(
  adapter : @core.ElkGraphAdapter,
) -> Unit {
  node_dimension_calculation_calculate_node_margins_for_adapter(adapter)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_calculate_node_margins_for_adapter(
  adapter : &NodeSpacingGraph,
) -> Unit {
  let calculator = new_node_margin_calculator_for_adapter(adapter)
  calculator.process()
  adapter.cleanup()
}

///|
pub fn node_dimension_calculation_get_node_margin_calculator(
  adapter : @core.ElkGraphAdapter,
) -> NodeMarginCalculator {
  new_node_margin_calculator_for_adapter(adapter)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_get_node_margin_calculator_for_adapter(
  adapter : &NodeSpacingGraph,
) -> NodeMarginCalculator {
  new_node_margin_calculator_for_adapter(adapter)
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
  node_dimension_calculation_sort_port_lists_for_adapter(adapter)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_sort_port_lists_for_adapter(
  adapter : &NodeSpacingGraph,
) -> Unit {
  for node in adapter.get_nodes() {
    node.sort_port_list()
  }
  adapter.cleanup()
}
