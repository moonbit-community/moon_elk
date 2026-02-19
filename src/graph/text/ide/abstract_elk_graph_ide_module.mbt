///|
pub let graph_text_ide_language_name : String = "org.eclipse.elk.graph.text.ElkGraph"

///|
pub let graph_text_ide_content_assist_lexer_binding : String = "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST"

///|
pub struct GraphTextIdeContentAssistLexerBinding {
  binding_name : String
  lexer_class_name : String
}

///|
pub fn new_graph_text_ide_content_assist_lexer_binding(
  binding_name : String,
  lexer_class_name : String,
) -> GraphTextIdeContentAssistLexerBinding {
  { binding_name, lexer_class_name }
}

///|
pub struct AbstractElkGraphIdeModule {
  unit : Unit
}

///|
pub fn new_abstract_elk_graph_ide_module() -> AbstractElkGraphIdeModule {
  { unit: () }
}

///|
pub fn AbstractElkGraphIdeModule::configure_content_assist_lexer(
  self : AbstractElkGraphIdeModule,
) -> GraphTextIdeContentAssistLexerBinding {
  ignore(self)
  new_graph_text_ide_content_assist_lexer_binding(
    graph_text_ide_content_assist_lexer_binding, "org.eclipse.elk.graph.text.ide.contentassist.antlr.internal.InternalElkGraphLexer",
  )
}

///|
pub fn AbstractElkGraphIdeModule::bind_i_content_assist_parser(
  self : AbstractElkGraphIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ide.contentassist.antlr.ElkGraphParser"
}

///|
pub fn AbstractElkGraphIdeModule::bind_i_proposal_conflict_helper(
  self : AbstractElkGraphIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractElkGraphIdeModule::bind_i_prefix_matcher(
  self : AbstractElkGraphIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher"
}
