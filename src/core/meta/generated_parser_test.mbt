///|
fn core_meta_generated_test_string_or_none(value : String?) -> String {
  match value {
    Some(result) => result
    None => "none"
  }
}

///|
fn core_meta_generated_test_contains(
  values : Array[String],
  target : String,
) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
}

///|
test "AbstractMetaDataRuntimeModule exposes generated bindings" {
  let runtime_module = new_abstract_meta_data_runtime_module()
  inspect(
    runtime_module.configure_language_name(),
    content="org.eclipse.elk.core.meta.MetaData",
  )
  inspect(runtime_module.configure_file_extensions(), content="melk")
  inspect(
    runtime_module.bind_igrammar_access(),
    content="org.eclipse.elk.core.meta.services.MetaDataGrammarAccess",
  )
  inspect(
    runtime_module.bind_iparser(),
    content="org.eclipse.elk.core.meta.parser.antlr.MetaDataParser",
  )
  inspect(
    runtime_module.bind_iantlr_token_file_provider(),
    content="org.eclipse.elk.core.meta.parser.antlr.MetaDataAntlrTokenFileProvider",
  )
  inspect(
    runtime_module.bind_lexer(),
    content="org.eclipse.elk.core.meta.parser.antlr.internal.InternalMetaDataLexer",
  )

  let properties : Map[String, String] = {}
  properties["fileExtensions"] = "my-melk"
  runtime_module.configure(properties)
  inspect(runtime_module.configure_file_extensions(), content="my-melk")
}

///|
test "MetaDataGrammarAccess exposes generated grammar rules" {
  let grammar_access = new_meta_data_grammar_access()
  inspect(
    grammar_access.get_grammar(),
    content="org.eclipse.elk.core.meta.MetaData",
  )
  inspect(
    grammar_access.get_md_model_rule(),
    content="('package' name=QualifiedName importSection=XImportSection? bundle=MdBundle)?",
  )
  inspect(
    grammar_access.get_md_bundle_rule().contains("'bundle' '{'"),
    content="true",
  )
  let rule_names = grammar_access.get_rule_names()
  inspect(
    core_meta_generated_test_contains(rule_names, "MdOption"),
    content="true",
  )
  inspect(
    core_meta_generated_test_contains(rule_names, "MdAlgorithm"),
    content="true",
  )
}

///|
test "MetaDataAntlrTokenFileProvider returns generated token file data" {
  let provider = new_meta_data_antlr_token_file_provider()
  inspect(
    provider.get_antlr_token_file_path(),
    content="org/eclipse/elk/core/meta/parser/antlr/internal/InternalMetaData.tokens",
  )
  inspect(provider.get_antlr_token_file().contains("RULE_ID=5"), content="true")
  inspect(
    provider.get_antlr_token_file().contains("T__124=124"),
    content="true",
  )
}

///|
test "InternalMetaDataLexer tokenizes generated terminal subset" {
  let lexer = new_internal_meta_data_lexer(
    "package org.example bundle { label \"Demo\" option spacing { targets nodes,edges } }",
  )
  let tokens = lexer.lex_all()
  inspect(lexer.get_grammar_file_name(), content="InternalMetaData.g")
  inspect(tokens.length() > 10, content="true")
  inspect(tokens[0].token_name, content="'package'")
  inspect(tokens[1].token_name, content="RULE_ID")
  inspect(tokens[5].token_name, content="'{'")
}

///|
test "InternalMetaDataParser parses package bundle and members" {
  let text = "package org.example bundle { label \"Demo\" idPrefix org.example } option spacing { label \"Spacing\" targets nodes,edges } category layering { label \"Layering\" } algorithm layered(org.example.Provider) { label \"Layered\" features ports supports spacing }"
  let lexer = new_internal_meta_data_lexer(text)
  let parser = new_internal_meta_data_parser(lexer.lex_all())
  let model = parser.entry_rule_md_model()

  inspect(parser.get_grammar_file_name(), content="InternalMetaData.g")
  inspect(parser.get_first_rule_name(), content="MdModel")
  inspect(
    core_meta_generated_test_string_or_none(model.get_name()),
    content="org.example",
  )

  let bundle = match model.get_bundle() {
    Some(value) => value
    None => core_meta_create_md_bundle()
  }
  inspect(
    core_meta_generated_test_string_or_none(bundle.get_label()),
    content="Demo",
  )
  inspect(bundle.get_members().length(), content="3")
  inspect(
    core_meta_md_bundle_member_tag(bundle.get_members()[0]),
    content="group_or_option",
  )
  inspect(
    core_meta_md_bundle_member_tag(bundle.get_members()[1]),
    content="category",
  )
  inspect(
    core_meta_md_bundle_member_tag(bundle.get_members()[2]),
    content="algorithm",
  )
}

///|
test "MetaDataParser wires lexer and internal parser" {
  let parser = new_meta_data_parser()
  inspect(parser.get_default_rule_name(), content="MdModel")
  inspect(parser.get_initial_hidden_tokens().length(), content="3")
  let model = parser.parse(
    "package org.example bundle { metadataClass org.example.Meta } option spacing { }",
  )
  let bundle = match model.get_bundle() {
    Some(value) => value
    None => core_meta_create_md_bundle()
  }
  inspect(
    core_meta_generated_test_string_or_none(bundle.get_target_class()),
    content="org.example.Meta",
  )
  inspect(bundle.get_members().length(), content="1")
}
