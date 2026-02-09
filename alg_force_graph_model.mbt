///|
pub type FNode = Int

///|
pub type FEdge = Int

///|
pub type FLabel = Int

///|
pub type FBendpoint = Int

///|
pub enum FParticle {
  Node(FNode)
  Label(FLabel)
  Bendpoint(FBendpoint)
}

///|
priv struct FNodeData {
  mut id : Int
  label : String
  mut parent : FNode?
  children : Array[FNode]
  displacement : KVector
  position : KVector
  size : KVector
  int_properties : Map[String, Int]
  double_properties : Map[String, Double]
  bool_properties : Map[String, Bool]
  mut origin : ElkNode?
}

///|
priv struct FEdgeData {
  mut source : FNode?
  mut target : FNode?
  labels : Array[FLabel]
  bendpoints : Array[FBendpoint]
  int_properties : Map[String, Int]
  double_properties : Map[String, Double]
  bool_properties : Map[String, Bool]
  mut origin : ElkEdge?
}

///|
priv struct FLabelData {
  edge : FEdge
  text : String
  displacement : KVector
  position : KVector
  size : KVector
  bool_properties : Map[String, Bool]
  double_properties : Map[String, Double]
  mut origin : ElkLabel?
}

///|
priv struct FBendpointData {
  edge : FEdge
  displacement : KVector
  position : KVector
  size : KVector
}

///|
let fnode_store : Ref[Array[FNodeData]] = Ref::new([])

///|
let fedge_store : Ref[Array[FEdgeData]] = Ref::new([])

///|
let flabel_store : Ref[Array[FLabelData]] = Ref::new([])

///|
let fbendpoint_store : Ref[Array[FBendpointData]] = Ref::new([])

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
fn checked_fbendpoint(bendpoint : FBendpoint) -> Unit {
  if bendpoint < 0 || bendpoint >= fbendpoint_store.val.length() {
    abort("invalid force bendpoint id")
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
pub fn new_fnode(label? : String = "") -> FNode {
  let id = fnode_store.val.length()
  fnode_store.val.push({
    id: -1,
    label,
    parent: None,
    children: [],
    displacement: new_kvector(),
    position: new_kvector(),
    size: new_kvector(),
    int_properties: {},
    double_properties: {},
    bool_properties: {},
    origin: None,
  })
  id
}

///|
pub fn fnode_set_id(node : FNode, id : Int) -> Unit {
  checked_fnode(node)
  let data = fnode_store.val[node]
  data.id = id
  set_fnode_data(node, data)
}

///|
pub fn fnode_id(node : FNode) -> Int {
  checked_fnode(node)
  fnode_store.val[node].id
}

///|
pub fn fnode_label(node : FNode) -> String {
  checked_fnode(node)
  fnode_store.val[node].label
}

///|
pub fn fnode_parent(node : FNode) -> FNode? {
  checked_fnode(node)
  fnode_store.val[node].parent
}

///|
pub fn fnode_children(node : FNode) -> Array[FNode] {
  checked_fnode(node)
  fnode_store.val[node].children
}

///|
pub fn fnode_add_child(parent : FNode, child : FNode) -> Unit {
  checked_fnode(parent)
  checked_fnode(child)
  let parent_data = fnode_store.val[parent]
  parent_data.children.push(child)
  set_fnode_data(parent, parent_data)
  let child_data = fnode_store.val[child]
  child_data.parent = Some(parent)
  set_fnode_data(child, child_data)
}

///|
pub fn fnode_is_compound(node : FNode) -> Bool {
  !fnode_children(node).is_empty()
}

///|
pub fn fnode_depth(node : FNode) -> Int {
  checked_fnode(node)
  let mut depth = 0
  let mut current = fnode_parent(node)
  while current is Some(parent) {
    depth += 1
    current = fnode_parent(parent)
  }
  depth
}

///|
pub fn fnode_displacement(node : FNode) -> KVector {
  checked_fnode(node)
  fnode_store.val[node].displacement
}

///|
pub fn fnode_position(node : FNode) -> KVector {
  checked_fnode(node)
  fnode_store.val[node].position
}

///|
pub fn fnode_size(node : FNode) -> KVector {
  checked_fnode(node)
  fnode_store.val[node].size
}

///|
pub fn fnode_radius(node : FNode) -> Double {
  fnode_size(node).length() / 2.0
}

///|
pub fn fnode_set_int_property(
  node : FNode,
  property : ForceIntOption,
  value : Int,
) -> Unit {
  checked_fnode(node)
  let data = fnode_store.val[node]
  data.int_properties[property.get_id()] = value
  set_fnode_data(node, data)
}

///|
pub fn fnode_get_int_property(node : FNode, property : ForceIntOption) -> Int {
  checked_fnode(node)
  let data = fnode_store.val[node]
  match data.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fnode_set_double_property(
  node : FNode,
  property : ForceDoubleOption,
  value : Double,
) -> Unit {
  checked_fnode(node)
  let data = fnode_store.val[node]
  data.double_properties[property.get_id()] = value
  set_fnode_data(node, data)
}

///|
pub fn fnode_get_double_property(
  node : FNode,
  property : ForceDoubleOption,
) -> Double {
  checked_fnode(node)
  let data = fnode_store.val[node]
  match data.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fnode_set_bool_property(
  node : FNode,
  property : ForceBoolOption,
  value : Bool,
) -> Unit {
  checked_fnode(node)
  let data = fnode_store.val[node]
  data.bool_properties[property.get_id()] = value
  set_fnode_data(node, data)
}

///|
pub fn fnode_get_bool_property(
  node : FNode,
  property : ForceBoolOption,
) -> Bool {
  checked_fnode(node)
  let data = fnode_store.val[node]
  match data.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fnode_has_bool_property(
  node : FNode,
  property : ForceBoolOption,
) -> Bool {
  checked_fnode(node)
  fnode_store.val[node].bool_properties.contains(property.get_id())
}

///|
pub fn fnode_set_origin(node : FNode, origin : ElkNode) -> Unit {
  checked_fnode(node)
  let data = fnode_store.val[node]
  data.origin = Some(origin)
  set_fnode_data(node, data)
}

///|
pub fn fnode_origin(node : FNode) -> ElkNode? {
  checked_fnode(node)
  fnode_store.val[node].origin
}

///|
pub fn new_fedge() -> FEdge {
  let id = fedge_store.val.length()
  fedge_store.val.push({
    source: None,
    target: None,
    labels: [],
    bendpoints: [],
    int_properties: {},
    double_properties: {},
    bool_properties: {},
    origin: None,
  })
  id
}

///|
pub fn fedge_set_source(edge : FEdge, source : FNode) -> Unit {
  checked_fedge(edge)
  checked_fnode(source)
  let data = fedge_store.val[edge]
  data.source = Some(source)
  set_fedge_data(edge, data)
}

///|
pub fn fedge_set_target(edge : FEdge, target : FNode) -> Unit {
  checked_fedge(edge)
  checked_fnode(target)
  let data = fedge_store.val[edge]
  data.target = Some(target)
  set_fedge_data(edge, data)
}

///|
pub fn fedge_source(edge : FEdge) -> FNode? {
  checked_fedge(edge)
  fedge_store.val[edge].source
}

///|
pub fn fedge_target(edge : FEdge) -> FNode? {
  checked_fedge(edge)
  fedge_store.val[edge].target
}

///|
pub fn fedge_labels(edge : FEdge) -> Array[FLabel] {
  checked_fedge(edge)
  fedge_store.val[edge].labels
}

///|
pub fn fedge_bendpoints(edge : FEdge) -> Array[FBendpoint] {
  checked_fedge(edge)
  fedge_store.val[edge].bendpoints
}

///|
pub fn fedge_set_int_property(
  edge : FEdge,
  property : ForceIntOption,
  value : Int,
) -> Unit {
  checked_fedge(edge)
  let data = fedge_store.val[edge]
  data.int_properties[property.get_id()] = value
  set_fedge_data(edge, data)
}

///|
pub fn fedge_get_int_property(edge : FEdge, property : ForceIntOption) -> Int {
  checked_fedge(edge)
  let data = fedge_store.val[edge]
  match data.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fedge_set_double_property(
  edge : FEdge,
  property : ForceDoubleOption,
  value : Double,
) -> Unit {
  checked_fedge(edge)
  let data = fedge_store.val[edge]
  data.double_properties[property.get_id()] = value
  set_fedge_data(edge, data)
}

///|
pub fn fedge_get_double_property(
  edge : FEdge,
  property : ForceDoubleOption,
) -> Double {
  checked_fedge(edge)
  let data = fedge_store.val[edge]
  match data.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fedge_has_double_property(
  edge : FEdge,
  property : ForceDoubleOption,
) -> Bool {
  checked_fedge(edge)
  fedge_store.val[edge].double_properties.contains(property.get_id())
}

///|
pub fn fedge_set_bool_property(
  edge : FEdge,
  property : ForceBoolOption,
  value : Bool,
) -> Unit {
  checked_fedge(edge)
  let data = fedge_store.val[edge]
  data.bool_properties[property.get_id()] = value
  set_fedge_data(edge, data)
}

///|
pub fn fedge_get_bool_property(
  edge : FEdge,
  property : ForceBoolOption,
) -> Bool {
  checked_fedge(edge)
  let data = fedge_store.val[edge]
  match data.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fedge_set_origin(edge : FEdge, origin : ElkEdge) -> Unit {
  checked_fedge(edge)
  let data = fedge_store.val[edge]
  data.origin = Some(origin)
  set_fedge_data(edge, data)
}

///|
pub fn fedge_origin(edge : FEdge) -> ElkEdge? {
  checked_fedge(edge)
  fedge_store.val[edge].origin
}

///|
pub fn fedge_source_point(edge : FEdge) -> KVector {
  checked_fedge(edge)
  let source = match fedge_source(edge) {
    Some(source) => source
    None => abort("edge source is missing")
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => abort("edge target is missing")
  }
  let vector = fnode_position(target).clone().sub(fnode_position(source))
  let source_size = fnode_size(source)
  ignore(clip_vector(vector, source_size.x, source_size.y))
  vector.add(fnode_position(source))
}

///|
pub fn fedge_target_point(edge : FEdge) -> KVector {
  checked_fedge(edge)
  let source = match fedge_source(edge) {
    Some(source) => source
    None => abort("edge source is missing")
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => abort("edge target is missing")
  }
  let vector = fnode_position(source).clone().sub(fnode_position(target))
  let target_size = fnode_size(target)
  ignore(clip_vector(vector, target_size.x, target_size.y))
  vector.add(fnode_position(target))
}

///|
pub fn fedge_to_vector_chain(edge : FEdge) -> KVectorChain {
  checked_fedge(edge)
  let chain = new_kvector_chain()
  chain.add_vector(fedge_source_point(edge))
  for bendpoint in fedge_bendpoints(edge) {
    chain.add_vector(fbendpoint_position(bendpoint))
  }
  chain.add_vector(fedge_target_point(edge))
  chain
}

///|
pub fn fedge_distribute_bendpoints(edge : FEdge) -> Unit {
  checked_fedge(edge)
  let bendpoints = fedge_bendpoints(edge)
  let count = bendpoints.length()
  if count <= 0 {
    return
  }
  let source = match fedge_source(edge) {
    Some(source) => source
    None => abort("edge source is missing")
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => abort("edge target is missing")
  }
  let source_position = fnode_position(source)
  let target_position = fnode_position(target)
  let increment = target_position
    .clone()
    .sub(source_position)
    .scale(1.0 / (count + 1).to_double())
  let position = source_position.clone()
  for bendpoint in bendpoints {
    let bendpoint_position = fbendpoint_position(bendpoint)
    bendpoint_position.x = position.x + increment.x
    bendpoint_position.y = position.y + increment.y
    ignore(position.add(increment))
  }
}

///|
pub fn new_flabel(edge : FEdge, text? : String = "") -> FLabel {
  checked_fedge(edge)
  let label = flabel_store.val.length()
  flabel_store.val.push({
    edge,
    text,
    displacement: new_kvector(),
    position: new_kvector(),
    size: new_kvector(),
    bool_properties: {},
    double_properties: {},
    origin: None,
  })
  let edge_data = fedge_store.val[edge]
  edge_data.labels.push(label)
  set_fedge_data(edge, edge_data)
  label
}

///|
pub fn flabel_text(label : FLabel) -> String {
  checked_flabel(label)
  flabel_store.val[label].text
}

///|
pub fn flabel_edge(label : FLabel) -> FEdge {
  checked_flabel(label)
  flabel_store.val[label].edge
}

///|
pub fn flabel_displacement(label : FLabel) -> KVector {
  checked_flabel(label)
  flabel_store.val[label].displacement
}

///|
pub fn flabel_position(label : FLabel) -> KVector {
  checked_flabel(label)
  flabel_store.val[label].position
}

///|
pub fn flabel_size(label : FLabel) -> KVector {
  checked_flabel(label)
  flabel_store.val[label].size
}

///|
pub fn flabel_radius(label : FLabel) -> Double {
  flabel_size(label).length() / 2.0
}

///|
pub fn flabel_set_bool_property(
  label : FLabel,
  property : ForceBoolOption,
  value : Bool,
) -> Unit {
  checked_flabel(label)
  let data = flabel_store.val[label]
  data.bool_properties[property.get_id()] = value
  set_flabel_data(label, data)
}

///|
pub fn flabel_get_bool_property(
  label : FLabel,
  property : ForceBoolOption,
) -> Bool {
  checked_flabel(label)
  let data = flabel_store.val[label]
  match data.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn flabel_set_double_property(
  label : FLabel,
  property : ForceDoubleOption,
  value : Double,
) -> Unit {
  checked_flabel(label)
  let data = flabel_store.val[label]
  data.double_properties[property.get_id()] = value
  set_flabel_data(label, data)
}

///|
pub fn flabel_get_double_property(
  label : FLabel,
  property : ForceDoubleOption,
) -> Double {
  checked_flabel(label)
  let data = flabel_store.val[label]
  match data.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn flabel_set_origin(label : FLabel, origin : ElkLabel) -> Unit {
  checked_flabel(label)
  let data = flabel_store.val[label]
  data.origin = Some(origin)
  set_flabel_data(label, data)
}

///|
pub fn flabel_origin(label : FLabel) -> ElkLabel? {
  checked_flabel(label)
  flabel_store.val[label].origin
}

///|
pub fn flabel_refresh_position(label : FLabel) -> Unit {
  checked_flabel(label)
  let edge = flabel_edge(label)
  let source = match fedge_source(edge) {
    Some(source) => source
    None => return
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => return
  }
  let source_position = fnode_position(source)
  let target_position = fnode_position(target)
  if flabel_get_bool_property(label, force_edge_labels_inline) {
    let source_to_target = target_position
      .clone()
      .sub(source_position)
      .scale(0.5)
    let to_label_center = flabel_size(label).clone().scale(0.5)
    let new_position = source_position
      .clone()
      .add(source_to_target)
      .sub(to_label_center)
    ignore(flabel_position(label).set(new_position))
  } else {
    let spacing = fedge_get_double_property(edge, force_spacing_edge_label)
    let position = flabel_position(label)
    if source_position.x >= target_position.x {
      if source_position.y >= target_position.y {
        position.x = target_position.x +
          (source_position.x - target_position.x) / 2.0 +
          spacing
        position.y = target_position.y +
          (source_position.y - target_position.y) / 2.0 -
          spacing -
          flabel_size(label).y
      } else {
        position.x = target_position.x +
          (source_position.x - target_position.x) / 2.0 +
          spacing
        position.y = source_position.y +
          (target_position.y - source_position.y) / 2.0 +
          spacing
      }
    } else if source_position.y >= target_position.y {
      position.x = source_position.x +
        (target_position.x - source_position.x) / 2.0 +
        spacing
      position.y = target_position.y +
        (source_position.y - target_position.y) / 2.0 +
        spacing
    } else {
      position.x = source_position.x +
        (target_position.x - source_position.x) / 2.0 +
        spacing
      position.y = source_position.y +
        (target_position.y - source_position.y) / 2.0 -
        spacing -
        flabel_size(label).y
    }
  }
}

///|
pub fn new_fbendpoint(edge : FEdge) -> FBendpoint {
  checked_fedge(edge)
  let bendpoint = fbendpoint_store.val.length()
  fbendpoint_store.val.push({
    edge,
    displacement: new_kvector(),
    position: new_kvector(),
    size: new_kvector(),
  })
  let edge_data = fedge_store.val[edge]
  edge_data.bendpoints.push(bendpoint)
  set_fedge_data(edge, edge_data)
  bendpoint
}

///|
pub fn fbendpoint_edge(bendpoint : FBendpoint) -> FEdge {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].edge
}

///|
pub fn fbendpoint_displacement(bendpoint : FBendpoint) -> KVector {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].displacement
}

///|
pub fn fbendpoint_position(bendpoint : FBendpoint) -> KVector {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].position
}

///|
pub fn fbendpoint_size(bendpoint : FBendpoint) -> KVector {
  checked_fbendpoint(bendpoint)
  fbendpoint_store.val[bendpoint].size
}

///|
pub fn fbendpoint_radius(bendpoint : FBendpoint) -> Double {
  fbendpoint_size(bendpoint).length() / 2.0
}

///|
pub fn fparticle_displacement(particle : FParticle) -> KVector {
  match particle {
    Node(node) => fnode_displacement(node)
    Label(label) => flabel_displacement(label)
    Bendpoint(bendpoint) => fbendpoint_displacement(bendpoint)
  }
}

///|
pub fn fparticle_position(particle : FParticle) -> KVector {
  match particle {
    Node(node) => fnode_position(node)
    Label(label) => flabel_position(label)
    Bendpoint(bendpoint) => fbendpoint_position(bendpoint)
  }
}

///|
pub fn fparticle_size(particle : FParticle) -> KVector {
  match particle {
    Node(node) => fnode_size(node)
    Label(label) => flabel_size(label)
    Bendpoint(bendpoint) => fbendpoint_size(bendpoint)
  }
}

///|
pub fn fparticle_radius(particle : FParticle) -> Double {
  fparticle_size(particle).length() / 2.0
}

///|
pub fn fparticle_get_int_property(
  particle : FParticle,
  property : ForceIntOption,
) -> Int {
  match particle {
    Node(node) => fnode_get_int_property(node, property)
    _ => property.get_default()
  }
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
  source.double_properties.each((id, value) => target.double_properties[id] = value)
  source.model_properties.each((id, value) => target.model_properties[id] = value)
  source.padding_properties.each((id, value) => target.padding_properties[id] = elk_padding_clone(
    value,
  ))
  source.node_properties.each((id, value) => target.node_properties[id] = value)
  source.random_properties.each((id, value) => target.random_properties[id] = value)
  source.vector_properties.each((id, value) => target.vector_properties[id] = new_kvector_copy(
    value,
  ))
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
