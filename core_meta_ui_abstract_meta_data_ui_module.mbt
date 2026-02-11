///|
pub let core_meta_ui_plugin_id : String = "org.eclipse.elk.core.meta.ui"

///|
pub struct CoreMetaUiLexerBinding {
  binding_name : String
  class_name : String
}

///|
pub fn new_core_meta_ui_lexer_binding(
  binding_name : String,
  class_name : String,
) -> CoreMetaUiLexerBinding {
  { binding_name, class_name }
}

///|
pub struct AbstractMetaDataUiModule {
  plugin_id : String
}

///|
pub fn new_abstract_meta_data_ui_module(
  plugin_id? : String = core_meta_ui_plugin_id,
) -> AbstractMetaDataUiModule {
  { plugin_id, }
}

///|
pub fn AbstractMetaDataUiModule::get_plugin_id(
  self : AbstractMetaDataUiModule,
) -> String {
  self.plugin_id
}

///|
pub fn AbstractMetaDataUiModule::provide_i_all_containers_state(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.Access.getJavaProjectsState"
}

///|
pub fn AbstractMetaDataUiModule::bind_xtext_document_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.editor.XbaseDocumentProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_open_generated_file_handler(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.generator.trace.XbaseOpenGeneratedFileHandler"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_proposal_conflict_helper(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractMetaDataUiModule::configure_content_assist_lexer(
  self : AbstractMetaDataUiModule,
) -> CoreMetaUiLexerBinding {
  ignore(self)
  new_core_meta_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST", "org.eclipse.elk.core.meta.ide.contentassist.antlr.internal.InternalMetaDataLexer",
  )
}

///|
pub fn AbstractMetaDataUiModule::configure_highlighting_lexer(
  self : AbstractMetaDataUiModule,
) -> CoreMetaUiLexerBinding {
  ignore(self)
  new_core_meta_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.elk.core.meta.parser.antlr.internal.InternalMetaDataLexer",
  )
}

///|
pub fn AbstractMetaDataUiModule::configure_highlighting_token_def_provider(
  self : AbstractMetaDataUiModule,
) -> CoreMetaUiLexerBinding {
  ignore(self)
  new_core_meta_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider",
  )
}

///|
pub fn AbstractMetaDataUiModule::bind_content_assist_context_factory(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.DelegatingContentAssistContextFactory"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_content_assist_parser(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ide.contentassist.antlr.MetaDataParser"
}

///|
pub fn AbstractMetaDataUiModule::configure_content_assist_lexer_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.LexerProvider.create(InternalMetaDataLexer)"
}

///|
pub fn AbstractMetaDataUiModule::configure_i_resource_descriptions_builder_scope(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(BUILDER_SCOPE)=CurrentDescriptions.ResourceSetAware"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_xtext_editor_callback(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.nature.NatureAddingEditorCallback"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_contextual_output_configuration_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.EclipseOutputConfigurationProvider"
}

///|
pub fn AbstractMetaDataUiModule::configure_i_resource_descriptions_persisted(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(PERSISTED_DESCRIPTIONS)=IBuilderState"
}

///|
pub fn AbstractMetaDataUiModule::bind_document_based_dirty_resource(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.impl.PersistentDataAwareDirtyResource"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_xtext_builder_participant(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.BuilderParticipant"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_workspace_root_to_instance(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.core.resources.ResourcesPlugin.getWorkspace().getRoot()"
}

///|
pub fn AbstractMetaDataUiModule::configure_builder_preference_store_initializer(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.preferences.BuilderPreferenceAccess.Initializer"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_content_formatter_factory(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.formatting2.ContentFormatterFactory"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_label_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ui.labeling.MetaDataLabelProvider"
}

///|
pub fn AbstractMetaDataUiModule::configure_resource_ui_service_label_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ui.labeling.MetaDataDescriptionLabelProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_outline_tree_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ui.outline.MetaDataOutlineTreeProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_outline_tree_structure_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ui.outline.MetaDataOutlineTreeProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_issue_resolution_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ui.quickfix.MetaDataQuickfixProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_content_proposal_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ui.contentassist.MetaDataProposalProvider"
}

///|
pub fn AbstractMetaDataUiModule::configure_i_preference_store_initializer(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.ui.RefactoringPreferences.Initializer"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_rename_support_factory(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.common.types.ui.refactoring.JdtRenameSupport.Factory"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_rename_strategy_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.common.types.ui.refactoring.participant.JvmMemberRenameStrategy.Provider"
}

///|
pub fn AbstractMetaDataUiModule::configure_jvm_member_rename_strategy_provider_delegate(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultRenameStrategyProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_prefix_matcher(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher"
}

///|
pub fn AbstractMetaDataUiModule::bind_find_references_handler(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.findrefs.JvmModelFindReferenceHandler"
}

///|
pub fn AbstractMetaDataUiModule::bind_reference_query_executor(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.findrefs.JvmModelReferenceQueryExecutor"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_dependent_elements_calculator(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.refactoring.JvmModelDependentElementsCalculator"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_rename_refactoring_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.refactoring.jdt.CombinedJvmJdtRenameRefactoringProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_reference_updater(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.refactoring.XbaseReferenceUpdater"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_rename_context_factory(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.refactoring.jdt.CombinedJvmJdtRenameContextFactory"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_rename_strategy(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.refactoring.DefaultJvmModelRenameStrategy"
}

///|
pub fn AbstractMetaDataUiModule::bind_jdt_rename_participant_context_factory(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.refactoring.JvmModelJdtRenameParticipantContext.ContextFactory"
}

///|
pub fn AbstractMetaDataUiModule::bind_outline_node_element_opener(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.outline.JvmOutlineNodeElementOpener"
}

///|
pub fn AbstractMetaDataUiModule::bind_global_uri_editor_opener(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.common.types.ui.navigation.GlobalDerivedMemberAwareURIEditorOpener"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_java_search_participation(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.common.types.ui.query.IJavaSearchParticipation.No"
}

///|
pub fn AbstractMetaDataUiModule::configure_language_specific_uri_editor_opener(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.jvmmodel.navigation.DerivedMemberAwareEditorOpener"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_unresolved_type_resolver(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.imports.InteractiveUnresolvedTypeResolver"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_types_proposal_provider(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.contentassist.ImportingTypesProposalProvider"
}

///|
pub fn AbstractMetaDataUiModule::bind_xtext_template_context_type(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.xbase.ui.templates.XbaseTemplateContextType"
}

///|
pub fn AbstractMetaDataUiModule::bind_xtext_editor(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ui.editor.MetaDataEditor"
}

///|
pub fn AbstractMetaDataUiModule::provide_templates_language_configuration(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getTemplatesLanguageConfigurationProvider"
}

///|
pub fn AbstractMetaDataUiModule::provide_language_registry(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getLanguageRegistry"
}

///|
pub fn AbstractMetaDataUiModule::bind_language_registrar(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.registry.LanguageRegistrar"
}

///|
pub fn AbstractMetaDataUiModule::bind_xtext_template_preference_page(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.preferences.AdvancedTemplatesPreferencePage"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_partial_editing_content_assist_parser(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.core.meta.ide.contentassist.antlr.PartialMetaDataContentAssistParser"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_partial_editing_content_assist_context_factory(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.partialEditing.PartialEditingContentAssistContextFactory"
}

///|
pub fn AbstractMetaDataUiModule::bind_i_viewer_creator(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.compare.DefaultViewerCreator"
}

///|
pub fn AbstractMetaDataUiModule::configure_compare_viewer_title(
  self : AbstractMetaDataUiModule,
) -> String {
  ignore(self)
  "MetaData Compare"
}
