///|
fn init_layout_metadata_for_option_validation_test() -> Unit {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
}

///|
test "LayoutOptionValidator invalid type" {
  reset_graph_model_for_test()
  init_layout_metadata_for_option_validation_test()
  let graph = create_graph()
  let aspect_ratio_option = layout_meta_data_service_get_option_data(
    aspect_ratio.get_id(),
  )
  node_set_layout_option_string_value(graph, aspect_ratio_option, "foo")
  let validator = new_layout_option_validator()
  apply_visitors(graph, [validator.to_visitor()])
  assert_eq(
    graph_issue_list_to_string(validator.get_issues()),
    "[ERROR: The assigned value foo of the option 'Aspect Ratio' does not match the type Double. (Root Node)]",
  )
}

///|
test "LayoutOptionValidator exclusive lower bound" {
  reset_graph_model_for_test()
  init_layout_metadata_for_option_validation_test()
  let graph = create_graph()
  node_set_double_property(graph, aspect_ratio, 0.0)
  let validator = new_layout_option_validator()
  apply_visitors(graph, [validator.to_visitor()])
  assert_eq(
    graph_issue_list_to_string(validator.get_issues()),
    "[ERROR: The assigned value 0.0 of the option 'org.eclipse.elk.aspectRatio' is less than the lower bound 0.0 (exclusive). (Root Node)]",
  )
}
