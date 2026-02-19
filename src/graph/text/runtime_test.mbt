///|
fn graph_text_runtime_issue_contains(
  issues : Array[GraphTextValidationIssue],
  fragment : String,
) -> Bool {
  for issue in issues {
    if issue.message.contains(fragment) {
      return true
    }
  }
  false
}

///|
fn graph_text_runtime_string_or_none(value : String?) -> String {
  match value {
    Some(text) => text
    None => "none"
  }
}

///|
test "ElkGraphRuntimeModule exposes custom binding overrides" {
  let runtime_module = new_elk_graph_runtime_module()
  inspect(
    runtime_module.bind_i_value_converter_service(),
    content="org.eclipse.elk.graph.text.conversion.ElkGraphValueConverterService",
  )
  inspect(
    runtime_module.bind_i_qualified_name_provider(),
    content="org.eclipse.elk.graph.text.naming.ElkGraphQualifiedNameProvider",
  )
  inspect(
    runtime_module.bind_i_qualified_name_converter(),
    content="org.eclipse.elk.graph.text.naming.ElkGraphQualifiedNameConverter",
  )
  inspect(
    runtime_module.bind_i_transient_value_service2(),
    content="org.eclipse.elk.graph.text.serializer.ElkGraphTransientValueService",
  )
  inspect(
    runtime_module.bind_ilinker(),
    content="org.eclipse.elk.graph.text.linking.ElkGraphLinker",
  )
}

///|
test "ElkGraphStandaloneSetup registers extension maps" {
  graph_text_reset_registries_for_test()
  ignore(elk_graph_standalone_setup_do_setup())

  inspect(
    graph_text_runtime_string_or_none(
      graph_text_registered_resource_factory(graph_text_file_extension),
    ),
    content="org.eclipse.xtext.resource.IResourceFactory",
  )
  inspect(
    graph_text_runtime_string_or_none(
      graph_text_registered_resource_service_provider(graph_text_file_extension),
    ),
    content="org.eclipse.xtext.resource.IResourceServiceProvider",
  )
}

///|
test "ElkGraphQualifiedNameConverter converts dotted names" {
  let converter = new_elk_graph_qualified_name_converter()
  converter.initialize(new_elk_graph_grammar_access())
  inspect(
    converter.to_qualified_name("org.eclipse.elk"),
    content="[\"org\", \"eclipse\", \"elk\"]",
  )
  inspect(converter.to_string(["org", "graph"]), content="org.^graph")
}

///|
test "ElkGraphQualifiedNameProvider prepends parent names" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  @graph.node_set_identifier(root, "root")
  let child = @graph.create_node(Some(root))
  @graph.node_set_identifier(child, "child")
  let port = @graph.create_port(Some(child))
  @graph.port_set_identifier(port, "p")

  let provider = new_elk_graph_qualified_name_provider()
  inspect(
    provider.qualified_name(GraphPort(port)),
    content="[\"root\", \"child\", \"p\"]",
  )
}

///|
test "ElkGraph value converters parse numbers keys and values" {
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_options()
  @core.layout_meta_data_service_register_default_algorithms()

  let number_converter = new_number_value_converter()
  inspect(number_converter.to_string(Some(12.0)), content="12")
  inspect(number_converter.to_value("-4.5"), content="-4.5")

  let key_converter = new_property_key_value_converter()
  key_converter.initialize(new_elk_graph_grammar_access())
  let key = key_converter.to_value("algorithm")
  inspect(graph_text_property_key_id(key), content="org.eclipse.elk.algorithm")
  inspect(key_converter.to_string(Some(key)), content="algorithm")

  let value_converter = new_property_value_value_converter()
  let no_layout_option = @core.layout_meta_data_service_get_option_data(
    @core.no_layout.get_id(),
  )
  inspect(
    value_converter.to_value(
      "true",
      property_key=Some(LayoutOption(no_layout_option)),
    ),
    content="BooleanValue(true)",
  )
  inspect(
    value_converter.to_string(ProxyValue("org.eclipse.elk.layered")),
    content="org.eclipse.elk.layered",
  )
  inspect(
    value_converter.to_value("\"hello world\""),
    content="ProxyValue(\"hello world\")",
  )
}

///|
test "ElkGraphScopeProvider resolves sibling section identifiers" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let edge = @graph.create_edge(Some(root))
  let s1 = @graph.create_edge_section(edge)
  @graph.edge_section_set_identifier(s1, "s1")
  let s2 = @graph.create_edge_section(edge)
  @graph.edge_section_set_identifier(s2, "s2")

  let scope_provider = new_elk_graph_scope_provider()
  let scope = scope_provider.get_scope(
    s1, graph_text_reference_elk_edge_section_outgoing_sections,
  )
  inspect(scope.length(), content="2")
  inspect(graph_text_generated_test_contains(scope, "s2"), content="true")
}

///|
test "ElkGraph syntactic and semantic sequencers keep generated defaults" {
  let syntactic = new_abstract_elk_graph_syntactic_sequencer()
  inspect(
    syntactic.emit_unassigned_tokens("", [
      "ElkEdge___LeftCurlyBracketKeyword_7_0_RightCurlyBracketKeyword_7_4__q",
    ]),
    content="[\"{}\"]",
  )

  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_options()
  let option = @core.layout_meta_data_service_get_option_data(
    @core.algorithm.get_id(),
  )
  let semantic = new_elk_graph_semantic_sequencer()
  let result = semantic.sequence_property(
    "Property",
    new_graph_text_property_assignment(
      LayoutOption(option),
      ProxyValue("org.eclipse.elk.layered"),
    ),
  )
  inspect(
    graph_text_property_value_to_string(result.value),
    content="org.eclipse.elk.layered",
  )
}

///|
test "ElkGraphTransientValueService marks opposite lists as transient" {
  let service = new_elk_graph_transient_value_service()
  inspect(
    service.is_list_transient("", graph_text_opposite_ref_incoming_edges),
    content="ListTransientYes",
  )
  inspect(service.is_list_transient("", "OTHER"), content="ListTransientNo")
}

///|
test "ElkGraphLinker skips opposite references during clearReference" {
  let linker = new_elk_graph_linker()
  inspect(
    linker.clear_reference("", graph_text_opposite_ref_incoming_edges),
    content="false",
  )
  inspect(
    linker.clear_reference("", "ELK_GRAPH_ELEMENT__IDENTIFIER"),
    content="true",
  )
}

///|
test "ElkGraphTextUtil resolves algorithm for nested elements" {
  @graph.reset_graph_model_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_options()
  @core.layout_meta_data_service_register_default_algorithms()

  let root = @graph.create_graph()
  @graph.node_set_identifier(root, "root")
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    "org.eclipse.elk.layered",
  )
  let child = @graph.create_node(Some(root))
  @graph.node_set_identifier(child, "child")
  let port = @graph.create_port(Some(child))
  @graph.port_set_identifier(port, "p")

  let algorithm_data = elk_graph_text_util_get_algorithm(GraphPort(port))
  inspect(
    graph_text_runtime_string_or_none(
      match algorithm_data {
        Some(value) => Some(value.get_id())
        None => None
      },
    ),
    content="org.eclipse.elk.layered",
  )
}

///|
test "ElkGraphValidator checks property values and uniqueness" {
  @graph.reset_graph_model_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_options()
  @core.layout_meta_data_service_register_default_algorithms()

  let validator = new_elk_graph_validator()
  let root = @graph.create_graph()
  @graph.node_set_identifier(root, "root")
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    "org.eclipse.elk.layered",
  )

  let priority_option = @core.layout_meta_data_service_get_option_data(
    @core.priority.get_id(),
  )
  let priority_entry = new_graph_text_property_assignment(
    LayoutOption(priority_option),
    NumberValue(2.0),
  )
  let priority_issues = validator.check_property_value(
    priority_entry,
    GraphNode(root),
  )
  inspect(
    graph_text_runtime_issue_contains(priority_issues, "not applicable"),
    content="true",
  )

  let unknown_algo_entry = new_graph_text_property_assignment(
    LayoutOption(
      @core.layout_meta_data_service_get_option_data(@core.algorithm.get_id()),
    ),
    ProxyValue("org.eclipse.elk.unknown"),
  )
  let algorithm_issues = validator.check_property_value(
    unknown_algo_entry,
    GraphNode(root),
  )
  inspect(
    graph_text_runtime_issue_contains(algorithm_issues, "No layout algorithm"),
    content="true",
  )

  let duplicate_properties = validator.check_unique_properties([
    priority_entry, priority_entry,
  ])
  inspect(duplicate_properties.length(), content="2")

  let n1 = @graph.create_node(Some(root))
  @graph.node_set_identifier(n1, "dup")
  let n2 = @graph.create_node(Some(root))
  @graph.node_set_identifier(n2, "dup")
  let duplicate_names = validator.check_unique_names_for_node(root)
  inspect(duplicate_names.length(), content="2")
}
