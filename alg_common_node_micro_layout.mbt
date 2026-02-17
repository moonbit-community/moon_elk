///|
pub struct NodeMicroLayout {
  adapter : LGraphAdapter
}

///|
pub fn node_micro_layout_for_graph(graph : LGraph) -> NodeMicroLayout {
  node_micro_layout_for_adapter(adapt_l_graph(graph))
}

///|
pub fn node_micro_layout_for_adapter(
  adapter : LGraphAdapter,
) -> NodeMicroLayout {
  { adapter, }
}

///|
pub fn NodeMicroLayout::execute(self : NodeMicroLayout) -> Unit {
  node_dimension_calculation_sort_port_lists(self.adapter)
  node_dimension_calculation_calculate_label_and_node_sizes(self.adapter)
  node_dimension_calculation_calculate_node_margins(self.adapter)
}
