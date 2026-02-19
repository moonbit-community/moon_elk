///|
pub let graph_text_disco_layout_alg_id : String = "org.eclipse.elk.disco.componentCompaction.componentLayoutAlgorithm"

///|
fn graph_text_disabled_keyword(keyword : String) -> Bool {
  keyword == "}" || keyword == "]"
}

///|
pub struct GraphTextIdeContentAssistEntry {
  proposal : String
  prefix : String
  kind : String
  label : String?
  description : String?
  documentation : String?
  source : String?
}

///|
pub fn new_graph_text_ide_content_assist_entry(
  proposal : String,
  prefix : String,
  kind : String,
  label? : String? = None,
  description? : String? = None,
  documentation? : String? = None,
  source? : String? = None,
) -> GraphTextIdeContentAssistEntry {
  { proposal, prefix, kind, label, description, documentation, source }
}

///|
pub struct GraphTextIdeCompletionProposalAcceptor {
  entries : Array[GraphTextIdeContentAssistEntry]
}

///|
pub fn new_graph_text_ide_completion_proposal_acceptor() -> GraphTextIdeCompletionProposalAcceptor {
  { entries: [] }
}

///|
pub fn GraphTextIdeCompletionProposalAcceptor::accept(
  self : GraphTextIdeCompletionProposalAcceptor,
  entry : GraphTextIdeContentAssistEntry,
) -> Unit {
  self.entries.push(entry)
}

///|
pub fn GraphTextIdeCompletionProposalAcceptor::get_entries(
  self : GraphTextIdeCompletionProposalAcceptor,
) -> Array[GraphTextIdeContentAssistEntry] {
  self.entries
}

///|
pub fn GraphTextIdeCompletionProposalAcceptor::get_proposals(
  self : GraphTextIdeCompletionProposalAcceptor,
) -> Array[String] {
  let result : Array[String] = []
  for entry in self.entries {
    result.push(entry.proposal)
  }
  result
}

///|
pub struct GraphTextIdeContentAssistContext {
  prefix : String
  current_model : @text.GraphTextElement?
  current_property_key : @text.GraphTextPropertyKey?
  current_edge_section : @graph.ElkEdgeSection?
  conflict_on_a : Bool
}

///|
pub fn new_graph_text_ide_content_assist_context(
  prefix? : String = "",
  current_model? : @text.GraphTextElement? = None,
  current_property_key? : @text.GraphTextPropertyKey? = None,
  current_edge_section? : @graph.ElkEdgeSection? = None,
  conflict_on_a? : Bool = false,
) -> GraphTextIdeContentAssistContext {
  {
    prefix,
    current_model,
    current_property_key,
    current_edge_section,
    conflict_on_a,
  }
}

///|
fn graph_text_ide_option_description(
  option_data : @core.LayoutOptionData,
) -> String {
  option_data.get_name() + " (" + option_data.get_id() + ")"
}

///|
fn graph_text_ide_algorithm_description(
  algorithm_data : @core.LayoutAlgorithmData,
) -> String {
  algorithm_data.get_name() + " (" + algorithm_data.get_id() + ")"
}

///|
fn graph_text_ide_layout_option_proposals_for_element(
  element : @text.GraphTextElement,
  prefix : String,
) -> Array[@core.LayoutDataProposal[@core.LayoutOptionData]] {
  match element {
    GraphNode(node) =>
      @core.layout_data_content_assist_get_layout_option_proposals(node, prefix)
    GraphEdge(edge) =>
      @core.layout_data_content_assist_get_layout_option_proposals_for_edge(
        edge, prefix,
      )
    GraphPort(port) =>
      @core.layout_data_content_assist_get_layout_option_proposals_for_port(
        port, prefix,
      )
    GraphLabel(label) =>
      @core.layout_data_content_assist_get_layout_option_proposals_for_label(
        label, prefix,
      )
  }
}

///|
fn graph_text_ide_shape_equals(
  left : @graph.ElkConnectableShape,
  right : @graph.ElkConnectableShape,
) -> Bool {
  match (left, right) {
    (NodeShape(left_node), NodeShape(right_node)) => left_node == right_node
    (PortShape(left_port), PortShape(right_port)) => left_port == right_port
    _ => false
  }
}

///|
fn graph_text_ide_shape_in_list(
  shape : @graph.ElkConnectableShape,
  values : Array[@graph.ElkConnectableShape],
) -> Bool {
  for value in values {
    if graph_text_ide_shape_equals(shape, value) {
      return true
    }
  }
  false
}

///|
fn graph_text_ide_find_parent_edge(
  section : @graph.ElkEdgeSection,
) -> @graph.ElkEdge? {
  for edge in @graph.all_edges() {
    for existing in @graph.edge_sections(edge) {
      if existing == section {
        return Some(edge)
      }
    }
  }
  None
}

///|
pub struct ElkGraphIdeProposalProvider {
  grammar : @text.ElkGraphGrammarAccess
}

///|
pub fn new_elk_graph_ide_proposal_provider(
  grammar? : @text.ElkGraphGrammarAccess = @text.new_elk_graph_grammar_access(),
) -> ElkGraphIdeProposalProvider {
  { grammar, }
}

///|
pub fn ElkGraphIdeProposalProvider::filter_keyword(
  self : ElkGraphIdeProposalProvider,
  keyword : String,
  context : GraphTextIdeContentAssistContext,
) -> Bool {
  ignore(self)
  !graph_text_disabled_keyword(keyword) && keyword != context.prefix
}

///|
pub fn ElkGraphIdeProposalProvider::create_keyword_proposals(
  self : ElkGraphIdeProposalProvider,
  keyword : String,
  context : GraphTextIdeContentAssistContext,
  acceptor : GraphTextIdeCompletionProposalAcceptor,
) -> Unit {
  if !self.filter_keyword(keyword, context) {
    return
  }
  acceptor.accept(
    new_graph_text_ide_content_assist_entry(
      keyword,
      context.prefix,
      "keyword",
      label=Some(keyword),
      source=Some("keyword"),
    ),
  )
}

///|
pub fn ElkGraphIdeProposalProvider::complete_rule_call(
  self : ElkGraphIdeProposalProvider,
  terminal : String,
  context : GraphTextIdeContentAssistContext,
  acceptor : GraphTextIdeCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(
    new_graph_text_ide_content_assist_entry(
      terminal,
      context.prefix,
      "rule",
      label=Some(terminal),
      source=Some("rule"),
    ),
  )
}

///|
pub fn ElkGraphIdeProposalProvider::lookup_cross_reference(
  self : ElkGraphIdeProposalProvider,
  terminal : String,
  context : GraphTextIdeContentAssistContext,
  acceptor : GraphTextIdeCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  acceptor.accept(
    new_graph_text_ide_content_assist_entry(
      terminal,
      context.prefix,
      "crossref",
      label=Some(terminal),
      source=Some("crossref"),
    ),
  )
}

///|
pub fn ElkGraphIdeProposalProvider::complete_property_key(
  self : ElkGraphIdeProposalProvider,
  context : GraphTextIdeContentAssistContext,
  acceptor : GraphTextIdeCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  if context.conflict_on_a {
    return
  }
  let model = match context.current_model {
    Some(value) => value
    None => return
  }
  for
    proposal in graph_text_ide_layout_option_proposals_for_element(
      model,
      context.prefix,
    ) {
    let option_data = proposal.get_data()
    let label = match proposal.get_label() {
      Some(value) => value
      None => proposal.get_proposal()
    }
    acceptor.accept(
      new_graph_text_ide_content_assist_entry(
        proposal.get_proposal(),
        context.prefix,
        "property",
        label=Some(label),
        description=Some(graph_text_ide_option_description(option_data)),
        documentation=Some(option_data.get_description()),
        source=Some(option_data.get_id()),
      ),
    )
  }
}

///|
fn graph_text_ide_push_value_entry(
  acceptor : GraphTextIdeCompletionProposalAcceptor,
  context : GraphTextIdeContentAssistContext,
  proposal : String,
  description? : String? = None,
) -> Unit {
  acceptor.accept(
    new_graph_text_ide_content_assist_entry(
      proposal,
      context.prefix,
      "value",
      label=Some(proposal),
      description~,
      source=Some("value"),
    ),
  )
}

///|
pub fn ElkGraphIdeProposalProvider::propose_algorithms(
  self : ElkGraphIdeProposalProvider,
  context : GraphTextIdeContentAssistContext,
  acceptor : GraphTextIdeCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
  if context.conflict_on_a {
    return
  }
  for
    proposal in @core.layout_data_content_assist_get_layout_algorithm_proposals(
      context.prefix,
    ) {
    let algorithm_data = proposal.get_data()
    let label = match proposal.get_label() {
      Some(value) => value
      None => proposal.get_proposal()
    }
    acceptor.accept(
      new_graph_text_ide_content_assist_entry(
        proposal.get_proposal(),
        context.prefix,
        "value",
        label=Some(label),
        description=Some(graph_text_ide_algorithm_description(algorithm_data)),
        documentation=Some(algorithm_data.get_description()),
        source=Some(algorithm_data.get_id()),
      ),
    )
  }
}

///|
pub fn ElkGraphIdeProposalProvider::complete_property_value(
  self : ElkGraphIdeProposalProvider,
  context : GraphTextIdeContentAssistContext,
  acceptor : GraphTextIdeCompletionProposalAcceptor,
) -> Unit {
  let property_key = match context.current_property_key {
    Some(value) => value
    None => return
  }
  match property_key {
    LayoutOption(option_data) => {
      if option_data.get_id() == @core.algorithm.get_id() ||
        option_data.get_id() == graph_text_disco_layout_alg_id {
        self.propose_algorithms(context, acceptor)
        return
      }
      match option_data.get_type() {
        BoolType => {
          graph_text_ide_push_value_entry(acceptor, context, "true")
          graph_text_ide_push_value_entry(acceptor, context, "false")
        }
        IntType =>
          for choice in option_data.get_choices() {
            graph_text_ide_push_value_entry(acceptor, context, choice)
          }
        DoubleType =>
          for choice in option_data.get_choices() {
            graph_text_ide_push_value_entry(acceptor, context, choice)
          }
        EnumSetType =>
          for choice in option_data.get_choices() {
            graph_text_ide_push_value_entry(acceptor, context, choice)
          }
        _ =>
          for choice in option_data.get_choices() {
            graph_text_ide_push_value_entry(acceptor, context, choice)
          }
      }
    }
    CustomProperty(_) => ()
  }
}

///|
pub fn ElkGraphIdeProposalProvider::create_assignment_proposals(
  self : ElkGraphIdeProposalProvider,
  assignment_key : String,
  terminal : String,
  context : GraphTextIdeContentAssistContext,
  acceptor : GraphTextIdeCompletionProposalAcceptor,
) -> Unit {
  ignore(self.grammar)
  if assignment_key == "Property.KeyAssignment_0" {
    self.complete_property_key(context, acceptor)
    return
  }
  if assignment_key == "Property.ValueAssignment_2_0" ||
    assignment_key == "Property.ValueAssignment_2_1" ||
    assignment_key == "Property.ValueAssignment_2_2" ||
    assignment_key == "Property.ValueAssignment_2_3" {
    self.complete_property_value(context, acceptor)
    return
  }
  self.complete_rule_call(terminal, context, acceptor)
}

///|
pub fn ElkGraphIdeProposalProvider::filter_cross_reference_candidates(
  self : ElkGraphIdeProposalProvider,
  reference_key : String,
  context : GraphTextIdeContentAssistContext,
  candidates : Array[@graph.ElkConnectableShape],
) -> Array[@graph.ElkConnectableShape] {
  ignore(self)
  let section = match context.current_edge_section {
    Some(value) => value
    None => return candidates
  }
  let edge = match graph_text_ide_find_parent_edge(section) {
    Some(value) => value
    None => return candidates
  }
  let allowed = if reference_key == "ElkEdgeSection.IncomingShape" ||
    reference_key == "ElkSingleEdgeSection.IncomingShape" {
    @graph.edge_sources(edge)
  } else if reference_key == "ElkEdgeSection.OutgoingShape" ||
    reference_key == "ElkSingleEdgeSection.OutgoingShape" {
    @graph.edge_targets(edge)
  } else {
    return candidates
  }

  let result : Array[@graph.ElkConnectableShape] = []
  for candidate in candidates {
    if graph_text_ide_shape_in_list(candidate, allowed) {
      result.push(candidate)
    }
  }
  result
}
