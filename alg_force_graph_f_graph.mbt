///|
let fnode_store : Ref[Array[FNodeData]] = Ref::new([])

///|
let fedge_store : Ref[Array[FEdgeData]] = Ref::new([])

///|
let flabel_store : Ref[Array[FLabelData]] = Ref::new([])

///|
fn checked_fnode(node : FNode) -> Unit {
  if node < 0 || node >= fnode_store.val.length() {
    abort("invalid force node id")
  }
}

///|
fn checked_fedge(edge : FEdge) -> Unit {
  if edge < 0 || edge >= fedge_store.val.length() {
    abort("invalid force edge id")
  }
}

///|
fn checked_flabel(label : FLabel) -> Unit {
  if label < 0 || label >= flabel_store.val.length() {
    abort("invalid force label id")
  }
}

///|
fn set_fnode_data(node : FNode, data : FNodeData) -> Unit {
  checked_fnode(node)
  fnode_store.val[node] = data
}

///|
fn set_fedge_data(edge : FEdge, data : FEdgeData) -> Unit {
  checked_fedge(edge)
  fedge_store.val[edge] = data
}

///|
fn set_flabel_data(label : FLabel, data : FLabelData) -> Unit {
  checked_flabel(label)
  flabel_store.val[label] = data
}

///|
pub fn reset_force_graph_model_for_test() -> Unit {
  fnode_store.val.clear()
  fedge_store.val.clear()
  flabel_store.val.clear()
  fbendpoint_store.val.clear()
}

///|
pub struct FGraph {
  nodes : Array[FNode]
  edges : Array[FEdge]
  labels : Array[FLabel]
  bendpoints : Array[FBendpoint]
  bool_properties : Map[String, Bool]
  int_properties : Map[String, Int]
  double_properties : Map[String, Double]
  model_properties : Map[String, ForceModelStrategy]
  padding_properties : Map[String, ElkPadding]
  node_properties : Map[String, ElkNode]
  random_properties : Map[String, @random.Rand]
  vector_properties : Map[String, KVector]
  adjacency : Array[Array[Int]]
}

///|
pub fn new_fgraph() -> FGraph {
  {
    nodes: [],
    edges: [],
    labels: [],
    bendpoints: [],
    bool_properties: {},
    int_properties: {},
    double_properties: {},
    model_properties: {},
    padding_properties: {},
    node_properties: {},
    random_properties: {},
    vector_properties: {},
    adjacency: [],
  }
}

///|
pub fn fgraph_copy_properties(target : FGraph, source : FGraph) -> Unit {
  source.bool_properties.each((id, value) => target.bool_properties[id] = value)
  source.int_properties.each((id, value) => target.int_properties[id] = value)
  source.double_properties.each((id, value) => {
    target.double_properties[id] = value
  })
  source.model_properties.each((id, value) => {
    target.model_properties[id] = value
  })
  source.padding_properties.each((id, value) => {
    target.padding_properties[id] = elk_padding_clone(value)
  })
  source.node_properties.each((id, value) => target.node_properties[id] = value)
  source.random_properties.each((id, value) => {
    target.random_properties[id] = value
  })
  source.vector_properties.each((id, value) => {
    target.vector_properties[id] = new_kvector_copy(value)
  })
}

///|
pub fn FGraph::add_node(self : FGraph, node : FNode) -> Unit {
  checked_fnode(node)
  self.nodes.push(node)
}

///|
pub fn FGraph::add_edge(self : FGraph, edge : FEdge) -> Unit {
  checked_fedge(edge)
  self.edges.push(edge)
}

///|
pub fn FGraph::add_label(self : FGraph, label : FLabel) -> Unit {
  checked_flabel(label)
  self.labels.push(label)
}

///|
pub fn FGraph::add_bendpoint(self : FGraph, bendpoint : FBendpoint) -> Unit {
  checked_fbendpoint(bendpoint)
  self.bendpoints.push(bendpoint)
}

///|
pub fn FGraph::set_property(
  self : FGraph,
  property : ForceBoolOption,
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn FGraph::get_property(self : FGraph, property : ForceBoolOption) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn FGraph::set_int_property(
  self : FGraph,
  property : ForceIntOption,
  value : Int,
) -> Unit {
  self.int_properties[property.get_id()] = value
}

///|
pub fn FGraph::get_int_property(
  self : FGraph,
  property : ForceIntOption,
) -> Int {
  match self.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn FGraph::set_double_property(
  self : FGraph,
  property : ForceDoubleOption,
  value : Double,
) -> Unit {
  self.double_properties[property.get_id()] = value
}

///|
pub fn FGraph::get_double_property(
  self : FGraph,
  property : ForceDoubleOption,
) -> Double {
  match self.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn FGraph::set_model_property(
  self : FGraph,
  property : ForceModelOption,
  value : ForceModelStrategy,
) -> Unit {
  self.model_properties[property.get_id()] = value
}

///|
pub fn FGraph::get_model_property(
  self : FGraph,
  property : ForceModelOption,
) -> ForceModelStrategy {
  match self.model_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn FGraph::set_padding_property(
  self : FGraph,
  property : ForcePaddingOption,
  value : ElkPadding,
) -> Unit {
  self.padding_properties[property.get_id()] = elk_padding_clone(value)
}

///|
pub fn FGraph::get_padding_property(
  self : FGraph,
  property : ForcePaddingOption,
) -> ElkPadding {
  match self.padding_properties.get(property.get_id()) {
    Some(value) => elk_padding_clone(value)
    None => elk_padding_clone(property.get_default())
  }
}

///|
pub fn FGraph::set_internal_node_property(
  self : FGraph,
  property : ForceInternalNodeProperty,
  value : ElkNode,
) -> Unit {
  self.node_properties[property.get_id()] = value
}

///|
pub fn FGraph::get_internal_node_property(
  self : FGraph,
  property : ForceInternalNodeProperty,
) -> ElkNode? {
  self.node_properties.get(property.get_id())
}

///|
pub fn FGraph::set_internal_random_property(
  self : FGraph,
  property : ForceInternalRandomProperty,
  value : @random.Rand,
) -> Unit {
  self.random_properties[property.get_id()] = value
}

///|
pub fn FGraph::get_internal_random_property(
  self : FGraph,
  property : ForceInternalRandomProperty,
) -> @random.Rand? {
  self.random_properties.get(property.get_id())
}

///|
pub fn FGraph::set_internal_vector_property(
  self : FGraph,
  property : ForceInternalVectorProperty,
  value : KVector,
) -> Unit {
  self.vector_properties[property.get_id()] = new_kvector_copy(value)
}

///|
pub fn FGraph::get_internal_vector_property(
  self : FGraph,
  property : ForceInternalVectorProperty,
) -> KVector? {
  match self.vector_properties.get(property.get_id()) {
    Some(value) => Some(new_kvector_copy(value))
    None => None
  }
}

///|
pub fn FGraph::get_nodes(self : FGraph) -> Array[FNode] {
  self.nodes
}

///|
pub fn FGraph::get_edges(self : FGraph) -> Array[FEdge] {
  self.edges
}

///|
pub fn FGraph::get_labels(self : FGraph) -> Array[FLabel] {
  self.labels
}

///|
pub fn FGraph::get_bendpoints(self : FGraph) -> Array[FBendpoint] {
  self.bendpoints
}

///|
pub fn FGraph::get_particles(self : FGraph) -> Array[FParticle] {
  let particles = []
  for node in self.nodes {
    particles.push(Node(node))
  }
  for label in self.labels {
    particles.push(Label(label))
  }
  for bendpoint in self.bendpoints {
    particles.push(Bendpoint(bendpoint))
  }
  particles
}

///|
pub fn FGraph::get_connection(
  self : FGraph,
  particle1 : FParticle,
  particle2 : FParticle,
) -> Int {
  match (particle1, particle2) {
    (Node(node1), Node(node2)) => {
      let node1_id = fnode_id(node1)
      let node2_id = fnode_id(node2)
      if node1_id < 0 || node2_id < 0 {
        return 0
      }
      if node1_id >= self.adjacency.length() ||
        node2_id >= self.adjacency.length() {
        return 0
      }
      self.adjacency[node1_id][node2_id] + self.adjacency[node2_id][node1_id]
    }
    (Bendpoint(bpoint1), Bendpoint(bpoint2)) => {
      let edge1 = fbendpoint_edge(bpoint1)
      let edge2 = fbendpoint_edge(bpoint2)
      if edge1 == edge2 {
        fedge_get_int_property(edge2, force_priority)
      } else {
        0
      }
    }
    _ => 0
  }
}

///|
pub fn FGraph::calc_adjacency(self : FGraph) -> Unit {
  let node_count = self.nodes.length()
  self.adjacency.clear()
  for _ in 0..<node_count {
    let row = []
    for _ in 0..<node_count {
      row.push(0)
    }
    self.adjacency.push(row)
  }
  for edge in self.edges {
    match (fedge_source(edge), fedge_target(edge)) {
      (Some(source), Some(target)) => {
        let source_id = fnode_id(source)
        let target_id = fnode_id(target)
        if source_id >= 0 &&
          source_id < node_count &&
          target_id >= 0 &&
          target_id < node_count {
          self.adjacency[source_id][target_id] += fedge_get_int_property(
            edge, force_priority,
          )
        }
      }
      _ => ()
    }
  }
}
