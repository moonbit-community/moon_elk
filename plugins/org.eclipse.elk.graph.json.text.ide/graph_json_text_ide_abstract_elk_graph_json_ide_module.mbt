///|
pub let graph_json_text_ide_language_name : String = "org.eclipse.elk.graph.json.text.ElkGraphJson"

///|
pub let graph_json_text_ide_content_assist_lexer_binding : String = "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST"

///|
pub struct GraphJsonTextIdeContentAssistLexerBinding {
  binding_name : String
  lexer_class_name : String
}

///|
pub fn new_graph_json_text_ide_content_assist_lexer_binding(
  binding_name : String,
  lexer_class_name : String,
) -> GraphJsonTextIdeContentAssistLexerBinding {
  { binding_name, lexer_class_name }
}

///|
pub struct AbstractElkGraphJsonIdeModule {
  unit : Unit
}

///|
pub fn new_abstract_elk_graph_json_ide_module() -> AbstractElkGraphJsonIdeModule {
  { unit: () }
}

///|
pub fn AbstractElkGraphJsonIdeModule::configure_content_assist_lexer(
  self : AbstractElkGraphJsonIdeModule,
) -> GraphJsonTextIdeContentAssistLexerBinding {
  ignore(self)
  new_graph_json_text_ide_content_assist_lexer_binding(
    graph_json_text_ide_content_assist_lexer_binding, "org.eclipse.elk.graph.json.text.ide.contentassist.antlr.internal.InternalElkGraphJsonLexer",
  )
}

///|
pub fn AbstractElkGraphJsonIdeModule::bind_i_content_assist_parser(
  self : AbstractElkGraphJsonIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ide.contentassist.antlr.ElkGraphJsonParser"
}

///|
pub fn AbstractElkGraphJsonIdeModule::bind_i_proposal_conflict_helper(
  self : AbstractElkGraphJsonIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractElkGraphJsonIdeModule::bind_i_prefix_matcher(
  self : AbstractElkGraphJsonIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher"
}
