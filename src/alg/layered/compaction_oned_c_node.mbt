///|
pub type LayeredCNode = @common.CNode

///|
pub fn layered_cnode_get_position(node : LayeredCNode) -> Double {
  node.hitbox().x
}

///|
pub fn layered_cnode_apply_position(node : LayeredCNode) -> Unit {
  let hitbox = node.hitbox()
  hitbox.x = node.start_pos()
  node.set_hitbox(hitbox)
}
