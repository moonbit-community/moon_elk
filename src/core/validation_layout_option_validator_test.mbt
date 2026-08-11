///|
fn init_layout_metadata_for_option_validation_test() -> OptionMetadata {
  let metadata = new_option_metadata()
  metadata.register_default_options()
  metadata
}

///|
test "LayoutOptionValidator invalid type" {
  let metadata = init_layout_metadata_for_option_validation_test()
  let graph = @graph.create_graph()
  let aspect_ratio_option = metadata.option_data(aspect_ratio.get_id())
  @graph.node_set_layout_option_string_by_id(
    graph,
    aspect_ratio_option.get_id(),
    "foo",
  )
  let validator = new_layout_option_validator(metadata)
  apply_visitors(graph, [validator.to_visitor()])
  assert_eq(
    graph_issue_list_to_string(validator.get_issues()),
    "[ERROR: The assigned value foo of the option 'Aspect Ratio' does not match the type Double. (Root Node)]",
  )
}

///|
test "LayoutOptionValidator exclusive lower bound" {
  let metadata = init_layout_metadata_for_option_validation_test()
  let graph = @graph.create_graph()
  @graph.node_set_double_property(graph, aspect_ratio, 0.0)
  let validator = new_layout_option_validator(metadata)
  apply_visitors(graph, [validator.to_visitor()])
  assert_eq(
    graph_issue_list_to_string(validator.get_issues()),
    "[ERROR: The assigned value 0.0 of the option 'org.eclipse.elk.aspectRatio' is less than the lower bound 0.0 (exclusive). (Root Node)]",
  )
}
