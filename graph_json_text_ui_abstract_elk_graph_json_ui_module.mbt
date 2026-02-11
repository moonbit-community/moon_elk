///|
pub let graph_json_text_ui_plugin_id : String = "org.eclipse.elk.graph.json.text.ui"

///|
pub struct GraphJsonTextUiLexerBinding {
  binding_name : String
  class_name : String
}

///|
pub fn new_graph_json_text_ui_lexer_binding(
  binding_name : String,
  class_name : String,
) -> GraphJsonTextUiLexerBinding {
  { binding_name, class_name }
}

///|
pub struct AbstractElkGraphJsonUiModule {
  plugin_id : String
}

///|
pub fn new_abstract_elk_graph_json_ui_module(
  plugin_id? : String = graph_json_text_ui_plugin_id,
) -> AbstractElkGraphJsonUiModule {
  { plugin_id, }
}

///|
pub fn AbstractElkGraphJsonUiModule::get_plugin_id(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  self.plugin_id
}

///|
pub fn AbstractElkGraphJsonUiModule::provide_i_all_containers_state(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.Access.getJavaProjectsState"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_proposal_conflict_helper(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.AntlrProposalConflictHelper"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_content_assist_lexer(
  self : AbstractElkGraphJsonUiModule,
) -> GraphJsonTextUiLexerBinding {
  ignore(self)
  new_graph_json_text_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.CONTENT_ASSIST", "org.eclipse.elk.graph.json.text.ide.contentassist.antlr.internal.InternalElkGraphJsonLexer",
  )
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_highlighting_lexer(
  self : AbstractElkGraphJsonUiModule,
) -> GraphJsonTextUiLexerBinding {
  ignore(self)
  new_graph_json_text_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.elk.graph.json.text.parser.antlr.internal.InternalElkGraphJsonLexer",
  )
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_highlighting_token_def_provider(
  self : AbstractElkGraphJsonUiModule,
) -> GraphJsonTextUiLexerBinding {
  ignore(self)
  new_graph_json_text_ui_lexer_binding(
    "org.eclipse.xtext.ide.LexerIdeBindings.HIGHLIGHTING", "org.eclipse.xtext.parser.antlr.AntlrTokenDefProvider",
  )
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_content_assist_context_factory(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.antlr.DelegatingContentAssistContextFactory"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_content_assist_parser(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ide.contentassist.antlr.ElkGraphJsonParser"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_content_assist_lexer_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.parser.antlr.LexerProvider.create(InternalElkGraphJsonLexer)"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_prefix_matcher(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_dependent_elements_calculator(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultDependentElementsCalculator"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_i_resource_descriptions_builder_scope(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(BUILDER_SCOPE)=CurrentDescriptions.ResourceSetAware"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_xtext_editor_callback(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.nature.NatureAddingEditorCallback"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_contextual_output_configuration_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.EclipseOutputConfigurationProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_i_resource_descriptions_persisted(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.resource.IResourceDescriptions@Named(PERSISTED_DESCRIPTIONS)=IBuilderState"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_document_based_dirty_resource(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.impl.PersistentDataAwareDirtyResource"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_xtext_builder_participant(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.BuilderParticipant"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_workspace_root_to_instance(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.core.resources.ResourcesPlugin.getWorkspace().getRoot()"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_builder_preference_store_initializer(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.builder.preferences.BuilderPreferenceAccess.Initializer"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_content_formatter_factory(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.editor.formatting2.ContentFormatterFactory"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_label_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ui.labeling.ElkGraphJsonLabelProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_resource_ui_service_label_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ui.labeling.ElkGraphJsonDescriptionLabelProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_outline_tree_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ui.outline.ElkGraphJsonOutlineTreeProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_outline_tree_structure_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ui.outline.ElkGraphJsonOutlineTreeProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_issue_resolution_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ui.quickfix.ElkGraphJsonQuickfixProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_abstract_validator_configuration_block(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.validation.ElkGraphJsonValidatorConfigurationBlock"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_content_proposal_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ui.contentassist.ElkGraphJsonProposalProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_rename_strategy(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultRenameStrategy"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_reference_updater(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultReferenceUpdater"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_i_preference_store_initializer(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.ui.RefactoringPreferences.Initializer"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_rename_refactoring_provider(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.impl.DefaultRenameRefactoringProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_rename_support_factory(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.refactoring.ui.DefaultRenameSupport.Factory"
}

///|
pub fn AbstractElkGraphJsonUiModule::provide_templates_language_configuration(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getTemplatesLanguageConfigurationProvider"
}

///|
pub fn AbstractElkGraphJsonUiModule::provide_language_registry(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.AccessibleCodetemplatesActivator.getLanguageRegistry"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_language_registrar(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.registry.LanguageRegistrar"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_xtext_template_preference_page(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.preferences.AdvancedTemplatesPreferencePage"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_partial_editing_content_assist_parser(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.ide.contentassist.antlr.PartialElkGraphJsonContentAssistParser"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_partial_editing_content_assist_context_factory(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.codetemplates.ui.partialEditing.PartialEditingContentAssistContextFactory"
}

///|
pub fn AbstractElkGraphJsonUiModule::bind_i_viewer_creator(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.compare.DefaultViewerCreator"
}

///|
pub fn AbstractElkGraphJsonUiModule::configure_compare_viewer_title(
  self : AbstractElkGraphJsonUiModule,
) -> String {
  ignore(self)
  "ElkGraphJson Compare"
}
