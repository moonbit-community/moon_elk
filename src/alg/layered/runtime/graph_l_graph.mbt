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
  priv mut port_side_array_properties : Map[
    @graph.PropertyId,
    Array[@core.PortSide],
  ]?
  priv mut graph_properties_array_properties : Map[
    @graph.PropertyId,
    Array[GraphProperties],
  ]?
  priv mut cross_hierarchy_map_entry_array_properties : Map[
    @graph.PropertyId,
    Array[(LEdge, (LEdge, LGraph, PortType))],
  ]?
  priv mut node_array_properties : Map[@graph.PropertyId, Array[LNode]]?
  priv mut int_properties : Map[@graph.PropertyId, Int]?
  priv mut bool_properties : Map[@graph.PropertyId, Bool]?
  priv mut double_properties : Map[@graph.PropertyId, Double]?
  priv mut string_properties : Map[@graph.PropertyId, String]?
  priv mut string_array_properties : Map[@graph.PropertyId, Array[String]]?
  priv mut label_manager_properties : Map[
    @graph.PropertyId,
    @core.ILabelManager,
  ]?
  priv mut spacings_properties : Map[@graph.PropertyId, Spacings]?
  priv mut elk_margin_properties : Map[@graph.PropertyId, @core.ElkMargin]?
  priv mut component_ordering_strategy_properties : Map[
    @graph.PropertyId,
    @options.ComponentOrderingStrategy,
  ]?
  priv mut direction_properties : Map[@graph.PropertyId, @core.Direction]?
  priv mut spline_routing_mode_properties : Map[
    @graph.PropertyId,
    @options.SplineRoutingMode,
  ]?
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
    port_side_array_properties: None,
    graph_properties_array_properties: None,
    cross_hierarchy_map_entry_array_properties: None,
    node_array_properties: None,
    int_properties: None,
    bool_properties: None,
    double_properties: None,
    string_properties: None,
    string_array_properties: None,
    label_manager_properties: None,
    spacings_properties: None,
    elk_margin_properties: None,
    component_ordering_strategy_properties: None,
    direction_properties: None,
    spline_routing_mode_properties: None,
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
  self.port_side_array_properties = Some(
    layered_property_bag_set(
      self.port_side_array_properties,
      property.get_property_id(),
      value.copy(),
    ),
  )
}

///|
pub fn LGraph::set_property_graph_properties_array(
  self : LGraph,
  property : @graph.IProperty[Array[GraphProperties]],
  value : Array[GraphProperties],
) -> Unit {
  self.graph_properties_array_properties = Some(
    layered_property_bag_set(
      self.graph_properties_array_properties,
      property.get_property_id(),
      value.copy(),
    ),
  )
}

///|
pub fn LGraph::get_property_port_side_array(
  self : LGraph,
  property : @graph.IProperty[Array[@core.PortSide]],
) -> Array[@core.PortSide] {
  match
    layered_property_bag_get(
      self.port_side_array_properties,
      property.get_property_id(),
    ) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::get_property_graph_properties_array(
  self : LGraph,
  property : @graph.IProperty[Array[GraphProperties]],
) -> Array[GraphProperties] {
  match
    layered_property_bag_get(
      self.graph_properties_array_properties,
      property.get_property_id(),
    ) {
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
  self.cross_hierarchy_map_entry_array_properties = Some(
    layered_property_bag_set(
      self.cross_hierarchy_map_entry_array_properties,
      property.get_property_id(),
      value.copy(),
    ),
  )
}

///|
pub fn LGraph::get_property_cross_hierarchy_map_entry_array(
  self : LGraph,
  property : @graph.IProperty[Array[(LEdge, (LEdge, LGraph, PortType))]],
) -> Array[(LEdge, (LEdge, LGraph, PortType))] {
  match
    layered_property_bag_get(
      self.cross_hierarchy_map_entry_array_properties,
      property.get_property_id(),
    ) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::has_property_cross_hierarchy_map_entry_array(
  self : LGraph,
  property : @graph.IProperty[Array[(LEdge, (LEdge, LGraph, PortType))]],
) -> Bool {
  layered_property_bag_has(
    self.cross_hierarchy_map_entry_array_properties,
    property.get_property_id(),
  )
}

///|
pub fn LGraph::set_property_l_node_array(
  self : LGraph,
  property : @graph.IProperty[Array[LNode]],
  value : Array[LNode],
) -> Unit {
  self.node_array_properties = Some(
    layered_property_bag_set(
      self.node_array_properties,
      property.get_property_id(),
      value.copy(),
    ),
  )
}

///|
pub fn LGraph::get_property_l_node_array(
  self : LGraph,
  property : @graph.IProperty[Array[LNode]],
) -> Array[LNode] {
  match
    layered_property_bag_get(
      self.node_array_properties,
      property.get_property_id(),
    ) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::has_property_l_node_array(
  self : LGraph,
  property : @graph.IProperty[Array[LNode]],
) -> Bool {
  layered_property_bag_has(
    self.node_array_properties,
    property.get_property_id(),
  )
}

///|
pub fn LGraph::set_property_int(
  self : LGraph,
  property : @graph.IProperty[Int],
  value : Int,
) -> Unit {
  self.int_properties = Some(
    layered_property_bag_set(
      self.int_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LGraph::get_property_int(
  self : LGraph,
  property : @graph.IProperty[Int],
) -> Int {
  match
    layered_property_bag_get(self.int_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_int(
  self : LGraph,
  property : @graph.IProperty[Int],
) -> Bool {
  layered_property_bag_has(self.int_properties, property.get_property_id())
}

///|
pub fn LGraph::set_property_bool(
  self : LGraph,
  property : @graph.IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties = Some(
    layered_property_bag_set(
      self.bool_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LGraph::get_property_bool(
  self : LGraph,
  property : @graph.IProperty[Bool],
) -> Bool {
  match
    layered_property_bag_get(self.bool_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_bool(
  self : LGraph,
  property : @graph.IProperty[Bool],
) -> Bool {
  layered_property_bag_has(self.bool_properties, property.get_property_id())
}

///|
pub fn LGraph::set_property_double(
  self : LGraph,
  property : @graph.IProperty[Double],
  value : Double,
) -> Unit {
  self.double_properties = Some(
    layered_property_bag_set(
      self.double_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LGraph::get_property_double(
  self : LGraph,
  property : @graph.IProperty[Double],
) -> Double {
  match
    layered_property_bag_get(self.double_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_double(
  self : LGraph,
  property : @graph.IProperty[Double],
) -> Bool {
  layered_property_bag_has(self.double_properties, property.get_property_id())
}

///|
pub fn LGraph::set_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
  value : String,
) -> Unit {
  self.string_properties = Some(
    layered_property_bag_set(
      self.string_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LGraph::set_property_string_array(
  self : LGraph,
  property : @graph.IProperty[Array[String]],
  value : Array[String],
) -> Unit {
  self.string_array_properties = Some(
    layered_property_bag_set(
      self.string_array_properties,
      property.get_property_id(),
      value.copy(),
    ),
  )
}

///|
pub fn LGraph::get_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
) -> String {
  match
    layered_property_bag_get(self.string_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
) -> Bool {
  layered_property_bag_has(self.string_properties, property.get_property_id())
}

///|
pub fn LGraph::clear_property_string(
  self : LGraph,
  property : @graph.IProperty[String],
) -> Unit {
  self.string_properties = layered_property_bag_remove(
    self.string_properties,
    property.get_property_id(),
  )
}

///|
pub fn LGraph::get_property_string_array(
  self : LGraph,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  match
    layered_property_bag_get(
      self.string_array_properties,
      property.get_property_id(),
    ) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LGraph::has_property_string_array(
  self : LGraph,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  layered_property_bag_has(
    self.string_array_properties,
    property.get_property_id(),
  )
}

///|
pub fn LGraph::set_property_i_label_manager(
  self : LGraph,
  property : @graph.IProperty[@core.ILabelManager?],
  value : @core.ILabelManager?,
) -> Unit {
  match value {
    Some(label_manager) =>
      self.label_manager_properties = Some(
        layered_property_bag_set(
          self.label_manager_properties,
          property.get_property_id(),
          label_manager,
        ),
      )
    None =>
      self.label_manager_properties = layered_property_bag_remove(
        self.label_manager_properties,
        property.get_property_id(),
      )
  }
}

///|
pub fn LGraph::get_property_i_label_manager(
  self : LGraph,
  property : @graph.IProperty[@core.ILabelManager?],
) -> @core.ILabelManager? {
  match
    layered_property_bag_get(
      self.label_manager_properties,
      property.get_property_id(),
    ) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_i_label_manager(
  self : LGraph,
  property : @graph.IProperty[@core.ILabelManager?],
) -> Bool {
  layered_property_bag_has(
    self.label_manager_properties,
    property.get_property_id(),
  )
}

///|
pub fn LGraph::set_property_spacings(
  self : LGraph,
  property : @graph.IProperty[Spacings?],
  value : Spacings?,
) -> Unit {
  match value {
    Some(spacings) =>
      self.spacings_properties = Some(
        layered_property_bag_set(
          self.spacings_properties,
          property.get_property_id(),
          spacings,
        ),
      )
    None =>
      self.spacings_properties = layered_property_bag_remove(
        self.spacings_properties,
        property.get_property_id(),
      )
  }
}

///|
pub fn LGraph::get_property_spacings(
  self : LGraph,
  property : @graph.IProperty[Spacings?],
) -> Spacings? {
  match
    layered_property_bag_get(
      self.spacings_properties,
      property.get_property_id(),
    ) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_spacings(
  self : LGraph,
  property : @graph.IProperty[Spacings?],
) -> Bool {
  layered_property_bag_has(self.spacings_properties, property.get_property_id())
}

///|
pub fn LGraph::set_property_elk_margin(
  self : LGraph,
  property : @graph.IProperty[@core.ElkMargin],
  value : @core.ElkMargin,
) -> Unit {
  self.elk_margin_properties = Some(
    layered_property_bag_set(
      self.elk_margin_properties,
      property.get_property_id(),
      value.clone(),
    ),
  )
}

///|
pub fn LGraph::get_property_elk_margin(
  self : LGraph,
  property : @graph.IProperty[@core.ElkMargin],
) -> @core.ElkMargin {
  match
    layered_property_bag_get(
      self.elk_margin_properties,
      property.get_property_id(),
    ) {
    Some(value) => value.clone()
    None => property.get_default().clone()
  }
}

///|
pub fn LGraph::has_property_elk_margin(
  self : LGraph,
  property : @graph.IProperty[@core.ElkMargin],
) -> Bool {
  layered_property_bag_has(
    self.elk_margin_properties,
    property.get_property_id(),
  )
}

///|
pub fn LGraph::set_property_component_ordering_strategy(
  self : LGraph,
  property : @graph.IProperty[@options.ComponentOrderingStrategy],
  value : @options.ComponentOrderingStrategy,
) -> Unit {
  self.component_ordering_strategy_properties = Some(
    layered_property_bag_set(
      self.component_ordering_strategy_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LGraph::get_property_component_ordering_strategy(
  self : LGraph,
  property : @graph.IProperty[@options.ComponentOrderingStrategy],
) -> @options.ComponentOrderingStrategy {
  match
    layered_property_bag_get(
      self.component_ordering_strategy_properties,
      property.get_property_id(),
    ) {
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
  self.direction_properties = Some(
    layered_property_bag_set(
      self.direction_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LGraph::get_property_direction(
  self : LGraph,
  property : @graph.IProperty[@core.Direction],
) -> @core.Direction {
  match
    layered_property_bag_get(
      self.direction_properties,
      property.get_property_id(),
    ) {
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
  self.spline_routing_mode_properties = Some(
    layered_property_bag_set(
      self.spline_routing_mode_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LGraph::get_property_spline_routing_mode(
  self : LGraph,
  property : @graph.IProperty[@options.SplineRoutingMode],
) -> @options.SplineRoutingMode {
  match
    layered_property_bag_get(
      self.spline_routing_mode_properties,
      property.get_property_id(),
    ) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LGraph::has_property_spline_routing_mode(
  self : LGraph,
  property : @graph.IProperty[@options.SplineRoutingMode],
) -> Bool {
  layered_property_bag_has(
    self.spline_routing_mode_properties,
    property.get_property_id(),
  )
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
pub fn LGraph::copy_properties(self : LGraph, source : LGraph) -> Unit {
  self.port_side_array_properties = layered_property_bag_copy(
    source.port_side_array_properties,
    value => value.copy(),
  )
  self.graph_properties_array_properties = layered_property_bag_copy(
    source.graph_properties_array_properties,
    value => value.copy(),
  )
  self.cross_hierarchy_map_entry_array_properties = layered_property_bag_copy(
    source.cross_hierarchy_map_entry_array_properties,
    value => value.copy(),
  )
  self.node_array_properties = layered_property_bag_copy(
    source.node_array_properties,
    value => value.copy(),
  )
  self.int_properties = layered_property_bag_copy(
    source.int_properties,
    layered_property_identity,
  )
  self.bool_properties = layered_property_bag_copy(
    source.bool_properties,
    layered_property_identity,
  )
  self.double_properties = layered_property_bag_copy(
    source.double_properties,
    layered_property_identity,
  )
  self.string_properties = layered_property_bag_copy(
    source.string_properties,
    layered_property_identity,
  )
  self.string_array_properties = layered_property_bag_copy(
    source.string_array_properties,
    value => value.copy(),
  )
  self.label_manager_properties = layered_property_bag_copy(
    source.label_manager_properties,
    layered_property_identity,
  )
  self.spacings_properties = layered_property_bag_copy(
    source.spacings_properties,
    layered_property_identity,
  )
  self.elk_margin_properties = layered_property_bag_copy(
    source.elk_margin_properties,
    value => value.clone(),
  )
  self.component_ordering_strategy_properties = layered_property_bag_copy(
    source.component_ordering_strategy_properties,
    layered_property_identity,
  )
  self.direction_properties = layered_property_bag_copy(
    source.direction_properties,
    layered_property_identity,
  )
  self.spline_routing_mode_properties = layered_property_bag_copy(
    source.spline_routing_mode_properties,
    layered_property_identity,
  )
}
