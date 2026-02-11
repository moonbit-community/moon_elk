///|
pub struct CoreDebugGRandomAssignment {
  terminal : String
}

///|
pub fn new_core_debug_grandom_assignment(
  terminal : String,
) -> CoreDebugGRandomAssignment {
  { terminal, }
}

///|
pub struct CoreDebugGRandomContentAssistContext {
  root_model : CoreDebugGRandomRandGraph?
  current_model_index : Int?
}

///|
pub fn new_core_debug_grandom_content_assist_context(
  root_model? : CoreDebugGRandomRandGraph? = None,
  current_model_index? : Int? = None,
) -> CoreDebugGRandomContentAssistContext {
  { root_model, current_model_index }
}

///|
pub struct CoreDebugGRandomCompletionProposalAcceptor {
  proposals : Array[String]
}

///|
pub fn new_core_debug_grandom_completion_proposal_acceptor() -> CoreDebugGRandomCompletionProposalAcceptor {
  { proposals: [] }
}

///|
pub fn CoreDebugGRandomCompletionProposalAcceptor::accept(
  self : CoreDebugGRandomCompletionProposalAcceptor,
  proposal : String,
) -> Unit {
  self.proposals.push(proposal)
}

///|
pub fn CoreDebugGRandomCompletionProposalAcceptor::get_proposals(
  self : CoreDebugGRandomCompletionProposalAcceptor,
) -> Array[String] {
  self.proposals
}

///|
pub struct AbstractCoreDebugGRandomProposalProvider {
  unit : Unit
}

///|
pub fn new_abstract_core_debug_grandom_proposal_provider() -> AbstractCoreDebugGRandomProposalProvider {
  { unit: () }
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_rule_call(
  self : AbstractCoreDebugGRandomProposalProvider,
  terminal : String,
  _context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(terminal)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_keyword(
  self : AbstractCoreDebugGRandomProposalProvider,
  keyword : String,
  _context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(keyword)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_samples(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_form(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_nodes(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_edges(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_max_width(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_max_degree(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_fraction(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_hierarchy(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_seed(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_format(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_configuration_filename(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_hierarchy_levels(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_hierarchy_edges(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_nodes_n_nodes(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_edges_n_edges(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_flow_side(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractCoreDebugGRandomProposalProvider::complete_flow_amount(
  self : AbstractCoreDebugGRandomProposalProvider,
  assignment : CoreDebugGRandomAssignment,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}
