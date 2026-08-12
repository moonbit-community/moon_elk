///|
pub fn node_dimension_calculation_calculate_label_and_node_sizes_for_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit raise {
  node_dimension_calculation_calculate_label_and_node_sizes(
    @core.adapt(layered_graph),
  )
}

///|
pub fn node_dimension_calculation_calculate_label_and_node_sizes(
  adapter : @core.ElkGraphAdapter,
) -> Unit raise {
  let input = capture_elk_node_spacing_input(adapter)
  let output = node_dimension_calculation_calculate_label_and_node_sizes_for_input(
    input,
  )
  apply_elk_node_spacing_output(adapter, output)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_calculate_label_and_node_sizes_for_input(
  input : NodeSpacingInput,
) -> NodeSpacingOutput raise {
  node_label_and_size_calculator_process_graph(input)
  input.output()
}

///|
pub fn node_dimension_calculation_calculate_node_margins_for_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit raise {
  node_dimension_calculation_calculate_node_margins(@core.adapt(layered_graph))
}

///|
pub fn node_dimension_calculation_calculate_node_margins(
  adapter : @core.ElkGraphAdapter,
) -> Unit raise {
  let input = capture_elk_node_spacing_input(adapter)
  let output = node_dimension_calculation_calculate_node_margins_for_input(
    input,
  )
  apply_elk_node_spacing_output(adapter, output)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_calculate_node_margins_for_input(
  input : NodeSpacingInput,
) -> NodeSpacingOutput {
  let calculator = new_node_margin_calculator_for_input(input)
  calculator.process()
  input.output()
}

///|
pub fn node_dimension_calculation_get_node_margin_calculator(
  adapter : @core.ElkGraphAdapter,
) -> NodeMarginCalculator raise {
  new_node_margin_calculator(adapter)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_get_node_margin_calculator_for_input(
  input : NodeSpacingInput,
) -> NodeMarginCalculator {
  new_node_margin_calculator_for_input(input)
}

///|
pub fn node_dimension_calculation_sort_port_lists_for_layered_graph(
  layered_graph : @graph.ElkNode,
) -> Unit raise {
  node_dimension_calculation_sort_port_lists(@core.adapt(layered_graph))
}

///|
pub fn node_dimension_calculation_sort_port_lists(
  adapter : @core.ElkGraphAdapter,
) -> Unit raise {
  let input = capture_elk_node_spacing_input(adapter)
  let output = node_dimension_calculation_sort_port_lists_for_input(input)
  apply_elk_node_spacing_output(adapter, output)
}

///|
#internal(nodespacing)
pub fn node_dimension_calculation_sort_port_lists_for_input(
  input : NodeSpacingInput,
) -> NodeSpacingOutput raise {
  for node in input.nodes {
    node.sort_port_list()
  }
  input.output()
}
