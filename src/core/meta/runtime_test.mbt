///|
fn core_meta_runtime_test_string_or_none(value : String?) -> String {
  match value {
    Some(result) => result
    None => "none"
  }
}

///|
test "MetaDataRuntimeModule exposes custom generator and validator bindings" {
  let runtime_module = new_meta_data_runtime_module()
  inspect(
    runtime_module.bind_igenerator(),
    content="org.eclipse.elk.core.meta.jvmmodel.MelkDocumentationGenerator",
  )
  inspect(
    runtime_module.bind_unique_class_name_validator(),
    content="org.eclipse.elk.core.meta.validation.MelkUniqueClassNameValidator",
  )

  let output_configurations = runtime_module.get_output_configurations()
  inspect(output_configurations.length(), content="2")
  inspect(output_configurations[1].id, content="AD_INPUT")
  inspect(output_configurations[1].output_directory, content="./")
}

///|
test "MetaDataStandaloneSetup registers package and extension" {
  core_meta_reset_registries_for_test()
  ignore(meta_data_standalone_setup_do_setup())

  inspect(
    core_meta_runtime_test_string_or_none(
      core_meta_registered_epackage(core_meta_ns_uri),
    ),
    content="org.eclipse.elk.core.meta.metaData.MetaDataPackage",
  )
  inspect(
    core_meta_runtime_test_string_or_none(
      core_meta_registered_resource_factory(core_meta_file_extension),
    ),
    content="org.eclipse.xtext.resource.IResourceFactory",
  )
  inspect(
    core_meta_runtime_test_string_or_none(
      core_meta_registered_resource_service_provider(core_meta_file_extension),
    ),
    content="org.eclipse.xtext.resource.IResourceServiceProvider",
  )
}

///|
test "MetaDataSyntacticSequencer emits generated ambiguous defaults" {
  let sequencer = new_meta_data_syntactic_sequencer()
  inspect(
    sequencer.emit_md_bundle___bundle_keyword_1_0_left_curly_bracket_keyword_1_1_right_curly_bracket_keyword_1_3__q(
      "",
      "",
      [0],
    ),
    content="bundle{}",
  )
  inspect(
    sequencer.emit_x_import_declaration_semicolon_keyword_2_q("", "", [0]),
    content=";",
  )
  inspect(
    sequencer.get_unassigned_rule_call_token("", "OpSingleAssign", ""),
    content="=",
  )
}

///|
test "MetaDataSemanticSequencer keeps sequence passthrough" {
  let sequencer = new_meta_data_semantic_sequencer()
  inspect(
    sequencer.sequence_md_option("context", "md-option"),
    content="md-option",
  )
  inspect(
    sequencer.sequence_md_algorithm("context", "md-algorithm"),
    content="md-algorithm",
  )
}

///|
test "MetaDataValidator reports duplicate ids recursively" {
  let option_a = core_meta_create_md_option()
  option_a.set_name(Some("dup"))

  let option_b = core_meta_create_md_option()
  option_b.set_name(Some("dup"))

  let group = core_meta_create_md_group()
  group.set_name(Some("group"))
  group.get_children().push(core_meta_md_group_or_option_option(option_b))

  let bundle = core_meta_create_md_bundle()
  bundle
  .get_members()
  .push(
    core_meta_md_bundle_member_group_or_option(
      core_meta_md_group_or_option_option(option_a),
    ),
  )
  bundle
  .get_members()
  .push(
    core_meta_md_bundle_member_group_or_option(
      core_meta_md_group_or_option_group(group),
    ),
  )

  let validator = new_meta_data_validator()
  let issues = validator.check_duplicate_member_id(bundle)
  inspect(issues.length(), content="2")
  inspect(issues[0].message.contains("already used"), content="true")
}
