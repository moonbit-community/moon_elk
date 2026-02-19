///|
fn node_dimension_calculation_is_normal_node(node : LNode) -> Bool {
  node.get_type() is NodeType::Normal
}

///|
pub fn node_dimension_calculation_calculate_label_and_node_sizes_for_layered_graph(
  layered_graph : LGraph,
) -> Unit {
  node_dimension_calculation_calculate_label_and_node_sizes(
    adapt_l_graph_with_options(
      layered_graph,
      true,
      true,
      node_dimension_calculation_is_normal_node,
    ),
  )
}

///|
pub fn node_dimension_calculation_calculate_label_and_node_sizes(
  adapter : LGraphAdapter,
) -> Unit {
  node_label_and_size_calculator_process_layered_graph(adapter.get_graph())
}

///|
pub fn node_dimension_calculation_calculate_node_margins_for_layered_graph(
  layered_graph : LGraph,
) -> Unit {
  node_dimension_calculation_calculate_node_margins(
    adapt_l_graph(layered_graph),
  )
}

///|
pub fn node_dimension_calculation_calculate_node_margins(
  adapter : LGraphAdapter,
) -> Unit {
  let calculator = new_node_margin_calculator(adapter)
  calculator.process()
}

///|
pub fn node_dimension_calculation_get_node_margin_calculator(
  adapter : LGraphAdapter,
) -> NodeMarginCalculator {
  new_node_margin_calculator(adapter)
}

///|
pub fn node_dimension_calculation_sort_port_lists_for_layered_graph(
  layered_graph : LGraph,
) -> Unit {
  node_dimension_calculation_sort_port_lists(adapt_l_graph(layered_graph))
}

///|
pub fn node_dimension_calculation_sort_port_lists(
  adapter : LGraphAdapter,
) -> Unit {
  for node in adapter.get_nodes() {
    node.sort_port_list()
  }
}
