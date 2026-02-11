///|
pub struct GraphJsonTextOutlineNode {
  kind : String
  label : String
  children : Array[GraphJsonTextOutlineNode]
}

///|
pub fn new_graph_json_text_outline_node(
  kind : String,
  label : String,
  children? : Array[GraphJsonTextOutlineNode] = [],
) -> GraphJsonTextOutlineNode {
  { kind, label, children }
}

///|
pub struct ElkGraphJsonOutlineTreeProvider {
  unit : Unit
}

///|
pub fn new_elk_graph_json_outline_tree_provider() -> ElkGraphJsonOutlineTreeProvider {
  { unit: () }
}

///|
pub fn ElkGraphJsonOutlineTreeProvider::create_children_for_edge(
  self : ElkGraphJsonOutlineTreeProvider,
  edge : ElkEdge,
) -> Array[GraphJsonTextOutlineNode] {
  ignore(self)
  let children : Array[GraphJsonTextOutlineNode] = []
  for label in edge_labels(edge) {
    children.push(
      new_graph_json_text_outline_node("label", label_identifier(label)),
    )
  }
  children
}

///|
pub fn ElkGraphJsonOutlineTreeProvider::create_children_for_node(
  self : ElkGraphJsonOutlineTreeProvider,
  node : ElkNode,
) -> Array[GraphJsonTextOutlineNode] {
  let children : Array[GraphJsonTextOutlineNode] = []
  for child_node in node_children(node) {
    children.push(
      new_graph_json_text_outline_node(
        "node",
        node_identifier(child_node),
        children=self.create_children_for_node(child_node),
      ),
    )
  }
  for edge in node_contained_edges(node) {
    children.push(
      new_graph_json_text_outline_node(
        "edge",
        edge_identifier(edge),
        children=self.create_children_for_edge(edge),
      ),
    )
  }
  children
}

///|
pub fn ElkGraphJsonOutlineTreeProvider::create_outline(
  self : ElkGraphJsonOutlineTreeProvider,
  root : ElkNode,
) -> GraphJsonTextOutlineNode {
  new_graph_json_text_outline_node(
    "graph",
    node_identifier(root),
    children=self.create_children_for_node(root),
  )
}
