///|
pub let graphviz_dot_default_file_extension : String = "graphviz_dot"

///|
pub let graphviz_dot_default_language_name : String = "org.eclipse.elk.alg.graphviz.dot.GraphvizDot"

///|
pub let graphviz_dot_default_serializer_class_name : String = "org.eclipse.xtext.serializer.impl.Serializer"

///|
pub struct AbstractGraphvizDotRuntimeModule {
  mut properties : Map[String, String]
}

///|
pub fn new_abstract_graphviz_dot_runtime_module(
  properties? : Map[String, String] = {},
) -> AbstractGraphvizDotRuntimeModule {
  { properties, }
}

///|
pub fn AbstractGraphvizDotRuntimeModule::configure(
  self : AbstractGraphvizDotRuntimeModule,
  properties : Map[String, String],
) -> Unit {
  self.properties = properties
}

///|
pub fn AbstractGraphvizDotRuntimeModule::configure_language_name(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  graphviz_dot_default_language_name
}

///|
pub fn AbstractGraphvizDotRuntimeModule::configure_file_extensions(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  match self.properties.get("fileExtensions") {
    Some(value) => value
    None => graphviz_dot_default_file_extension
  }
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_class_loader_to_instance(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_igrammar_access(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.services.GraphvizDotGrammarAccess"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_iparser(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.parser.antlr.GraphvizDotParser"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_itoken_to_string_converter(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenToStringConverter"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_iantlr_token_file_provider(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.parser.antlr.GraphvizDotAntlrTokenFileProvider"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_lexer(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.parser.antlr.internal.InternalGraphvizDotLexer"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_itoken_def_provider(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::provide_internal_graphviz_dot_lexer(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.parser.antlr.internal.InternalGraphvizDotLexer"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::configure_runtime_lexer(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.parser.antlr.internal.InternalGraphvizDotLexer"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_iformatter2(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.formatting2.GraphvizDotFormatter"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::configure_formatter_preferences(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.formatting2.FormatterPreferenceValuesProvider"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_isemantic_sequencer(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.serializer.GraphvizDotSemanticSequencer"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_isyntactic_sequencer(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.alg.graphviz.dot.serializer.GraphvizDotSyntacticSequencer"
}

///|
pub fn AbstractGraphvizDotRuntimeModule::bind_iserializer(
  self : AbstractGraphvizDotRuntimeModule,
) -> String {
  ignore(self)
  graphviz_dot_default_serializer_class_name
}
