///|
let layered_l_graph_next_handle : Ref[Int] = Ref(1)

///|
fn layered_l_graph_allocate_handle() -> Int {
  let handle = layered_l_graph_next_handle.val
  layered_l_graph_next_handle.val = handle + 1
  handle
}

///|
pub struct LGraph {
  mut id : Int
  handle : Int
  port_side_array_properties : Map[String, Array[@core.PortSide]]
  graph_properties_array_properties : Map[String, Array[GraphProperties]]
  cross_hierarchy_map_entry_array_properties : Map[
    String,
    Array[(LEdge, (LEdge, LGraph, PortType))],
  ]
  node_array_properties : Map[String, Array[LNode]]
  mut layout_state : LayeredLayoutState
  int_properties : Map[String, Int]
  bool_properties : Map[String, Bool]
  double_properties : Map[String, Double]
  string_properties : Map[String, String]
  string_array_properties : Map[String, Array[String]]
  label_manager_properties : Map[String, @core.ILabelManager]
  spacings_properties : Map[String, Spacings]
  elk_margin_properties : Map[String, @core.ElkMargin]
  component_ordering_strategy_properties : Map[
    String,
    @options.ComponentOrderingStrategy,
  ]
  direction_properties : Map[String, @core.Direction]
  spline_routing_mode_properties : Map[String, @options.SplineRoutingMode]
  size : @core.KVector
  padding : LPadding
  offset : @core.KVector
  layerless_nodes : Array[LNode]
  layers : Array[Layer]
  mut parent_node : LNode?
}

///|
pub fn new_l_graph() -> LGraph {
  {
    id: 0,
    handle: layered_l_graph_allocate_handle(),
    port_side_array_properties: Map([]),
    graph_properties_array_properties: Map([]),
    cross_hierarchy_map_entry_array_properties: Map([]),
    node_array_properties: Map([]),
    layout_state: new_layered_layout_state(),
    int_properties: Map([]),
    bool_properties: Map([]),
    double_properties: Map([]),
    string_properties: Map([]),
    string_array_properties: Map([]),
    label_manager_properties: Map([]),
    spacings_properties: Map([]),
    elk_margin_properties: Map([]),
    component_ordering_strategy_properties: Map([]),
    direction_properties: Map([]),
    spline_routing_mode_properties: Map([]),
    size: @core.new_kvector(),
    padding: new_l_padding(),
    offset: @core.new_kvector(),
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
pub fn LGraph::get_handle(self : LGraph) -> Int {
  self.handle
}

///|
pub fn LGraph::get_id(self : LGraph) -> Int {
  self.id
}

///|
pub fn LGraph::set_property_port_side_array(
  self : LGraph,
  property : @graph.IProperty[Array[@core.PortSide]],
  value : Array[@core.PortSide],
) -> Unit {
  self.port_side_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LGraph::set_property_graph_properties_array(
  self : LGraph,
  property : @graph.IProperty[Array[GraphProperties]],
  value : Array[GraphProperties],
) -> Unit {
  self.graph_properties_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LGraph::get_property_port_side_array(
  self : LGraph,
  property : @graph.IProperty[Array[@core.PortSide]],
) -> Array[@core.PortSide] {
  match self.port_side_array_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::get_property_graph_properties_array(
  self : LGraph,
  property : @graph.IProperty[Array[GraphProperties]],
) -> Array[GraphProperties] {
  match self.graph_properties_array_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::set_property_cross_hierarchy_map_entry_array(
  self : LGraph,
  property : @graph.IProperty[Array[(LEdge, (LEdge, LGraph, PortType))]],
  value : Array[(LEdge, (LEdge, LGraph, PortType))],
) -> Unit {
  self.cross_hierarchy_map_entry_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LGraph::get_property_cross_hierarchy_map_entry_array(
  self : LGraph,
  property : @graph.IProperty[Array[(LEdge, (LEdge, LGraph, PortType))]],
) -> Array[(LEdge, (LEdge, LGraph, PortType))] {
  match self.cross_hierarchy_map_entry_array_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::has_property_cross_hierarchy_map_entry_array(
  self : LGraph,
  property : @graph.IProperty[Array[(LEdge, (LEdge, LGraph, PortType))]],
) -> Bool {
  self.cross_hierarchy_map_entry_array_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_l_node_array(
  self : LGraph,
  property : @graph.IProperty[Array[LNode]],
  value : Array[LNode],
) -> Unit {
  self.node_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LGraph::get_property_l_node_array(
  self : LGraph,
  property : @graph.IProperty[Array[LNode]],
) -> Array[LNode] {
  match self.node_array_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::has_property_l_node_array(
  self : LGraph,
  property : @graph.IProperty[Array[LNode]],
) -> Bool {
  self.node_array_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_int(
  self : LGraph,
  property : @graph.IProperty[Int],
  value : Int,
) -> Unit {
  self.int_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_int(
  self : LGraph,
  property : @graph.IProperty[Int],
) -> Int {
  match self.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_int(
  self : LGraph,
  property : @graph.IProperty[Int],
) -> Bool {
  self.int_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_bool(
  self : LGraph,
  property : @graph.IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_bool(
  self : LGraph,
  property : @graph.IProperty[Bool],
) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_bool(
  self : LGraph,
  property : @graph.IProperty[Bool],
) -> Bool {
  self.bool_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_double(
  self : LGraph,
  property : @graph.IProperty[Double],
  value : Double,
) -> Unit {
  self.double_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_double(
  self : LGraph,
  property : @graph.IProperty[Double],
) -> Double {
  match self.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_double(
  self : LGraph,
  property : @graph.IProperty[Double],
) -> Bool {
  self.double_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
  value : String,
) -> Unit {
  self.string_properties[property.get_id()] = value
}

///|
pub fn LGraph::set_property_string_array(
  self : LGraph,
  property : @graph.IProperty[Array[String]],
  value : Array[String],
) -> Unit {
  self.string_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LGraph::get_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
) -> String {
  match self.string_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
) -> Bool {
  self.string_properties.contains(property.get_id())
}

///|
pub fn LGraph::clear_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
) -> Unit {
  ignore(self.string_properties.remove(property.get_id()))
}

///|
pub fn LGraph::get_property_string_array(
  self : LGraph,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  match self.string_array_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::has_property_string_array(
  self : LGraph,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  self.string_array_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_i_label_manager(
  self : LGraph,
  property : @graph.IProperty[@core.ILabelManager?],
  value : @core.ILabelManager?,
) -> Unit {
  match value {
    Some(label_manager) =>
      self.label_manager_properties[property.get_id()] = label_manager
    None => ignore(self.label_manager_properties.remove(property.get_id()))
  }
}

///|
pub fn LGraph::get_property_i_label_manager(
  self : LGraph,
  property : @graph.IProperty[@core.ILabelManager?],
) -> @core.ILabelManager? {
  match self.label_manager_properties.get(property.get_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_i_label_manager(
  self : LGraph,
  property : @graph.IProperty[@core.ILabelManager?],
) -> Bool {
  self.label_manager_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_spacings(
  self : LGraph,
  property : @graph.IProperty[Spacings?],
  value : Spacings?,
) -> Unit {
  match value {
    Some(spacings) => self.spacings_properties[property.get_id()] = spacings
    None => ignore(self.spacings_properties.remove(property.get_id()))
  }
}

///|
pub fn LGraph::get_property_spacings(
  self : LGraph,
  property : @graph.IProperty[Spacings?],
) -> Spacings? {
  match self.spacings_properties.get(property.get_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_spacings(
  self : LGraph,
  property : @graph.IProperty[Spacings?],
) -> Bool {
  self.spacings_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_elk_margin(
  self : LGraph,
  property : @graph.IProperty[@core.ElkMargin],
  value : @core.ElkMargin,
) -> Unit {
  self.elk_margin_properties[property.get_id()] = value.clone()
}

///|
pub fn LGraph::get_property_elk_margin(
  self : LGraph,
  property : @graph.IProperty[@core.ElkMargin],
) -> @core.ElkMargin {
  match self.elk_margin_properties.get(property.get_id()) {
    Some(value) => value.clone()
    None => property.get_default().clone()
  }
}

///|
pub fn LGraph::has_property_elk_margin(
  self : LGraph,
  property : @graph.IProperty[@core.ElkMargin],
) -> Bool {
  self.elk_margin_properties.contains(property.get_id())
}

///|
pub fn LGraph::set_property_component_ordering_strategy(
  self : LGraph,
  property : @graph.IProperty[@options.ComponentOrderingStrategy],
  value : @options.ComponentOrderingStrategy,
) -> Unit {
  self.component_ordering_strategy_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_component_ordering_strategy(
  self : LGraph,
  property : @graph.IProperty[@options.ComponentOrderingStrategy],
) -> @options.ComponentOrderingStrategy {
  match self.component_ordering_strategy_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::set_property_direction(
  self : LGraph,
  property : @graph.IProperty[@core.Direction],
  value : @core.Direction,
) -> Unit {
  self.direction_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_direction(
  self : LGraph,
  property : @graph.IProperty[@core.Direction],
) -> @core.Direction {
  match self.direction_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::set_property_spline_routing_mode(
  self : LGraph,
  property : @graph.IProperty[@options.SplineRoutingMode],
  value : @options.SplineRoutingMode,
) -> Unit {
  self.spline_routing_mode_properties[property.get_id()] = value
}

///|
pub fn LGraph::get_property_spline_routing_mode(
  self : LGraph,
  property : @graph.IProperty[@options.SplineRoutingMode],
) -> @options.SplineRoutingMode {
  match self.spline_routing_mode_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_spline_routing_mode(
  self : LGraph,
  property : @graph.IProperty[@options.SplineRoutingMode],
) -> Bool {
  self.spline_routing_mode_properties.contains(property.get_id())
}

///|
pub fn LGraph::get_size(self : LGraph) -> @core.KVector {
  self.size
}

///|
pub fn LGraph::set_size_xy(self : LGraph, x : Double, y : Double) -> Unit {
  self.size.x = x
  self.size.y = y
}

///|
pub fn LGraph::get_actual_size(self : LGraph) -> @core.KVector {
  @core.new_kvector_xy(
    self.size.x + self.padding.left + self.padding.right,
    self.size.y + self.padding.top + self.padding.bottom,
  )
}

///|
pub fn LGraph::get_padding(self : LGraph) -> LPadding {
  self.padding
}

///|
pub fn LGraph::get_offset(self : LGraph) -> @core.KVector {
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
pub fn LGraph::get_layout_state(self : LGraph) -> LayeredLayoutState {
  self.layout_state
}

///|
pub fn LGraph::copy_properties(self : LGraph, source : LGraph) -> Unit {
  // Component graphs participate in the same execution plan and must consume
  // the same transient state, especially the deterministic random sequence.
  self.layout_state = source.layout_state

  self.port_side_array_properties.clear()
  for entry in source.port_side_array_properties.to_array() {
    let (key, value) = entry
    self.port_side_array_properties[key] = value.copy()
  }

  self.graph_properties_array_properties.clear()
  for entry in source.graph_properties_array_properties.to_array() {
    let (key, value) = entry
    self.graph_properties_array_properties[key] = value.copy()
  }

  self.cross_hierarchy_map_entry_array_properties.clear()
  for entry in source.cross_hierarchy_map_entry_array_properties.to_array() {
    let (key, value) = entry
    self.cross_hierarchy_map_entry_array_properties[key] = value.copy()
  }

  self.node_array_properties.clear()
  for entry in source.node_array_properties.to_array() {
    let (key, value) = entry
    self.node_array_properties[key] = value.copy()
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

  self.string_array_properties.clear()
  for entry in source.string_array_properties.to_array() {
    let (key, value) = entry
    self.string_array_properties[key] = value.copy()
  }

  self.label_manager_properties.clear()
  for entry in source.label_manager_properties.to_array() {
    let (key, value) = entry
    self.label_manager_properties[key] = value
  }

  self.spacings_properties.clear()
  for entry in source.spacings_properties.to_array() {
    let (key, value) = entry
    self.spacings_properties[key] = value
  }

  self.elk_margin_properties.clear()
  for entry in source.elk_margin_properties.to_array() {
    let (key, value) = entry
    self.elk_margin_properties[key] = value.clone()
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

  self.spline_routing_mode_properties.clear()
  for entry in source.spline_routing_mode_properties.to_array() {
    let (key, value) = entry
    self.spline_routing_mode_properties[key] = value
  }
}
