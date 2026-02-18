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
pub fn dot_create_edge_target() -> DotEdgeTarget {
  { operator: DotEdgeOperatorDirected, target_subgraph: None, targetnode: None }
}

///|
pub fn dot_create_subgraph() -> DotSubgraph {
  { name: None, statements: [] }
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
