///|
pub struct FNode {
  priv mut data : FNodeData
}

///|
pub impl Eq for FNode with fn equal(self, other) {
  physical_equal(self, other)
}

///|
priv struct FNodeData {
  mut id : Int
  label : String
  mut parent : FNode?
  children : Array[FNode]
  displacement : @core.KVector
  position : @core.KVector
  size : @core.KVector
  mut int_properties : Map[@graph.PropertyId, Int]?
  mut double_properties : Map[@graph.PropertyId, Double]?
  mut bool_properties : Map[@graph.PropertyId, Bool]?
  mut origin : @graph.ElkNode?
}

///|
fn set_fnode_data(node : FNode, data : FNodeData) -> Unit {
  node.data = data
}

///|
pub fn new_fnode(label? : String = "") -> FNode {
  {
    data: {
      id: -1,
      label,
      parent: None,
      children: [],
      displacement: @core.new_kvector(),
      position: @core.new_kvector(),
      size: @core.new_kvector(),
      int_properties: None,
      double_properties: None,
      bool_properties: None,
      origin: None,
    },
  }
}

///|
pub fn fnode_set_id(node : FNode, id : Int) -> Unit {
  let data = node.data
  data.id = id
  set_fnode_data(node, data)
}

///|
pub fn fnode_id(node : FNode) -> Int {
  node.data.id
}

///|
pub fn fnode_label(node : FNode) -> String {
  node.data.label
}

///|
pub fn fnode_parent(node : FNode) -> FNode? {
  node.data.parent
}

///|
pub fn fnode_children(node : FNode) -> Array[FNode] {
  node.data.children
}

///|
pub fn fnode_add_child(parent : FNode, child : FNode) -> Unit {
  let parent_data = parent.data
  parent_data.children.push(child)
  set_fnode_data(parent, parent_data)
  let child_data = child.data
  child_data.parent = Some(parent)
  set_fnode_data(child, child_data)
}

///|
pub fn fnode_is_compound(node : FNode) -> Bool {
  !fnode_children(node).is_empty()
}

///|
pub fn fnode_depth(node : FNode) -> Int {
  let mut depth = 0
  let mut current = fnode_parent(node)
  while current is Some(parent) {
    depth += 1
    current = fnode_parent(parent)
  }
  depth
}

///|
pub fn fnode_displacement(node : FNode) -> @core.KVector {
  node.data.displacement
}

///|
pub fn fnode_position(node : FNode) -> @core.KVector {
  node.data.position
}

///|
pub fn fnode_size(node : FNode) -> @core.KVector {
  node.data.size
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
  let data = node.data
  data.int_properties = Some(
    force_property_bag_set(
      data.int_properties,
      property.get_property_id(),
      value,
    ),
  )
  set_fnode_data(node, data)
}

///|
pub fn fnode_get_int_property(node : FNode, property : ForceIntOption) -> Int {
  let data = node.data
  match
    force_property_bag_get(data.int_properties, property.get_property_id()) {
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
  let data = node.data
  data.double_properties = Some(
    force_property_bag_set(
      data.double_properties,
      property.get_property_id(),
      value,
    ),
  )
  set_fnode_data(node, data)
}

///|
pub fn fnode_get_double_property(
  node : FNode,
  property : ForceDoubleOption,
) -> Double {
  let data = node.data
  match
    force_property_bag_get(data.double_properties, property.get_property_id()) {
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
  let data = node.data
  data.bool_properties = Some(
    force_property_bag_set(
      data.bool_properties,
      property.get_property_id(),
      value,
    ),
  )
  set_fnode_data(node, data)
}

///|
pub fn fnode_get_bool_property(
  node : FNode,
  property : ForceBoolOption,
) -> Bool {
  let data = node.data
  match
    force_property_bag_get(data.bool_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn fnode_has_bool_property(
  node : FNode,
  property : ForceBoolOption,
) -> Bool {
  force_property_bag_has(node.data.bool_properties, property.get_property_id())
}

///|
pub fn fnode_set_origin(node : FNode, origin : @graph.ElkNode) -> Unit {
  let data = node.data
  data.origin = Some(origin)
  set_fnode_data(node, data)
}

///|
pub fn fnode_origin(node : FNode) -> @graph.ElkNode? {
  node.data.origin
}
