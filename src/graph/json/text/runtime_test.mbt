///|
fn graph_json_text_runtime_bool_to_string(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn graph_json_text_runtime_string_or_none(value : String?) -> String {
  match value {
    Some(text) => text
    None => "none"
  }
}

///|
test "ElkGraphJsonRuntimeModule exposes custom binding overrides" {
  let runtime_module = new_elk_graph_json_runtime_module()
  debug_inspect(
    runtime_module.bind_i_value_converter_service(),
    content=(
      #|"org.eclipse.elk.graph.json.text.conversion.ElkGraphJsonValueConverterService"
    ),
  )
  debug_inspect(
    runtime_module.bind_i_qualified_name_provider(),
    content=(
      #|"org.eclipse.elk.graph.json.text.naming.ElkGraphJsonQualifiedNameProvider"
    ),
  )
  debug_inspect(
    runtime_module.bind_i_transient_value_service2(),
    content=(
      #|"org.eclipse.elk.graph.json.text.serializer.ElkGraphJsonTransientValueService"
    ),
  )
}

///|
test "ElkGraphJsonStandaloneSetup registers extension maps" {
  graph_json_text_reset_registries_for_test()
  ignore(elk_graph_json_standalone_setup_do_setup())

  debug_inspect(
    graph_json_text_runtime_string_or_none(
      graph_json_text_registered_resource_factory(
        graph_json_text_file_extension,
      ),
    ),
    content=(
      #|"org.eclipse.xtext.resource.IResourceFactory"
    ),
  )
  debug_inspect(
    graph_json_text_runtime_string_or_none(
      graph_json_text_registered_resource_service_provider(
        graph_json_text_file_extension,
      ),
    ),
    content=(
      #|"org.eclipse.xtext.resource.IResourceServiceProvider"
    ),
  )
}

///|
test "ElkGraphJsonQualifiedNameProvider yields element identifier" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  @graph.node_set_identifier(root, "root")
  let provider = new_elk_graph_json_qualified_name_provider()
  debug_inspect(
    provider.qualified_name(GraphJsonTextNode(root)),
    content="[\"root\"]",
  )
}

///|
test "ElkGraphJson value converters parse numbers keys and values" {
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_options()
  @core.layout_meta_data_service_register_default_algorithms()

  let number_converter = new_graph_json_text_number_value_converter()
  debug_inspect(
    number_converter.to_string(Some(12.0)),
    content=(
      #|"12"
    ),
  )
  debug_inspect(number_converter.to_value("-4.5"), content="-4.5")

  let key_converter = new_graph_json_text_property_key_value_converter()
  key_converter.initialize(new_elk_graph_json_grammar_access())
  let key = key_converter.to_value("\"algorithm\"")
  debug_inspect(
    graph_json_text_property_key_id(key),
    content=(
      #|"org.eclipse.elk.algorithm"
    ),
  )
  debug_inspect(
    key_converter.to_string(Some(key)),
    content=(
      #|"algorithm"
    ),
  )

  let value_converter = new_graph_json_text_property_value_value_converter()
  let no_layout_option = @core.layout_meta_data_service_get_option_data(
    @core.no_layout.get_id(),
  )
  debug_inspect(
    value_converter.to_value(
      "\"true\"",
      property_key=Some(GraphJsonTextLayoutOption(no_layout_option)),
    ),
    content="GraphJsonTextBooleanValue(true)",
  )
  debug_inspect(
    value_converter.to_string(
      GraphJsonTextProxyValue("org.eclipse.elk.layered"),
    ),
    content=(
      #|"\"org.eclipse.elk.layered\""
    ),
  )
  debug_inspect(
    value_converter.to_value("\"hello world\""),
    content="GraphJsonTextProxyValue(\"hello world\")",
  )
}

///|
test "ElkGraphJsonScopeProvider resolves sibling section identifiers" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let edge = @graph.create_edge(Some(root))
  let s1 = @graph.create_edge_section(edge)
  @graph.edge_section_set_identifier(s1, "s1")
  let s2 = @graph.create_edge_section(edge)
  @graph.edge_section_set_identifier(s2, "s2")

  let scope_provider = new_elk_graph_json_scope_provider()
  let scope = scope_provider.get_scope(
    s1, graph_json_text_reference_elk_edge_section_outgoing_sections,
  )
  debug_inspect(scope.length(), content="2")
}

///|
test "ElkGraphJson syntactic and semantic sequencers keep generated defaults" {
  let syntactic = new_abstract_elk_graph_json_syntactic_sequencer()
  debug_inspect(
    syntactic.emit_unassigned_tokens("", [
      "JsonObject___LeftCurlyBracketKeyword_0_RightCurlyBracketKeyword_3__q",
    ]),
    content="[\"{}\"]",
  )

  let semantic = new_elk_graph_json_semantic_sequencer()
  let option = @core.layout_meta_data_service_get_option_data(
    @core.algorithm.get_id(),
  )
  let result = semantic.sequence_property(
    "Property",
    new_graph_json_text_property_assignment(
      GraphJsonTextLayoutOption(option),
      GraphJsonTextProxyValue("org.eclipse.elk.layered"),
    ),
  )
  debug_inspect(
    graph_json_text_property_value_to_string(result.value),
    content=(
      #|"org.eclipse.elk.layered"
    ),
  )
}

///|
test "ElkGraphJsonTransientValueService marks opposite lists as transient" {
  let service = new_elk_graph_json_transient_value_service()
  debug_inspect(
    service.is_list_transient("", graph_json_text_opposite_ref_incoming_edges),
    content="GraphJsonTextListTransientYes",
  )
  debug_inspect(
    service.is_list_transient("", "OTHER"),
    content="GraphJsonTextListTransientNo",
  )
}

///|
test "ElkGraphJson validator and issue-code provider expose generated defaults" {
  let validator = new_elk_graph_json_validator()
  debug_inspect(
    graph_json_text_runtime_bool_to_string(validator.is_enabled()),
    content=(
      #|"true"
    ),
  )
  let provider = new_elk_graph_json_configurable_issue_codes_provider()
  debug_inspect(
    provider.issue_code_prefix(),
    content=(
      #|"org.eclipse.elk.graph.json.text."
    ),
  )
  debug_inspect(
    provider.deprecated_model_part(),
    content=(
      #|"org.eclipse.elk.graph.json.text.deprecatedModelPart"
    ),
  )
}
