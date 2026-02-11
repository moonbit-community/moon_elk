///|
pub struct ElkGraphIdeNameMappings {
  mappings : Map[String, String]
}

///|
pub fn new_elk_graph_ide_name_mappings(
  grammar_access : ElkGraphGrammarAccess,
) -> ElkGraphIdeNameMappings {
  ignore(grammar_access)
  let mappings : Map[String, String] = {}
  mappings["RootNode.Alternatives_4"] = "rule__RootNode__Alternatives_4"
  mappings["ElkNode.Alternatives_2_3"] = "rule__ElkNode__Alternatives_2_3"
  mappings["EdgeLayout.Alternatives_2"] = "rule__EdgeLayout__Alternatives_2"
  mappings["Number.Alternatives"] = "rule__Number__Alternatives"
  mappings["Property.Alternatives_2"] = "rule__Property__Alternatives_2"
  mappings["NumberValue.Alternatives"] = "rule__NumberValue__Alternatives"
  mappings["BooleanValue.Alternatives"] = "rule__BooleanValue__Alternatives"
  mappings["RootNode.Group"] = "rule__RootNode__Group__0"
  mappings["RootNode.Group_1"] = "rule__RootNode__Group_1__0"
  mappings["ElkNode.Group"] = "rule__ElkNode__Group__0"
  mappings["ElkNode.Group_2"] = "rule__ElkNode__Group_2__0"
  mappings["ElkLabel.Group"] = "rule__ElkLabel__Group__0"
  mappings["ElkLabel.Group_1"] = "rule__ElkLabel__Group_1__0"
  mappings["ElkLabel.Group_3"] = "rule__ElkLabel__Group_3__0"
  mappings["ElkPort.Group"] = "rule__ElkPort__Group__0"
  mappings["ElkPort.Group_2"] = "rule__ElkPort__Group_2__0"
  mappings["ShapeLayout.Group"] = "rule__ShapeLayout__Group__0"
  mappings["ShapeLayout.Group_2_0"] = "rule__ShapeLayout__Group_2_0__0"
  mappings["ShapeLayout.Group_2_1"] = "rule__ShapeLayout__Group_2_1__0"
  mappings["ElkEdge.Group"] = "rule__ElkEdge__Group__0"
  mappings["ElkEdge.Group_1"] = "rule__ElkEdge__Group_1__0"
  mappings["ElkEdge.Group_3"] = "rule__ElkEdge__Group_3__0"
  mappings["ElkEdge.Group_6"] = "rule__ElkEdge__Group_6__0"
  mappings["ElkEdge.Group_7"] = "rule__ElkEdge__Group_7__0"
  mappings["EdgeLayout.Group"] = "rule__EdgeLayout__Group__0"
  mappings["ElkSingleEdgeSection.Group"] = "rule__ElkSingleEdgeSection__Group__0"
  mappings["ElkSingleEdgeSection.Group_1"] = "rule__ElkSingleEdgeSection__Group_1__0"
  mappings["ElkSingleEdgeSection.Group_1_0_0"] = "rule__ElkSingleEdgeSection__Group_1_0_0__0"
  mappings["ElkSingleEdgeSection.Group_1_0_1"] = "rule__ElkSingleEdgeSection__Group_1_0_1__0"
  mappings["ElkSingleEdgeSection.Group_1_0_2"] = "rule__ElkSingleEdgeSection__Group_1_0_2__0"
  mappings["ElkSingleEdgeSection.Group_1_0_3"] = "rule__ElkSingleEdgeSection__Group_1_0_3__0"
  mappings["ElkSingleEdgeSection.Group_1_1"] = "rule__ElkSingleEdgeSection__Group_1_1__0"
  mappings["ElkSingleEdgeSection.Group_1_1_3"] = "rule__ElkSingleEdgeSection__Group_1_1_3__0"
  mappings["ElkEdgeSection.Group"] = "rule__ElkEdgeSection__Group__0"
  mappings["ElkEdgeSection.Group_2"] = "rule__ElkEdgeSection__Group_2__0"
  mappings["ElkEdgeSection.Group_2_2"] = "rule__ElkEdgeSection__Group_2_2__0"
  mappings["ElkEdgeSection.Group_4"] = "rule__ElkEdgeSection__Group_4__0"
  mappings["ElkEdgeSection.Group_4_0_0"] = "rule__ElkEdgeSection__Group_4_0_0__0"
  mappings["ElkEdgeSection.Group_4_0_1"] = "rule__ElkEdgeSection__Group_4_0_1__0"
  mappings["ElkEdgeSection.Group_4_0_2"] = "rule__ElkEdgeSection__Group_4_0_2__0"
  mappings["ElkEdgeSection.Group_4_0_3"] = "rule__ElkEdgeSection__Group_4_0_3__0"
  mappings["ElkEdgeSection.Group_4_1"] = "rule__ElkEdgeSection__Group_4_1__0"
  mappings["ElkEdgeSection.Group_4_1_3"] = "rule__ElkEdgeSection__Group_4_1_3__0"
  mappings["ElkBendPoint.Group"] = "rule__ElkBendPoint__Group__0"
  mappings["QualifiedId.Group"] = "rule__QualifiedId__Group__0"
  mappings["QualifiedId.Group_1"] = "rule__QualifiedId__Group_1__0"
  mappings["Property.Group"] = "rule__Property__Group__0"
  mappings["PropertyKey.Group"] = "rule__PropertyKey__Group__0"
  mappings["PropertyKey.Group_1"] = "rule__PropertyKey__Group_1__0"
  mappings["RootNode.IdentifierAssignment_1_1"] = "rule__RootNode__IdentifierAssignment_1_1"
  mappings["RootNode.PropertiesAssignment_3"] = "rule__RootNode__PropertiesAssignment_3"
  mappings["RootNode.LabelsAssignment_4_0"] = "rule__RootNode__LabelsAssignment_4_0"
  mappings["RootNode.PortsAssignment_4_1"] = "rule__RootNode__PortsAssignment_4_1"
  mappings["RootNode.ChildrenAssignment_4_2"] = "rule__RootNode__ChildrenAssignment_4_2"
  mappings["RootNode.ContainedEdgesAssignment_4_3"] = "rule__RootNode__ContainedEdgesAssignment_4_3"
  mappings["ElkNode.IdentifierAssignment_1"] = "rule__ElkNode__IdentifierAssignment_1"
  mappings["ElkNode.PropertiesAssignment_2_2"] = "rule__ElkNode__PropertiesAssignment_2_2"
  mappings["ElkNode.LabelsAssignment_2_3_0"] = "rule__ElkNode__LabelsAssignment_2_3_0"
  mappings["ElkNode.PortsAssignment_2_3_1"] = "rule__ElkNode__PortsAssignment_2_3_1"
  mappings["ElkNode.ChildrenAssignment_2_3_2"] = "rule__ElkNode__ChildrenAssignment_2_3_2"
  mappings["ElkNode.ContainedEdgesAssignment_2_3_3"] = "rule__ElkNode__ContainedEdgesAssignment_2_3_3"
  mappings["ElkLabel.IdentifierAssignment_1_0"] = "rule__ElkLabel__IdentifierAssignment_1_0"
  mappings["ElkLabel.TextAssignment_2"] = "rule__ElkLabel__TextAssignment_2"
  mappings["ElkLabel.PropertiesAssignment_3_2"] = "rule__ElkLabel__PropertiesAssignment_3_2"
  mappings["ElkLabel.LabelsAssignment_3_3"] = "rule__ElkLabel__LabelsAssignment_3_3"
  mappings["ElkPort.IdentifierAssignment_1"] = "rule__ElkPort__IdentifierAssignment_1"
  mappings["ElkPort.PropertiesAssignment_2_2"] = "rule__ElkPort__PropertiesAssignment_2_2"
  mappings["ElkPort.LabelsAssignment_2_3"] = "rule__ElkPort__LabelsAssignment_2_3"
  mappings["ShapeLayout.XAssignment_2_0_2"] = "rule__ShapeLayout__XAssignment_2_0_2"
  mappings["ShapeLayout.YAssignment_2_0_4"] = "rule__ShapeLayout__YAssignment_2_0_4"
  mappings["ShapeLayout.WidthAssignment_2_1_2"] = "rule__ShapeLayout__WidthAssignment_2_1_2"
  mappings["ShapeLayout.HeightAssignment_2_1_4"] = "rule__ShapeLayout__HeightAssignment_2_1_4"
  mappings["ElkEdge.IdentifierAssignment_1_0"] = "rule__ElkEdge__IdentifierAssignment_1_0"
  mappings["ElkEdge.SourcesAssignment_2"] = "rule__ElkEdge__SourcesAssignment_2"
  mappings["ElkEdge.SourcesAssignment_3_1"] = "rule__ElkEdge__SourcesAssignment_3_1"
  mappings["ElkEdge.TargetsAssignment_5"] = "rule__ElkEdge__TargetsAssignment_5"
  mappings["ElkEdge.TargetsAssignment_6_1"] = "rule__ElkEdge__TargetsAssignment_6_1"
  mappings["ElkEdge.PropertiesAssignment_7_2"] = "rule__ElkEdge__PropertiesAssignment_7_2"
  mappings["ElkEdge.LabelsAssignment_7_3"] = "rule__ElkEdge__LabelsAssignment_7_3"
  mappings["EdgeLayout.SectionsAssignment_2_0"] = "rule__EdgeLayout__SectionsAssignment_2_0"
  mappings["EdgeLayout.SectionsAssignment_2_1"] = "rule__EdgeLayout__SectionsAssignment_2_1"
  mappings["ElkSingleEdgeSection.IncomingShapeAssignment_1_0_0_2"] = "rule__ElkSingleEdgeSection__IncomingShapeAssignment_1_0_0_2"
  mappings["ElkSingleEdgeSection.OutgoingShapeAssignment_1_0_1_2"] = "rule__ElkSingleEdgeSection__OutgoingShapeAssignment_1_0_1_2"
  mappings["ElkSingleEdgeSection.StartXAssignment_1_0_2_2"] = "rule__ElkSingleEdgeSection__StartXAssignment_1_0_2_2"
  mappings["ElkSingleEdgeSection.StartYAssignment_1_0_2_4"] = "rule__ElkSingleEdgeSection__StartYAssignment_1_0_2_4"
  mappings["ElkSingleEdgeSection.EndXAssignment_1_0_3_2"] = "rule__ElkSingleEdgeSection__EndXAssignment_1_0_3_2"
  mappings["ElkSingleEdgeSection.EndYAssignment_1_0_3_4"] = "rule__ElkSingleEdgeSection__EndYAssignment_1_0_3_4"
  mappings["ElkSingleEdgeSection.BendPointsAssignment_1_1_2"] = "rule__ElkSingleEdgeSection__BendPointsAssignment_1_1_2"
  mappings["ElkSingleEdgeSection.BendPointsAssignment_1_1_3_1"] = "rule__ElkSingleEdgeSection__BendPointsAssignment_1_1_3_1"
  mappings["ElkSingleEdgeSection.PropertiesAssignment_1_2"] = "rule__ElkSingleEdgeSection__PropertiesAssignment_1_2"
  mappings["ElkEdgeSection.IdentifierAssignment_1"] = "rule__ElkEdgeSection__IdentifierAssignment_1"
  mappings["ElkEdgeSection.OutgoingSectionsAssignment_2_1"] = "rule__ElkEdgeSection__OutgoingSectionsAssignment_2_1"
  mappings["ElkEdgeSection.OutgoingSectionsAssignment_2_2_1"] = "rule__ElkEdgeSection__OutgoingSectionsAssignment_2_2_1"
  mappings["ElkEdgeSection.IncomingShapeAssignment_4_0_0_2"] = "rule__ElkEdgeSection__IncomingShapeAssignment_4_0_0_2"
  mappings["ElkEdgeSection.OutgoingShapeAssignment_4_0_1_2"] = "rule__ElkEdgeSection__OutgoingShapeAssignment_4_0_1_2"
  mappings["ElkEdgeSection.StartXAssignment_4_0_2_2"] = "rule__ElkEdgeSection__StartXAssignment_4_0_2_2"
  mappings["ElkEdgeSection.StartYAssignment_4_0_2_4"] = "rule__ElkEdgeSection__StartYAssignment_4_0_2_4"
  mappings["ElkEdgeSection.EndXAssignment_4_0_3_2"] = "rule__ElkEdgeSection__EndXAssignment_4_0_3_2"
  mappings["ElkEdgeSection.EndYAssignment_4_0_3_4"] = "rule__ElkEdgeSection__EndYAssignment_4_0_3_4"
  mappings["ElkEdgeSection.BendPointsAssignment_4_1_2"] = "rule__ElkEdgeSection__BendPointsAssignment_4_1_2"
  mappings["ElkEdgeSection.BendPointsAssignment_4_1_3_1"] = "rule__ElkEdgeSection__BendPointsAssignment_4_1_3_1"
  mappings["ElkEdgeSection.PropertiesAssignment_4_2"] = "rule__ElkEdgeSection__PropertiesAssignment_4_2"
  mappings["ElkBendPoint.XAssignment_0"] = "rule__ElkBendPoint__XAssignment_0"
  mappings["ElkBendPoint.YAssignment_2"] = "rule__ElkBendPoint__YAssignment_2"
  mappings["Property.KeyAssignment_0"] = "rule__Property__KeyAssignment_0"
  mappings["Property.ValueAssignment_2_0"] = "rule__Property__ValueAssignment_2_0"
  mappings["Property.ValueAssignment_2_1"] = "rule__Property__ValueAssignment_2_1"
  mappings["Property.ValueAssignment_2_2"] = "rule__Property__ValueAssignment_2_2"
  mappings["Property.ValueAssignment_2_3"] = "rule__Property__ValueAssignment_2_3"
  mappings["ShapeLayout.UnorderedGroup_2"] = "rule__ShapeLayout__UnorderedGroup_2"
  mappings["ElkSingleEdgeSection.UnorderedGroup_1_0"] = "rule__ElkSingleEdgeSection__UnorderedGroup_1_0"
  mappings["ElkEdgeSection.UnorderedGroup_4_0"] = "rule__ElkEdgeSection__UnorderedGroup_4_0"
  { mappings, }
}

///|
pub fn ElkGraphIdeNameMappings::get_rule_name(
  self : ElkGraphIdeNameMappings,
  element_key : String,
) -> String? {
  self.mappings.get(element_key)
}

///|
pub struct ElkGraphIdeParser {
  mut name_mappings : ElkGraphIdeNameMappings
  mut grammar_access : ElkGraphGrammarAccess
  mut initial_hidden_tokens : Array[String]
}

///|
pub fn new_elk_graph_ide_parser(
  grammar_access? : ElkGraphGrammarAccess = new_elk_graph_grammar_access(),
) -> ElkGraphIdeParser {
  {
    name_mappings: new_elk_graph_ide_name_mappings(grammar_access),
    grammar_access,
    initial_hidden_tokens: ["RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT"],
  }
}

///|
pub fn ElkGraphIdeParser::create_parser(
  self : ElkGraphIdeParser,
  tokens : Array[ElkGraphLexToken],
) -> InternalElkGraphIdeParser {
  new_internal_elk_graph_ide_parser(tokens, grammar_access=self.grammar_access)
}

///|
pub fn ElkGraphIdeParser::get_rule_name(
  self : ElkGraphIdeParser,
  element_key : String,
) -> String? {
  self.name_mappings.get_rule_name(element_key)
}

///|
pub fn ElkGraphIdeParser::get_initial_hidden_tokens(
  self : ElkGraphIdeParser,
) -> Array[String] {
  self.initial_hidden_tokens
}

///|
pub fn ElkGraphIdeParser::set_initial_hidden_tokens(
  self : ElkGraphIdeParser,
  hidden_tokens : Array[String],
) -> Unit {
  self.initial_hidden_tokens = hidden_tokens
}

///|
pub fn ElkGraphIdeParser::get_grammar_access(
  self : ElkGraphIdeParser,
) -> ElkGraphGrammarAccess {
  self.grammar_access
}

///|
pub fn ElkGraphIdeParser::set_grammar_access(
  self : ElkGraphIdeParser,
  grammar_access : ElkGraphGrammarAccess,
) -> Unit {
  self.grammar_access = grammar_access
}

///|
pub fn ElkGraphIdeParser::get_name_mappings(
  self : ElkGraphIdeParser,
) -> ElkGraphIdeNameMappings {
  self.name_mappings
}

///|
pub fn ElkGraphIdeParser::set_name_mappings(
  self : ElkGraphIdeParser,
  name_mappings : ElkGraphIdeNameMappings,
) -> Unit {
  self.name_mappings = name_mappings
}

///|
pub fn ElkGraphIdeParser::parse(
  self : ElkGraphIdeParser,
  input : String,
) -> ElkNode {
  let lexer = new_internal_elk_graph_ide_lexer(input)
  let parser = self.create_parser(lexer.lex_all())
  parser.entry_rule_root_node()
}
