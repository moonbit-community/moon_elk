///|
pub let graph_text_grammar_name : String = "org.eclipse.elk.graph.text.ElkGraph"

///|
pub struct ElkGraphGrammarAccess {
  grammar : String
  rules : Map[String, String]
}

///|
pub fn new_elk_graph_grammar_access() -> ElkGraphGrammarAccess {
  let rules : Map[String, String] = {}
  rules["RootNode"] = "{ElkNode} ('graph' identifier=ID)? ShapeLayout? properties+=Property* (labels+=ElkLabel | ports+=ElkPort | children+=ElkNode | containedEdges+=ElkEdge)*"
  rules["ElkNode"] = "'node' identifier=ID ('{' ShapeLayout? properties+=Property* (labels+=ElkLabel | ports+=ElkPort | children+=ElkNode | containedEdges+=ElkEdge)* '}')?"
  rules["ElkLabel"] = "'label' (identifier=ID ':')? text=STRING ('{' ShapeLayout? properties+=Property* labels+=ElkLabel* '}')?"
  rules["ElkPort"] = "'port' identifier=ID ('{' ShapeLayout? properties+=Property* labels+=ElkLabel* '}')?"
  rules["ShapeLayout"] = "'layout' '['(('position' ':' x=Number ',' y=Number)? & ('size' ':' width=Number ',' height=Number)?)']'"
  rules["ElkEdge"] = "'edge' (identifier=ID ':')? sources+=[ElkConnectableShape|QualifiedId] (',' sources+=[ElkConnectableShape|QualifiedId])* '->' targets+=[ElkConnectableShape|QualifiedId] (',' targets+=[ElkConnectableShape|QualifiedId])* ('{' EdgeLayout? properties+=Property* labels+=ElkLabel* '}')?"
  rules["EdgeLayout"] = "'layout' '['(sections+=ElkSingleEdgeSection | sections+=ElkEdgeSection+)']'"
  rules["ElkSingleEdgeSection"] = "{ElkEdgeSection} ((('incoming' ':' incomingShape=[ElkConnectableShape|QualifiedId])? & ('outgoing' ':' outgoingShape=[ElkConnectableShape|QualifiedId])? & ('start' ':' startX=Number ',' startY=Number)? & ('end' ':' endX=Number ',' endY=Number)?) ('bends' ':' bendPoints+=ElkBendPoint ('|' bendPoints+=ElkBendPoint)*)? properties+=Property*)"
  rules["ElkEdgeSection"] = "'section' identifier=ID ('->' outgoingSections+=[ElkEdgeSection|ID] (',' outgoingSections+=[ElkEdgeSection|ID])*)? '['((('incoming' ':' incomingShape=[ElkConnectableShape|QualifiedId])? & ('outgoing' ':' outgoingShape=[ElkConnectableShape|QualifiedId])? & ('start' ':' startX=Number ',' startY=Number)? & ('end' ':' endX=Number ',' endY=Number)?) ('bends' ':' bendPoints+=ElkBendPoint ('|' bendPoints+=ElkBendPoint)*)? properties+=Property*)']'"
  rules["ElkBendPoint"] = "x=Number ',' y=Number"
  rules["QualifiedId"] = "ID ('.' ID)*"
  rules["Number"] = "SIGNED_INT | FLOAT"
  rules["Property"] = "key=PropertyKey ':' (value=StringValue | value=QualifiedIdValue | value=NumberValue | value=BooleanValue | 'null')"
  rules["PropertyKey"] = "ID ('.' ID)*"
  rules["StringValue"] = "STRING"
  rules["QualifiedIdValue"] = "QualifiedId"
  rules["NumberValue"] = "SIGNED_INT | FLOAT"
  rules["BooleanValue"] = "'true' | 'false'"
  { grammar: graph_text_grammar_name, rules }
}

///|
pub fn ElkGraphGrammarAccess::get_grammar(
  self : ElkGraphGrammarAccess,
) -> String {
  self.grammar
}

///|
pub fn ElkGraphGrammarAccess::get_rule(
  self : ElkGraphGrammarAccess,
  rule_name : String,
) -> String? {
  self.rules.get(rule_name)
}

///|
pub fn ElkGraphGrammarAccess::get_rule_names(
  self : ElkGraphGrammarAccess,
) -> Array[String] {
  let names : Array[String] = []
  for entry in self.rules.to_array() {
    names.push(entry.0)
  }
  names
}

///|
fn graph_text_grammar_access_rule(
  grammar_access : ElkGraphGrammarAccess,
  rule_name : String,
) -> String {
  match grammar_access.get_rule(rule_name) {
    Some(value) => value
    None => ""
  }
}

///|
pub fn ElkGraphGrammarAccess::get_root_node_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "RootNode")
}

///|
pub fn ElkGraphGrammarAccess::get_elk_node_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ElkNode")
}

///|
pub fn ElkGraphGrammarAccess::get_elk_label_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ElkLabel")
}

///|
pub fn ElkGraphGrammarAccess::get_elk_port_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ElkPort")
}

///|
pub fn ElkGraphGrammarAccess::get_shape_layout_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ShapeLayout")
}

///|
pub fn ElkGraphGrammarAccess::get_elk_edge_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ElkEdge")
}

///|
pub fn ElkGraphGrammarAccess::get_edge_layout_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "EdgeLayout")
}

///|
pub fn ElkGraphGrammarAccess::get_elk_single_edge_section_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ElkSingleEdgeSection")
}

///|
pub fn ElkGraphGrammarAccess::get_elk_edge_section_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ElkEdgeSection")
}

///|
pub fn ElkGraphGrammarAccess::get_elk_bend_point_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "ElkBendPoint")
}

///|
pub fn ElkGraphGrammarAccess::get_qualified_id_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "QualifiedId")
}

///|
pub fn ElkGraphGrammarAccess::get_number_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "Number")
}

///|
pub fn ElkGraphGrammarAccess::get_property_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "Property")
}

///|
pub fn ElkGraphGrammarAccess::get_property_key_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "PropertyKey")
}

///|
pub fn ElkGraphGrammarAccess::get_string_value_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "StringValue")
}

///|
pub fn ElkGraphGrammarAccess::get_qualified_id_value_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "QualifiedIdValue")
}

///|
pub fn ElkGraphGrammarAccess::get_number_value_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "NumberValue")
}

///|
pub fn ElkGraphGrammarAccess::get_boolean_value_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  graph_text_grammar_access_rule(self, "BooleanValue")
}

///|
pub fn ElkGraphGrammarAccess::get_id_rule(
  self : ElkGraphGrammarAccess,
) -> String {
  ignore(self)
  "ID"
}
