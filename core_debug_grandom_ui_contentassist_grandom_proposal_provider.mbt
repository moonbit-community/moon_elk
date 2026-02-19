///|
fn core_debug_grandom_proposal_doc(
  default_text : String,
  default_value : String,
) -> String {
  default_text + " (Default: " + default_value + ")"
}

///|
fn core_debug_grandom_proposal_number_of(subject : String) -> String {
  "Number of " + subject
}

///|
fn core_debug_grandom_proposal_optional_block(text : String) -> String {
  text + " With extra options in own block, i.e. {...}."
}

///|
fn core_debug_grandom_proposal_relative(text : String) -> String {
  text + ". Relative to other given numbers."
}

///|
let core_debug_grandom_keyword_documentation : Ref[Map[String, String]] = Ref::new({
    "nodes": core_debug_grandom_proposal_doc(
      core_debug_grandom_proposal_number_of("nodes"),
      "30",
    ),
    "edges": core_debug_grandom_proposal_doc(
      core_debug_grandom_proposal_number_of("edges"),
      "total",
    ),
    "density": core_debug_grandom_proposal_optional_block(
      "Fraction of number of nodes squared.",
    ),
    "relative": core_debug_grandom_proposal_optional_block(
      "Relative to number of nodes.",
    ),
    "outgoing": core_debug_grandom_proposal_optional_block(
      "Number of outgoing edges per node.",
    ),
    "total": core_debug_grandom_proposal_doc(
      "Total number of edges in graph.", "20",
    ),
    "labels": "Add labels.",
    "self loops": "Allow edges with equal source and target.",
    "filename": core_debug_grandom_proposal_doc("Name + index.", "\"random\""),
    "format": core_debug_grandom_proposal_doc("Textual or xml.", "elkt"),
    "maxDegree": "Maximum Degree (trees)",
    "maxWidth": "Maximum Width (trees)",
    "partitionFraction": "Minimal fraction of nodes in second partition set (bipartite).",
    "seed": "Random seed.",
    "size": core_debug_grandom_proposal_optional_block("size"),
    "ports": core_debug_grandom_proposal_optional_block("ports"),
    "constraint": core_debug_grandom_proposal_doc(
      "set port constraints", "free",
    ),
    "incoming": core_debug_grandom_proposal_relative(
      core_debug_grandom_proposal_number_of("incoming ports"),
    ),
    "north": core_debug_grandom_proposal_relative(
      core_debug_grandom_proposal_number_of("north ports"),
    ),
    "east": core_debug_grandom_proposal_relative(
      core_debug_grandom_proposal_number_of("east ports"),
    ),
    "south": core_debug_grandom_proposal_relative(
      core_debug_grandom_proposal_number_of("south ports"),
    ),
    "west": core_debug_grandom_proposal_relative(
      core_debug_grandom_proposal_number_of("west ports"),
    ),
    "re-use": "Fraction of edges with same source or target port.",
    "+/-": "Gaussian distribution: Mean +/- Standard deviation.",
    "to": "Equal distribution: Min to max value.",
  },
)

///|
fn core_debug_grandom_proposal_find_config(
  context : CoreDebugGRandomContentAssistContext,
) -> CoreDebugGRandomConfiguration? {
  let root = match context.root_model {
    Some(value) => value
    None => return None
  }
  let current_index = match context.current_model_index {
    Some(value) => value
    None => return None
  }
  if current_index < 0 || current_index >= root.configs.length() {
    return None
  }
  Some(root.configs[current_index])
}

///|
fn core_debug_grandom_proposal_forbidden_by_form(
  keyword : String,
  configuration : CoreDebugGRandomConfiguration?,
) -> Bool {
  let config = match configuration {
    Some(value) => value
    None => return false
  }
  let form_is_trees = match config.form {
    FormTrees => true
    _ => false
  }
  let form_is_bipartite = match config.form {
    FormBipartite => true
    _ => false
  }
  if keyword == "maxWidth" || keyword == "maxDegree" {
    return !form_is_trees
  }
  if keyword == "partitionFraction" {
    return !form_is_bipartite
  }
  false
}

///|
pub struct CoreDebugGRandomProposalProvider {
  base : AbstractCoreDebugGRandomProposalProvider
}

///|
pub fn new_core_debug_grandom_proposal_provider() -> CoreDebugGRandomProposalProvider {
  { base: new_abstract_core_debug_grandom_proposal_provider() }
}

///|
pub fn CoreDebugGRandomProposalProvider::get_keyword_display_string(
  self : CoreDebugGRandomProposalProvider,
  keyword : String,
) -> String {
  ignore(self)
  match core_debug_grandom_keyword_documentation.val.get(keyword) {
    Some(doc) => keyword + ": " + doc
    None => keyword
  }
}

///|
pub fn CoreDebugGRandomProposalProvider::complete_keyword(
  self : CoreDebugGRandomProposalProvider,
  keyword : String,
  context : CoreDebugGRandomContentAssistContext,
  acceptor : CoreDebugGRandomCompletionProposalAcceptor,
) -> Unit {
  let configuration = core_debug_grandom_proposal_find_config(context)
  if core_debug_grandom_proposal_forbidden_by_form(keyword, configuration) {
    return
  }
  self.base.complete_keyword(keyword, context, acceptor)
}
