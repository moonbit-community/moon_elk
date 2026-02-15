///|
fn end_label_sorter_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown strategy")
}

///|
fn end_label_sorter_test_node_type(name : String) -> NodeType {
  for node_type in node_type_values() {
    match node_type {
      NodeType::Normal => if name == "NORMAL" { return node_type }
      NodeType::LongEdge => if name == "LONG_EDGE" { return node_type }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NodeType::NorthSouthPort =>
        if name == "NORTH_SOUTH_PORT" {
          return node_type
        }
      NodeType::LabelNode => if name == "LABEL_NODE" { return node_type }
      NodeType::BreakingPoint =>
        if name == "BREAKING_POINT" {
          return node_type
        }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return node_type }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
test "end label sorter reports expected task name" {
  let processor = new_end_label_sorter_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Sort end labels")
}

///|
test "end label sorter keeps represented labels lexicographically sorted" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let label_node = new_l_node(graph=Some(graph))
  label_node.set_type(end_label_sorter_test_node_type("LABEL_NODE"))
  label_node.set_layer(Some(layer))
  label_node.set_property_l_label_array(
    internal_properties_represented_labels,
    [new_l_label_text("B"), new_l_label_text("A"), new_l_label_text("C")],
  )

  let processor = new_end_label_sorter_layout_processor()
  processor.process(graph, None)

  let represented_labels = label_node.get_property_l_label_array(
    internal_properties_represented_labels,
  )
  assert_eq(represented_labels.length(), 3)
  assert_eq(represented_labels[0].get_text(), "A")
  assert_eq(represented_labels[1].get_text(), "B")
  assert_eq(represented_labels[2].get_text(), "C")
}

///|
test "intermediate strategy factory exposes end label sorter" {
  let factory = layered_intermediate_processor_factory(
    end_label_sorter_test_strategy("END_LABEL_SORTER"),
  )
  assert_eq(factory.factory_id(), 23053)
  assert_eq(factory.factory_order(), 53)
}
