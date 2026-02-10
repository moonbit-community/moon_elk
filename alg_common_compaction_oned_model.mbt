///|
pub type ILockFunction = (CNode, Direction) -> Bool

///|
pub type IConstraintCalculationAlgorithm = (OneDimensionalCompactor) -> Unit

///|
pub type ICompactionAlgorithm = (OneDimensionalCompactor) -> Unit

///|
pub struct ISpacingsHandler {
  get_horizontal_spacing : (CNode, CNode) -> Double
  get_vertical_spacing : (CNode, CNode) -> Double
}

///|
pub fn default_spacing_handler() -> ISpacingsHandler {
  { get_horizontal_spacing: (_, _) => 0.0, get_vertical_spacing: (_, _) => 0.0 }
}

///|
pub fn new_spacings_handler(
  get_horizontal_spacing : (CNode, CNode) -> Double,
  get_vertical_spacing : (CNode, CNode) -> Double,
) -> ISpacingsHandler {
  { get_horizontal_spacing, get_vertical_spacing }
}

///|
pub struct CNode {
  handle : Int
} derive(Eq)

///|
pub struct CGroup {
  handle : Int
} derive(Eq)

///|
priv struct CNodeData {
  mut id : Int
  mut origin : String?
  mut node_type : String?
  mut c_group : CGroup?
  mut c_group_offset : KVector
  mut hitbox_pre_compaction : ElkRectangle?
  mut hitbox : ElkRectangle
  constraints : Array[CNode]
  mut start_pos : Double
}

///|
priv struct CGroupData {
  mut id : Int
  mut master : CNode?
  c_nodes : Array[CNode]
  mut start_pos : Double
  incoming_constraints : Array[CNode]
  mut out_degree : Int
  mut out_degree_real : Int
  mut reference : CNode?
  mut delta : Double
  mut delta_normalized : Double
}

///|
pub struct CGraph {
  c_nodes : Array[CNode]
  c_groups : Array[CGroup]
  supported_directions : Array[Direction]
  predefined_horizontal_constraints : Array[(CNode, CNode)]
  predefined_vertical_constraints : Array[(CNode, CNode)]
}

///|
pub struct CNodeBuilder {
  mut id : Int
  mut origin : String?
  mut node_type : String?
  mut hitbox : ElkRectangle?
  mut group_parent : CNode?
}

///|
pub struct CGroupBuilder {
  nodes : Array[CNode]
  mut reference : CNode?
  mut master : CNode?
}

///|
let cnode_store : Ref[Array[CNodeData]] = Ref::new([])

///|
let cgroup_store : Ref[Array[CGroupData]] = Ref::new([])

///|
fn[T : Eq] array_add_unique(array : Array[T], value : T) -> Bool {
  for existing in array {
    if existing == value {
      return false
    }
  }
  array.push(value)
  true
}

///|
fn[T : Eq] array_remove_first(array : Array[T], value : T) -> Bool {
  for i in 0..<array.length() {
    if array[i] == value {
      ignore(array.remove(i))
      return true
    }
  }
  false
}

///|
fn direction_eq(left : Direction, right : Direction) -> Bool {
  match (left, right) {
    (Undefined, Undefined) => true
    (Rightward, Rightward) => true
    (Leftward, Leftward) => true
    (Upward, Upward) => true
    (Downward, Downward) => true
    _ => false
  }
}

///|
fn checked_cnode(node : CNode) -> Unit {
  if node.handle < 0 || node.handle >= cnode_store.val.length() {
    abort("invalid compaction node")
  }
}

///|
fn checked_cgroup(group : CGroup) -> Unit {
  if group.handle < 0 || group.handle >= cgroup_store.val.length() {
    abort("invalid compaction group")
  }
}

///|
fn copy_rect(rect : ElkRectangle) -> ElkRectangle {
  { x: rect.x, y: rect.y, width: rect.width, height: rect.height }
}

///|
fn copy_vec(vec : KVector) -> KVector {
  { x: vec.x, y: vec.y }
}

///|
pub fn reset_compaction_oned_model_for_test() -> Unit {
  cnode_store.val.clear()
  cgroup_store.val.clear()
}

///|
pub fn new_cgraph(supported_directions : Array[Direction]) -> CGraph {
  {
    c_nodes: [],
    c_groups: [],
    supported_directions: supported_directions.copy(),
    predefined_horizontal_constraints: [],
    predefined_vertical_constraints: [],
  }
}

///|
pub fn CGraph::supports(self : CGraph, direction : Direction) -> Bool {
  for current in self.supported_directions {
    if direction_eq(current, direction) {
      return true
    }
  }
  false
}

///|
pub fn CGraph::nodes(self : CGraph) -> Array[CNode] {
  self.c_nodes
}

///|
pub fn CGraph::groups(self : CGraph) -> Array[CGroup] {
  self.c_groups
}

///|
pub fn CGraph::add_predefined_horizontal_constraint(
  self : CGraph,
  from : CNode,
  to : CNode,
) -> Unit {
  checked_cnode(from)
  checked_cnode(to)
  self.predefined_horizontal_constraints.push((from, to))
}

///|
pub fn CGraph::add_predefined_vertical_constraint(
  self : CGraph,
  from : CNode,
  to : CNode,
) -> Unit {
  checked_cnode(from)
  checked_cnode(to)
  self.predefined_vertical_constraints.push((from, to))
}

///|
pub fn cnode_of() -> CNodeBuilder {
  { id: 0, origin: None, node_type: None, hitbox: None, group_parent: None }
}

///|
pub fn CNodeBuilder::id(self : CNodeBuilder, id : Int) -> CNodeBuilder {
  self.id = id
  self
}

///|
pub fn CNodeBuilder::origin(
  self : CNodeBuilder,
  origin : String,
) -> CNodeBuilder {
  self.origin = Some(origin)
  self
}

///|
pub fn CNodeBuilder::node_type(
  self : CNodeBuilder,
  node_type : String,
) -> CNodeBuilder {
  self.node_type = Some(node_type)
  self
}

///|
pub fn CNodeBuilder::hitbox(
  self : CNodeBuilder,
  hitbox : ElkRectangle,
) -> CNodeBuilder {
  self.hitbox = Some(copy_rect(hitbox))
  self
}

///|
pub fn CNodeBuilder::group_with(
  self : CNodeBuilder,
  group_parent : CNode,
) -> CNodeBuilder {
  checked_cnode(group_parent)
  self.group_parent = Some(group_parent)
  self
}

///|
pub fn CNodeBuilder::create(self : CNodeBuilder, graph : CGraph) -> CNode {
  let hitbox = match self.hitbox {
    Some(rect) => rect
    None => abort("CNode must have a hitbox.")
  }

  let node : CNode = { handle: cnode_store.val.length() }
  cnode_store.val.push({
    id: self.id,
    origin: self.origin,
    node_type: self.node_type,
    c_group: None,
    c_group_offset: { x: 0.0, y: 0.0 },
    hitbox_pre_compaction: None,
    hitbox,
    constraints: [],
    start_pos: @double.neg_infinity,
  })
  graph.c_nodes.push(node)

  match self.group_parent {
    Some(parent) =>
      match parent.group() {
        Some(group) => group.add_cnode(node)
        None => ignore(cgroup_of().nodes([parent, node]).create(graph))
      }
    None => ()
  }

  node
}

///|
pub fn cgroup_of() -> CGroupBuilder {
  { nodes: [], reference: None, master: None }
}

///|
pub fn CGroupBuilder::nodes(
  self : CGroupBuilder,
  nodes : Array[CNode],
) -> CGroupBuilder {
  for node in nodes {
    checked_cnode(node)
    ignore(array_add_unique(self.nodes, node))
  }
  self
}

///|
pub fn CGroupBuilder::reference(
  self : CGroupBuilder,
  reference : CNode,
) -> CGroupBuilder {
  checked_cnode(reference)
  self.reference = Some(reference)
  self
}

///|
pub fn CGroupBuilder::master(
  self : CGroupBuilder,
  master : CNode,
) -> CGroupBuilder {
  checked_cnode(master)
  self.master = Some(master)
  self
}

///|
pub fn CGroupBuilder::create(self : CGroupBuilder, graph : CGraph) -> CGroup {
  let group : CGroup = { handle: cgroup_store.val.length() }
  cgroup_store.val.push({
    id: 0,
    master: self.master,
    c_nodes: [],
    start_pos: @double.neg_infinity,
    incoming_constraints: [],
    out_degree: 0,
    out_degree_real: 0,
    reference: None,
    delta: 0.0,
    delta_normalized: 0.0,
  })
  graph.c_groups.push(group)

  for node in self.nodes {
    group.add_cnode(node)
  }

  match self.reference {
    Some(reference) => group.set_reference(Some(reference))
    None => ()
  }

  match self.master {
    Some(master) => group.set_master(master)
    None => ()
  }

  group
}

///|
pub fn CNode::id(self : CNode) -> Int {
  checked_cnode(self)
  cnode_store.val[self.handle].id
}

///|
pub fn CNode::set_id(self : CNode, id : Int) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].id = id
}

///|
pub fn CNode::group(self : CNode) -> CGroup? {
  checked_cnode(self)
  cnode_store.val[self.handle].c_group
}

///|
pub fn CNode::set_group(self : CNode, group : CGroup?) -> Unit {
  checked_cnode(self)
  match group {
    Some(value) => checked_cgroup(value)
    None => ()
  }
  cnode_store.val[self.handle].c_group = group
}

///|
pub fn CNode::hitbox(self : CNode) -> ElkRectangle {
  checked_cnode(self)
  cnode_store.val[self.handle].hitbox
}

///|
pub fn CNode::set_hitbox(self : CNode, hitbox : ElkRectangle) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].hitbox = copy_rect(hitbox)
}

///|
pub fn CNode::hitbox_pre_compaction(self : CNode) -> ElkRectangle? {
  checked_cnode(self)
  cnode_store.val[self.handle].hitbox_pre_compaction
}

///|
pub fn CNode::set_hitbox_pre_compaction(
  self : CNode,
  hitbox : ElkRectangle?,
) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].hitbox_pre_compaction = match hitbox {
    Some(value) => Some(copy_rect(value))
    None => None
  }
}

///|
pub fn CNode::start_pos(self : CNode) -> Double {
  checked_cnode(self)
  cnode_store.val[self.handle].start_pos
}

///|
pub fn CNode::set_start_pos(self : CNode, start_pos : Double) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].start_pos = start_pos
}

///|
pub fn CNode::c_group_offset(self : CNode) -> KVector {
  checked_cnode(self)
  cnode_store.val[self.handle].c_group_offset
}

///|
pub fn CNode::set_c_group_offset(self : CNode, offset : KVector) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].c_group_offset = copy_vec(offset)
}

///|
pub fn CNode::constraints(self : CNode) -> Array[CNode] {
  checked_cnode(self)
  cnode_store.val[self.handle].constraints
}

///|
pub fn CNode::clear_constraints(self : CNode) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].constraints.clear()
}

///|
pub fn CNode::add_constraint(self : CNode, node : CNode) -> Unit {
  checked_cnode(self)
  checked_cnode(node)
  cnode_store.val[self.handle].constraints.push(node)
}

///|
pub fn CNode::replace_constraints(
  self : CNode,
  constraints : Array[CNode],
) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].constraints.clear()
  for node in constraints {
    checked_cnode(node)
    cnode_store.val[self.handle].constraints.push(node)
  }
}

///|
pub fn CGroup::id(self : CGroup) -> Int {
  checked_cgroup(self)
  cgroup_store.val[self.handle].id
}

///|
pub fn CGroup::set_id(self : CGroup, id : Int) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].id = id
}

///|
pub fn CGroup::set_master(self : CGroup, master : CNode) -> Unit {
  checked_cgroup(self)
  checked_cnode(master)
  cgroup_store.val[self.handle].master = Some(master)
}

///|
pub fn CGroup::master(self : CGroup) -> CNode? {
  checked_cgroup(self)
  cgroup_store.val[self.handle].master
}

///|
pub fn CGroup::c_nodes(self : CGroup) -> Array[CNode] {
  checked_cgroup(self)
  cgroup_store.val[self.handle].c_nodes
}

///|
pub fn CGroup::add_cnode(self : CGroup, node : CNode) -> Unit {
  checked_cgroup(self)
  checked_cnode(node)

  match node.group() {
    Some(_) => abort("CNode belongs to another CGroup.")
    None => ()
  }

  cgroup_store.val[self.handle].c_nodes.push(node)
  node.set_group(Some(self))

  match cgroup_store.val[self.handle].reference {
    Some(_) => ()
    None => cgroup_store.val[self.handle].reference = Some(node)
  }
}

///|
pub fn CGroup::remove_cnode(self : CGroup, node : CNode) -> Bool {
  checked_cgroup(self)
  checked_cnode(node)

  let removed = array_remove_first(cgroup_store.val[self.handle].c_nodes, node)
  if removed {
    node.set_group(None)
  }
  removed
}

///|
pub fn CGroup::reference(self : CGroup) -> CNode? {
  checked_cgroup(self)
  cgroup_store.val[self.handle].reference
}

///|
pub fn CGroup::set_reference(self : CGroup, reference : CNode?) -> Unit {
  checked_cgroup(self)
  match reference {
    Some(node) => {
      checked_cnode(node)
      cgroup_store.val[self.handle].reference = Some(node)
    }
    None => cgroup_store.val[self.handle].reference = None
  }
}

///|
pub fn CGroup::start_pos(self : CGroup) -> Double {
  checked_cgroup(self)
  cgroup_store.val[self.handle].start_pos
}

///|
pub fn CGroup::set_start_pos(self : CGroup, start_pos : Double) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].start_pos = start_pos
}

///|
pub fn CGroup::incoming_constraints(self : CGroup) -> Array[CNode] {
  checked_cgroup(self)
  cgroup_store.val[self.handle].incoming_constraints
}

///|
pub fn CGroup::clear_incoming_constraints(self : CGroup) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].incoming_constraints.clear()
}

///|
pub fn CGroup::add_incoming_constraint(self : CGroup, node : CNode) -> Bool {
  checked_cgroup(self)
  checked_cnode(node)
  array_add_unique(cgroup_store.val[self.handle].incoming_constraints, node)
}

///|
pub fn CGroup::out_degree(self : CGroup) -> Int {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree
}

///|
pub fn CGroup::set_out_degree(self : CGroup, out_degree : Int) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree = out_degree
}

///|
pub fn CGroup::out_degree_real(self : CGroup) -> Int {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree_real
}

///|
pub fn CGroup::set_out_degree_real(
  self : CGroup,
  out_degree_real : Int,
) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].out_degree_real = out_degree_real
}

///|
pub fn CGroup::delta(self : CGroup) -> Double {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta
}

///|
pub fn CGroup::add_delta(self : CGroup, delta : Double) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta = cgroup_store.val[self.handle].delta +
    delta
}

///|
pub fn CGroup::delta_normalized(self : CGroup) -> Double {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta_normalized
}

///|
pub fn CGroup::add_delta_normalized(self : CGroup, delta : Double) -> Unit {
  checked_cgroup(self)
  cgroup_store.val[self.handle].delta_normalized = cgroup_store.val[self.handle].delta_normalized +
    delta
}

///|
pub let compare_fuzzy_tolerance = 0.0001

///|
pub fn compare_fuzzy_eq(d1 : Double, d2 : Double) -> Bool {
  (d1 - d2).abs() <= compare_fuzzy_tolerance
}

///|
pub fn compare_fuzzy_gt(d1 : Double, d2 : Double) -> Bool {
  d1 - d2 > compare_fuzzy_tolerance
}

///|
pub fn compare_fuzzy_lt(d1 : Double, d2 : Double) -> Bool {
  d2 - d1 > compare_fuzzy_tolerance
}

///|
pub fn compare_fuzzy_ge(d1 : Double, d2 : Double) -> Bool {
  d1 > d2 || compare_fuzzy_eq(d1, d2)
}

///|
pub fn compare_fuzzy_le(d1 : Double, d2 : Double) -> Bool {
  d1 < d2 || compare_fuzzy_eq(d1, d2)
}
