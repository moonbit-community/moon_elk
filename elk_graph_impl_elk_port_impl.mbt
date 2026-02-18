///|
pub type ElkPortImpl = ElkPort

///|
pub fn new_elk_port_impl(parent? : ElkNode? = None) -> ElkPortImpl {
  create_port(parent)
}
