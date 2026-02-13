///|
fn cross_hierarchy_edge_comparator_hierarchy_level(
  nested_graph : LGraph,
  top_level_graph : LGraph,
) -> Int {
  ignore(top_level_graph)
  cross_hierarchy_edge_comparator_hierarchy_level_recur(nested_graph, 0)
}

///|
fn cross_hierarchy_edge_comparator_hierarchy_level_recur(
  current_graph : LGraph,
  level : Int,
) -> Int {
  match current_graph.get_parent_node() {
    Some(current_node) =>
      cross_hierarchy_edge_comparator_hierarchy_level_recur(
        current_node.get_graph(),
        level + 1,
      )
    None => level
  }
}

///|
fn cross_hierarchy_edge_comparator_is_output(port_type : PortType) -> Bool {
  match port_type {
    Output => true
    _ => false
  }
}

///|
fn cross_hierarchy_edge_comparator_is_input(port_type : PortType) -> Bool {
  match port_type {
    Input => true
    _ => false
  }
}

///|
pub struct CrossHierarchyEdgeComparator {
  graph : LGraph
}

///|
pub fn new_cross_hierarchy_edge_comparator(
  graph : LGraph,
) -> CrossHierarchyEdgeComparator {
  { graph, }
}

///|
pub fn CrossHierarchyEdgeComparator::compare(
  self : CrossHierarchyEdgeComparator,
  edge1 : CrossHierarchyEdge,
  edge2 : CrossHierarchyEdge,
) -> Int {
  if cross_hierarchy_edge_comparator_is_output(edge1.get_type()) &&
    cross_hierarchy_edge_comparator_is_input(edge2.get_type()) {
    return -1
  } else if cross_hierarchy_edge_comparator_is_input(edge1.get_type()) &&
    cross_hierarchy_edge_comparator_is_output(edge2.get_type()) {
    return 1
  }

  let level1 = cross_hierarchy_edge_comparator_hierarchy_level(
    edge1.get_graph(),
    self.graph,
  )
  let level2 = cross_hierarchy_edge_comparator_hierarchy_level(
    edge2.get_graph(),
    self.graph,
  )
  if cross_hierarchy_edge_comparator_is_output(edge1.get_type()) {
    level2 - level1
  } else {
    level1 - level2
  }
}
