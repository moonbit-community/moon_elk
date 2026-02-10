///|
pub let graphviz_dot_grammar_name : String = "org.eclipse.elk.alg.graphviz.dot.GraphvizDot"

///|
pub struct GraphvizDotGrammarAccess {
  grammar : String
  rules : Map[String, String]
}

///|
pub fn new_graphviz_dot_grammar_access() -> GraphvizDotGrammarAccess {
  let rules : Map[String, String] = {}
  rules["GraphvizModel"] = "graphs+=Graph*"
  rules["Graph"] = "strict? type=GraphType name=DotID? '{' statements+=Statement* '}'"
  rules["Statement"] = "(NodeStatement|EdgeStatement|AttributeStatement|Attribute|Subgraph) ';'?"
  rules["Attribute"] = "name=DotID '=' value=DotID"
  rules["NodeStatement"] = "node=Node ('[' (attributes+=ListAttribute (','? attributes+=ListAttribute)*)? ']')?"
  rules["Node"] = "name=DotID (':' port=Port)?"
  rules["Port"] = "name=DotID (':' compass_pt=ID)?"
  rules["Subgraph"] = "'subgraph'? name=ID? '{' statements+=Statement* '}'"
  rules["EdgeStatement"] = "sourceNode=Node edgeTargets+=EdgeTarget+ ('[' (attributes+=ListAttribute (','? attributes+=ListAttribute)*)? ']')?"
  rules["EdgeTarget"] = "operator=EdgeOperator (targetSubgraph=Subgraph|targetnode=Node)"
  rules["AttributeStatement"] = "type=AttributeType '[' (attributes+=ListAttribute (','? attributes+=ListAttribute)*)? ']'"
  rules["ListAttribute"] = "name=DotID ('=' value=DotID)?"
  rules["DotID"] = "ID|INT|FLOAT|STRING|PREC_LINE"
  rules["GraphType"] = "'graph'|'digraph'"
  rules["AttributeType"] = "'graph'|'node'|'edge'"
  rules["EdgeOperator"] = "'->'|'--'"
  { grammar: graphviz_dot_grammar_name, rules }
}

///|
pub fn GraphvizDotGrammarAccess::get_grammar(
  self : GraphvizDotGrammarAccess,
) -> String {
  self.grammar
}

///|
pub fn GraphvizDotGrammarAccess::get_rule(
  self : GraphvizDotGrammarAccess,
  rule_name : String,
) -> String? {
  self.rules.get(rule_name)
}

///|
pub fn GraphvizDotGrammarAccess::get_rule_names(
  self : GraphvizDotGrammarAccess,
) -> Array[String] {
  let names : Array[String] = []
  for entry in self.rules.to_array() {
    names.push(entry.0)
  }
  names
}

///|
pub fn GraphvizDotGrammarAccess::get_graphviz_model_rule(
  self : GraphvizDotGrammarAccess,
) -> String {
  match self.get_rule("GraphvizModel") {
    Some(value) => value
    None => ""
  }
}

///|
pub fn GraphvizDotGrammarAccess::get_graph_rule(
  self : GraphvizDotGrammarAccess,
) -> String {
  match self.get_rule("Graph") {
    Some(value) => value
    None => ""
  }
}

///|
pub fn GraphvizDotGrammarAccess::get_statement_rule(
  self : GraphvizDotGrammarAccess,
) -> String {
  match self.get_rule("Statement") {
    Some(value) => value
    None => ""
  }
}

///|
pub fn GraphvizDotGrammarAccess::get_attribute_statement_rule(
  self : GraphvizDotGrammarAccess,
) -> String {
  match self.get_rule("AttributeStatement") {
    Some(value) => value
    None => ""
  }
}

///|
pub fn GraphvizDotGrammarAccess::get_edge_statement_rule(
  self : GraphvizDotGrammarAccess,
) -> String {
  match self.get_rule("EdgeStatement") {
    Some(value) => value
    None => ""
  }
}

///|
pub fn GraphvizDotGrammarAccess::get_node_statement_rule(
  self : GraphvizDotGrammarAccess,
) -> String {
  match self.get_rule("NodeStatement") {
    Some(value) => value
    None => ""
  }
}

///|
pub fn GraphvizDotGrammarAccess::get_subgraph_rule(
  self : GraphvizDotGrammarAccess,
) -> String {
  match self.get_rule("Subgraph") {
    Some(value) => value
    None => ""
  }
}
