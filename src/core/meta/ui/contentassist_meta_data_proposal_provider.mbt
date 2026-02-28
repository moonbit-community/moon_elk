///|
pub(all) struct CoreMetaAssignment {
  terminal : String
}

///|
pub fn new_core_meta_assignment(terminal : String) -> CoreMetaAssignment {
  { terminal, }
}

///|
pub(all) struct CoreMetaContentAssistContext {
  unit : Unit
}

///|
pub fn new_core_meta_content_assist_context() -> CoreMetaContentAssistContext {
  { unit: () }
}

///|
pub(all) struct CoreMetaCompletionProposalAcceptor {
  proposals : Array[String]
}

///|
pub fn new_core_meta_completion_proposal_acceptor() -> CoreMetaCompletionProposalAcceptor {
  { proposals: [] }
}

///|
pub fn CoreMetaCompletionProposalAcceptor::accept(
  self : CoreMetaCompletionProposalAcceptor,
  proposal : String,
) -> Unit {
  self.proposals.push(proposal)
}

///|
pub fn CoreMetaCompletionProposalAcceptor::get_proposals(
  self : CoreMetaCompletionProposalAcceptor,
) -> Array[String] {
  self.proposals
}

///|
pub(all) struct MetaDataProposalProvider {
  unit : Unit
}

///|
pub fn new_meta_data_proposal_provider() -> MetaDataProposalProvider {
  { unit: () }
}

///|
pub fn MetaDataProposalProvider::complete_rule_call(
  self : MetaDataProposalProvider,
  terminal : String,
  _context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(terminal)
}

///|
pub fn MetaDataProposalProvider::lookup_cross_reference(
  self : MetaDataProposalProvider,
  terminal : String,
  _context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(terminal)
}

///|
pub fn MetaDataProposalProvider::complete_md_model_name(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_model_import_section(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_model_bundle(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_bundle_label(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_bundle_target_class(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_bundle_documentation_folder(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_bundle_id_prefix(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_bundle_members(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_group_name(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_group_documentation(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_group_children(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_deprecated(
  self : MetaDataProposalProvider,
  _assignment : CoreMetaAssignment,
  _context : CoreMetaContentAssistContext,
  _acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_advanced(
  self : MetaDataProposalProvider,
  _assignment : CoreMetaAssignment,
  _context : CoreMetaContentAssistContext,
  _acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_programmatic(
  self : MetaDataProposalProvider,
  _assignment : CoreMetaAssignment,
  _context : CoreMetaContentAssistContext,
  _acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_output(
  self : MetaDataProposalProvider,
  _assignment : CoreMetaAssignment,
  _context : CoreMetaContentAssistContext,
  _acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_global(
  self : MetaDataProposalProvider,
  _assignment : CoreMetaAssignment,
  _context : CoreMetaContentAssistContext,
  _acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_name(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_type(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_label(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_description(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_documentation(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_default_value(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_lower_bound(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_upper_bound(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_targets(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_legacy_ids(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_dependencies(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_dependency_target(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_dependency_value(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_deprecated(
  self : MetaDataProposalProvider,
  _assignment : CoreMetaAssignment,
  _context : CoreMetaContentAssistContext,
  _acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_name(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_provider(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_parameter(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_label(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_target_class(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_description(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_category(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_preview_image(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_supported_features(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_validator(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_supported_options(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_category_deprecated(
  self : MetaDataProposalProvider,
  _assignment : CoreMetaAssignment,
  _context : CoreMetaContentAssistContext,
  _acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_category_name(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_category_label(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_category_description(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_category_documentation(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_support_option(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_support_value(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_support_documentation(
  self : MetaDataProposalProvider,
  assignment : CoreMetaAssignment,
  context : CoreMetaContentAssistContext,
  acceptor : CoreMetaCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn MetaDataProposalProvider::complete_md_model_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_bundle_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_bundle_member_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_group_or_option_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_group_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_dependency_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_algorithm_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_category_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_support_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_path_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_option_target_type_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}

///|
pub fn MetaDataProposalProvider::complete_md_graph_feature_rule(
  self : MetaDataProposalProvider,
) -> Unit {
  ignore(self)
}
