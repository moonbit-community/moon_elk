///| DOT syntax model owned by the parent package. Keeping these imports explicit

///| makes the dependency direction clear: transformation depends on the model,

///|
/// while the model remains independent of transformation behavior.
using @dot {
  type DotAttribute,
  type DotEdgeStatement,
  type DotEdgeTarget,
  type DotGraph,
  type DotGraphvizModel,
  type DotNodeStatement,
  type DotStatement,
  dot_attribute_type_edge,
  dot_attribute_type_graph,
  dot_attribute_type_node,
  dot_attribute_type_value,
  dot_create_attribute,
  dot_create_attribute_statement,
  dot_create_edge_statement,
  dot_create_edge_target,
  dot_create_graph,
  dot_create_graphviz_model,
  dot_create_node,
  dot_create_node_statement,
  dot_create_subgraph,
  dot_graph_type_digraph,
  dot_statement_attribute,
  dot_statement_attribute_statement,
  dot_statement_edge_statement,
  dot_statement_node_statement,
  dot_statement_subgraph,
}
