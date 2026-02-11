///|
fn graph_json_text_ide_ui_bool_to_string(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn graph_json_text_ide_ui_option_or_none(value : String?) -> String {
  match value {
    Some(text) => text
    None => "none"
  }
}

///|
test "ElkGraphJson ide modules expose generated bindings" {
  let abstract_module = new_abstract_elk_graph_json_ide_module()
  inspect(
    abstract_module.bind_i_content_assist_parser(),
    content="org.eclipse.elk.graph.json.text.ide.contentassist.antlr.ElkGraphJsonParser",
  )
  inspect(
    abstract_module.configure_content_assist_lexer().lexer_class_name,
    content="org.eclipse.elk.graph.json.text.ide.contentassist.antlr.internal.InternalElkGraphJsonLexer",
  )

  let setup = new_elk_graph_json_ide_setup()
  let injector = setup.create_injector_and_do_emf_registration()
  inspect(
    injector.get_ide_module().get_base().bind_i_prefix_matcher(),
    content="org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher",
  )
  inspect(
    injector.get_runtime_module().bind_i_qualified_name_provider(),
    content="org.eclipse.elk.graph.json.text.naming.ElkGraphJsonQualifiedNameProvider",
  )
}

///|
test "ElkGraphJson ide parser and partial parser keep generated defaults" {
  let parser = new_elk_graph_json_ide_parser()
  inspect(parser.get_initial_hidden_tokens().length(), content="3")
  inspect(
    parser.get_rule_name("ElkNode.Group").unwrap_or("missing"),
    content="rule__ElkNode__Group__0",
  )

  let model = parser.parse(
    "{\"id\":\"root\",\"children\":[{\"id\":\"child\"}]}",
  )
  inspect(node_identifier(model), content="root")
  inspect(node_children(model).length(), content="1")

  let partial = new_partial_elk_graph_json_content_assist_parser()
  inspect(partial.get_follow_elements(parser).length(), content="0")
  partial.initialize_for(Some("ElkNode"))
  inspect(partial.get_follow_elements(parser)[0], content="entryRuleElkNode")
}

///|
test "ElkGraphJson ide proposal provider exposes property and key behavior" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_default_algorithms()
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_identifier(root, "root")

  let provider = new_elk_graph_json_ide_proposal_provider()

  let keyword_acceptor = new_graph_json_text_ide_completion_proposal_acceptor()
  provider.create_keyword_proposals(
    "children",
    new_graph_json_text_ide_content_assist_context(prefix="c"),
    keyword_acceptor,
  )
  inspect(keyword_acceptor.get_proposals()[0], content="children")

  let key_acceptor = new_graph_json_text_ide_completion_proposal_acceptor()
  provider.create_assignment_proposals(
    "Property.KeyAssignment_0",
    "RULE_ID",
    new_graph_json_text_ide_content_assist_context(
      current_model=Some(GraphJsonTextNode(root)),
    ),
    key_acceptor,
  )
  inspect(
    graph_json_text_ide_ui_bool_to_string(
      key_acceptor.get_proposals().length() > 0,
    ),
    content="true",
  )
  inspect(
    graph_json_text_ide_ui_bool_to_string(
      key_acceptor.get_proposals()[0].has_prefix("\""),
    ),
    content="true",
  )
}

///|
test "ElkGraphJson ui module and activator wiring works" {
  let abstract_module = new_abstract_elk_graph_json_ui_module()
  inspect(
    abstract_module.bind_i_content_proposal_provider(),
    content="org.eclipse.elk.graph.json.text.ui.contentassist.ElkGraphJsonProposalProvider",
  )
  inspect(
    abstract_module.bind_abstract_validator_configuration_block(),
    content="org.eclipse.elk.graph.json.text.validation.ElkGraphJsonValidatorConfigurationBlock",
  )

  graph_json_text_activator_reset_for_test()
  let activator = new_graph_json_text_activator()
  activator.start()
  ignore(activator.get_injector(graph_json_text_ui_language_name))
  ignore(activator.get_injector(graph_json_text_ui_language_name))
  inspect(activator.injector_count(), content="1")
  activator.stop()
}

///|
test "ElkGraphJson executable extension factory resolves provider and initializes extension" {
  graph_json_text_activator_reset_for_test()
  let activator = new_graph_json_text_activator()
  let class_name = "example.ElkGraphJsonExtension"
  let contributor_ref : Ref[String] = Ref::new("none")

  activator.register_bundle_class(class_name)
  activator.register_injector_provider(
    graph_json_text_ui_language_name,
    class_name,
    () => {
      graph_json_text_ui_object_executable_extension(
        new_graph_json_text_executable_extension(set_initialization_data_fn=(
          config,
          _property_name,
          _data,
        ) => {
          contributor_ref.val = match config {
            Some(value) => value.get_contributor().unwrap_or("none")
            None => "none"
          }
        }),
      )
    },
  )
  activator.start()

  let data_map : Map[String, String] = {}
  data_map[graph_json_text_extension_factory_guicekey] = class_name
  let factory = new_elk_graph_json_executable_extension_factory()
  factory.set_initialization_data(
    Some(
      new_graph_json_text_configuration_element(
        contributor=Some("json-text-contributor"),
      ),
    ),
    None,
    Some(graph_json_text_initialization_data_map(data_map)),
  )
  let result = factory.create()
  inspect(
    match result {
      Ok(value) => graph_json_text_ui_object_tag(value)
      Err(_) => "error"
    },
    content="executable_extension",
  )
  inspect(contributor_ref.val, content="json-text-contributor")
  activator.stop()
}

///|
test "ElkGraphJson ui providers expose generated behavior" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_identifier(root, "root")
  let child = create_node(Some(root))
  node_set_identifier(child, "child")

  let proposal_provider = new_elk_graph_json_ui_proposal_provider()
  let proposal_acceptor = new_graph_json_text_ui_completion_proposal_acceptor()
  proposal_provider.create_assignment_proposals(
    "Property.KeyAssignment_0",
    new_graph_json_text_assignment("RULE_ID"),
    new_graph_json_text_ui_content_assist_context(
      current_model=Some(GraphJsonTextNode(root)),
    ),
    proposal_acceptor,
  )
  inspect(
    graph_json_text_ide_ui_bool_to_string(
      proposal_acceptor.get_proposals().length() > 0,
    ),
    content="true",
  )
  inspect(
    graph_json_text_ide_ui_option_or_none(
      proposal_provider.get_keyword_image("children"),
    ),
    content="none",
  )

  let description_provider = new_elk_graph_json_description_label_provider()
  inspect(
    graph_json_text_ide_ui_option_or_none(
      description_provider.image("ELK_NODE"),
    ),
    content="none",
  )

  let label_provider = new_elk_graph_json_label_provider()
  inspect(label_provider.text_elk_node(root), content="root")

  let outline_provider = new_elk_graph_json_outline_tree_provider()
  let outline = outline_provider.create_outline(root)
  inspect(outline.children.length(), content="1")

  let quickfix_provider = new_elk_graph_json_quickfix_provider()
  inspect(
    graph_json_text_ide_ui_bool_to_string(
      quickfix_provider.supports_issue(
        "org.eclipse.elk.graph.json.text.deprecatedModelPart",
      ),
    ),
    content="true",
  )
}

///|
test "ElkGraphJson convert handler works" {
  let project = new_graph_json_text_project()
  project.write_file("demo.elkj", "existing")
  let handler = new_graph_json_text_convert_graph_handler(project~)
  let processed = handler.execute(
    [
      GraphJsonTextSelectionOther,
      GraphJsonTextSelectionFile(
        "demo.elkg", "{\"id\":\"root\",\"children\":[{\"id\":\"child\"}]}",
      ),
    ],
    graph_json_text_target_ext_elkj,
  )
  inspect(processed, content="1")
  inspect(project.file_exists("demo0.elkj"), content="true")

  let invalid = handler.execute([], "txt")
  inspect(invalid, content="0")
  inspect(
    graph_json_text_ide_ui_bool_to_string(handler.get_errors().length() > 0),
    content="true",
  )
}
