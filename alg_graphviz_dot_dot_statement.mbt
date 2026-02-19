///|
pub enum DotStatement {
  DotStatementBase
  DotStatementAttribute(DotAttribute)
  DotStatementNodeStatement(DotNodeStatement)
  DotStatementEdgeStatement(DotEdgeStatement)
  DotStatementAttributeStatement(DotAttributeStatement)
  DotStatementSubgraph(DotSubgraph)
}

///|
pub fn dot_statement_base() -> DotStatement {
  DotStatementBase
}

///|
pub fn dot_statement_attribute(attribute : DotAttribute) -> DotStatement {
  DotStatementAttribute(attribute)
}

///|
pub fn dot_statement_node_statement(
  node_statement : DotNodeStatement,
) -> DotStatement {
  DotStatementNodeStatement(node_statement)
}

///|
pub fn dot_statement_edge_statement(
  edge_statement : DotEdgeStatement,
) -> DotStatement {
  DotStatementEdgeStatement(edge_statement)
}

///|
pub fn dot_statement_attribute_statement(
  attribute_statement : DotAttributeStatement,
) -> DotStatement {
  DotStatementAttributeStatement(attribute_statement)
}

///|
pub fn dot_statement_subgraph(subgraph : DotSubgraph) -> DotStatement {
  DotStatementSubgraph(subgraph)
}

///|
pub fn dot_create_statement() -> DotStatement {
  dot_statement_base()
}
