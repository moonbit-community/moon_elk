///|
pub struct OutlineNode {
  relative_x : Double
  absolute_y : Double
  mut next : OutlineNode?
}

///|
pub fn new_outline_node(
  relative_x : Double,
  absolute_y : Double,
  next : OutlineNode?,
) -> OutlineNode {
  { relative_x, absolute_y, next }
}

///|
pub fn OutlineNode::to_string(self : OutlineNode) -> String {
  "X:\{self.relative_x},  Y:\{self.absolute_y}"
}

///|
pub fn OutlineNode::is_last(self : OutlineNode) -> Bool {
  self.next is None
}

///|
pub fn OutlineNode::print_full_outline(self : OutlineNode) -> Unit {
  ignore(self)
}
