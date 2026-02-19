///|
pub type FNode = Int

///|
let fnode_store : Ref[Array[FNodeData]] = Ref::new([])

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
fn checked_fnode(node : FNode) -> Unit {
  if node < 0 || node >= fnode_store.val.length() {
    abort("invalid force node id")
  }
}

///|
fn set_fnode_data(node : FNode, data : FNodeData) -> Unit {
  checked_fnode(node)
  fnode_store.val[node] = data
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
