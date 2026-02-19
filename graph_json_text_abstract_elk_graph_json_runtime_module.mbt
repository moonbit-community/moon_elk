///|
pub let graph_json_text_default_file_extension : String = "elkj"

///|
pub let graph_json_text_default_language_name : String = "org.eclipse.elk.graph.json.text.ElkGraphJson"

///|
pub let graph_json_text_default_serializer_class_name : String = "org.eclipse.xtext.serializer.impl.Serializer"

///|
pub struct AbstractElkGraphJsonRuntimeModule {
  mut properties : Map[String, String]
}

///|
pub fn new_abstract_elk_graph_json_runtime_module(
  properties? : Map[String, String] = {},
) -> AbstractElkGraphJsonRuntimeModule {
  { properties, }
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure(
  self : AbstractElkGraphJsonRuntimeModule,
  properties : Map[String, String],
) -> Unit {
  self.properties = properties
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_language_name(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  graph_json_text_default_language_name
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_file_extensions(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  match self.properties.get("fileExtensions") {
    Some(value) => value
    None => graph_json_text_default_file_extension
  }
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_class_loader_to_instance(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_igrammar_access(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.services.ElkGraphJsonGrammarAccess"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_isemantic_sequencer(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.serializer.ElkGraphJsonSemanticSequencer"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_isyntactic_sequencer(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.serializer.ElkGraphJsonSyntacticSequencer"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_iserializer(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  graph_json_text_default_serializer_class_name
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_iparser(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.parser.antlr.ElkGraphJsonParser"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_itoken_to_string_converter(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenToStringConverter"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_iantlr_token_file_provider(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.parser.antlr.ElkGraphJsonAntlrTokenFileProvider"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_lexer(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.parser.antlr.internal.InternalElkGraphJsonLexer"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_itoken_def_provider(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::provide_internal_elk_graph_json_lexer(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.parser.antlr.internal.InternalElkGraphJsonLexer"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_runtime_lexer(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.parser.antlr.internal.InternalElkGraphJsonLexer"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_iunordered_group_helper(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.UnorderedGroupHelper"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_elk_graph_json_validator(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.validation.ElkGraphJsonValidator"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_i_scope_provider(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.scoping.ElkGraphJsonScopeProvider"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_i_scope_provider_delegate(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_i_global_scope_provider(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_ignore_case_linking(
  self : AbstractElkGraphJsonRuntimeModule,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_i_qualified_name_provider(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_i_container_manager(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.containers.StateBasedContainerManager"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_i_all_containers_state_provider(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.containers.ResourceSetBasedAllContainersStateProvider"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_i_resource_descriptions(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_i_resource_descriptions_persisted(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::bind_iformatter2(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.formatting2.ElkGraphJsonFormatter"
}

///|
pub fn AbstractElkGraphJsonRuntimeModule::configure_formatter_preferences(
  self : AbstractElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.formatting2.FormatterPreferenceValuesProvider"
}
