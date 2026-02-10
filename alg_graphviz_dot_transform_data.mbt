///|
pub enum DotGraphElement {
  DotGraphElementNode(ElkNode)
  DotGraphElementEdge(ElkEdge)
  DotGraphElementPort(ElkPort)
  DotGraphElementLabel(ElkLabel)
}

///|
pub fn dot_graph_element_node(node : ElkNode) -> DotGraphElement {
  DotGraphElementNode(node)
}

///|
pub fn dot_graph_element_edge(edge : ElkEdge) -> DotGraphElement {
  DotGraphElementEdge(edge)
}

///|
pub fn dot_graph_element_port(port : ElkPort) -> DotGraphElement {
  DotGraphElementPort(port)
}

///|
pub fn dot_graph_element_label(label : ElkLabel) -> DotGraphElement {
  DotGraphElementLabel(label)
}

///|
pub fn dot_graph_element_as_node(graph_element : DotGraphElement) -> ElkNode? {
  match graph_element {
    DotGraphElementNode(node) => Some(node)
    _ => None
  }
}

///|
pub fn dot_graph_element_as_edge(graph_element : DotGraphElement) -> ElkEdge? {
  match graph_element {
    DotGraphElementEdge(edge) => Some(edge)
    _ => None
  }
}

///|
pub struct DotTransformationData[S, T] {
  mut source_graph : S?
  target_graphs : Array[T]
  log_messages : Array[String]
  bool_properties : Map[String, Bool]
  int_properties : Map[String, Int]
  string_properties : Map[String, String]
  command_properties : Map[String, Command]
  graph_elem_map_properties : Map[String, Map[String, DotGraphElement]]
}

///|
pub type IDotTransformationData[S, T] = DotTransformationData[S, T]

///|
pub fn[S, T] new_dot_transformation_data() -> DotTransformationData[S, T] {
  {
    source_graph: None,
    target_graphs: [],
    log_messages: [],
    bool_properties: {},
    int_properties: {},
    string_properties: {},
    command_properties: {},
    graph_elem_map_properties: {},
  }
}

///|
pub fn[S, T] DotTransformationData::set_source_graph(
  self : DotTransformationData[S, T],
  src_graph : S,
) -> Unit {
  self.source_graph = Some(src_graph)
}

///|
pub fn[S, T] DotTransformationData::get_source_graph(
  self : DotTransformationData[S, T],
) -> S? {
  self.source_graph
}

///|
pub fn[S, T] DotTransformationData::get_target_graphs(
  self : DotTransformationData[S, T],
) -> Array[T] {
  self.target_graphs
}

///|
pub fn[S, T] DotTransformationData::log(
  self : DotTransformationData[S, T],
  msg : String,
) -> Unit {
  self.log_messages.push(msg)
}

///|
pub fn[S, T] DotTransformationData::get_messages(
  self : DotTransformationData[S, T],
) -> Array[String] {
  self.log_messages
}

///|
pub fn[S, T] DotTransformationData::set_bool_property(
  self : DotTransformationData[S, T],
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn[S, T] DotTransformationData::get_bool_property(
  self : DotTransformationData[S, T],
  property : IProperty[Bool],
) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn[S, T] DotTransformationData::set_int_property(
  self : DotTransformationData[S, T],
  property : IProperty[Int],
  value : Int,
) -> Unit {
  self.int_properties[property.get_id()] = value
}

///|
pub fn[S, T] DotTransformationData::get_int_property(
  self : DotTransformationData[S, T],
  property : IProperty[Int],
) -> Int {
  match self.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn[S, T] DotTransformationData::set_string_property(
  self : DotTransformationData[S, T],
  property : IProperty[String],
  value : String,
) -> Unit {
  self.string_properties[property.get_id()] = value
}

///|
pub fn[S, T] DotTransformationData::get_string_property(
  self : DotTransformationData[S, T],
  property : IProperty[String],
) -> String {
  match self.string_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn[S, T] DotTransformationData::set_command_property(
  self : DotTransformationData[S, T],
  property : IProperty[Command],
  value : Command,
) -> Unit {
  self.command_properties[property.get_id()] = value
}

///|
pub fn[S, T] DotTransformationData::get_command_property(
  self : DotTransformationData[S, T],
  property : IProperty[Command],
) -> Command {
  match self.command_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
fn dot_graph_elem_map_clone(
  source : Map[String, DotGraphElement],
) -> Map[String, DotGraphElement] {
  let copied : Map[String, DotGraphElement] = {}
  for entry in source.to_array() {
    copied[entry.0] = entry.1
  }
  copied
}

///|
pub fn[S, T] DotTransformationData::set_graph_elem_map_property(
  self : DotTransformationData[S, T],
  property : IProperty[Map[String, DotGraphElement]],
  value : Map[String, DotGraphElement],
) -> Unit {
  self.graph_elem_map_properties[property.get_id()] = value
}

///|
pub fn[S, T] DotTransformationData::get_graph_elem_map_property(
  self : DotTransformationData[S, T],
  property : IProperty[Map[String, DotGraphElement]],
) -> Map[String, DotGraphElement] {
  match self.graph_elem_map_properties.get(property.get_id()) {
    Some(value) => value
    None => {
      let created = dot_graph_elem_map_clone(property.get_default())
      self.graph_elem_map_properties[property.get_id()] = created
      created
    }
  }
}
