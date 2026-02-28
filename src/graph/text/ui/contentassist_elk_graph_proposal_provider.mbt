///|
pub let graph_text_ui_max_entries : Int = 1000

///|
pub struct ElkGraphUiProposalProvider {
  base : AbstractElkGraphProposalProvider
  ide_provider : @ide.ElkGraphIdeProposalProvider
  grammar : @text.ElkGraphGrammarAccess
}

///|
pub fn new_elk_graph_ui_proposal_provider(
  ide_provider? : @ide.ElkGraphIdeProposalProvider = @ide.new_elk_graph_ide_proposal_provider(),
  grammar? : @text.ElkGraphGrammarAccess = @text.new_elk_graph_grammar_access(),
) -> ElkGraphUiProposalProvider {
  { base: new_abstract_elk_graph_proposal_provider(), ide_provider, grammar }
}

///|
fn graph_text_ui_context_to_ide_context(
  context : GraphTextUiContentAssistContext,
) -> @ide.GraphTextIdeContentAssistContext {
  @ide.new_graph_text_ide_content_assist_context(
    prefix=context.prefix,
    current_model=context.current_model,
    current_property_key=context.current_property_key,
    current_edge_section=context.current_edge_section,
    conflict_on_a=context.conflict_on_a,
  )
}

///|
pub fn ElkGraphUiProposalProvider::create_assignment_proposals(
  self : ElkGraphUiProposalProvider,
  assignment_key : String,
  assignment : GraphTextAssignment,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  let ide_acceptor = @ide.new_graph_text_ide_completion_proposal_acceptor()
  self.ide_provider.create_assignment_proposals(
    assignment_key,
    assignment.terminal,
    graph_text_ui_context_to_ide_context(context),
    ide_acceptor,
  )

  let mut count = 0
  for entry in ide_acceptor.get_entries() {
    if count >= graph_text_ui_max_entries {
      break
    }
    acceptor.accept(entry.proposal)
    count += 1
  }
}

///|
pub fn ElkGraphUiProposalProvider::create_keyword_proposals(
  self : ElkGraphUiProposalProvider,
  keyword : String,
  context : GraphTextUiContentAssistContext,
  acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  let ide_acceptor = @ide.new_graph_text_ide_completion_proposal_acceptor()
  self.ide_provider.create_keyword_proposals(
    keyword,
    graph_text_ui_context_to_ide_context(context),
    ide_acceptor,
  )
  for entry in ide_acceptor.get_entries() {
    acceptor.accept(entry.proposal)
  }
}

///|
pub fn ElkGraphUiProposalProvider::complete_assignment(
  self : ElkGraphUiProposalProvider,
  _object : GraphTextAssignment,
  _context : GraphTextUiContentAssistContext,
  _acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn ElkGraphUiProposalProvider::complete_keyword(
  self : ElkGraphUiProposalProvider,
  _keyword : String,
  _context : GraphTextUiContentAssistContext,
  _acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn ElkGraphUiProposalProvider::complete_rule_call(
  self : ElkGraphUiProposalProvider,
  _rule_call : String,
  _context : GraphTextUiContentAssistContext,
  _acceptor : GraphTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn ElkGraphUiProposalProvider::get_keyword_image(
  self : ElkGraphUiProposalProvider,
  keyword : String,
) -> String? {
  ignore(self.base)
  ignore(self.grammar)
  if keyword == "graph" {
    return Some("elkgraph.gif")
  }
  if keyword == "node" {
    return Some("elknode.gif")
  }
  if keyword == "edge" {
    return Some("elkedge.gif")
  }
  if keyword == "port" {
    return Some("elkport.gif")
  }
  if keyword == "label" {
    return Some("elklabel.gif")
  }
  None
}

///|
pub fn ElkGraphUiProposalProvider::get_layout_option_image(
  self : ElkGraphUiProposalProvider,
  option : @core.LayoutOptionData,
  value : String,
) -> String {
  ignore(self)
  let key = match option.get_type() {
    @core.BoolType => if value == "false" { "prop_false" } else { "prop_true" }
    @core.IntType => "prop_int"
    @core.DoubleType => "prop_double"
    @core.EnumSetType => "prop_choice"
    _ => "prop_text"
  }
  key + ".gif"
}
