///|
pub enum EdgeType {
  NoneType
  Directed
  Undirected
  Association
  Generalization
  Dependency
}

///|
pub fn edge_type_to_string(edge_type : EdgeType) -> String {
  match edge_type {
    NoneType => "NONE"
    Directed => "DIRECTED"
    Undirected => "UNDIRECTED"
    Association => "ASSOCIATION"
    Generalization => "GENERALIZATION"
    Dependency => "DEPENDENCY"
  }
}
