///|
fn core_debug_grandom_test_format_tag(
  value : @grandom.CoreDebugGRandomFormats?,
) -> String {
  match value {
    Some(@grandom.FormatElkg) => "elkg"
    Some(@grandom.FormatElkt) => "elkt"
    None => "none"
  }
}

///|
fn core_debug_grandom_test_bool_to_string(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
test "GRandom ide modules expose generated bindings" {
  let abstract_module = new_abstract_core_debug_grandom_ide_module()
  inspect(
    abstract_module.bind_i_content_assist_parser(),
    content="org.eclipse.elk.core.debug.grandom.ide.contentassist.antlr.GRandomParser",
  )
  inspect(
    abstract_module.bind_i_rename_service(),
    content="org.eclipse.xtext.ide.server.rename.RenameService2",
  )
  inspect(
    abstract_module.configure_content_assist_lexer().lexer_class_name,
    content="org.eclipse.elk.core.debug.grandom.ide.contentassist.antlr.internal.InternalGRandomLexer",
  )

  let setup = new_core_debug_grandom_ide_setup()
  let injector = setup.create_injector_and_do_emf_registration()
  ignore(injector.get_runtime_module())
  inspect(
    injector.get_ide_module().get_base().bind_i_prefix_matcher(),
    content="org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher",
  )
}

///|
test "GRandom lexer and parser parse generate blocks" {
  let parser = new_core_debug_grandom_parser()
  let rand_graph = parser.parse(
    "generate { trees maxWidth = 9 maxDegree = 4 seed = 17 format = elkg filename = \"case\" nodes = 5 edges = 6 partitionFraction = 0.3 }",
  )
  inspect(rand_graph.configs.length(), content="1")

  let configuration = rand_graph.configs[0]
  inspect(configuration.max_width.unwrap_or(-1), content="9")
  inspect(configuration.max_degree.unwrap_or(-1), content="4")
  inspect(configuration.seed.unwrap_or(-1), content="17")
  inspect(
    core_debug_grandom_test_format_tag(configuration.format),
    content="elkg",
  )
  inspect(configuration.filename.unwrap_or("missing"), content="case")
}

///|
test "GRandom parser helper APIs return generated defaults" {
  let parser = new_core_debug_grandom_parser()
  inspect(parser.get_initial_hidden_tokens().length(), content="3")
  inspect(
    parser.get_rule_name("Configuration.Group").unwrap_or("missing"),
    content="rule__Configuration__Group__0",
  )

  let partial = new_partial_core_debug_grandom_content_assist_parser()
  inspect(partial.get_follow_elements(parser).length(), content="0")
  partial.initialize_for(Some("Configuration"))
  inspect(
    partial.get_follow_elements(parser)[0],
    content="entryRuleConfiguration",
  )
}

///|
test "GRandom ui module and activator wiring works" {
  let abstract_module = @ui.new_abstract_core_debug_grandom_ui_module()
  inspect(
    abstract_module.bind_i_content_proposal_provider(),
    content="org.eclipse.elk.core.debug.grandom.ui.contentassist.GRandomProposalProvider",
  )
  inspect(
    abstract_module.configure_compare_viewer_title(),
    content="GRandom Compare",
  )

  @ui.grandom_activator_reset_for_test()
  let activator = @ui.new_grandom_activator()
  activator.start()
  ignore(activator.get_injector(@ui.core_debug_grandom_ui_language_name))
  ignore(activator.get_injector(@ui.core_debug_grandom_ui_language_name))
  inspect(activator.injector_count(), content="1")
  activator.stop()
  inspect(
    core_debug_grandom_test_bool_to_string(
      match @ui.grandom_activator_get_instance() {
        Some(_) => true
        None => false
      },
    ),
    content="false",
  )
}

///|
test "GRandom executable extension factory resolves provider and initializes extension" {
  @ui.grandom_activator_reset_for_test()
  let activator = @ui.new_grandom_activator()
  let class_name = "example.GRandomExtension"
  let contributor_ref : Ref[String] = Ref::new("none")

  activator.register_bundle_class(class_name)
  activator.register_injector_provider(
    @ui.core_debug_grandom_ui_language_name,
    class_name,
    () => {
      @ui.core_debug_grandom_ui_object_executable_extension(
        @ui.new_core_debug_grandom_executable_extension(set_initialization_data_fn=(
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
  data_map[@ui.core_debug_grandom_ui_extension_factory_guicekey] = class_name
  let factory = @ui.new_core_debug_grandom_executable_extension_factory()
  factory.set_initialization_data(
    Some(
      @ui.new_core_debug_grandom_configuration_element(
        contributor=Some("test-contributor"),
      ),
    ),
    None,
    Some(@ui.core_debug_grandom_initialization_data_map(data_map)),
  )
  let result = factory.create()
  inspect(
    match result {
      Ok(value) => @ui.core_debug_grandom_ui_object_tag(value)
      Err(_) => "error"
    },
    content="executable_extension",
  )
  inspect(contributor_ref.val, content="test-contributor")
  activator.stop()
}

///|
test "GRandom graph maker generates file names with collision handling" {
  let project = @ui.new_core_debug_grandom_project()
  project.write_file("random0.elkt", "existing")

  let configuration = @grandom.new_core_debug_grandom_configuration()
    .set_samples(2)
    .set_form(@grandom.core_debug_grandom_form_custom())
    .set_nodes(
      Some(
        @grandom.new_core_debug_grandom_nodes().set_n_nodes(
          Some(@grandom.core_debug_grandom_double_quantity_exact(3.0)),
        ),
      ),
    )
    .set_edges(
      Some(
        @grandom.new_core_debug_grandom_edges().set_n_edges(
          Some(@grandom.core_debug_grandom_double_quantity_exact(2.0)),
        ),
      ),
    )
  let rand_graph = @grandom.new_core_debug_grandom_rand_graph(configs=[configuration])
  let maker = @ui.new_core_debug_grandom_graph_maker(rand_graph)
  maker.gen(project)

  inspect(project.file_exists("random1.elkt"), content="true")
  inspect(project.file_exists("random2.elkt"), content="true")
}

///|
test "GRandom handler executes selection and writes graphs" {
  let handler = @ui.new_core_debug_grandom_handler()
  let processed = handler.execute([
    @ui.CoreDebugGRandomSelectionOther,
    @ui.CoreDebugGRandomSelectionFile(
      "generate { graphs nodes = 4 edges = 3 filename = \"sample\" }",
    ),
  ])
  inspect(processed, content="1")
  inspect(
    core_debug_grandom_test_bool_to_string(
      handler.get_project().list_files().length() > 0,
    ),
    content="true",
  )
}

///|
test "GRandom proposal provider filters keywords by form and appends docs" {
  let provider = @ui.new_core_debug_grandom_proposal_provider()
  inspect(
    provider.get_keyword_display_string("nodes").contains(": "),
    content="true",
  )

  let trees_config = @grandom.new_core_debug_grandom_configuration().set_form(
    @grandom.core_debug_grandom_form_trees(),
  )
  let trees_context = @ui.new_core_debug_grandom_content_assist_context(
    root_model=Some(@grandom.new_core_debug_grandom_rand_graph(configs=[trees_config])),
    current_model_index=Some(0),
  )
  let trees_acceptor = @ui.new_core_debug_grandom_completion_proposal_acceptor()
  provider.complete_keyword("maxWidth", trees_context, trees_acceptor)
  inspect(trees_acceptor.get_proposals().length(), content="1")

  let custom_config = @grandom.new_core_debug_grandom_configuration().set_form(
    @grandom.core_debug_grandom_form_custom(),
  )
  let custom_context = @ui.new_core_debug_grandom_content_assist_context(
    root_model=Some(@grandom.new_core_debug_grandom_rand_graph(configs=[custom_config])),
    current_model_index=Some(0),
  )
  let custom_acceptor = @ui.new_core_debug_grandom_completion_proposal_acceptor()
  provider.complete_keyword("maxWidth", custom_context, custom_acceptor)
  inspect(custom_acceptor.get_proposals().length(), content="0")
}
