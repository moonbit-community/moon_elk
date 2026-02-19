///|
pub enum DotGraphType {
  DotGraphTypeGraph
  DotGraphTypeDigraph
}

///|
pub fn dot_graph_type_graph() -> DotGraphType {
  DotGraphTypeGraph
}

///|
pub fn dot_graph_type_digraph() -> DotGraphType {
  DotGraphTypeDigraph
}

///|
pub fn dot_graph_type_value(graph_type : DotGraphType) -> Int {
  match graph_type {
    DotGraphTypeGraph => 0
    DotGraphTypeDigraph => 1
  }
}

///|
pub fn dot_graph_type_name(graph_type : DotGraphType) -> String {
  match graph_type {
    DotGraphTypeGraph => "graph"
    DotGraphTypeDigraph => "digraph"
  }
}

///|
pub fn dot_graph_type_literal(graph_type : DotGraphType) -> String {
  dot_graph_type_name(graph_type)
}

///|
pub fn dot_graph_type_from_string(literal : String) -> DotGraphType? {
  if literal == "graph" {
    Some(DotGraphTypeGraph)
  } else if literal == "digraph" {
    Some(DotGraphTypeDigraph)
  } else {
    None
  }
}

///|
pub fn dot_graph_type_from_name(name : String) -> DotGraphType? {
  dot_graph_type_from_string(name)
}

///|
pub fn dot_graph_type_from_int(value : Int) -> DotGraphType? {
  if value == 0 {
    Some(DotGraphTypeGraph)
  } else if value == 1 {
    Some(DotGraphTypeDigraph)
  } else {
    None
  }
}

///|
pub fn dot_graph_type_to_string(graph_type : DotGraphType) -> String {
  dot_graph_type_literal(graph_type)
}
