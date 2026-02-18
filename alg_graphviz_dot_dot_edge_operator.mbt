///|
pub enum DotEdgeOperator {
  DotEdgeOperatorDirected
  DotEdgeOperatorUndirected
}

///|
pub fn dot_edge_operator_directed() -> DotEdgeOperator {
  DotEdgeOperatorDirected
}

///|
pub fn dot_edge_operator_undirected() -> DotEdgeOperator {
  DotEdgeOperatorUndirected
}

///|
pub fn dot_edge_operator_value(edge_operator : DotEdgeOperator) -> Int {
  match edge_operator {
    DotEdgeOperatorDirected => 0
    DotEdgeOperatorUndirected => 1
  }
}

///|
pub fn dot_edge_operator_name(edge_operator : DotEdgeOperator) -> String {
  match edge_operator {
    DotEdgeOperatorDirected => "directed"
    DotEdgeOperatorUndirected => "undirected"
  }
}

///|
pub fn dot_edge_operator_literal(edge_operator : DotEdgeOperator) -> String {
  match edge_operator {
    DotEdgeOperatorDirected => "->"
    DotEdgeOperatorUndirected => "--"
  }
}

///|
pub fn dot_edge_operator_from_string(literal : String) -> DotEdgeOperator? {
  if literal == "->" {
    Some(DotEdgeOperatorDirected)
  } else if literal == "--" {
    Some(DotEdgeOperatorUndirected)
  } else {
    None
  }
}

///|
pub fn dot_edge_operator_from_name(name : String) -> DotEdgeOperator? {
  if name == "directed" {
    Some(DotEdgeOperatorDirected)
  } else if name == "undirected" {
    Some(DotEdgeOperatorUndirected)
  } else {
    None
  }
}

///|
pub fn dot_edge_operator_from_int(value : Int) -> DotEdgeOperator? {
  if value == 0 {
    Some(DotEdgeOperatorDirected)
  } else if value == 1 {
    Some(DotEdgeOperatorUndirected)
  } else {
    None
  }
}

///|
pub fn dot_edge_operator_to_string(edge_operator : DotEdgeOperator) -> String {
  dot_edge_operator_literal(edge_operator)
}
