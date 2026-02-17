///|
pub enum LoggedGraphType {
  ElkGraph
  LGraph
}

///|
pub struct LoggedGraph {
  tag : String
  graph_type : LoggedGraphType
}

///|
pub fn new_logged_graph(
  tag : String,
  graph_type : LoggedGraphType,
) -> LoggedGraph {
  { tag, graph_type }
}
