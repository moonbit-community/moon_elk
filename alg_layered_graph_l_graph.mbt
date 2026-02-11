///|
pub struct LGraph {
  mut id : Int
  port_side_array_properties : Map[String, Array[PortSide]]
  int_properties : Map[String, Int]
  bool_properties : Map[String, Bool]
}

///|
pub fn new_l_graph() -> LGraph {
  {
    id: 0,
    port_side_array_properties: {},
    int_properties: {},
    bool_properties: {},
  }
}

///|
pub fn LGraph::set_id(self : LGraph, id : Int) -> Unit {
  self.id = id
}

///|
pub fn LGraph::get_id(self : LGraph) -> Int {
  self.id
}

///|
pub fn LGraph::set_property_port_side_array(
  self : LGraph,
  property : IProperty[Array[PortSide]],
  value : Array[PortSide],
) -> Unit {
  self.port_side_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LGraph::get_property_port_side_array(
  self : LGraph,
  property : IProperty[Array[PortSide]],
) -> Array[PortSide] {
  match self.port_side_array_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::set_property_int(
  self : LGraph,
  property : IProperty[Int],
  value : Int,
) -> Unit {
  self.int_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_int(
  self : LGraph,
  property : IProperty[Int],
) -> Int {
  match self.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::set_property_bool(
  self : LGraph,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_bool(
  self : LGraph,
  property : IProperty[Bool],
) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}
