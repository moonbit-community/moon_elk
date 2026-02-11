///|
pub struct TestGraph[T] {
  provide_graph_fn : (T) -> ElkNode
  description : String
}

///|
pub fn[T] new_test_graph(
  provide_graph_fn : (T) -> ElkNode,
  description : String,
) -> TestGraph[T] {
  { provide_graph_fn, description }
}

///|
pub fn[T] TestGraph::provide_graph(
  self : TestGraph[T],
  test_instance : T,
) -> ElkNode {
  (self.provide_graph_fn)(test_instance)
}

///|
pub fn[T] TestGraph::to_string(self : TestGraph[T]) -> String {
  self.description
}
