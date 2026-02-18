///|
pub type ElkNodeImpl = ElkNode

///|
pub fn new_elk_node_impl(parent? : ElkNode? = None) -> ElkNodeImpl {
  create_node(parent)
}
