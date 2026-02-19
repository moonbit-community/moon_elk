///|
priv struct CNodeData {
  mut id : Int
  mut origin : String?
  mut node_type : String?
  mut to_string_delegate : ((CNode) -> String)?
  mut c_group : CGroup?
  mut c_group_offset : @core.KVector
  mut hitbox_pre_compaction : @core.ElkRectangle?
  mut hitbox : @core.ElkRectangle
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
  supported_directions : Array[@core.Direction]
  predefined_horizontal_constraints : Array[(CNode, CNode)]
  predefined_vertical_constraints : Array[(CNode, CNode)]
}

///|
pub struct CNodeBuilder {
  mut id : Int
  mut origin : String?
  mut node_type : String?
  mut to_string_delegate : ((CNode) -> String)?
  mut hitbox : @core.ElkRectangle?
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
fn direction_eq(left : @core.Direction, right : @core.Direction) -> Bool {
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
fn copy_rect(rect : @core.ElkRectangle) -> @core.ElkRectangle {
  { x: rect.x, y: rect.y, width: rect.width, height: rect.height }
}

///|
fn copy_vec(vec : @core.KVector) -> @core.KVector {
  { x: vec.x, y: vec.y }
}

///|
pub fn reset_compaction_oned_model_for_test() -> Unit {
  cnode_store.val.clear()
  cgroup_store.val.clear()
}

///|
pub fn new_cgraph(supported_directions : Array[@core.Direction]) -> CGraph {
  {
    c_nodes: [],
    c_groups: [],
    supported_directions: supported_directions.copy(),
    predefined_horizontal_constraints: [],
    predefined_vertical_constraints: [],
  }
}

///|
pub fn CGraph::supports(self : CGraph, direction : @core.Direction) -> Bool {
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
  {
    id: 0,
    origin: None,
    node_type: None,
    to_string_delegate: None,
    hitbox: None,
    group_parent: None,
  }
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
pub fn CNodeBuilder::to_string_delegate(
  self : CNodeBuilder,
  delegate : (CNode) -> String,
) -> CNodeBuilder {
  self.to_string_delegate = Some(delegate)
  self
}

///|
pub fn CNodeBuilder::hitbox(
  self : CNodeBuilder,
  hitbox : @core.ElkRectangle,
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
    to_string_delegate: self.to_string_delegate,
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
