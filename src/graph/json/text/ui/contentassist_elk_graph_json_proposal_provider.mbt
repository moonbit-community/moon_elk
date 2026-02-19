///|
pub let graph_json_text_ui_max_entries : Int = 1000

///|
pub struct ElkGraphJsonUiProposalProvider {
  base : AbstractElkGraphJsonProposalProvider
  ide_provider : @ide.ElkGraphJsonIdeProposalProvider
  grammar : @text.ElkGraphJsonGrammarAccess
}

///|
pub fn new_elk_graph_json_ui_proposal_provider(
  ide_provider? : @ide.ElkGraphJsonIdeProposalProvider = @ide.new_elk_graph_json_ide_proposal_provider(),
  grammar? : @text.ElkGraphJsonGrammarAccess = @text.new_elk_graph_json_grammar_access(),
) -> ElkGraphJsonUiProposalProvider {
  {
    base: new_abstract_elk_graph_json_proposal_provider(),
    ide_provider,
    grammar,
  }
}

///|
fn graph_json_text_ui_context_to_ide_context(
  context : GraphJsonTextUiContentAssistContext,
) -> @ide.GraphJsonTextIdeContentAssistContext {
  @ide.new_graph_json_text_ide_content_assist_context(
    prefix=context.prefix,
    current_model=context.current_model,
    current_property_key=context.current_property_key,
    current_edge_section=context.current_edge_section,
    conflict_on_a=context.conflict_on_a,
  )
}

///|
pub fn ElkGraphJsonUiProposalProvider::create_assignment_proposals(
  self : ElkGraphJsonUiProposalProvider,
  assignment_key : String,
  assignment : GraphJsonTextAssignment,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  let ide_acceptor = @ide.new_graph_json_text_ide_completion_proposal_acceptor()
  self.ide_provider.create_assignment_proposals(
    assignment_key,
    assignment.terminal,
    graph_json_text_ui_context_to_ide_context(context),
    ide_acceptor,
  )

  let mut count = 0
  for entry in ide_acceptor.get_entries() {
    if count >= graph_json_text_ui_max_entries {
      break
    }
    acceptor.accept(entry.proposal)
    count += 1
  }
}

///|
pub fn ElkGraphJsonUiProposalProvider::create_keyword_proposals(
  self : ElkGraphJsonUiProposalProvider,
  keyword : String,
  context : GraphJsonTextUiContentAssistContext,
  acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  let ide_acceptor = @ide.new_graph_json_text_ide_completion_proposal_acceptor()
  self.ide_provider.create_keyword_proposals(
    keyword,
    graph_json_text_ui_context_to_ide_context(context),
    ide_acceptor,
  )
  for entry in ide_acceptor.get_entries() {
    acceptor.accept(entry.proposal)
  }
}

///|
pub fn ElkGraphJsonUiProposalProvider::complete_assignment(
  self : ElkGraphJsonUiProposalProvider,
  _object : GraphJsonTextAssignment,
  _context : GraphJsonTextUiContentAssistContext,
  _acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn ElkGraphJsonUiProposalProvider::complete_keyword(
  self : ElkGraphJsonUiProposalProvider,
  _keyword : String,
  _context : GraphJsonTextUiContentAssistContext,
  _acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn ElkGraphJsonUiProposalProvider::complete_rule_call(
  self : ElkGraphJsonUiProposalProvider,
  _rule_call : String,
  _context : GraphJsonTextUiContentAssistContext,
  _acceptor : GraphJsonTextUiCompletionProposalAcceptor,
) -> Unit {
  ignore(self)
}

///|
pub fn ElkGraphJsonUiProposalProvider::get_keyword_image(
  self : ElkGraphJsonUiProposalProvider,
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
pub fn ElkGraphJsonUiProposalProvider::get_layout_option_image(
  self : ElkGraphJsonUiProposalProvider,
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
