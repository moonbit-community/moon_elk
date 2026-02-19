///|
pub type LayeredCNode = CNode

///|
pub fn LayeredCNode::get_position(self : LayeredCNode) -> Double {
  self.hitbox().x
}

///|
pub fn LayeredCNode::apply_position(self : LayeredCNode) -> Unit {
  let hitbox = self.hitbox()
  hitbox.x = self.start_pos()
  self.set_hitbox(hitbox)
}
