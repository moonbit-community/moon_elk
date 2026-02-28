///|
pub let graph_text_ui_plugin_id : String = "org.eclipse.elk.graph.text.ui"

///|
pub struct GraphTextUiLexerBinding {
  binding_name : String
  class_name : String
}

///|
pub fn new_graph_text_ui_lexer_binding(
  binding_name : String,
  class_name : String,
) -> GraphTextUiLexerBinding {
  { binding_name, class_name }
}

///|
pub struct AbstractElkGraphUiModule {
  plugin_id : String
}

///|
pub fn new_abstract_elk_graph_ui_module(
  plugin_id? : String = graph_text_ui_plugin_id,
) -> AbstractElkGraphUiModule {
  { plugin_id, }
}

///|
pub fn AbstractElkGraphUiModule::get_plugin_id(
  self : AbstractElkGraphUiModule,
) -> String {
  self.plugin_id
}

///|
pub fn AbstractElkGraphUiModule::provide_i_all_containers_state(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.Access.getJavaProjectsState"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_proposal_conflict_helper(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractElkGraphUiModule::configure_content_assist_lexer(
  self : AbstractElkGraphUiModule,
) -> GraphTextUiLexerBinding {
  ignore(self)
  new_graph_text_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST", "org.eclipse.elk.graph.text.ide.contentassist.antlr.internal.InternalElkGraphLexer",
  )
}

///|
pub fn AbstractElkGraphUiModule::configure_highlighting_lexer(
  self : AbstractElkGraphUiModule,
) -> GraphTextUiLexerBinding {
  ignore(self)
  new_graph_text_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.elk.graph.text.parser.antlr.internal.InternalElkGraphLexer",
  )
}

///|
pub fn AbstractElkGraphUiModule::configure_highlighting_token_def_provider(
  self : AbstractElkGraphUiModule,
) -> GraphTextUiLexerBinding {
  ignore(self)
  new_graph_text_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider",
  )
}

///|
pub fn AbstractElkGraphUiModule::bind_content_assist_context_factory(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.DelegatingContentAssistContextFactory"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_content_assist_parser(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ide.contentassist.antlr.ElkGraphParser"
}

///|
pub fn AbstractElkGraphUiModule::configure_content_assist_lexer_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.LexerProvider.create(InternalElkGraphLexer)"
}

///|
pub fn AbstractElkGraphUiModule::bind_prefix_matcher(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_dependent_elements_calculator(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultDependentElementsCalculator"
}

///|
pub fn AbstractElkGraphUiModule::configure_i_resource_descriptions_builder_scope(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(BUILDER_SCOPE)=CurrentDescriptions.ResourceSetAware"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_xtext_editor_callback(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.nature.NatureAddingEditorCallback"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_contextual_output_configuration_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.EclipseOutputConfigurationProvider"
}

///|
pub fn AbstractElkGraphUiModule::configure_i_resource_descriptions_persisted(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(PERSISTED_DESCRIPTIONS)=IBuilderState"
}

///|
pub fn AbstractElkGraphUiModule::bind_document_based_dirty_resource(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.impl.PersistentDataAwareDirtyResource"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_xtext_builder_participant(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.BuilderParticipant"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_workspace_root_to_instance(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.core.resources.ResourcesPlugin.getWorkspace().getRoot()"
}

///|
pub fn AbstractElkGraphUiModule::configure_builder_preference_store_initializer(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.preferences.BuilderPreferenceAccess.Initializer"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_content_formatter_factory(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.formatting2.ContentFormatterFactory"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_label_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ui.labeling.ElkGraphLabelProvider"
}

///|
pub fn AbstractElkGraphUiModule::configure_resource_ui_service_label_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ui.labeling.ElkGraphDescriptionLabelProvider"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_outline_tree_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ui.outline.ElkGraphOutlineTreeProvider"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_outline_tree_structure_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ui.outline.ElkGraphOutlineTreeProvider"
}

///|
pub fn AbstractElkGraphUiModule::bind_issue_resolution_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ui.quickfix.ElkGraphQuickfixProvider"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_content_proposal_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ui.contentassist.ElkGraphProposalProvider"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_rename_strategy(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultRenameStrategy"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_reference_updater(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultReferenceUpdater"
}

///|
pub fn AbstractElkGraphUiModule::configure_i_preference_store_initializer(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.ui.RefactoringPreferences.Initializer"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_rename_refactoring_provider(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultRenameRefactoringProvider"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_rename_support_factory(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.ui.DefaultRenameSupport.Factory"
}

///|
pub fn AbstractElkGraphUiModule::provide_templates_language_configuration(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getTemplatesLanguageConfigurationProvider"
}

///|
pub fn AbstractElkGraphUiModule::provide_language_registry(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getLanguageRegistry"
}

///|
pub fn AbstractElkGraphUiModule::bind_language_registrar(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.registry.LanguageRegistrar"
}

///|
pub fn AbstractElkGraphUiModule::bind_xtext_template_preference_page(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.preferences.AdvancedTemplatesPreferencePage"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_partial_editing_content_assist_parser(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.ide.contentassist.antlr.PartialElkGraphContentAssistParser"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_partial_editing_content_assist_context_factory(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.partialEditing.PartialEditingContentAssistContextFactory"
}

///|
pub fn AbstractElkGraphUiModule::bind_i_viewer_creator(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.compare.DefaultViewerCreator"
}

///|
pub fn AbstractElkGraphUiModule::configure_compare_viewer_title(
  self : AbstractElkGraphUiModule,
) -> String {
  ignore(self)
  "ElkGraph Compare"
}
