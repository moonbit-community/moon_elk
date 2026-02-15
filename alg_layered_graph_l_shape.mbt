///|
pub struct LShape {
  graph_element : LGraphElement
  position : KVector
  size : KVector
}

///|
pub fn new_l_shape() -> LShape {
  {
    graph_element: new_l_graph_element(),
    position: new_kvector(),
    size: new_kvector(),
  }
}

///|
pub fn LShape::get_id(self : LShape) -> Int {
  self.graph_element.get_id()
}

///|
pub fn LShape::set_id(self : LShape, id : Int) -> Unit {
  self.graph_element.set_id(id)
}

///|
pub fn LShape::set_origin_identifier(
  self : LShape,
  identifier : String?,
) -> Unit {
  self.graph_element.set_origin_identifier(identifier)
}

///|
pub fn LShape::get_origin_identifier(self : LShape) -> String? {
  self.graph_element.get_origin_identifier()
}

///|
pub fn LShape::get_designation(self : LShape) -> String? {
  self.graph_element.get_designation()
}

///|
pub fn LShape::get_position(self : LShape) -> KVector {
  self.position
}

///|
pub fn LShape::get_size(self : LShape) -> KVector {
  self.size
}
