///|
let core_comments_comment_box : IProperty[Bool] = new_property(
  "org.eclipse.elk.commentBox", false,
)

///|
pub struct ElkGraphDataProvider {
  graph : ElkNode
}

///|
pub fn new_elk_graph_data_provider(graph : ElkNode) -> ElkGraphDataProvider {
  { graph, }
}

///|
pub fn ElkGraphDataProvider::provide_comments(
  self : ElkGraphDataProvider,
) -> Array[ElkNode] {
  let comments = []
  for node in node_children(self.graph) {
    if node_get_bool_property(node, core_comments_comment_box) {
      comments.push(node)
    }
  }
  comments
}

///|
pub fn ElkGraphDataProvider::provide_targets(
  self : ElkGraphDataProvider,
) -> Array[ElkNode] {
  let targets = []
  for node in node_children(self.graph) {
    if !node_get_bool_property(node, core_comments_comment_box) {
      targets.push(node)
    }
  }
  targets
}

///|
pub fn ElkGraphDataProvider::provide_sub_hierarchies(
  self : ElkGraphDataProvider,
) -> Array[IDataProvider[ElkNode, ElkNode]] {
  let providers = []
  for node in node_children(self.graph) {
    if !node_children(node).is_empty() {
      providers.push(new_elk_graph_data_provider(node).as_data_provider())
    }
  }
  providers
}

///|
pub fn ElkGraphDataProvider::attach(
  self : ElkGraphDataProvider,
  comment : ElkNode,
  target : ElkNode,
) -> Unit {
  ignore(self)
  ignore(create_simple_edge(comment, target))
}

///|
pub fn ElkGraphDataProvider::as_data_provider(
  self : ElkGraphDataProvider,
) -> IDataProvider[ElkNode, ElkNode] {
  new_data_provider_with_default_targets_for(
    () => self.provide_comments(),
    () => self.provide_targets(),
    () => self.provide_sub_hierarchies(),
    (comment, target) => self.attach(comment, target),
  )
}
