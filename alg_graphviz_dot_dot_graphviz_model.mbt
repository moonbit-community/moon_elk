///|
pub struct DotGraphvizModel {
  graphs : Array[DotGraph]
}

///|
pub fn dot_create_graphviz_model() -> DotGraphvizModel {
  { graphs: [] }
}

///|
pub fn DotGraphvizModel::get_graphs(self : DotGraphvizModel) -> Array[DotGraph] {
  self.graphs
}
