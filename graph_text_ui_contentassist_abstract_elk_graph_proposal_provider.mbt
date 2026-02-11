///|
pub struct GraphTextAssignment {
  terminal : String
}

///|
pub fn new_graph_text_assignment(terminal : String) -> GraphTextAssignment {
  { terminal, }
}

///|
pub struct GraphTextUiContentAssistContext {
  prefix : String
  current_model : GraphTextElement?
  current_property_key : GraphTextPropertyKey?
  current_edge_section : ElkEdgeSection?
  conflict_on_a : Bool
}

///|
pub fn new_graph_text_ui_content_assist_context(
  prefix? : String = "",
  current_model? : GraphTextElement? = None,
  current_property_key? : GraphTextPropertyKey? = None,
  current_edge_section? : ElkEdgeSection? = None,
  conflict_on_a? : Bool = false,
) -> GraphTextUiContentAssistContext {
  {
    prefix,
    current_model,
    current_property_key,
    current_edge_section,
    conflict_on_a,
  }
}

///|
pub struct GraphTextUiCompletionProposalAcceptor {
  proposals : Array[String]
}

///|
pub fn new_graph_text_ui_completion_proposal_acceptor() -> GraphTextUiCompletionProposalAcceptor {
  { proposals: [] }
}

///|
pub fn GraphTextUiCompletionProposalAcceptor::accept(
  self : GraphTextUiCompletionProposalAcceptor,
  proposal : String,
) -> Unit {
  self.proposals.push(proposal)
}

///|
pub fn GraphTextUiCompletionProposalAcceptor::get_proposals(
  self : GraphTextUiCompletionProposalAcceptor,
) -> Array[String] {
  self.proposals
}

///|
pub struct AbstractElkGraphProposalProvider {
  unit : Unit
}

///|
pub fn new_abstract_elk_graph_proposal_provider() -> AbstractElkGraphProposalProvider {
  { unit: () }
}

///|
pub fn AbstractElkGraphProposalProvider::complete_rule_call(
  self : AbstractElkGraphProposalProvider,
  terminal : String,
  _context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(terminal)
}

///|
pub fn AbstractElkGraphProposalProvider::lookup_cross_reference(
  self : AbstractElkGraphProposalProvider,
  terminal : String,
  _context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(terminal)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_root_node_identifier(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_root_node_properties(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_root_node_labels(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_root_node_ports(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_root_node_children(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_root_node_contained_edges(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_node_identifier(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_node_properties(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_node_labels(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_node_ports(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_node_children(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_node_contained_edges(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_label_identifier(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_label_text(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_label_properties(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_label_labels(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_port_identifier(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_port_properties(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_port_labels(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_shape_layout_x(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_shape_layout_y(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_shape_layout_width(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_shape_layout_height(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_identifier(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_sources(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_targets(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_properties(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_labels(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_edge_layout_sections(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_incoming_shape(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_outgoing_shape(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_start_x(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_start_y(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_end_x(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_end_y(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_bend_points(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section_properties(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_identifier(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_outgoing_sections(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_incoming_shape(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_outgoing_shape(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.lookup_cross_reference(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_start_x(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_start_y(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_end_x(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_end_y(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_bend_points(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section_properties(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_bend_point_x(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_bend_point_y(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_property_key(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_property_value(
  self : AbstractElkGraphProposalProvider,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  self.complete_rule_call(assignment.terminal, context, acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_root_node(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_node(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_label(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_port(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_shape_layout(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_edge_layout(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_single_edge_section(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_edge_section(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_elk_bend_point(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_qualified_id(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_number(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_property(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_property_key_rule(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_string_value(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_qualified_id_value(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_number_value(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_boolean_value(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_signed_int(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}

///|
pub fn AbstractElkGraphProposalProvider::complete_float(
  self : AbstractElkGraphProposalProvider,
  rule_call : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  ignore(rule_call)
  ignore(context)
  ignore(acceptor)
}
