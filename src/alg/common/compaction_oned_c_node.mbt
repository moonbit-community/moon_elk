///|
pub struct CNode {
  handle : Int
} derive(Eq)

///|
pub fn CNode::id(self : CNode) -> Int {
  checked_cnode(self)
  cnode_store.val[self.handle].id
}

///|
pub fn CNode::origin(self : CNode) -> String? {
  checked_cnode(self)
  cnode_store.val[self.handle].origin
}

///|
pub fn CNode::set_origin(self : CNode, origin : String?) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].origin = origin
}

///|
pub fn CNode::node_type(self : CNode) -> String? {
  checked_cnode(self)
  cnode_store.val[self.handle].node_type
}

///|
pub fn CNode::set_node_type(self : CNode, node_type : String?) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].node_type = node_type
}

///|
pub fn CNode::to_string_delegate(self : CNode) -> ((CNode) -> String)? {
  checked_cnode(self)
  cnode_store.val[self.handle].to_string_delegate
}

///|
pub fn CNode::set_to_string_delegate(
  self : CNode,
  delegate : ((CNode) -> String)?,
) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].to_string_delegate = delegate
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
pub fn CNode::hitbox(self : CNode) -> @core.ElkRectangle {
  checked_cnode(self)
  cnode_store.val[self.handle].hitbox
}

///|
pub fn CNode::set_hitbox(self : CNode, hitbox : @core.ElkRectangle) -> Unit {
  checked_cnode(self)
  cnode_store.val[self.handle].hitbox = copy_rect(hitbox)
}

///|
pub fn CNode::hitbox_pre_compaction(self : CNode) -> @core.ElkRectangle? {
  checked_cnode(self)
  cnode_store.val[self.handle].hitbox_pre_compaction
}

///|
pub fn CNode::set_hitbox_pre_compaction(
  self : CNode,
  hitbox : @core.ElkRectangle?,
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
pub fn CNode::c_group_offset(self : CNode) -> @core.KVector {
  checked_cnode(self)
  cnode_store.val[self.handle].c_group_offset
}

///|
pub fn CNode::set_c_group_offset(self : CNode, offset : @core.KVector) -> Unit {
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
pub fn CNode::to_string(self : CNode) -> String {
  checked_cnode(self)
  match self.to_string_delegate() {
    Some(delegate) => delegate(self)
    None => "CNode(\{self.id()})"
  }
}

///|
pub fn CNode::get_debug_svg(self : CNode) -> String {
  checked_cnode(self)
  let hitbox = self.hitbox()
  let width = if hitbox.width > 1.0 { hitbox.width } else { 1.0 }
  let height = if hitbox.height > 1.0 { hitbox.height } else { 1.0 }
  let x = hitbox.x
  let y = hitbox.y
  let text_x = x + 2.0
  let text_y = y + 11.0
  let rect_svg = "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{width}\" height=\"\{height}\" fill=\"green\" stroke=\"black\" opacity=\"0.5\"/>"
  let text_svg = "<text x=\"\{text_x}\" y=\"\{text_y}\">(\{x.round()}, \{y.round()})\n\{self.to_string()}</text>"
  rect_svg + text_svg
}
