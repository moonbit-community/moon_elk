///|
pub let core_debug_grandom_ide_grammar_name : String = "org.eclipse.elk.core.debug.grandom.GRandom"

///|
pub struct CoreDebugGRandomIdeGrammarAccess {
  grammar : String
  rules : Map[String, String]
}

///|
pub fn new_core_debug_grandom_ide_grammar_access() -> CoreDebugGRandomIdeGrammarAccess {
  let rules : Map[String, String] = {}
  rules["RandGraph"] = "configs+=Configuration*"
  rules["Configuration"] = "'generate' '{' ... '}'"
  rules["Hierarchy"] = "'hierarchy' '{' ... '}'"
  rules["Form"] = "'trees' | 'graphs' | 'bipartite graphs' | 'biconnected graphs' | 'triconnected graphs' | 'acyclic graphs'"
  rules["Edges"] = "'edges' (DoubleQuantity | '{' ... '}')"
  rules["Nodes"] = "'nodes' (DoubleQuantity | '{' ... '}')"
  rules["Size"] = "'size' '{' ... '}'"
  rules["Ports"] = "'ports' '{' ... '}'"
  rules["Flow"] = "FlowType Side? '=' DoubleQuantity"
  rules["Side"] = "'north' | 'east' | 'south' | 'west'"
  rules["FlowType"] = "'incoming' | 'outgoing'"
  rules["ConstraintType"] = "'free' | 'side' | 'position' | 'order' | 'ratio'"
  rules["Labels"] = "'labels'"
  rules["DoubleQuantity"] = "Double | Double 'to' Double | Double '+/-' Double"
  rules["Pm"] = "'+/-'"
  rules["Double"] = "Integer ('.' Integer)?"
  rules["Float"] = "Integer '.' Integer"
  rules["Integer"] = "RULE_INT"
  rules["Formats"] = "'elkt' | 'elkg'"
  { grammar: core_debug_grandom_ide_grammar_name, rules }
}

///|
pub fn CoreDebugGRandomIdeGrammarAccess::get_grammar(
  self : CoreDebugGRandomIdeGrammarAccess,
) -> String {
  self.grammar
}

///|
pub fn CoreDebugGRandomIdeGrammarAccess::get_rule(
  self : CoreDebugGRandomIdeGrammarAccess,
  rule_name : String,
) -> String? {
  self.rules.get(rule_name)
}

///|
pub fn CoreDebugGRandomIdeGrammarAccess::get_rule_names(
  self : CoreDebugGRandomIdeGrammarAccess,
) -> Array[String] {
  let names : Array[String] = []
  for pair in self.rules.to_array() {
    names.push(pair.0)
  }
  names
}

///|
pub struct CoreDebugGRandomNameMappings {
  mappings : Map[String, String]
}

///|
pub fn new_core_debug_grandom_name_mappings(
  grammar_access : CoreDebugGRandomIdeGrammarAccess,
) -> CoreDebugGRandomNameMappings {
  ignore(grammar_access)
  let mappings : Map[String, String] = {}
  mappings["Edges.Alternatives_0_1"] = "rule__Edges__Alternatives_0_1"
  mappings["DoubleQuantity.Alternatives"] = "rule__DoubleQuantity__Alternatives"
  mappings["Formats.Alternatives"] = "rule__Formats__Alternatives"
  mappings["Form.Alternatives"] = "rule__Form__Alternatives"
  mappings["Side.Alternatives"] = "rule__Side__Alternatives"
  mappings["FlowType.Alternatives"] = "rule__FlowType__Alternatives"
  mappings["ConstraintType.Alternatives"] = "rule__ConstraintType__Alternatives"
  mappings["Configuration.Group"] = "rule__Configuration__Group__0"
  mappings["Configuration.Group_3"] = "rule__Configuration__Group_3__0"
  mappings["Hierarchy.Group"] = "rule__Hierarchy__Group__0"
  mappings["Edges.Group"] = "rule__Edges__Group__0"
  mappings["Nodes.Group"] = "rule__Nodes__Group__0"
  mappings["Size.Group"] = "rule__Size__Group__0"
  mappings["Ports.Group"] = "rule__Ports__Group__0"
  mappings["Flow.Group"] = "rule__Flow__Group__0"
  mappings["Double.Group"] = "rule__Double__Group__0"
  mappings["Float.Group"] = "rule__Float__Group__0"
  mappings["Integer.Group"] = "rule__Integer__Group__0"
  mappings["RandGraph.ConfigsAssignment"] = "rule__RandGraph__ConfigsAssignment"
  mappings["Configuration.SamplesAssignment_1"] = "rule__Configuration__SamplesAssignment_1"
  mappings["Configuration.FormAssignment_2"] = "rule__Configuration__FormAssignment_2"
  mappings["Configuration.NodesAssignment_3_1_0"] = "rule__Configuration__NodesAssignment_3_1_0"
  mappings["Configuration.EdgesAssignment_3_1_1"] = "rule__Configuration__EdgesAssignment_3_1_1"
  mappings["Configuration.MaxWidthAssignment_3_1_2_2"] = "rule__Configuration__MaxWidthAssignment_3_1_2_2"
  mappings["Configuration.MaxDegreeAssignment_3_1_3_2"] = "rule__Configuration__MaxDegreeAssignment_3_1_3_2"
  mappings["Configuration.FractionAssignment_3_1_4_2"] = "rule__Configuration__FractionAssignment_3_1_4_2"
  mappings["Configuration.HierarchyAssignment_3_1_5"] = "rule__Configuration__HierarchyAssignment_3_1_5"
  mappings["Configuration.SeedAssignment_3_1_6_2"] = "rule__Configuration__SeedAssignment_3_1_6_2"
  mappings["Configuration.FormatAssignment_3_1_7_2"] = "rule__Configuration__FormatAssignment_3_1_7_2"
  mappings["Configuration.FilenameAssignment_3_1_8_2"] = "rule__Configuration__FilenameAssignment_3_1_8_2"
  mappings["Hierarchy.LevelsAssignment_2_1_0_2"] = "rule__Hierarchy__LevelsAssignment_2_1_0_2"
  mappings["Hierarchy.EdgesAssignment_2_1_1_2"] = "rule__Hierarchy__EdgesAssignment_2_1_1_2"
  mappings["Hierarchy.NumHierarchNodesAssignment_2_1_2_2"] = "rule__Hierarchy__NumHierarchNodesAssignment_2_1_2_2"
  mappings["Hierarchy.CrossHierarchRelAssignment_2_1_3_2"] = "rule__Hierarchy__CrossHierarchRelAssignment_2_1_3_2"
  mappings["Edges.NEdgesAssignment_0_3"] = "rule__Edges__NEdgesAssignment_0_3"
  mappings["Edges.LabelsAssignment_1_1_0"] = "rule__Edges__LabelsAssignment_1_1_0"
  mappings["Edges.SelfLoopsAssignment_1_1_1"] = "rule__Edges__SelfLoopsAssignment_1_1_1"
  mappings["Nodes.NNodesAssignment_3"] = "rule__Nodes__NNodesAssignment_3"
  mappings["Nodes.PortsAssignment_4_1_0"] = "rule__Nodes__PortsAssignment_4_1_0"
  mappings["Nodes.LabelsAssignment_4_1_1"] = "rule__Nodes__LabelsAssignment_4_1_1"
  mappings["Nodes.SizeAssignment_4_1_2"] = "rule__Nodes__SizeAssignment_4_1_2"
  mappings["Nodes.RemoveIsolatedAssignment_4_1_3"] = "rule__Nodes__RemoveIsolatedAssignment_4_1_3"
  mappings["Ports.ConstraintAssignment_2_1_3_2"] = "rule__Ports__ConstraintAssignment_2_1_3_2"
  mappings["Ports.FlowAssignment_2_1_4"] = "rule__Ports__FlowAssignment_2_1_4"
  mappings["Flow.FlowTypeAssignment_0"] = "rule__Flow__FlowTypeAssignment_0"
  mappings["Flow.SideAssignment_1"] = "rule__Flow__SideAssignment_1"
  mappings["Flow.AmountAssignment_3"] = "rule__Flow__AmountAssignment_3"
  { mappings, }
}

///|
pub fn CoreDebugGRandomNameMappings::get_rule_name(
  self : CoreDebugGRandomNameMappings,
  element_key : String,
) -> String? {
  self.mappings.get(element_key)
}

///|
pub struct CoreDebugGRandomParser {
  mut name_mappings : CoreDebugGRandomNameMappings
  mut grammar_access : CoreDebugGRandomIdeGrammarAccess
  mut initial_hidden_tokens : Array[String]
}

///|
pub fn new_core_debug_grandom_parser(
  grammar_access? : CoreDebugGRandomIdeGrammarAccess = new_core_debug_grandom_ide_grammar_access(),
) -> CoreDebugGRandomParser {
  {
    name_mappings: new_core_debug_grandom_name_mappings(grammar_access),
    grammar_access,
    initial_hidden_tokens: ["RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT"],
  }
}

///|
pub fn CoreDebugGRandomParser::create_parser(
  self : CoreDebugGRandomParser,
  tokens : Array[CoreDebugGRandomIdeLexToken],
) -> InternalCoreDebugGRandomParser {
  new_internal_core_debug_grandom_parser(
    tokens,
    grammar_access=self.grammar_access,
  )
}

///|
pub fn CoreDebugGRandomParser::get_rule_name(
  self : CoreDebugGRandomParser,
  element_key : String,
) -> String? {
  self.name_mappings.get_rule_name(element_key)
}

///|
pub fn CoreDebugGRandomParser::get_initial_hidden_tokens(
  self : CoreDebugGRandomParser,
) -> Array[String] {
  self.initial_hidden_tokens
}

///|
pub fn CoreDebugGRandomParser::set_initial_hidden_tokens(
  self : CoreDebugGRandomParser,
  hidden_tokens : Array[String],
) -> Unit {
  self.initial_hidden_tokens = hidden_tokens
}

///|
pub fn CoreDebugGRandomParser::get_grammar_access(
  self : CoreDebugGRandomParser,
) -> CoreDebugGRandomIdeGrammarAccess {
  self.grammar_access
}

///|
pub fn CoreDebugGRandomParser::set_grammar_access(
  self : CoreDebugGRandomParser,
  grammar_access : CoreDebugGRandomIdeGrammarAccess,
) -> Unit {
  self.grammar_access = grammar_access
}

///|
pub fn CoreDebugGRandomParser::get_name_mappings(
  self : CoreDebugGRandomParser,
) -> CoreDebugGRandomNameMappings {
  self.name_mappings
}

///|
pub fn CoreDebugGRandomParser::set_name_mappings(
  self : CoreDebugGRandomParser,
  name_mappings : CoreDebugGRandomNameMappings,
) -> Unit {
  self.name_mappings = name_mappings
}

///|
pub fn CoreDebugGRandomParser::parse(
  self : CoreDebugGRandomParser,
  input : String,
) -> CoreDebugGRandomRandGraph {
  let lexer = new_internal_core_debug_grandom_lexer(input)
  let parser = self.create_parser(lexer.lex_all())
  parser.entry_rule_rand_graph()
}
