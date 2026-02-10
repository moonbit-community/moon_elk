///|
pub struct DotTransformationData[S, T] {
  mut source_graph : S?
  target_graphs : Array[T]
  log_messages : Array[String]
}

///|
pub type IDotTransformationData[S, T] = DotTransformationData[S, T]

///|
pub fn[S, T] new_dot_transformation_data() -> DotTransformationData[S, T] {
  { source_graph: None, target_graphs: [], log_messages: [] }
}

///|
pub fn[S, T] DotTransformationData::set_source_graph(
  self : DotTransformationData[S, T],
  src_graph : S,
) -> Unit {
  self.source_graph = Some(src_graph)
}

///|
pub fn[S, T] DotTransformationData::get_source_graph(
  self : DotTransformationData[S, T],
) -> S? {
  self.source_graph
}

///|
pub fn[S, T] DotTransformationData::get_target_graphs(
  self : DotTransformationData[S, T],
) -> Array[T] {
  self.target_graphs
}

///|
pub fn[S, T] DotTransformationData::log(
  self : DotTransformationData[S, T],
  msg : String,
) -> Unit {
  self.log_messages.push(msg)
}

///|
pub fn[S, T] DotTransformationData::get_messages(
  self : DotTransformationData[S, T],
) -> Array[String] {
  self.log_messages
}
