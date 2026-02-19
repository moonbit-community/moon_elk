///|
pub struct ComponentsProcessor {
  _dummy : Unit
}

///|
pub fn new_components_processor() -> ComponentsProcessor {
  { _dummy: () }
}

///|
fn force_build_incidence_lists(graph : FGraph) -> Array[Array[FEdge]] {
  let incidence = []
  for node in graph.get_nodes() {
    ignore(node)
    incidence.push([])
  }
  for edge in graph.get_edges() {
    match (fedge_source(edge), fedge_target(edge)) {
      (Some(source), Some(target)) => {
        incidence[fnode_id(source)].push(edge)
        incidence[fnode_id(target)].push(edge)
      }
      _ => ()
    }
  }
  incidence
}

///|
fn force_dfs(
  node : FNode,
  last : FNode?,
  graph : FGraph?,
  visited : Array[Bool],
  incidence : Array[Array[FEdge]],
) -> FGraph? {
  let node_id = fnode_id(node)
  if visited[node_id] {
    return None
  }
  visited[node_id] = true
  let component = match graph {
    Some(component) => component
    None => new_fgraph()
  }
  component.add_node(node)
  for edge in incidence[node_id] {
    let mut from_last = false
    if last is Some(last_node) {
      match (fedge_source(edge), fedge_target(edge)) {
        (Some(source), Some(target)) =>
          from_last = source == last_node || target == last_node
        _ => ()
      }
    }
    if from_last {
      continue
    }
    match fedge_source(edge) {
      Some(source) =>
        if source != node {
          ignore(
            force_dfs(source, Some(node), Some(component), visited, incidence),
          )
        }
      None => ()
    }
    match fedge_target(edge) {
      Some(target) =>
        if target != node {
          ignore(
            force_dfs(target, Some(node), Some(component), visited, incidence),
          )
        }
      None => ()
    }
    component.add_edge(edge)
    for label in fedge_labels(edge) {
      component.add_label(label)
    }
  }
  Some(component)
}

///|
fn component_box_size(graph : FGraph) -> @core.KVector {
  let up_left = match
    graph.get_internal_vector_property(force_internal_bb_up_left) {
    Some(value) => value
    None => @core.new_kvector()
  }
  let low_right = match
    graph.get_internal_vector_property(force_internal_bb_low_right) {
    Some(value) => value
    None => @core.new_kvector()
  }
  low_right.clone().sub(up_left)
}

///|
fn component_less(left : FGraph, right : FGraph) -> Bool {
  let left_priority = left.get_int_property(force_priority)
  let right_priority = right.get_int_property(force_priority)
  if left_priority != right_priority {
    return left_priority > right_priority
  }
  let left_size = component_box_size(left)
  let right_size = component_box_size(right)
  left_size.x * left_size.y < right_size.x * right_size.y
}

///|
fn sort_components(components : Array[FGraph]) -> Array[FGraph] {
  let sorted = components.copy()
  let length = sorted.length()
  for i in 1..<length {
    let current = sorted[i]
    let mut j = i
    while j > 0 && component_less(current, sorted[j - 1]) {
      sorted[j] = sorted[j - 1]
      j -= 1
    }
    sorted[j] = current
  }
  sorted
}

///|
fn move_graph(
  destination_graph : FGraph,
  source_graph : FGraph,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let up_left = match
    source_graph.get_internal_vector_property(force_internal_bb_up_left) {
    Some(value) => value
    None => @core.new_kvector()
  }
  let graph_offset = @core.new_kvector_xy(offset_x, offset_y).sub(up_left)
  for node in source_graph.get_nodes() {
    ignore(fnode_position(node).add(graph_offset))
    destination_graph.add_node(node)
  }
  for edge in source_graph.get_edges() {
    for bendpoint in fedge_bendpoints(edge) {
      ignore(fbendpoint_position(bendpoint).add(graph_offset))
    }
    destination_graph.add_edge(edge)
  }
  for label in source_graph.get_labels() {
    ignore(flabel_position(label).add(graph_offset))
    destination_graph.add_label(label)
  }
}

///|
pub fn ComponentsProcessor::split(
  self : ComponentsProcessor,
  graph : FGraph,
) -> Array[FGraph] {
  ignore(self)
  if !graph.get_property(force_separate_connected_components) {
    return [graph]
  }
  let visited = []
  for node in graph.get_nodes() {
    ignore(node)
    visited.push(false)
  }
  let incidence = force_build_incidence_lists(graph)
  let components = []
  for node in graph.get_nodes() {
    match force_dfs(node, None, None, visited, incidence) {
      Some(component) => {
        fgraph_copy_properties(component, graph)
        components.push(component)
      }
      None => ()
    }
  }
  if components.length() > 1 {
    for component in components {
      let mut id = 0
      for node in component.get_nodes() {
        fnode_set_id(node, id)
        id += 1
      }
    }
  }
  components
}

///|
pub fn ComponentsProcessor::recombine(
  self : ComponentsProcessor,
  components : Array[FGraph],
) -> FGraph {
  ignore(self)
  if components.length() == 1 {
    return components[0]
  }
  if components.is_empty() {
    return new_fgraph()
  }
  for graph in components {
    let mut priority = 0
    let mut min_x = 1.0e20
    let mut min_y = 1.0e20
    let mut max_x = -1.0e20
    let mut max_y = -1.0e20
    for node in graph.get_nodes() {
      priority += fnode_get_int_property(node, force_priority)
      let node_position = fnode_position(node)
      let node_size = fnode_size(node)
      min_x = force_min(min_x, node_position.x - node_size.x / 2.0)
      min_y = force_min(min_y, node_position.y - node_size.y / 2.0)
      max_x = force_max(max_x, node_position.x + node_size.x / 2.0)
      max_y = force_max(max_y, node_position.y + node_size.y / 2.0)
    }
    graph.set_int_property(force_priority, priority)
    graph.set_internal_vector_property(
      force_internal_bb_up_left,
      @core.new_kvector_xy(min_x, min_y),
    )
    graph.set_internal_vector_property(
      force_internal_bb_low_right,
      @core.new_kvector_xy(max_x, max_y),
    )
  }
  let sorted = sort_components(components)
  let result = new_fgraph()
  fgraph_copy_properties(result, sorted[0])
  let mut max_row_width = 0.0
  let mut total_area = 0.0
  for graph in sorted {
    let size = component_box_size(graph)
    max_row_width = force_max(max_row_width, size.x)
    total_area += size.x * size.y
  }
  max_row_width = force_max(
    max_row_width,
    total_area.sqrt() * result.get_double_property(force_aspect_ratio),
  )
  let spacing = result.get_double_property(force_spacing_node_node)
  let mut xpos = 0.0
  let mut ypos = 0.0
  let mut highest_box = 0.0
  let mut broadest_row = spacing
  for graph in sorted {
    let size = component_box_size(graph)
    if xpos + size.x > max_row_width {
      xpos = 0.0
      ypos += highest_box + spacing
      highest_box = 0.0
    }
    move_graph(result, graph, xpos, ypos)
    broadest_row = force_max(broadest_row, xpos + size.x)
    highest_box = force_max(highest_box, size.y)
    xpos += size.x + spacing
  }
  ignore(broadest_row)
  result
}
