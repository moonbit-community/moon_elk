///|
pub let core_debug_grandom_ui_plugin_id : String = "org.eclipse.elk.core.debug.grandom.ui"

///|
pub struct CoreDebugGRandomUiLexerBinding {
  binding_name : String
  class_name : String
}

///|
pub fn new_core_debug_grandom_ui_lexer_binding(
  binding_name : String,
  class_name : String,
) -> CoreDebugGRandomUiLexerBinding {
  { binding_name, class_name }
}

///|
pub struct AbstractCoreDebugGRandomUiModule {
  plugin_id : String
}

///|
pub fn new_abstract_core_debug_grandom_ui_module(
  plugin_id? : String = core_debug_grandom_ui_plugin_id,
) -> AbstractCoreDebugGRandomUiModule {
  { plugin_id, }
}

///|
pub fn AbstractCoreDebugGRandomUiModule::provide_i_all_containers_state(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.Access.getJavaProjectsState"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_proposal_conflict_helper(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_content_assist_lexer(
  self : AbstractCoreDebugGRandomUiModule,
) -> CoreDebugGRandomUiLexerBinding {
  ignore(self)
  new_core_debug_grandom_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST", "org.eclipse.elk.core.debug.grandom.ide.contentassist.antlr.internal.InternalGRandomLexer",
  )
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_highlighting_lexer(
  self : AbstractCoreDebugGRandomUiModule,
) -> CoreDebugGRandomUiLexerBinding {
  ignore(self)
  new_core_debug_grandom_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.elk.core.debug.grandom.parser.antlr.internal.InternalGRandomLexer",
  )
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_highlighting_token_def_provider(
  self : AbstractCoreDebugGRandomUiModule,
) -> CoreDebugGRandomUiLexerBinding {
  ignore(self)
  new_core_debug_grandom_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider",
  )
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_content_assist_context_factory(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.DelegatingContentAssistContextFactory"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_content_assist_parser(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.debug.grandom.ide.contentassist.antlr.GRandomParser"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_content_assist_lexer_provider(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.LexerProvider.create(InternalGRandomLexer)"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_prefix_matcher(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_dependent_elements_calculator(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultDependentElementsCalculator"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_i_resource_descriptions_builder_scope(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(BUILDER_SCOPE)=CurrentDescriptions.ResourceSetAware"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_xtext_editor_callback(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.nature.NatureAddingEditorCallback"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_contextual_output_configuration_provider(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.EclipseOutputConfigurationProvider"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_i_resource_descriptions_persisted(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(PERSISTED_DESCRIPTIONS)=IBuilderState"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_document_based_dirty_resource(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.impl.PersistentDataAwareDirtyResource"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_xtext_builder_participant(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.BuilderParticipant"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_workspace_root_to_instance(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.core.resources.ResourcesPlugin.getWorkspace().getRoot()"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_builder_preference_store_initializer(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.preferences.BuilderPreferenceAccess.Initializer"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_issue_resolution_provider(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.debug.grandom.ui.quickfix.GRandomQuickfixProvider"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_content_proposal_provider(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.debug.grandom.ui.contentassist.GRandomProposalProvider"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_i_preference_store_initializer(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.ui.RefactoringPreferences.Initializer"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_rename_strategy(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultRenameStrategy"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_reference_updater(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultReferenceUpdater"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_rename_refactoring_provider(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultRenameRefactoringProvider"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_rename_support_factory(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.ui.DefaultRenameSupport.Factory"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::provide_templates_language_configuration(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getTemplatesLanguageConfigurationProvider"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::provide_language_registry(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getLanguageRegistry"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_language_registrar(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.registry.LanguageRegistrar"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_xtext_template_preference_page(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.preferences.AdvancedTemplatesPreferencePage"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_partial_editing_content_assist_parser(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.debug.grandom.ide.contentassist.antlr.PartialGRandomContentAssistParser"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_partial_editing_content_assist_context_factory(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.partialEditing.PartialEditingContentAssistContextFactory"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::bind_i_viewer_creator(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.compare.DefaultViewerCreator"
}

///|
pub fn AbstractCoreDebugGRandomUiModule::configure_compare_viewer_title(
  self : AbstractCoreDebugGRandomUiModule,
) -> String {
  ignore(self)
  "GRandom Compare"
}
