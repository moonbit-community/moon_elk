///|
pub struct GraphJsonTextAssignment {
  terminal : String
}

///|
pub fn new_graph_json_text_assignment(
  terminal : String,
) -> GraphJsonTextAssignment {
  { terminal, }
}

///|
pub struct GraphJsonTextUiContentAssistContext {
  prefix : String
  current_model : GraphJsonTextElement?
  current_property_key : GraphJsonTextPropertyKey?
  current_edge_section : ElkEdgeSection?
  conflict_on_a : Bool
}

///|
pub fn new_graph_json_text_ui_content_assist_context(
  prefix? : String = "",
  current_model? : GraphJsonTextElement? = None,
  current_property_key? : GraphJsonTextPropertyKey? = None,
  current_edge_section? : ElkEdgeSection? = None,
  conflict_on_a? : Bool = false,
) -> GraphJsonTextUiContentAssistContext {
  {
    prefix,
    current_model,
    current_property_key,
    current_edge_section,
    conflict_on_a,
  }
}

///|
pub struct GraphJsonTextUiCompletionProposalAcceptor {
  proposals : Array[String]
}

///|
pub fn new_graph_json_text_ui_completion_proposal_acceptor() -> GraphJsonTextUiCompletionProposalAcceptor {
  { proposals: [] }
}

///|
pub fn GraphJsonTextUiCompletionProposalAcceptor::accept(
  self : GraphJsonTextUiCompletionProposalAcceptor,
  proposal : String,
) -> Unit {
  self.proposals.push(proposal)
}

///|
pub fn GraphJsonTextUiCompletionProposalAcceptor::get_proposals(
  self : GraphJsonTextUiCompletionProposalAcceptor,
) -> Array[String] {
  self.proposals
}

///|
pub struct AbstractElkGraphJsonProposalProvider {
  unit : Unit
}

///|
pub fn new_abstract_elk_graph_json_proposal_provider() -> AbstractElkGraphJsonProposalProvider {
  { unit: () }
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_rule_call(
  self : AbstractElkGraphJsonProposalProvider,
  terminal : String,
  _context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(terminal)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::lookup_cross_reference(
  self : AbstractElkGraphJsonProposalProvider,
  terminal : String,
  _context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(terminal)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_root_node_identifier(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_root_node_properties(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_root_node_labels(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_root_node_ports(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_root_node_children(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_root_node_contained_edges(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_node_identifier(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_node_properties(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_node_labels(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_node_ports(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_node_children(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_node_contained_edges(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_label_identifier(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_label_text(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_label_properties(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_label_labels(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_port_identifier(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_port_properties(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_port_labels(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_shape_layout_x(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_shape_layout_y(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_shape_layout_width(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_shape_layout_height(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_identifier(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_sources(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_targets(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_properties(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_labels(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_edge_layout_sections(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_incoming_shape(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_outgoing_shape(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_start_x(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_start_y(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_end_x(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_end_y(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_bend_points(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section_properties(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_identifier(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_outgoing_sections(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_incoming_shape(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_outgoing_shape(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_start_x(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_start_y(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_end_x(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_end_y(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_bend_points(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section_properties(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_bend_point_x(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_bend_point_y(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_property_key(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_property_value(
  self : AbstractElkGraphJsonProposalProvider,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_root_node(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_node(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_label(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_port(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_shape_layout(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_edge_layout(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_single_edge_section(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_edge_section(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_elk_bend_point(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_qualified_id(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_number(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_property(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_property_key_rule(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_string_value(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_qualified_id_value(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_number_value(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_boolean_value(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_signed_int(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphJsonProposalProvider::complete_float(
  self : AbstractElkGraphJsonProposalProvider,
  rule_call : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}
