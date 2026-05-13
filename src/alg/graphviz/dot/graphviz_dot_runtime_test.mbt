///|
fn graphviz_dot_runtime_test_string_or_none(value : String?) -> String {
  match value {
    Some(result) => result
    None => "none"
  }
}

///|
fn graphviz_dot_runtime_test_data_map(
  class_name : String,
) -> Map[String, String] {
  let data : Map[String, String] = {}
  data[graphviz_dot_executable_extension_factory_guicekey] = class_name
  data
}

///|
fn graphviz_dot_runtime_test_formatter(
  max_width_ref : Ref[Int],
  undefined_only_ref : Ref[Bool],
) -> GraphvizDotFormatter2 {
  request => {
    max_width_ref.val = request.get_max_line_width()
    undefined_only_ref.val = request.is_format_undefined_hidden_regions_only()
    request.get_text() + "|formatted"
  }
}

///|
test "GraphvizDotActivator caches injector and manages lifecycle" {
  graphviz_dot_activator_reset_for_test()
  let activator = new_graphviz_dot_activator()

  activator.start()
  ignore(activator.get_injector(graphviz_dot_language_name))
  ignore(activator.get_injector(graphviz_dot_language_name))
  debug_inspect(activator.injector_count(), content="1")
  debug_inspect(
    match graphviz_dot_activator_get_instance() {
      Some(_) => true
      None => false
    },
    content="true",
  )

  activator.stop()
  debug_inspect(
    match graphviz_dot_activator_get_instance() {
      Some(_) => true
      None => false
    },
    content="false",
  )
}

///|
test "panic GraphvizDotActivator rejects unknown grammar" {
  let activator = new_graphviz_dot_activator()
  ignore(activator.get_runtime_module("unknown.grammar"))
}

///|
test "GraphvizDotRuntimeModule binds GraphvizDotSerializer" {
  let runtime_module = new_graphviz_dot_runtime_module()
  debug_inspect(
    runtime_module.bind_iserializer(),
    content=(
      #|"org.eclipse.elk.alg.graphviz.dot.serializer.GraphvizDotSerializer"
    ),
  )

  let injector = runtime_module.create_injector()
  let injected = injector.get_instance(graphviz_dot_serializer_class_name)
  debug_inspect(
    match injected {
      Some(value) => graphviz_dot_object_tag(value)
      None => "missing"
    },
    content=(
      #|"serializer"
    ),
  )
}

///|
test "GraphvizDotSerializer configures formatter request" {
  let max_width_ref : Ref[Int] = Ref(-1)
  let undefined_only_ref : Ref[Bool] = Ref(false)
  let formatter_provider : () -> GraphvizDotFormatter2 = () => {
    graphviz_dot_runtime_test_formatter(max_width_ref, undefined_only_ref)
  }
  let serializer = new_graphviz_dot_serializer(
    formatter2_provider=formatter_provider,
  )

  debug_inspect(
    serializer.serialize(
      "digraph { a -> b; }",
      new_graphviz_dot_save_options(formatting=true),
    ),
    content=(
      #|"digraph { a -> b; }|formatted"
    ),
  )
  debug_inspect(max_width_ref.val, content="255")
  debug_inspect(undefined_only_ref.val, content="false")

  ignore(serializer.serialize("graph {}", new_graphviz_dot_save_options()))
  debug_inspect(undefined_only_ref.val, content="true")
}

///|
test "GraphvizDotStandaloneSetup registers package and extension" {
  graphviz_dot_reset_registries_for_test()
  ignore(graphviz_dot_standalone_setup_do_setup())

  debug_inspect(
    graphviz_dot_runtime_test_string_or_none(
      graphviz_dot_registered_epackage(graphviz_dot_ns_uri),
    ),
    content=(
      #|"org.eclipse.elk.alg.graphviz.dot.dot.DotPackage"
    ),
  )
  debug_inspect(
    graphviz_dot_runtime_test_string_or_none(
      graphviz_dot_registered_resource_factory(graphviz_dot_file_extension),
    ),
    content=(
      #|"org.eclipse.xtext.resource.IResourceFactory"
    ),
  )
  debug_inspect(
    graphviz_dot_runtime_test_string_or_none(
      graphviz_dot_registered_resource_service_provider(
        graphviz_dot_file_extension,
      ),
    ),
    content=(
      #|"org.eclipse.xtext.resource.IResourceServiceProvider"
    ),
  )
}

///|
test "GraphvizDotSyntacticSequencer emits fixed optional keywords" {
  let sequencer = new_graphviz_dot_syntactic_sequencer()
  debug_inspect(
    sequencer.emit_attribute_statement_comma_keyword_2_1_0_q("", "", [0]),
    content=(
      #|","
    ),
  )
  debug_inspect(
    sequencer.emit_edge_statement_comma_keyword_2_1_1_0_q("", "", [0]),
    content=(
      #|","
    ),
  )
  debug_inspect(
    sequencer.emit_edge_statement___left_square_bracket_keyword_2_0_right_square_bracket_keyword_2_2__q(
      "",
      "",
      [0],
    ),
    content=(
      #|"[]"
    ),
  )
  debug_inspect(
    sequencer.emit_node_statement_comma_keyword_1_1_1_0_q("", "", [0]),
    content=(
      #|","
    ),
  )
  debug_inspect(
    sequencer.emit_node_statement___left_square_bracket_keyword_1_0_right_square_bracket_keyword_1_2__q(
      "",
      "",
      [0],
    ),
    content=(
      #|"[]"
    ),
  )
  debug_inspect(
    sequencer.emit_statement_semicolon_keyword_1_q("", "", [0]),
    content=(
      #|";"
    ),
  )
  debug_inspect(
    sequencer.emit_subgraph_subgraph_keyword_1_0_q("", "", [0]),
    content=(
      #|"subgraph"
    ),
  )
}

///|
test "AbstractGraphvizDotSyntacticSequencer keeps ambiguous syntax defaults" {
  let sequencer = new_abstract_graphviz_dot_syntactic_sequencer()
  debug_inspect(
    sequencer.get_unassigned_rule_call_token("", "", ""),
    content=(
      #|""
    ),
  )
  debug_inspect(
    sequencer.emit_unassigned_tokens("", [
      "AttributeStatement_CommaKeyword_2_1_0_q", "EdgeStatement___LeftSquareBracketKeyword_2_0_RightSquareBracketKeyword_2_2__q",
      "NodeStatement___LeftSquareBracketKeyword_1_0_RightSquareBracketKeyword_1_2__q",
      "Statement_SemicolonKeyword_1_q",
    ]),
    content="[\",\", \"[]\", \"[]\", \";\"]",
  )
}

///|
test "AbstractGraphvizDotSemanticSequencer keeps sequence passthrough" {
  let sequencer = new_abstract_graphviz_dot_semantic_sequencer()
  debug_inspect(
    sequencer.sequence_graphviz_model("context", "graphviz-model"),
    content=(
      #|"graphviz-model"
    ),
  )
  debug_inspect(
    sequencer.sequence_attribute("context", "attribute"),
    content=(
      #|"attribute"
    ),
  )
}

///|
test "GraphvizDotSemanticSequencer delegates semantic object unchanged" {
  let sequencer = new_graphviz_dot_semantic_sequencer()
  debug_inspect(
    sequencer.sequence("statement"),
    content=(
      #|"statement"
    ),
  )
}

///|
test "GraphvizDotExecutableExtensionFactory resolves and initializes class" {
  graphviz_dot_activator_reset_for_test()
  let activator = new_graphviz_dot_activator()
  let extension_class_name = "example.GraphvizExtension"
  let contributor_ref : Ref[String] = Ref("none")

  activator.register_bundle_class(extension_class_name)
  activator.register_injector_provider(
    graphviz_dot_language_name,
    extension_class_name,
    () => {
      graphviz_dot_object_executable_extension(
        new_graphviz_dot_executable_extension(set_initialization_data_fn=(
          config,
          _property_name,
          _data,
        ) => {
          contributor_ref.val = graphviz_dot_runtime_test_string_or_none(
            match config {
              Some(value) => value.get_contributor()
              None => None
            },
          )
        }),
      )
    },
  )
  activator.start()

  let factory = new_graphviz_dot_executable_extension_factory()
  factory.set_initialization_data(
    Some(
      new_graphviz_dot_configuration_element(contributor=Some("factory-test")),
    ),
    None,
    Some(
      graphviz_dot_initialization_data_map(
        graphviz_dot_runtime_test_data_map(extension_class_name),
      ),
    ),
  )
  let result = factory.create()
  debug_inspect(
    match result {
      Ok(value) => graphviz_dot_object_tag(value)
      Err(_error) => "error"
    },
    content=(
      #|"executable_extension"
    ),
  )
  debug_inspect(
    contributor_ref.val,
    content=(
      #|"factory-test"
    ),
  )

  activator.stop()
}
