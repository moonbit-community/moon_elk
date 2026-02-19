///|
pub struct StressMajorization {
  mut graph : FGraph?
  apsp : Array[Array[Double]]
  weights : Array[Array[Double]]
  mut desired_edge_length : Double
  mut dimension : StressDimension
  mut epsilon : Double
  mut iteration_limit : Int
  connected_edges : Map[Int, Array[FEdge]]
  node_by_id : Map[Int, FNode]
}

///|
pub fn new_stress_majorization() -> StressMajorization {
  {
    graph: None,
    apsp: [],
    weights: [],
    desired_edge_length: stress_desired_edge_length.get_default(),
    dimension: StressDimensionXY,
    epsilon: stress_epsilon.get_default(),
    iteration_limit: stress_iteration_limit.get_default(),
    connected_edges: {},
    node_by_id: {},
  }
}

///|
fn stress_get_other(edge : FEdge, one : FNode) -> FNode {
  match (fedge_source(edge), fedge_target(edge)) {
    (Some(source), Some(target)) =>
      if source == one {
        target
      } else if target == one {
        source
      } else {
        abort("Node 'one' must be either source or target of edge 'edge'.")
      }
    _ => abort("Stress edge must have source and target")
  }
}

///|
fn stress_allows_x(dimension : StressDimension) -> Bool {
  match dimension {
    StressDimensionY => false
    _ => true
  }
}

///|
fn stress_allows_y(dimension : StressDimension) -> Bool {
  match dimension {
    StressDimensionX => false
    _ => true
  }
}

///|
fn stress_initialize_matrices(stress : StressMajorization, size : Int) -> Unit {
  stress.apsp.clear()
  stress.weights.clear()
  for _ in 0..<size {
    let apsp_row = []
    let weight_row = []
    for _ in 0..<size {
      apsp_row.push(0.0)
      weight_row.push(0.0)
    }
    stress.apsp.push(apsp_row)
    stress.weights.push(weight_row)
  }
}

///|
fn stress_dijkstra(
  stress : StressMajorization,
  source_id : Int,
) -> Array[Double] {
  let graph = match stress.graph {
    Some(graph) => graph
    None => return []
  }
  let node_count = graph.get_nodes().length()
  let distances = []
  let visited = []
  for _ in 0..<node_count {
    distances.push(1.0e20)
    visited.push(false)
  }
  distances[source_id] = 0.0
  for _ in 0..<node_count {
    let mut candidate_id = -1
    let mut candidate_distance = 1.0e20
    for node in graph.get_nodes() {
      let node_id = fnode_id(node)
      if !visited[node_id] && distances[node_id] < candidate_distance {
        candidate_id = node_id
        candidate_distance = distances[node_id]
      }
    }
    if candidate_id < 0 {
      break
    }
    visited[candidate_id] = true
    let candidate_node = match stress.node_by_id.get(candidate_id) {
      Some(node) => node
      None => continue
    }
    let incident_edges = match stress.connected_edges.get(candidate_id) {
      Some(edges) => edges
      None => []
    }
    for edge in incident_edges {
      let other = stress_get_other(edge, candidate_node)
      let other_id = fnode_id(other)
      if visited[other_id] {
        continue
      }
      let edge_length = if fedge_has_double_property(
          edge, stress_desired_edge_length,
        ) {
        fedge_get_double_property(edge, stress_desired_edge_length)
      } else {
        stress.desired_edge_length
      }
      let path_distance = distances[candidate_id] + edge_length
      if path_distance < distances[other_id] {
        distances[other_id] = path_distance
      }
    }
  }
  distances
}

///|
pub fn StressMajorization::initialize(
  self : StressMajorization,
  graph : FGraph,
) -> Unit {
  if graph.get_nodes().length() <= 1 {
    self.graph = Some(graph)
    return
  }
  self.graph = Some(graph)
  self.dimension = stress_dimension_from_int(
    graph.get_int_property(stress_dimension),
  )
  self.iteration_limit = graph.get_int_property(stress_iteration_limit)
  self.epsilon = graph.get_double_property(stress_epsilon)
  self.desired_edge_length = graph.get_double_property(
    stress_desired_edge_length,
  )
  self.connected_edges.clear()
  self.node_by_id.clear()
  for node in graph.get_nodes() {
    let node_id = fnode_id(node)
    self.connected_edges[node_id] = []
    self.node_by_id[node_id] = node
  }
  for edge in graph.get_edges() {
    match (fedge_source(edge), fedge_target(edge)) {
      (Some(source), Some(target)) => {
        let source_id = fnode_id(source)
        let target_id = fnode_id(target)
        match self.connected_edges.get(source_id) {
          Some(edges) => edges.push(edge)
          None => self.connected_edges[source_id] = [edge]
        }
        match self.connected_edges.get(target_id) {
          Some(edges) => edges.push(edge)
          None => self.connected_edges[target_id] = [edge]
        }
      }
      _ => ()
    }
  }
  let node_count = graph.get_nodes().length()
  stress_initialize_matrices(self, node_count)
  for source in graph.get_nodes() {
    let source_id = fnode_id(source)
    self.apsp[source_id] = stress_dijkstra(self, source_id)
  }
  for i in 0..<node_count {
    for j in 0..<node_count {
      let distance = self.apsp[i][j]
      if distance > 0.0 && distance < 1.0e19 {
        self.weights[i][j] = 1.0 / (distance * distance)
      }
    }
  }
}

///|
fn stress_done(
  stress : StressMajorization,
  count : Int,
  previous_stress : Double,
  current_stress : Double,
) -> Bool {
  let improved = (previous_stress - current_stress) / previous_stress <
    stress.epsilon
  previous_stress == 0.0 || improved || count >= stress.iteration_limit
}

///|
fn stress_compute_stress(stress : StressMajorization) -> Double {
  let graph = match stress.graph {
    Some(graph) => graph
    None => return 0.0
  }
  let nodes = graph.get_nodes()
  let mut stress_value = 0.0
  for i in 0..<nodes.length() {
    let source = nodes[i]
    for j in (i + 1)..<nodes.length() {
      let target = nodes[j]
      let source_id = fnode_id(source)
      let target_id = fnode_id(target)
      let euclidean_distance = fnode_position(source).distance(
        fnode_position(target),
      )
      let displacement = euclidean_distance - stress.apsp[source_id][target_id]
      stress_value += stress.weights[source_id][target_id] *
        displacement *
        displacement
    }
  }
  stress_value
}

///|
fn stress_compute_new_position(
  stress : StressMajorization,
  node : FNode,
) -> @core.KVector {
  let graph = match stress.graph {
    Some(graph) => graph
    None => return @core.new_kvector()
  }
  let mut weight_sum = 0.0
  let mut x_displacement = 0.0
  let mut y_displacement = 0.0
  for other in graph.get_nodes() {
    if node == other {
      continue
    }
    let node_id = fnode_id(node)
    let other_id = fnode_id(other)
    let weight = stress.weights[node_id][other_id]
    weight_sum += weight
    let euclidean_distance = fnode_position(node).distance(
      fnode_position(other),
    )
    if euclidean_distance > 0.0 && stress_allows_x(stress.dimension) {
      let x_part = fnode_position(other).x +
        stress.apsp[node_id][other_id] *
        (fnode_position(node).x - fnode_position(other).x) /
        euclidean_distance
      x_displacement += weight * x_part
    }
    if euclidean_distance > 0.0 && stress_allows_y(stress.dimension) {
      let y_part = fnode_position(other).y +
        stress.apsp[node_id][other_id] *
        (fnode_position(node).y - fnode_position(other).y) /
        euclidean_distance
      y_displacement += weight * y_part
    }
  }
  if weight_sum <= 0.0 {
    return fnode_position(node).clone()
  }
  match stress.dimension {
    StressDimensionX =>
      @core.new_kvector_xy(x_displacement / weight_sum, fnode_position(node).y)
    StressDimensionY =>
      @core.new_kvector_xy(fnode_position(node).x, y_displacement / weight_sum)
    StressDimensionXY =>
      @core.new_kvector_xy(x_displacement / weight_sum, y_displacement / weight_sum)
  }
}

///|
pub fn StressMajorization::execute(self : StressMajorization) -> Unit {
  let graph = match self.graph {
    Some(graph) => graph
    None => return
  }
  if graph.get_nodes().length() <= 1 {
    return
  }
  let mut count = 0
  let mut previous_stress = stress_compute_stress(self)
  let mut current_stress = 1.0e20
  while true {
    if count > 0 {
      previous_stress = current_stress
    }
    for node in graph.get_nodes() {
      if fnode_get_bool_property(node, stress_fixed) {
        continue
      }
      let new_position = stress_compute_new_position(self, node)
      ignore(fnode_position(node).reset().add(new_position))
    }
    current_stress = stress_compute_stress(self)
    if stress_done(self, count, previous_stress, current_stress) {
      break
    }
    count += 1
  }
}
