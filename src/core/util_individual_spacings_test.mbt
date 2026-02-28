///|
test "individual_spacings parse and serialize" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  let spacings = new_individual_spacings()
  spacings.parse("spacing.nodeNode:12")
  inspect(
    spacings.get_option(spacing_node_node.get_id()),
    content="Some(\"12\")",
  )
  inspect(
    spacings.to_string().contains("org.eclipse.elk.spacing.nodeNode:12"),
    content="true",
  )
}

///|
test "individual_spacings copy constructor preserves entries" {
  let source = new_individual_spacings()
  source.set_option(spacing_node_node.get_id(), "7.5")
  let copied = new_individual_spacings_from(source)
  inspect(
    copied.get_option(spacing_node_node.get_id()),
    content="Some(\"7.5\")",
  )
}

///|
test "individual_spacings move between node and object" {
  @graph.reset_graph_model_for_test()
  let source = @graph.create_graph()
  @graph.node_set_individual_spacing_option_string_by_id(
    source,
    spacing_node_node.get_id(),
    "31",
  )
  let spacings = individual_spacings_from_node(source)
  let target = @graph.create_graph()
  individual_spacings_apply_to_node(spacings, target)
  inspect(
    @graph.node_individual_spacing_option_string_value(
      target,
      spacing_node_node.get_id(),
    ),
    content="Some(\"31\")",
  )
}

///|
test "individual_spacings_get_individual_or_inherited prefers node override" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let child = @graph.create_node(Some(root))
  @graph.node_set_double_property(root, spacing_node_node, 3.0)
  @graph.node_set_individual_spacing_option_string_by_id(
    child,
    spacing_node_node.get_id(),
    "17.5",
  )
  inspect(
    individual_spacings_get_individual_or_inherited(child, spacing_node_node),
    content="17.5",
  )
}

///|
test "individual_spacings_get_individual_or_inherited falls back to parent" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let child = @graph.create_node(Some(root))
  @graph.node_set_double_property(root, spacing_node_node, 3.0)
  inspect(
    individual_spacings_get_individual_or_inherited(child, spacing_node_node),
    content="3",
  )
}
