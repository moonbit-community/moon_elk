///|
pub struct DotGraph {
  mut strict : Bool
  mut type_ : DotGraphType
  mut name : String?
  statements : Array[DotStatement]
}

///|
pub fn dot_create_graph() -> DotGraph {
  { strict: false, type_: DotGraphTypeGraph, name: None, statements: [] }
}

///|
pub fn DotGraph::is_strict(self : DotGraph) -> Bool {
  self.strict
}

///|
pub fn DotGraph::set_strict(self : DotGraph, value : Bool) -> Unit {
  self.strict = value
}

///|
pub fn DotGraph::get_type(self : DotGraph) -> DotGraphType {
  self.type_
}

///|
pub fn DotGraph::set_type(self : DotGraph, value : DotGraphType?) -> Unit {
  match value {
    Some(v) => self.type_ = v
    None => self.type_ = DotGraphTypeGraph
  }
}

///|
pub fn DotGraph::get_name(self : DotGraph) -> String? {
  self.name
}

///|
pub fn DotGraph::set_name(self : DotGraph, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotGraph::get_statements(self : DotGraph) -> Array[DotStatement] {
  self.statements
}
