///|
pub let graph_json_text_grammar_name : String = "org.eclipse.elk.graph.json.text.ElkGraphJson"

///|
pub struct ElkGraphJsonGrammarAccess {
  grammar : String
  rules : Map[String, String]
}

///|
pub fn new_elk_graph_json_grammar_access() -> ElkGraphJsonGrammarAccess {
  let rules : Map[String, String] = {}
  rules["RootNode"] = "{ElkNode} ('graph' identifier=ID)? ShapeLayout? properties+=Property* (labels+=ElkLabel | ports+=ElkPort | children+=ElkNode | containedEdges+=ElkEdge)*"
  rules["JsonObject"] = "'{' (members+=JsonMember (',' members+=JsonMember)*)? '}'"
  rules["JsonMember"] = "key=STRING ':' value=JsonValue"
  rules["JsonValue"] = "JsonObject | JsonArray | STRING | Number | 'true' | 'false' | 'null'"
  rules["JsonArray"] = "'[' (values+=JsonValue (',' values+=JsonValue)*)? ']'"
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
  { grammar: graph_json_text_grammar_name, rules }
}

///|
pub fn ElkGraphJsonGrammarAccess::get_grammar(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  self.grammar
}

///|
pub fn ElkGraphJsonGrammarAccess::get_rule(
  self : ElkGraphJsonGrammarAccess,
  rule_name : String,
) -> String? {
  self.rules.get(rule_name)
}

///|
pub fn ElkGraphJsonGrammarAccess::get_rule_names(
  self : ElkGraphJsonGrammarAccess,
) -> Array[String] {
  let names : Array[String] = []
  for entry in self.rules.to_array() {
    names.push(entry.0)
  }
  names
}

///|
fn graph_json_text_grammar_access_rule(
  grammar_access : ElkGraphJsonGrammarAccess,
  rule_name : String,
) -> String {
  match grammar_access.get_rule(rule_name) {
    Some(value) => value
    None => ""
  }
}

///|
pub fn ElkGraphJsonGrammarAccess::get_root_node_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "RootNode")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_json_object_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "JsonObject")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_elk_node_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ElkNode")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_elk_label_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ElkLabel")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_elk_port_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ElkPort")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_shape_layout_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ShapeLayout")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_elk_edge_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ElkEdge")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_edge_layout_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "EdgeLayout")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_elk_single_edge_section_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ElkSingleEdgeSection")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_elk_edge_section_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ElkEdgeSection")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_elk_bend_point_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "ElkBendPoint")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_qualified_id_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "QualifiedId")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_number_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "Number")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_property_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "Property")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_property_key_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "PropertyKey")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_string_value_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "StringValue")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_qualified_id_value_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "QualifiedIdValue")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_number_value_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "NumberValue")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_boolean_value_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  graph_json_text_grammar_access_rule(self, "BooleanValue")
}

///|
pub fn ElkGraphJsonGrammarAccess::get_id_rule(
  self : ElkGraphJsonGrammarAccess,
) -> String {
  ignore(self)
  "ID"
}
