///|
pub struct IRadialRotator {
  rotate_fn : (ElkNode) -> Unit
}

///|
pub fn new_i_radial_rotator(rotate : (ElkNode) -> Unit) -> IRadialRotator {
  { rotate_fn: rotate }
}

///|
pub fn IRadialRotator::rotate(self : IRadialRotator, graph : ElkNode) -> Unit {
  (self.rotate_fn)(graph)
}
