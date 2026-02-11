///|
pub struct GraphTextOutlineNode {
  kind : String
  label : String
  children : Array[GraphTextOutlineNode]
}

///|
pub fn new_graph_text_outline_node(
  kind : String,
  label : String,
  children? : Array[GraphTextOutlineNode] = [],
) -> GraphTextOutlineNode {
  { kind, label, children }
}

///|
pub struct ElkGraphOutlineTreeProvider {
  unit : Unit
}

///|
pub fn new_elk_graph_outline_tree_provider() -> ElkGraphOutlineTreeProvider {
  { unit: () }
}

///|
pub fn ElkGraphOutlineTreeProvider::create_children_for_edge(
  self : ElkGraphOutlineTreeProvider,
  edge : ElkEdge,
) -> Array[GraphTextOutlineNode] {
  ignore(self)
  let children : Array[GraphTextOutlineNode] = []
  for label in edge_labels(edge) {
    children.push(new_graph_text_outline_node("label", label_identifier(label)))
  }
  children
}

///|
pub fn ElkGraphOutlineTreeProvider::create_outline(
  self : ElkGraphOutlineTreeProvider,
  root : ElkNode,
) -> GraphTextOutlineNode {
  let root_node = new_graph_text_outline_node("graph", node_identifier(root))
  for edge in node_contained_edges(root) {
    root_node.children.push(
      new_graph_text_outline_node(
        "edge",
        edge_identifier(edge),
        children=self.create_children_for_edge(edge),
      ),
    )
  }
  root_node
}
