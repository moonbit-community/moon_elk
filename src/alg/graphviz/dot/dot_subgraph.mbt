///|
pub struct DotSubgraph {
  mut name : String?
  statements : Array[DotStatement]
}

///|
pub fn dot_create_subgraph() -> DotSubgraph {
  { name: None, statements: [] }
}

///|
pub fn DotSubgraph::get_name(self : DotSubgraph) -> String? {
  self.name
}

///|
pub fn DotSubgraph::set_name(self : DotSubgraph, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotSubgraph::get_statements(self : DotSubgraph) -> Array[DotStatement] {
  self.statements
}
