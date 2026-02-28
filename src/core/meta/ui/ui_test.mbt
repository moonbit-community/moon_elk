///|
fn core_meta_ui_test_string_or_none(value : String?) -> String {
  match value {
    Some(text) => text
    None => "none"
  }
}

///|
fn core_meta_ui_test_bool_to_string(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
test "MetaData ide modules expose generated bindings" {
  let abstract_module = @ide.new_abstract_core_meta_ide_module()
  inspect(
    abstract_module.bind_i_content_assist_parser(),
    content="org.eclipse.elk.core.meta.ide.contentassist.antlr.MetaDataParser",
  )
  inspect(
    abstract_module.bind_i_rename_service(),
    content="org.eclipse.xtext.ide.server.rename.RenameService2",
  )
  inspect(
    abstract_module.configure_content_assist_lexer().lexer_class_name,
    content="org.eclipse.elk.core.meta.ide.contentassist.antlr.internal.InternalMetaDataLexer",
  )

  let setup = @ide.new_core_meta_ide_setup()
  let injector = setup.create_injector_and_do_emf_registration()
  inspect(
    injector.get_runtime_module().bind_igenerator(),
    content="org.eclipse.elk.core.meta.jvmmodel.MelkDocumentationGenerator",
  )
  inspect(
    injector.get_ide_module().get_base().bind_i_prefix_matcher(),
    content="org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher",
  )
}

///|
test "MetaData ide parser and partial parser keep generated defaults" {
  let parser = @ide.new_core_meta_ide_parser()
  inspect(parser.get_initial_hidden_tokens().length(), content="3")
  inspect(
    parser.get_rule_name("MdBundleMember.Alternatives").unwrap_or("missing"),
    content="rule__MdBundleMember__Alternatives",
  )

  let model = parser.parse(
    "package org.example bundle { label \"Demo\" } option spacing { targets nodes,edges }",
  )
  inspect(
    core_meta_ui_test_string_or_none(model.get_name()),
    content="org.example",
  )
  let bundle = match model.get_bundle() {
    Some(value) => value
    None => @meta.core_meta_create_md_bundle()
  }
  inspect(core_meta_ui_test_string_or_none(bundle.get_label()), content="Demo")
  inspect(bundle.get_members().length(), content="1")

  let partial = @ide.new_partial_core_meta_content_assist_parser()
  inspect(partial.get_follow_elements(parser).length(), content="0")
  partial.initialize_for(Some("MdBundle"))
  inspect(partial.get_follow_elements(parser)[0], content="entryRuleMdBundle")
}

///|
test "MetaData ui module and activator wiring works" {
  let abstract_module = new_abstract_meta_data_ui_module()
  inspect(
    abstract_module.bind_i_content_proposal_provider(),
    content="org.eclipse.elk.core.meta.ui.contentassist.MetaDataProposalProvider",
  )
  inspect(
    abstract_module.configure_compare_viewer_title(),
    content="MetaData Compare",
  )

  let ui_module = new_meta_data_ui_module()
  inspect(
    ui_module.bind_unique_class_name_validator(),
    content="org.eclipse.elk.core.meta.validation.MelkUniqueClassNameValidator",
  )

  meta_activator_reset_for_test()
  let activator = new_meta_activator()
  activator.start()
  ignore(activator.get_injector(core_meta_ui_language_name))
  ignore(activator.get_injector(core_meta_ui_language_name))
  inspect(activator.injector_count(), content="1")
  activator.stop()
  inspect(
    core_meta_ui_test_bool_to_string(
      match meta_activator_get_instance() {
        Some(_) => true
        None => false
      },
    ),
    content="false",
  )
}

///|
test "MetaData executable extension factory resolves provider and initializes extension" {
  meta_activator_reset_for_test()
  let activator = new_meta_activator()
  let class_name = "example.MetaDataExtension"
  let contributor_ref : Ref[String] = Ref::new("none")

  activator.register_bundle_class(class_name)
  activator.register_injector_provider(core_meta_ui_language_name, class_name, () => {
    core_meta_ui_object_executable_extension(
      new_core_meta_executable_extension(set_initialization_data_fn=(
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
  })
  activator.start()

  let data_map : Map[String, String] = {}
  data_map[core_meta_ui_extension_factory_guicekey] = class_name
  let factory = new_meta_data_executable_extension_factory()
  factory.set_initialization_data(
    Some(
      new_core_meta_configuration_element(contributor=Some("meta-contributor")),
    ),
    None,
    Some(core_meta_initialization_data_map(data_map)),
  )
  let result = factory.create()
  inspect(
    match result {
      Ok(value) => core_meta_ui_object_tag(value)
      Err(_) => "error"
    },
    content="executable_extension",
  )
  inspect(contributor_ref.val, content="meta-contributor")
  activator.stop()
}

///|
test "MetaData proposal, label and outline providers expose generated behavior" {
  let proposal_provider = new_meta_data_proposal_provider()
  let acceptor = new_core_meta_completion_proposal_acceptor()
  let context = new_core_meta_content_assist_context()
  proposal_provider.complete_md_option_name(
    new_core_meta_assignment("RULE_ID"),
    context,
    acceptor,
  )
  inspect(acceptor.get_proposals()[0], content="RULE_ID")

  let label_provider = new_meta_data_label_provider()
  let algorithm = @meta.core_meta_create_md_algorithm()
  algorithm.set_name(Some("layered"))
  inspect(
    label_provider.text_md_algorithm(algorithm),
    content="Algorithm: layered",
  )

  let model = @meta.core_meta_create_md_model()
  let bundle = @meta.core_meta_create_md_bundle()
  let category = @meta.core_meta_create_md_category()
  category.set_name(Some("main"))
  let group = @meta.core_meta_create_md_group()
  group.set_name(Some("group"))
  let option = @meta.core_meta_create_md_option()
  option.set_name(Some("spacing"))
  group.get_children().push(@meta.core_meta_md_group_or_option_option(option))
  bundle.get_members().push(@meta.core_meta_md_bundle_member_category(category))
  bundle
  .get_members()
  .push(
    @meta.core_meta_md_bundle_member_group_or_option(
      @meta.core_meta_md_group_or_option_group(group),
    ),
  )
  model.set_bundle(Some(bundle))

  let outline_provider = new_meta_data_outline_tree_provider()
  let root = outline_provider.create_outline(model)
  inspect(root.children.length(), content="1")
  inspect(root.children[0].children.length(), content="2")
  inspect(root.children[0].children[1].children.length(), content="1")
  inspect(
    core_meta_ui_test_bool_to_string(
      outline_provider.is_leaf_category(category),
    ),
    content="true",
  )
}
