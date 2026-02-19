///|
test "property_constants_delegator create_empty" {
  let delegator = property_constants_delegator_create_empty()
  inspect(
    delegator.has_delegate_for(spacing_node_node.get_id()),
    content="false",
  )
}

///|
test "property_constants_delegator create_for_layout_algorithm_data" {
  let algorithm_data = new_layout_algorithm_data("test.algorithm")
  algorithm_data.add_known_option(spacing_node_node.get_id())
  algorithm_data.add_known_option(padding.get_id())
  let delegator = property_constants_delegator_create_for_layout_algorithm_data(
    algorithm_data,
  )
  inspect(
    delegator.has_delegate_for(spacing_node_node.get_id()),
    content="true",
  )
  inspect(delegator.has_delegate_for(padding.get_id()), content="true")
}

///|
test "property_constants_delegator create_for_layout_algorithm_with_id" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()
  let delegator = property_constants_delegator_create_for_layout_algorithm_with_id(
    "org.eclipse.elk.box",
  )
  inspect(
    delegator.has_delegate_for(spacing_node_node.get_id()),
    content="true",
  )
  inspect(delegator.has_delegate_for(priority.get_id()), content="true")
  let missing = property_constants_delegator_create_for_layout_algorithm_with_id(
    "org.eclipse.elk.unknown",
  )
  inspect(missing.has_delegate_for(spacing_node_node.get_id()), content="false")
}

///|
test "property_constants_delegator get_property helpers on node" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_double_property(graph, spacing_node_node, 77.0)
  node_set_bool_property(graph, no_layout, true)
  node_set_string_property(graph, algorithm, "org.eclipse.elk.box")
  let delegator = property_constants_delegator_create_empty()
    .add_delegate(spacing_node_node)
    .add_delegate(no_layout)
    .add_delegate(algorithm)
  inspect(delegator.get_property_double(graph, spacing_node_node), content="77")
  inspect(delegator.get_property_bool(graph, no_layout), content="true")
  inspect(
    delegator.get_property_string(graph, algorithm),
    content="org.eclipse.elk.box",
  )
}

///|
test "property_constants_delegator get_individual_or_inherited_property" {
  reset_graph_model_for_test()
  let root = create_graph()
  let child = create_node(Some(root))
  node_set_double_property(root, spacing_edge_label, 3.0)
  node_set_individual_spacing_option_string_by_id(
    child,
    spacing_edge_label.get_id(),
    "17.5",
  )
  let delegator = property_constants_delegator_create_empty().add_delegate(
    spacing_edge_label,
  )
  inspect(
    delegator.get_individual_or_inherited_property(child, spacing_edge_label),
    content="17.5",
  )
  let sibling = create_node(Some(root))
  inspect(
    delegator.get_individual_or_inherited_property(sibling, spacing_edge_label),
    content="3",
  )
}
