///|
pub let core_meta_ide_language_name : String = "org.eclipse.elk.core.meta.MetaData"

///|
pub let core_meta_ide_content_assist_lexer_binding : String = "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST"

///|
pub struct CoreMetaIdeContentAssistLexerBinding {
  binding_name : String
  lexer_class_name : String
}

///|
pub fn new_core_meta_ide_content_assist_lexer_binding(
  binding_name : String,
  lexer_class_name : String,
) -> CoreMetaIdeContentAssistLexerBinding {
  { binding_name, lexer_class_name }
}

///|
pub struct AbstractCoreMetaIdeModule {
  unit : Unit
}

///|
pub fn new_abstract_core_meta_ide_module() -> AbstractCoreMetaIdeModule {
  { unit: () }
}

///|
pub fn AbstractCoreMetaIdeModule::configure_content_assist_lexer(
  self : AbstractCoreMetaIdeModule,
) -> CoreMetaIdeContentAssistLexerBinding {
  ignore(self)
  new_core_meta_ide_content_assist_lexer_binding(
    core_meta_ide_content_assist_lexer_binding, "org.eclipse.elk.core.meta.ide.contentassist.antlr.internal.InternalMetaDataLexer",
  )
}

///|
pub fn AbstractCoreMetaIdeModule::bind_i_content_assist_parser(
  self : AbstractCoreMetaIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ide.contentassist.antlr.MetaDataParser"
}

///|
pub fn AbstractCoreMetaIdeModule::bind_i_proposal_conflict_helper(
  self : AbstractCoreMetaIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractCoreMetaIdeModule::bind_i_prefix_matcher(
  self : AbstractCoreMetaIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.editor.contentassist.FQNPrefixMatcher"
}

///|
pub fn AbstractCoreMetaIdeModule::bind_i_rename_service(
  self : AbstractCoreMetaIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.server.rename.RenameService2"
}

///|
pub fn AbstractCoreMetaIdeModule::bind_i_rename_strategy2(
  self : AbstractCoreMetaIdeModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ide.refactoring.IRenameStrategy2.DefaultImpl"
}
