///|
pub struct LayeredICGraphTransformer[T] {
  transform_fn : (T) -> LayeredCGraph
  apply_layout_fn : () -> Unit
}

///|
pub fn[T] new_layered_c_graph_transformer(
  transform : (T) -> LayeredCGraph,
  apply_layout : () -> Unit,
) -> LayeredICGraphTransformer[T] {
  { transform_fn: transform, apply_layout_fn: apply_layout }
}

///|
pub fn[T] LayeredICGraphTransformer::transform(
  self : LayeredICGraphTransformer[T],
  input_graph : T,
) -> LayeredCGraph {
  (self.transform_fn)(input_graph)
}

///|
pub fn[T] LayeredICGraphTransformer::apply_layout(
  self : LayeredICGraphTransformer[T],
) -> Unit {
  (self.apply_layout_fn)()
}
