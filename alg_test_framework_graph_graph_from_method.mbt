///|
pub struct GraphFromMethod[T] {
  method_name : String
  provider_fn : (T) -> ElkNode
}

///|
pub fn[T] new_graph_from_method(
  method_name : String,
  provider_fn : (T) -> ElkNode,
) -> GraphFromMethod[T] {
  { method_name, provider_fn }
}

///|
pub fn[T] GraphFromMethod::provide_graph(
  self : GraphFromMethod[T],
  test_instance : T,
) -> ElkNode {
  (self.provider_fn)(test_instance)
}

///|
pub fn[T] GraphFromMethod::to_test_graph(
  self : GraphFromMethod[T],
) -> TestGraph[T] {
  new_test_graph(instance => self.provide_graph(instance), self.to_string())
}

///|
pub fn[T] GraphFromMethod::to_string(self : GraphFromMethod[T]) -> String {
  "graphMethod(" + self.method_name + ")"
}
