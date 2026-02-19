///|
pub let graph_text_default_file_extension : String = "elkt"

///|
pub let graph_text_default_language_name : String = "org.eclipse.elk.graph.text.ElkGraph"

///|
pub let graph_text_default_serializer_class_name : String = "org.eclipse.xtext.serializer.impl.Serializer"

///|
pub struct AbstractElkGraphRuntimeModule {
  mut properties : Map[String, String]
}

///|
pub fn new_abstract_elk_graph_runtime_module(
  properties? : Map[String, String] = {},
) -> AbstractElkGraphRuntimeModule {
  { properties, }
}

///|
pub fn AbstractElkGraphRuntimeModule::configure(
  self : AbstractElkGraphRuntimeModule,
  properties : Map[String, String],
) -> Unit {
  self.properties = properties
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_language_name(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  graph_text_default_language_name
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_file_extensions(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  match self.properties.get("fileExtensions") {
    Some(value) => value
    None => graph_text_default_file_extension
  }
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_class_loader_to_instance(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_igrammar_access(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.services.ElkGraphGrammarAccess"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_isemantic_sequencer(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.serializer.ElkGraphSemanticSequencer"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_isyntactic_sequencer(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.serializer.ElkGraphSyntacticSequencer"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_iserializer(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  graph_text_default_serializer_class_name
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_iparser(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.parser.antlr.ElkGraphParser"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_itoken_to_string_converter(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenToStringConverter"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_iantlr_token_file_provider(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.parser.antlr.ElkGraphAntlrTokenFileProvider"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_lexer(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.parser.antlr.internal.InternalElkGraphLexer"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_itoken_def_provider(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider"
}

///|
pub fn AbstractElkGraphRuntimeModule::provide_internal_elk_graph_lexer(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.parser.antlr.internal.InternalElkGraphLexer"
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_runtime_lexer(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.parser.antlr.internal.InternalElkGraphLexer"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_iunordered_group_helper(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.UnorderedGroupHelper"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_elk_graph_validator(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.validation.ElkGraphValidator"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_i_scope_provider(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.scoping.ElkGraphScopeProvider"
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_i_scope_provider_delegate(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_i_global_scope_provider(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider"
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_ignore_case_linking(
  self : AbstractElkGraphRuntimeModule,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_i_qualified_name_provider(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_i_container_manager(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.containers.StateBasedContainerManager"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_i_all_containers_state_provider(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.containers.ResourceSetBasedAllContainersStateProvider"
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_i_resource_descriptions(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions"
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_i_resource_descriptions_persisted(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions"
}

///|
pub fn AbstractElkGraphRuntimeModule::bind_iformatter2(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.formatting2.ElkGraphFormatter"
}

///|
pub fn AbstractElkGraphRuntimeModule::configure_formatter_preferences(
  self : AbstractElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.formatting2.FormatterPreferenceValuesProvider"
}
