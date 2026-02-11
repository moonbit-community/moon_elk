///|
pub struct LGraph {
  mut id : Int
  port_side_array_properties : Map[String, Array[PortSide]]
  int_properties : Map[String, Int]
  bool_properties : Map[String, Bool]
  double_properties : Map[String, Double]
  string_properties : Map[String, String]
  component_ordering_strategy_properties : Map[
    String,
    ComponentOrderingStrategy,
  ]
  direction_properties : Map[String, Direction]
  size : KVector
  offset : KVector
  layerless_nodes : Array[LNode]
  layers : Array[Layer]
  mut parent_node : LNode?
}

///|
pub fn new_l_graph() -> LGraph {
  {
    id: 0,
    port_side_array_properties: {},
    int_properties: {},
    bool_properties: {},
    double_properties: {},
    string_properties: {},
    component_ordering_strategy_properties: {},
    direction_properties: {},
    size: new_kvector(),
    offset: new_kvector(),
    layerless_nodes: [],
    layers: [],
    parent_node: None,
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

///|
pub fn LGraph::set_property_double(
  self : LGraph,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  self.double_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_double(
  self : LGraph,
  property : IProperty[Double],
) -> Double {
  match self.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::set_property_string(
  self : LGraph,
  property : IProperty[String],
  value : String,
) -> Unit {
  self.string_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_string(
  self : LGraph,
  property : IProperty[String],
) -> String {
  match self.string_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::set_property_component_ordering_strategy(
  self : LGraph,
  property : IProperty[ComponentOrderingStrategy],
  value : ComponentOrderingStrategy,
) -> Unit {
  self.component_ordering_strategy_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_component_ordering_strategy(
  self : LGraph,
  property : IProperty[ComponentOrderingStrategy],
) -> ComponentOrderingStrategy {
  match self.component_ordering_strategy_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::set_property_direction(
  self : LGraph,
  property : IProperty[Direction],
  value : Direction,
) -> Unit {
  self.direction_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_direction(
  self : LGraph,
  property : IProperty[Direction],
) -> Direction {
  match self.direction_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::get_size(self : LGraph) -> KVector {
  self.size
}

///|
pub fn LGraph::set_size_xy(self : LGraph, x : Double, y : Double) -> Unit {
  self.size.x = x
  self.size.y = y
}

///|
pub fn LGraph::get_offset(self : LGraph) -> KVector {
  self.offset
}

///|
pub fn LGraph::set_offset_xy(self : LGraph, x : Double, y : Double) -> Unit {
  self.offset.x = x
  self.offset.y = y
}

///|
pub fn LGraph::get_layerless_nodes(self : LGraph) -> Array[LNode] {
  self.layerless_nodes
}

///|
pub fn LGraph::get_layers(self : LGraph) -> Array[Layer] {
  self.layers
}

///|
pub fn LGraph::get_parent_node(self : LGraph) -> LNode? {
  self.parent_node
}

///|
pub fn LGraph::set_parent_node(self : LGraph, parent_node : LNode?) -> Unit {
  self.parent_node = parent_node
}

///|
pub fn LGraph::copy_properties(self : LGraph, source : LGraph) -> Unit {
  self.port_side_array_properties.clear()
  for entry in source.port_side_array_properties.to_array() {
    let (key, value) = entry
    self.port_side_array_properties[key] = value.copy()
  }

  self.int_properties.clear()
  for entry in source.int_properties.to_array() {
    let (key, value) = entry
    self.int_properties[key] = value
  }

  self.bool_properties.clear()
  for entry in source.bool_properties.to_array() {
    let (key, value) = entry
    self.bool_properties[key] = value
  }

  self.double_properties.clear()
  for entry in source.double_properties.to_array() {
    let (key, value) = entry
    self.double_properties[key] = value
  }

  self.string_properties.clear()
  for entry in source.string_properties.to_array() {
    let (key, value) = entry
    self.string_properties[key] = value
  }

  self.component_ordering_strategy_properties.clear()
  for entry in source.component_ordering_strategy_properties.to_array() {
    let (key, value) = entry
    self.component_ordering_strategy_properties[key] = value
  }

  self.direction_properties.clear()
  for entry in source.direction_properties.to_array() {
    let (key, value) = entry
    self.direction_properties[key] = value
  }
}
