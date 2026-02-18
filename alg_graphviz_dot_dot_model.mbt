///|
pub struct DotPort {
  mut name : String?
  mut compass_pt : String?
}

///|
pub struct DotNode {
  mut name : String?
  mut port : DotPort?
}

///|
pub struct DotAttribute {
  mut name : String?
  mut value : String?
}

///|
pub struct DotNodeStatement {
  mut node : DotNode?
  attributes : Array[DotAttribute]
}

///|
pub struct DotEdgeStatement {
  mut source_node : DotNode?
  edge_targets : Array[DotEdgeTarget]
  attributes : Array[DotAttribute]
}

///|
pub struct DotAttributeStatement {
  mut type_ : DotAttributeType
  attributes : Array[DotAttribute]
}

///|
pub struct DotSubgraph {
  mut name : String?
  statements : Array[DotStatement]
}

///|
pub struct DotEdgeTarget {
  mut operator : DotEdgeOperator
  mut target_subgraph : DotSubgraph?
  mut targetnode : DotNode?
}

///|
pub fn dot_create_attribute() -> DotAttribute {
  { name: None, value: None }
}

///|
pub fn dot_create_node_statement() -> DotNodeStatement {
  { node: None, attributes: [] }
}

///|
pub fn dot_create_node() -> DotNode {
  { name: None, port: None }
}

///|
pub fn dot_create_edge_statement() -> DotEdgeStatement {
  { source_node: None, edge_targets: [], attributes: [] }
}

///|
pub fn dot_create_edge_target() -> DotEdgeTarget {
  { operator: DotEdgeOperatorDirected, target_subgraph: None, targetnode: None }
}

///|
pub fn dot_create_attribute_statement() -> DotAttributeStatement {
  { type_: DotAttributeTypeGraph, attributes: [] }
}

///|
pub fn dot_create_subgraph() -> DotSubgraph {
  { name: None, statements: [] }
}

///|
pub fn dot_create_port() -> DotPort {
  { name: None, compass_pt: None }
}

///|
pub struct DotFactory {
  create_graphviz_model_fn : () -> DotGraphvizModel
  create_graph_fn : () -> DotGraph
  create_statement_fn : () -> DotStatement
  create_attribute_fn : () -> DotAttribute
  create_node_statement_fn : () -> DotNodeStatement
  create_node_fn : () -> DotNode
  create_edge_statement_fn : () -> DotEdgeStatement
  create_edge_target_fn : () -> DotEdgeTarget
  create_attribute_statement_fn : () -> DotAttributeStatement
  create_subgraph_fn : () -> DotSubgraph
  create_port_fn : () -> DotPort
}

///|
pub fn new_dot_factory() -> DotFactory {
  {
    create_graphviz_model_fn: dot_create_graphviz_model,
    create_graph_fn: dot_create_graph,
    create_statement_fn: dot_create_statement,
    create_attribute_fn: dot_create_attribute,
    create_node_statement_fn: dot_create_node_statement,
    create_node_fn: dot_create_node,
    create_edge_statement_fn: dot_create_edge_statement,
    create_edge_target_fn: dot_create_edge_target,
    create_attribute_statement_fn: dot_create_attribute_statement,
    create_subgraph_fn: dot_create_subgraph,
    create_port_fn: dot_create_port,
  }
}

///|
pub let dot_factory_instance : DotFactory = new_dot_factory()

///|
pub fn DotFactory::create_graphviz_model(self : DotFactory) -> DotGraphvizModel {
  (self.create_graphviz_model_fn)()
}

///|
pub fn DotFactory::create_graph(self : DotFactory) -> DotGraph {
  (self.create_graph_fn)()
}

///|
pub fn DotFactory::create_statement(self : DotFactory) -> DotStatement {
  (self.create_statement_fn)()
}

///|
pub fn DotFactory::create_attribute(self : DotFactory) -> DotAttribute {
  (self.create_attribute_fn)()
}

///|
pub fn DotFactory::create_node_statement(self : DotFactory) -> DotNodeStatement {
  (self.create_node_statement_fn)()
}

///|
pub fn DotFactory::create_node(self : DotFactory) -> DotNode {
  (self.create_node_fn)()
}

///|
pub fn DotFactory::create_edge_statement(self : DotFactory) -> DotEdgeStatement {
  (self.create_edge_statement_fn)()
}

///|
pub fn DotFactory::create_edge_target(self : DotFactory) -> DotEdgeTarget {
  (self.create_edge_target_fn)()
}

///|
pub fn DotFactory::create_attribute_statement(
  self : DotFactory,
) -> DotAttributeStatement {
  (self.create_attribute_statement_fn)()
}

///|
pub fn DotFactory::create_subgraph(self : DotFactory) -> DotSubgraph {
  (self.create_subgraph_fn)()
}

///|
pub fn DotFactory::create_port(self : DotFactory) -> DotPort {
  (self.create_port_fn)()
}

///|
pub fn DotPort::get_name(self : DotPort) -> String? {
  self.name
}

///|
pub fn DotPort::set_name(self : DotPort, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotPort::get_compass_pt(self : DotPort) -> String? {
  self.compass_pt
}

///|
pub fn DotPort::set_compass_pt(self : DotPort, value : String?) -> Unit {
  self.compass_pt = value
}

///|
pub fn DotNode::get_name(self : DotNode) -> String? {
  self.name
}

///|
pub fn DotNode::set_name(self : DotNode, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotNode::get_port(self : DotNode) -> DotPort? {
  self.port
}

///|
pub fn DotNode::set_port(self : DotNode, value : DotPort?) -> Unit {
  self.port = value
}

///|
pub fn DotAttribute::get_name(self : DotAttribute) -> String? {
  self.name
}

///|
pub fn DotAttribute::set_name(self : DotAttribute, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotAttribute::get_value(self : DotAttribute) -> String? {
  self.value
}

///|
pub fn DotAttribute::set_value(self : DotAttribute, value : String?) -> Unit {
  self.value = value
}

///|
pub fn DotNodeStatement::get_node(self : DotNodeStatement) -> DotNode? {
  self.node
}

///|
pub fn DotNodeStatement::set_node(
  self : DotNodeStatement,
  value : DotNode?,
) -> Unit {
  self.node = value
}

///|
pub fn DotNodeStatement::get_attributes(
  self : DotNodeStatement,
) -> Array[DotAttribute] {
  self.attributes
}

///|
pub fn DotEdgeStatement::get_source_node(self : DotEdgeStatement) -> DotNode? {
  self.source_node
}

///|
pub fn DotEdgeStatement::set_source_node(
  self : DotEdgeStatement,
  value : DotNode?,
) -> Unit {
  self.source_node = value
}

///|
pub fn DotEdgeStatement::get_edge_targets(
  self : DotEdgeStatement,
) -> Array[DotEdgeTarget] {
  self.edge_targets
}

///|
pub fn DotEdgeStatement::get_attributes(
  self : DotEdgeStatement,
) -> Array[DotAttribute] {
  self.attributes
}

///|
pub fn DotAttributeStatement::get_type(
  self : DotAttributeStatement,
) -> DotAttributeType {
  self.type_
}

///|
pub fn DotAttributeStatement::set_type(
  self : DotAttributeStatement,
  value : DotAttributeType?,
) -> Unit {
  match value {
    Some(v) => self.type_ = v
    None => self.type_ = DotAttributeTypeGraph
  }
}

///|
pub fn DotAttributeStatement::get_attributes(
  self : DotAttributeStatement,
) -> Array[DotAttribute] {
  self.attributes
}

///|
pub fn DotSubgraph::get_name(self : DotSubgraph) -> String? {
  self.name
}

///|
pub fn DotSubgraph::set_name(self : DotSubgraph, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotSubgraph::get_statements(self : DotSubgraph) -> Array[DotStatement] {
  self.statements
}

///|
pub fn DotEdgeTarget::get_operator(self : DotEdgeTarget) -> DotEdgeOperator {
  self.operator
}

///|
pub fn DotEdgeTarget::set_operator(
  self : DotEdgeTarget,
  value : DotEdgeOperator?,
) -> Unit {
  match value {
    Some(v) => self.operator = v
    None => self.operator = DotEdgeOperatorDirected
  }
}

///|
pub fn DotEdgeTarget::get_target_subgraph(self : DotEdgeTarget) -> DotSubgraph? {
  self.target_subgraph
}

///|
pub fn DotEdgeTarget::set_target_subgraph(
  self : DotEdgeTarget,
  value : DotSubgraph?,
) -> Unit {
  self.target_subgraph = value
}

///|
pub fn DotEdgeTarget::get_targetnode(self : DotEdgeTarget) -> DotNode? {
  self.targetnode
}

///|
pub fn DotEdgeTarget::set_targetnode(
  self : DotEdgeTarget,
  value : DotNode?,
) -> Unit {
  self.targetnode = value
}
