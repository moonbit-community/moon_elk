///|
pub struct MrtreeComponentsProcessor {
  marker : Int
}

///|
pub fn new_mrtree_components_processor() -> MrtreeComponentsProcessor {
  { marker: 0 }
}

///|
fn mrtree_initialize_incidence(graph : MrtreeGraph) -> Array[Array[MrtreeEdge]] {
  let incidence = []
  for node in mrtree_graph_nodes(graph) {
    ignore(node)
    incidence.push([])
  }
  for edge in mrtree_graph_edges(graph) {
    let source = mrtree_edge_source(edge)
    let target = mrtree_edge_target(edge)
    incidence[mrtree_node_id(source)].push(edge)
    incidence[mrtree_node_id(target)].push(edge)
  }
  incidence
}

///|
fn mrtree_component_add_edge_unique(
  component : MrtreeGraph,
  edge : MrtreeEdge,
) -> Unit {
  if !mrtree_graph_edges(component).contains(edge) {
    mrtree_graph_add_existing_edge(component, edge)
  }
}

///|
fn mrtree_dfs(
  node : MrtreeNode,
  visited : Array[Bool],
  incidence : Array[Array[MrtreeEdge]],
  component? : MrtreeGraph = -1,
) -> MrtreeGraph? {
  let node_id = mrtree_node_id(node)
  if visited[node_id] {
    return None
  }
  visited[node_id] = true
  let current_component = if component >= 0 {
    component
  } else {
    new_mrtree_graph()
  }
  mrtree_graph_add_existing_node(current_component, node)
  for edge in incidence[node_id] {
    let source = mrtree_edge_source(edge)
    let target = mrtree_edge_target(edge)
    if source != node {
      ignore(
        mrtree_dfs(source, visited, incidence, component=current_component),
      )
    }
    if target != node {
      ignore(
        mrtree_dfs(target, visited, incidence, component=current_component),
      )
    }
    mrtree_component_add_edge_unique(current_component, edge)
  }
  Some(current_component)
}

///|
pub fn MrtreeComponentsProcessor::split(
  self : MrtreeComponentsProcessor,
  graph : MrtreeGraph,
) -> Array[MrtreeGraph] {
  ignore(self)
  if !mrtree_graph_separate_connected_components(graph) {
    return [graph]
  }
  let incidence = mrtree_initialize_incidence(graph)
  let visited = []
  for node in mrtree_graph_nodes(graph) {
    ignore(node)
    visited.push(false)
  }
  let components = []
  for node in mrtree_graph_nodes(graph) {
    match mrtree_dfs(node, visited, incidence) {
      Some(component) => {
        mrtree_graph_copy_properties(component, graph)
        components.push(component)
      }
      None => ()
    }
  }
  if components.length() > 1 {
    for component in components {
      let mut id = 0
      for node in mrtree_graph_nodes(component) {
        mrtree_node_set_id(node, id)
        id += 1
      }
    }
  }
  components
}

///|
fn mrtree_component_bounds(graph : MrtreeGraph) -> Unit {
  let mut priority = 0
  let mut min_x = 1.0e20
  let mut min_y = 1.0e20
  let mut max_x = -1.0e20
  let mut max_y = -1.0e20
  for node in mrtree_graph_nodes(graph) {
    priority += mrtree_node_priority(node)
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    min_x = if position.x < min_x { position.x } else { min_x }
    min_y = if position.y < min_y { position.y } else { min_y }
    max_x = if position.x + size.x > max_x {
      position.x + size.x
    } else {
      max_x
    }
    max_y = if position.y + size.y > max_y {
      position.y + size.y
    } else {
      max_y
    }
  }
  mrtree_graph_set_priority(graph, priority)
  mrtree_graph_set_bb_up_left(graph, new_kvector_xy(min_x, min_y))
  mrtree_graph_set_bb_low_right(graph, new_kvector_xy(max_x, max_y))
}

///|
fn mrtree_component_less(left : MrtreeGraph, right : MrtreeGraph) -> Bool {
  let left_priority = mrtree_graph_priority(left)
  let right_priority = mrtree_graph_priority(right)
  if left_priority != right_priority {
    return left_priority > right_priority
  }
  let left_size = mrtree_graph_bb_low_right(left)
    .clone()
    .sub(mrtree_graph_bb_up_left(left))
  let right_size = mrtree_graph_bb_low_right(right)
    .clone()
    .sub(mrtree_graph_bb_up_left(right))
  left_size.x * left_size.y < right_size.x * right_size.y
}

///|
fn mrtree_sort_components(
  components : Array[MrtreeGraph],
) -> Array[MrtreeGraph] {
  let sorted = components.copy()
  let length = sorted.length()
  for i in 1..<length {
    let current = sorted[i]
    let mut j = i
    while j > 0 && mrtree_component_less(current, sorted[j - 1]) {
      sorted[j] = sorted[j - 1]
      j -= 1
    }
    sorted[j] = current
  }
  sorted
}

///|
fn mrtree_move_graph(
  destination_graph : MrtreeGraph,
  source_graph : MrtreeGraph,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let graph_offset = new_kvector_xy(offset_x, offset_y).sub(
    mrtree_graph_bb_up_left(source_graph),
  )
  for node in mrtree_graph_nodes(source_graph) {
    ignore(mrtree_node_position(node).add(graph_offset))
    mrtree_graph_add_existing_node(destination_graph, node)
  }
  for edge in mrtree_graph_edges(source_graph) {
    let bend_points = mrtree_edge_bend_points(edge).to_array()
    for point in bend_points {
      ignore(point.add(graph_offset))
    }
    mrtree_graph_add_existing_edge(destination_graph, edge)
  }
}

///|
fn mrtree_process_graph_bounds(graph : MrtreeGraph) -> Unit {
  if mrtree_graph_nodes(graph).is_empty() {
    mrtree_graph_set_graph_xmin(graph, 0.0)
    mrtree_graph_set_graph_ymin(graph, 0.0)
    mrtree_graph_set_graph_xmax(graph, 0.0)
    mrtree_graph_set_graph_ymax(graph, 0.0)
    return
  }
  let mut min_x = 1.0e20
  let mut min_y = 1.0e20
  let mut max_x = -1.0e20
  let mut max_y = -1.0e20
  for node in mrtree_graph_nodes(graph) {
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    min_x = if position.x < min_x { position.x } else { min_x }
    min_y = if position.y < min_y { position.y } else { min_y }
    max_x = if position.x + size.x > max_x {
      position.x + size.x
    } else {
      max_x
    }
    max_y = if position.y + size.y > max_y {
      position.y + size.y
    } else {
      max_y
    }
  }
  mrtree_graph_set_graph_xmin(graph, min_x)
  mrtree_graph_set_graph_ymin(graph, min_y)
  mrtree_graph_set_graph_xmax(graph, max_x)
  mrtree_graph_set_graph_ymax(graph, max_y)
}

///|
fn mrtree_apply_padding_and_normalize_positions(graph : MrtreeGraph) -> Unit {
  let padding_value = mrtree_graph_padding(graph)
  mrtree_graph_set_bb_up_left(graph, new_kvector())
  let temp_graph = new_mrtree_graph()
  mrtree_move_graph(
    temp_graph,
    graph,
    padding_value.get_left() - mrtree_graph_graph_xmin(graph),
    padding_value.get_top() - mrtree_graph_graph_ymin(graph),
  )
  mrtree_process_graph_bounds(graph)
}

///|
pub fn MrtreeComponentsProcessor::pack(
  self : MrtreeComponentsProcessor,
  components : Array[MrtreeGraph],
) -> MrtreeGraph {
  ignore(self)
  if components.length() == 1 {
    let component = components[0]
    mrtree_process_graph_bounds(component)
    mrtree_apply_padding_and_normalize_positions(component)
    return component
  }
  if components.is_empty() {
    return new_mrtree_graph()
  }

  for component in components {
    mrtree_component_bounds(component)
  }
  let sorted = mrtree_sort_components(components)
  let result = new_mrtree_graph()
  mrtree_graph_copy_properties(result, sorted[0])

  let mut max_row_width = 0.0
  let mut total_area = 0.0
  for component in sorted {
    let size = mrtree_graph_bb_low_right(component)
      .clone()
      .sub(mrtree_graph_bb_up_left(component))
    if size.x > max_row_width {
      max_row_width = size.x
    }
    total_area += size.x * size.y
  }
  let suggested_width = total_area.sqrt() * mrtree_graph_aspect_ratio(result)
  if suggested_width > max_row_width {
    max_row_width = suggested_width
  }
  let spacing = mrtree_graph_spacing_node_node(result)
  let mut x_pos = 0.0
  let mut y_pos = 0.0
  let mut highest_box = 0.0
  for component in sorted {
    let size = mrtree_graph_bb_low_right(component)
      .clone()
      .sub(mrtree_graph_bb_up_left(component))
    if x_pos + size.x > max_row_width {
      x_pos = 0.0
      y_pos += highest_box + spacing
      highest_box = 0.0
    }
    mrtree_move_graph(result, component, x_pos, y_pos)
    if size.y > highest_box {
      highest_box = size.y
    }
    x_pos += size.x + spacing
  }

  mrtree_process_graph_bounds(result)
  mrtree_apply_padding_and_normalize_positions(result)
  result
}
