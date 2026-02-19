///|
pub let core_debug_grandom_ide_language_name : String = "org.eclipse.elk.core.debug.grandom.GRandom"

///|
pub let core_debug_grandom_ide_content_assist_lexer_binding : String = "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST"

///|
pub(all) struct CoreDebugGRandomIdeContentAssistLexerBinding {
  binding_name : String
  lexer_class_name : String
}

///|
pub fn new_core_debug_grandom_ide_content_assist_lexer_binding(
  binding_name : String,
  lexer_class_name : String,
) -> CoreDebugGRandomIdeContentAssistLexerBinding {
  { binding_name, lexer_class_name }
}

///|
pub(all) struct AbstractCoreDebugGRandomIdeModule {
  unit : Unit
}

///|
pub fn new_abstract_core_debug_grandom_ide_module() -> AbstractCoreDebugGRandomIdeModule {
  { unit: () }
}

///|
pub fn AbstractCoreDebugGRandomIdeModule::configure_content_assist_lexer(
  self : AbstractCoreDebugGRandomIdeModule,
) -> CoreDebugGRandomIdeContentAssistLexerBinding {
  ignore(self)
  new_core_debug_grandom_ide_content_assist_lexer_binding(
    core_debug_grandom_ide_content_assist_lexer_binding, "org.eclipse.elk.core.debug.grandom.ide.contentassist.antlr.internal.InternalGRandomLexer",
  )
}

///|
pub fn AbstractCoreDebugGRandomIdeModule::bind_i_content_assist_parser(
  self : AbstractCoreDebugGRandomIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.debug.grandom.ide.contentassist.antlr.GRandomParser"
}

///|
pub fn AbstractCoreDebugGRandomIdeModule::bind_i_proposal_conflict_helper(
  self : AbstractCoreDebugGRandomIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractCoreDebugGRandomIdeModule::bind_i_prefix_matcher(
  self : AbstractCoreDebugGRandomIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher"
}

///|
pub fn AbstractCoreDebugGRandomIdeModule::bind_i_rename_service(
  self : AbstractCoreDebugGRandomIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.server.rename.RenameService2"
}

///|
pub fn AbstractCoreDebugGRandomIdeModule::bind_i_rename_strategy2(
  self : AbstractCoreDebugGRandomIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.refactoring.IRenameStrategy2.DefaultImpl"
}
