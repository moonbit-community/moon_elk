///|
fn graph_text_ide_ui_bool_to_string(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn graph_text_ide_ui_option_or_none(value : String?) -> String {
  match value {
    Some(text) => text
    None => "none"
  }
}

///|
fn graph_text_ide_ui_contains(values : Array[String], target : String) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
}

///|
test "ElkGraph ide modules expose generated bindings" {
  let abstract_module = new_abstract_elk_graph_ide_module()
  inspect(
    abstract_module.bind_i_content_assist_parser(),
    content="org.eclipse.elk.graph.text.ide.contentassist.antlr.ElkGraphParser",
  )
  inspect(
    abstract_module.configure_content_assist_lexer().lexer_class_name,
    content="org.eclipse.elk.graph.text.ide.contentassist.antlr.internal.InternalElkGraphLexer",
  )

  let setup = new_elk_graph_ide_setup()
  let injector = setup.create_injector_and_do_emf_registration()
  inspect(
    injector.get_ide_module().get_base().bind_i_prefix_matcher(),
    content="org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher",
  )
  inspect(
    injector.get_runtime_module().bind_i_qualified_name_provider(),
    content="org.eclipse.elk.graph.text.naming.ElkGraphQualifiedNameProvider",
  )
}

///|
test "ElkGraph ide parser and partial parser keep generated defaults" {
  let parser = new_elk_graph_ide_parser()
  inspect(parser.get_initial_hidden_tokens().length(), content="3")
  inspect(
    parser.get_rule_name("RootNode.Group").unwrap_or("missing"),
    content="rule__RootNode__Group__0",
  )

  let model = parser.parse(
    "graph root layout [size: 30, 20] node child { layout [size: 10, 5] }",
  )
  inspect(node_identifier(model), content="root")
  inspect(node_children(model).length(), content="1")

  let partial = new_partial_elk_graph_content_assist_parser()
  inspect(partial.get_follow_elements(parser).length(), content="0")
  partial.initialize_for(Some("ElkNode"))
  inspect(partial.get_follow_elements(parser)[0], content="entryRuleElkNode")
}

///|
test "ElkGraph ide proposal provider exposes property and crossref behavior" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_default_algorithms()
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_identifier(root, "root")
  let node = create_node(Some(root))
  node_set_identifier(node, "n1")
  let port = create_port(Some(node))
  port_set_identifier(port, "p1")
  let edge = create_edge(Some(root))
  edge_set_identifier(edge, "e1")
  edge_add_source(edge, make_node_shape(node))
  edge_add_target(edge, make_port_shape(port))
  let section = create_edge_section(edge)

  let provider = new_elk_graph_ide_proposal_provider()

  let keyword_acceptor = new_graph_text_ide_completion_proposal_acceptor()
  provider.create_keyword_proposals(
    "graph",
    new_graph_text_ide_content_assist_context(prefix="g"),
    keyword_acceptor,
  )
  inspect(keyword_acceptor.get_proposals()[0], content="graph")

  let key_acceptor = new_graph_text_ide_completion_proposal_acceptor()
  provider.create_assignment_proposals(
    "Property.KeyAssignment_0",
    "RULE_ID",
    new_graph_text_ide_content_assist_context(
      current_model=Some(GraphNode(root)),
    ),
    key_acceptor,
  )
  inspect(
    graph_text_ide_ui_bool_to_string(key_acceptor.get_proposals().length() > 0),
    content="true",
  )

  let option = layout_meta_data_service_get_option_data(algorithm.get_id())
  let value_acceptor = new_graph_text_ide_completion_proposal_acceptor()
  provider.create_assignment_proposals(
    "Property.ValueAssignment_2_1",
    "RULE_ID",
    new_graph_text_ide_content_assist_context(
      current_property_key=Some(LayoutOption(option)),
      prefix="layer",
    ),
    value_acceptor,
  )
  inspect(
    graph_text_ide_ui_bool_to_string(
      value_acceptor.get_proposals().length() > 0,
    ),
    content="true",
  )

  let candidates = [make_node_shape(node), make_port_shape(port)]
  let incoming = provider.filter_cross_reference_candidates(
    "ElkEdgeSection.IncomingShape",
    new_graph_text_ide_content_assist_context(
      current_edge_section=Some(section),
    ),
    candidates,
  )
  inspect(incoming.length(), content="1")
  let outgoing = provider.filter_cross_reference_candidates(
    "ElkEdgeSection.OutgoingShape",
    new_graph_text_ide_content_assist_context(
      current_edge_section=Some(section),
    ),
    candidates,
  )
  inspect(outgoing.length(), content="1")
}

///|
test "ElkGraph ui module and activator wiring works" {
  let abstract_module = new_abstract_elk_graph_ui_module()
  inspect(
    abstract_module.bind_i_content_proposal_provider(),
    content="org.eclipse.elk.graph.text.ui.contentassist.ElkGraphProposalProvider",
  )
  inspect(
    abstract_module.configure_compare_viewer_title(),
    content="ElkGraph Compare",
  )

  text_activator_reset_for_test()
  let activator = new_text_activator()
  activator.start()
  ignore(activator.get_injector(graph_text_ui_language_name))
  ignore(activator.get_injector(graph_text_ui_language_name))
  inspect(activator.injector_count(), content="1")
  activator.stop()
  inspect(
    graph_text_ide_ui_bool_to_string(
      match text_activator_get_instance() {
        Some(_) => true
        None => false
      },
    ),
    content="false",
  )

  let ui_activator = new_elk_graph_text_ui_activator()
  let ui_injector = ui_activator.create_injector(graph_text_ui_language_name)
  inspect(ui_injector.provider_count(), content="2")
}

///|
test "ElkGraph executable extension factory resolves provider and initializes extension" {
  text_activator_reset_for_test()
  let activator = new_text_activator()
  let class_name = "example.ElkGraphExtension"
  let contributor_ref : Ref[String] = Ref::new("none")

  activator.register_bundle_class(class_name)
  activator.register_injector_provider(
    graph_text_ui_language_name,
    class_name,
    () => {
      graph_text_ui_object_executable_extension(
        new_graph_text_executable_extension(set_initialization_data_fn=(
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
  data_map[graph_text_ui_extension_factory_guicekey] = class_name
  let factory = new_elk_graph_executable_extension_factory()
  factory.set_initialization_data(
    Some(
      new_graph_text_configuration_element(contributor=Some("text-contributor")),
    ),
    None,
    Some(graph_text_initialization_data_map(data_map)),
  )
  let result = factory.create()
  inspect(
    match result {
      Ok(value) => graph_text_ui_object_tag(value)
      Err(_) => "error"
    },
    content="executable_extension",
  )
  inspect(contributor_ref.val, content="text-contributor")
  activator.stop()
}

///|
test "ElkGraph ui providers expose generated behavior" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_default_algorithms()
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_identifier(root, "root")
  let child = create_node(Some(root))
  node_set_identifier(child, "child")
  let port = create_port(Some(child))
  port_set_identifier(port, "p")
  let edge = create_edge(Some(root))
  edge_set_identifier(edge, "e")
  edge_add_source(edge, make_node_shape(child))
  edge_add_target(edge, make_port_shape(port))
  let label = create_label(Some(make_edge_label_parent(edge)))
  label_set_identifier(label, "l")
  label_set_text(label, "txt")

  let proposal_provider = new_elk_graph_ui_proposal_provider()
  let proposal_acceptor = new_graph_text_ui_completion_proposal_acceptor()
  proposal_provider.create_assignment_proposals(
    "Property.KeyAssignment_0",
    new_graph_text_assignment("RULE_ID"),
    new_graph_text_ui_content_assist_context(
      current_model=Some(GraphNode(root)),
    ),
    proposal_acceptor,
  )
  inspect(
    graph_text_ide_ui_bool_to_string(
      proposal_acceptor.get_proposals().length() > 0,
    ),
    content="true",
  )
  inspect(
    graph_text_ide_ui_option_or_none(
      proposal_provider.get_keyword_image("node"),
    ),
    content="elknode.gif",
  )

  let option = layout_meta_data_service_get_option_data(
    port_labels_next_to_port_if_possible.get_id(),
  )
  inspect(
    proposal_provider.get_layout_option_image(option, "false"),
    content="prop_false.gif",
  )

  let description_provider = new_elk_graph_description_label_provider()
  inspect(
    graph_text_ide_ui_option_or_none(description_provider.image("ELK_EDGE")),
    content="elkedge.gif",
  )

  let label_provider = new_elk_graph_label_provider()
  inspect(label_provider.image_elk_node(root), content="elkgraph.gif")
  inspect(label_provider.image_elk_node(child), content="elknode.gif")
  inspect(
    graph_text_ide_ui_bool_to_string(
      label_provider.text_elk_edge(edge).contains("->"),
    ),
    content="true",
  )
  inspect(label_provider.text_elk_label(label), content="l: \"txt\"")

  let outline_provider = new_elk_graph_outline_tree_provider()
  let outline = outline_provider.create_outline(root)
  inspect(outline.children.length(), content="1")
  inspect(outline.children[0].children.length(), content="1")

  let quickfix_provider = new_elk_graph_quickfix_provider()
  inspect(
    graph_text_ide_ui_bool_to_string(
      quickfix_provider.supports_issue(graph_text_option_not_applicable),
    ),
    content="true",
  )
  let properties = [
    new_graph_text_property_assignment(CustomProperty("a"), StringValue("1")),
    new_graph_text_property_assignment(CustomProperty("b"), StringValue("2")),
  ]
  inspect(quickfix_provider.remove_option(properties, 0).length(), content="1")
}

///|
test "ElkGraph layout connector setup and convert handler work" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_identifier(root, "root")

  let connector = new_text_layout_connector()
  let mapping_result = connector.build_layout_graph("xtext", Some(root))
  inspect(
    match mapping_result {
      Ok(_) => "ok"
      Err(_) => "error"
    },
    content="ok",
  )
  let mapping = match mapping_result {
    Ok(value) => value
    Err(_) => new_text_layout_mapping("xtext", root, root)
  }
  inspect(connector.apply_layout(mapping, {}), content="layout-dialog:xtext")

  let setup = new_text_layout_setup()
  inspect(
    graph_text_ide_ui_bool_to_string(
      setup.supports(graph_text_ui_language_name),
    ),
    content="true",
  )
  inspect(setup.create_injector("default"), content="default+TextLayoutModule")
  inspect(
    new_text_layout_module().configure_connector_class(),
    content="org.eclipse.elk.graph.text.ui.layout.TextLayoutConnector",
  )

  let project = new_graph_text_project()
  project.write_file("demo.elkt", "existing")
  let handler = new_convert_graph_handler(project~)
  let processed = handler.execute(
    [
      GraphTextSelectionOther,
      GraphTextSelectionFile(
        "demo.elkg", "graph root layout [size: 30, 20] node child { layout [size: 10, 5] }",
      ),
    ],
    "elkt",
  )
  inspect(processed, content="1")
  inspect(
    graph_text_ide_ui_bool_to_string(
      graph_text_ide_ui_contains(
        handler.get_project().list_files(),
        "demo0.elkt",
      ),
    ),
    content="true",
  )

  let invalid = handler.execute([], "txt")
  inspect(invalid, content="0")
  inspect(
    graph_text_ide_ui_bool_to_string(handler.get_errors().length() > 0),
    content="true",
  )
}
