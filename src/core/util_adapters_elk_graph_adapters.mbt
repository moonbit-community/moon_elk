///|
let elk_graph_adapters_margins_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.margins", "[top=0,left=0,bottom=0,right=0]",
)

///|
let elk_graph_adapters_port_border_offset_property : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.port.borderOffset", 0.0,
)

///|
let elk_graph_adapters_inside_self_loops_yo_property : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.insideSelfLoops.yo", false,
)

///|
let elk_graph_adapters_port_index_property : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.port.index", -1,
)

///|
let elk_graph_adapters_label_side_property : @graph.IProperty[String] = @graph.new_property(
  "labelSide", "UNKNOWN",
)

///|
fn elk_graph_adapters_parse_int(raw : String) -> Int? {
  try @strconv.parse_int(raw.trim().to_string()) catch {
    _ => None
  } noraise {
    value => Some(value)
  }
}

///|
fn elk_graph_adapters_parse_double(raw : String) -> Double? {
  try @strconv.parse_double(raw.trim().to_string()) catch {
    _ => None
  } noraise {
    value => Some(value)
  }
}

///|
fn elk_graph_adapters_parse_bool(raw : String) -> Bool? {
  match raw.trim().to_string() {
    "true" => Some(true)
    "TRUE" => Some(true)
    "True" => Some(true)
    "1" => Some(true)
    "false" => Some(false)
    "FALSE" => Some(false)
    "False" => Some(false)
    "0" => Some(false)
    _ => None
  }
}

///|
fn elk_graph_adapters_parse_port_constraints(raw : String) -> PortConstraints {
  match raw {
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn elk_graph_adapters_parse_port_side(raw : String) -> PortSide {
  match raw {
    "NORTH" => PortSide::North
    "EAST" => PortSide::East
    "SOUTH" => PortSide::South
    "WEST" => PortSide::West
    _ => PortSide::SideUndefined
  }
}

///|
fn elk_graph_adapters_parse_label_side(raw : String) -> LabelSide {
  match raw {
    "ABOVE" => LabelSide::Above
    "BELOW" => LabelSide::Below
    "INLINE" => LabelSide::Inline
    _ => LabelSide::Unknown
  }
}

///|
fn elk_graph_adapters_compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn elk_graph_adapters_port_side_rank(side : PortSide) -> Int {
  match side {
    PortSide::SideUndefined => 0
    PortSide::North => 1
    PortSide::East => 2
    PortSide::South => 3
    PortSide::West => 4
  }
}

///|
fn elk_graph_adapters_node_padding(node : @graph.ElkNode) -> ElkPadding {
  if @graph.node_has_string_property(node, padding) {
    let parsed = new_elk_padding()
    parsed.parse(@graph.node_get_string_property(node, padding))
    return parsed
  }

  match @graph.node_layout_option_string_value(node, padding.get_id()) {
    Some(raw) => {
      let parsed = new_elk_padding()
      parsed.parse(raw)
      parsed
    }
    None => new_elk_padding()
  }
}

///|
fn elk_graph_adapters_node_set_padding(
  node : @graph.ElkNode,
  padding_value : ElkPadding,
) -> Unit {
  let copied = new_elk_padding_copy(padding_value)
  let text = copied.to_string()
  @graph.node_set_string_property(node, padding, text)
  @graph.node_set_layout_option_string_by_id(node, padding.get_id(), text)
}

///|
fn elk_graph_adapters_node_margin(node : @graph.ElkNode) -> ElkMargin {
  if @graph.node_has_string_property(node, elk_graph_adapters_margins_property) {
    let parsed = new_elk_margin()
    parsed.parse(
      @graph.node_get_string_property(node, elk_graph_adapters_margins_property),
    )
    return parsed
  }

  match
    @graph.node_layout_option_string_value(
      node,
      elk_graph_adapters_margins_property.get_id(),
    ) {
    Some(raw) => {
      let parsed = new_elk_margin()
      parsed.parse(raw)
      parsed
    }
    None => new_elk_margin()
  }
}

///|
fn elk_graph_adapters_node_set_margin(
  node : @graph.ElkNode,
  margin_value : ElkMargin,
) -> Unit {
  let copied = new_elk_margin_copy(margin_value)
  let text = copied.to_string()
  @graph.node_set_string_property(
    node, elk_graph_adapters_margins_property, text,
  )
  @graph.node_set_layout_option_string_by_id(
    node,
    elk_graph_adapters_margins_property.get_id(),
    text,
  )
}

///|
fn elk_graph_adapters_port_margin(port : @graph.ElkPort) -> ElkMargin {
  match
    @graph.port_layout_option_string_value(
      port,
      elk_graph_adapters_margins_property.get_id(),
    ) {
    Some(raw) => {
      let parsed = new_elk_margin()
      parsed.parse(raw)
      parsed
    }
    None => new_elk_margin()
  }
}

///|
fn elk_graph_adapters_port_set_margin(
  port : @graph.ElkPort,
  margin_value : ElkMargin,
) -> Unit {
  let copied = new_elk_margin_copy(margin_value)
  @graph.port_set_layout_option_string_by_id(
    port,
    elk_graph_adapters_margins_property.get_id(),
    copied.to_string(),
  )
}

///|
fn elk_graph_adapters_node_port_constraints(
  node : @graph.ElkNode,
) -> PortConstraints {
  if @graph.node_has_string_property(node, port_constraints) {
    return elk_graph_adapters_parse_port_constraints(
      @graph.node_get_string_property(node, port_constraints),
    )
  }

  match
    @graph.node_layout_option_string_value(node, port_constraints.get_id()) {
    Some(raw) => elk_graph_adapters_parse_port_constraints(raw)
    None =>
      elk_graph_adapters_parse_port_constraints(port_constraints.get_default())
  }
}

///|
fn elk_graph_adapters_node_inside_self_loops_activate(
  node : @graph.ElkNode,
) -> Bool {
  if @graph.node_has_bool_property(node, inside_self_loops_activate) {
    return @graph.node_get_bool_property(node, inside_self_loops_activate)
  }

  match
    @graph.node_layout_option_string_value(
      node,
      inside_self_loops_activate.get_id(),
    ) {
    Some(raw) =>
      match elk_graph_adapters_parse_bool(raw) {
        Some(value) => value
        None => inside_self_loops_activate.get_default()
      }
    None => inside_self_loops_activate.get_default()
  }
}

///|
fn elk_graph_adapters_port_side(port : @graph.ElkPort) -> PortSide {
  match @graph.port_layout_option_string_value(port, port_side.get_id()) {
    Some(raw) => elk_graph_adapters_parse_port_side(raw)
    None => elk_graph_adapters_parse_port_side(port_side.get_default())
  }
}

///|
fn elk_graph_adapters_port_index(port : @graph.ElkPort) -> Int? {
  match
    @graph.port_layout_option_string_value(
      port,
      elk_graph_adapters_port_index_property.get_id(),
    ) {
    Some(raw) => elk_graph_adapters_parse_int(raw)
    None => None
  }
}

///|
fn elk_graph_adapters_edge_inside_self_loops_yo(edge : @graph.ElkEdge) -> Bool {
  match
    @graph.edge_layout_option_string_value(
      edge,
      elk_graph_adapters_inside_self_loops_yo_property.get_id(),
    ) {
    Some(raw) =>
      match elk_graph_adapters_parse_bool(raw) {
        Some(value) => value
        None => elk_graph_adapters_inside_self_loops_yo_property.get_default()
      }
    None => elk_graph_adapters_inside_self_loops_yo_property.get_default()
  }
}

///|
fn elk_graph_adapters_port_double_option_or_default(
  port : @graph.ElkPort,
  option : @graph.IProperty[Double],
) -> Double {
  match @graph.port_layout_option_string_value(port, option.get_id()) {
    Some(raw) =>
      match elk_graph_adapters_parse_double(raw) {
        Some(value) => value
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_label_double_option_or_default(
  label : @graph.ElkLabel,
  option : @graph.IProperty[Double],
) -> Double {
  match @graph.label_layout_option_string_value(label, option.get_id()) {
    Some(raw) =>
      match elk_graph_adapters_parse_double(raw) {
        Some(value) => value
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_port_int_option_or_default(
  port : @graph.ElkPort,
  option : @graph.IProperty[Int],
) -> Int {
  match @graph.port_layout_option_string_value(port, option.get_id()) {
    Some(raw) =>
      match elk_graph_adapters_parse_int(raw) {
        Some(value) => value
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_label_int_option_or_default(
  label : @graph.ElkLabel,
  option : @graph.IProperty[Int],
) -> Int {
  match @graph.label_layout_option_string_value(label, option.get_id()) {
    Some(raw) =>
      match elk_graph_adapters_parse_int(raw) {
        Some(value) => value
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_port_bool_option_or_default(
  port : @graph.ElkPort,
  option : @graph.IProperty[Bool],
) -> Bool {
  match @graph.port_layout_option_string_value(port, option.get_id()) {
    Some(raw) =>
      match elk_graph_adapters_parse_bool(raw) {
        Some(value) => value
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_label_bool_option_or_default(
  label : @graph.ElkLabel,
  option : @graph.IProperty[Bool],
) -> Bool {
  match @graph.label_layout_option_string_value(label, option.get_id()) {
    Some(raw) =>
      match elk_graph_adapters_parse_bool(raw) {
        Some(value) => value
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_port_string_option_or_default(
  port : @graph.ElkPort,
  option : @graph.IProperty[String],
) -> String {
  match @graph.port_layout_option_string_value(port, option.get_id()) {
    Some(raw) => raw
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_label_string_option_or_default(
  label : @graph.ElkLabel,
  option : @graph.IProperty[String],
) -> String {
  match @graph.label_layout_option_string_value(label, option.get_id()) {
    Some(raw) => raw
    None => option.get_default()
  }
}

///|
fn elk_graph_adapters_port_string_array_option_or_default(
  port : @graph.ElkPort,
  option : @graph.IProperty[Array[String]],
) -> Array[String] {
  match @graph.port_layout_option_string_value(port, option.get_id()) {
    Some(raw) => [raw]
    None => option.get_default().copy()
  }
}

///|
fn elk_graph_adapters_label_string_array_option_or_default(
  label : @graph.ElkLabel,
  option : @graph.IProperty[Array[String]],
) -> Array[String] {
  match @graph.label_layout_option_string_value(label, option.get_id()) {
    Some(raw) => [raw]
    None => option.get_default().copy()
  }
}

///|
pub fn adapt(graph : @graph.ElkNode) -> ElkGraphAdapter {
  new_elk_graph_adapter(graph)
}

///|
pub fn adapt_single_node(node : @graph.ElkNode) -> ElkNodeAdapter {
  if @graph.node_parent(node) is Some(parent) {
    return new_elk_node_adapter(Some(adapt(parent)), node)
  }
  new_elk_node_adapter(None, node)
}

///|
pub fn adapt_single_port(port : @graph.ElkPort) -> ElkPortAdapter {
  new_elk_port_adapter(port)
}

///|
pub(all) struct ElkGraphAdapter {
  element : @graph.ElkNode
  mut child_nodes : Array[ElkNodeAdapter]?
  mut volatile_id : Int
}

///|
pub fn new_elk_graph_adapter(node : @graph.ElkNode) -> ElkGraphAdapter {
  { element: node, child_nodes: None, volatile_id: 0 }
}

///|
pub fn ElkGraphAdapter::get_size(self : ElkGraphAdapter) -> KVector {
  new_kvector_xy(
    @graph.node_width(self.element),
    @graph.node_height(self.element),
  )
}

///|
pub fn ElkGraphAdapter::set_size(
  self : ElkGraphAdapter,
  size : KVector,
) -> Unit {
  @graph.node_set_dimensions(self.element, size.x, size.y)
}

///|
pub fn ElkGraphAdapter::get_position(self : ElkGraphAdapter) -> KVector {
  new_kvector_xy(@graph.node_x(self.element), @graph.node_y(self.element))
}

///|
pub fn ElkGraphAdapter::set_position(
  self : ElkGraphAdapter,
  pos : KVector,
) -> Unit {
  @graph.node_set_location(self.element, pos.x, pos.y)
}

///|
pub fn ElkGraphAdapter::get_property_int(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Int],
) -> Int {
  @graph.node_get_int_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::has_property_int(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Int],
) -> Bool {
  @graph.node_has_int_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::get_property_bool(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.node_get_bool_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::has_property_bool(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.node_has_bool_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::get_property_double(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Double],
) -> Double {
  if property.get_id() ==
    elk_graph_adapters_port_border_offset_property.get_id() {
    match
      @graph.node_layout_option_string_value(self.element, property.get_id()) {
      Some(raw) =>
        match elk_graph_adapters_parse_double(raw) {
          Some(value) => value
          None => elk_graph_adapters_port_border_offset_property.get_default()
        }
      None => elk_graph_adapters_port_border_offset_property.get_default()
    }
  } else {
    @graph.node_get_double_property(self.element, property)
  }
}

///|
pub fn ElkGraphAdapter::has_property_double(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Double],
) -> Bool {
  @graph.node_has_double_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::get_property_string(
  self : ElkGraphAdapter,
  property : @graph.IProperty[String],
) -> String {
  @graph.node_get_string_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::has_property_string(
  self : ElkGraphAdapter,
  property : @graph.IProperty[String],
) -> Bool {
  @graph.node_has_string_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::get_property_string_array(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  @graph.node_get_string_set_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::has_property_string_array(
  self : ElkGraphAdapter,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  @graph.node_has_string_set_property(self.element, property)
}

///|
pub fn ElkGraphAdapter::get_volatile_id(self : ElkGraphAdapter) -> Int {
  self.volatile_id
}

///|
pub fn ElkGraphAdapter::set_volatile_id(
  self : ElkGraphAdapter,
  volatile_id : Int,
) -> Unit {
  self.volatile_id = volatile_id
}

///|
pub fn ElkGraphAdapter::get_graph(self : ElkGraphAdapter) -> @graph.ElkNode {
  self.element
}

///|
pub fn ElkGraphAdapter::get_nodes(
  self : ElkGraphAdapter,
) -> Array[ElkNodeAdapter] {
  match self.child_nodes {
    Some(value) => value
    None => {
      let adapters = []
      for node in @graph.node_children(self.element) {
        adapters.push(new_elk_node_adapter(Some(self), node))
      }
      self.child_nodes = Some(adapters)
      adapters
    }
  }
}

///|
pub(all) struct ElkNodeAdapter {
  parent_graph_adapter : ElkGraphAdapter?
  element : @graph.ElkNode
  mut label_adapters : Array[ElkLabelAdapter]?
  mut port_adapters : Array[ElkPortAdapter]?
  mut incoming_edge_adapters : Array[ElkEdgeAdapter]?
  mut outgoing_edge_adapters : Array[ElkEdgeAdapter]?
  mut volatile_id : Int
}

///|
pub fn new_elk_node_adapter(
  parent_graph_adapter : ElkGraphAdapter?,
  node : @graph.ElkNode,
) -> ElkNodeAdapter {
  {
    parent_graph_adapter,
    element: node,
    label_adapters: None,
    port_adapters: None,
    incoming_edge_adapters: None,
    outgoing_edge_adapters: None,
    volatile_id: 0,
  }
}

///|
pub fn ElkNodeAdapter::get_size(self : ElkNodeAdapter) -> KVector {
  new_kvector_xy(
    @graph.node_width(self.element),
    @graph.node_height(self.element),
  )
}

///|
pub fn ElkNodeAdapter::set_size(self : ElkNodeAdapter, size : KVector) -> Unit {
  @graph.node_set_dimensions(self.element, size.x, size.y)
}

///|
pub fn ElkNodeAdapter::get_position(self : ElkNodeAdapter) -> KVector {
  new_kvector_xy(@graph.node_x(self.element), @graph.node_y(self.element))
}

///|
pub fn ElkNodeAdapter::set_position(
  self : ElkNodeAdapter,
  pos : KVector,
) -> Unit {
  @graph.node_set_location(self.element, pos.x, pos.y)
}

///|
pub fn ElkNodeAdapter::get_property_int(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Int],
) -> Int {
  @graph.node_get_int_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::has_property_int(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Int],
) -> Bool {
  @graph.node_has_int_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::get_property_bool(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.node_get_bool_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::has_property_bool(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.node_has_bool_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::get_property_double(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Double],
) -> Double {
  if property.get_id() ==
    elk_graph_adapters_port_border_offset_property.get_id() {
    match
      @graph.node_layout_option_string_value(self.element, property.get_id()) {
      Some(raw) =>
        match elk_graph_adapters_parse_double(raw) {
          Some(value) => value
          None => elk_graph_adapters_port_border_offset_property.get_default()
        }
      None => elk_graph_adapters_port_border_offset_property.get_default()
    }
  } else {
    @graph.node_get_double_property(self.element, property)
  }
}

///|
pub fn ElkNodeAdapter::has_property_double(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Double],
) -> Bool {
  @graph.node_has_double_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::get_property_string(
  self : ElkNodeAdapter,
  property : @graph.IProperty[String],
) -> String {
  @graph.node_get_string_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::has_property_string(
  self : ElkNodeAdapter,
  property : @graph.IProperty[String],
) -> Bool {
  @graph.node_has_string_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::get_property_string_array(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  @graph.node_get_string_set_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::has_property_string_array(
  self : ElkNodeAdapter,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  @graph.node_has_string_set_property(self.element, property)
}

///|
pub fn ElkNodeAdapter::get_volatile_id(self : ElkNodeAdapter) -> Int {
  self.volatile_id
}

///|
pub fn ElkNodeAdapter::set_volatile_id(
  self : ElkNodeAdapter,
  volatile_id : Int,
) -> Unit {
  self.volatile_id = volatile_id
}

///|
pub fn ElkNodeAdapter::get_node(self : ElkNodeAdapter) -> @graph.ElkNode {
  self.element
}

///|
pub fn ElkNodeAdapter::get_graph(self : ElkNodeAdapter) -> ElkGraphAdapter? {
  self.parent_graph_adapter
}

///|
pub fn ElkNodeAdapter::get_labels(
  self : ElkNodeAdapter,
) -> Array[ElkLabelAdapter] {
  match self.label_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for label in @graph.node_labels(self.element) {
        adapters.push(new_elk_label_adapter(label))
      }
      self.label_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn ElkNodeAdapter::get_ports(
  self : ElkNodeAdapter,
) -> Array[ElkPortAdapter] {
  match self.port_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for port in @graph.node_ports(self.element) {
        adapters.push(new_elk_port_adapter(port))
      }
      self.port_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn ElkNodeAdapter::get_incoming_edges(
  self : ElkNodeAdapter,
) -> Array[ElkEdgeAdapter] {
  match self.incoming_edge_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for edge in @graph.all_incoming_edges(self.element) {
        adapters.push(new_elk_edge_adapter(edge))
      }
      self.incoming_edge_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn ElkNodeAdapter::get_outgoing_edges(
  self : ElkNodeAdapter,
) -> Array[ElkEdgeAdapter] {
  match self.outgoing_edge_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for edge in @graph.all_outgoing_edges(self.element) {
        adapters.push(new_elk_edge_adapter(edge))
      }
      self.outgoing_edge_adapters = Some(adapters)
      adapters
    }
  }
}

///|
fn elk_graph_adapters_insertion_sort_ports_with_adapters(
  ports : Array[@graph.ElkPort],
  adapters : Array[ElkPortAdapter],
  comparator : (ElkPortAdapter, ElkPortAdapter) -> Int,
) -> Unit {
  let mut index = 1
  while index < adapters.length() {
    let current_port = ports[index]
    let current_adapter = adapters[index]
    let mut insert_index = index

    while insert_index > 0 &&
          comparator(adapters[insert_index - 1], current_adapter) > 0 {
      ports[insert_index] = ports[insert_index - 1]
      adapters[insert_index] = adapters[insert_index - 1]
      insert_index = insert_index - 1
    }

    ports[insert_index] = current_port
    adapters[insert_index] = current_adapter
    index = index + 1
  }
}

///|
pub fn ElkNodeAdapter::sort_port_list(self : ElkNodeAdapter) -> Unit {
  self.sort_port_list_with((left, right) => {
    elk_default_portlist_sorter.compare(left.get_port(), right.get_port())
  })
}

///|
pub fn ElkNodeAdapter::sort_port_list_with(
  self : ElkNodeAdapter,
  comparator : (ElkPortAdapter, ElkPortAdapter) -> Int,
) -> Unit {
  if !elk_graph_adapters_node_port_constraints(self.element).is_order_fixed() {
    return
  }

  let adapters = self.get_ports()
  let ports = @graph.node_ports(self.element)
  elk_graph_adapters_insertion_sort_ports_with_adapters(
    ports, adapters, comparator,
  )
}

///|
pub fn ElkNodeAdapter::is_compound_node(self : ElkNodeAdapter) -> Bool {
  !@graph.node_children(self.element).is_empty() ||
  elk_graph_adapters_node_inside_self_loops_activate(self.element)
}

///|
pub fn ElkNodeAdapter::get_padding(self : ElkNodeAdapter) -> ElkPadding {
  new_elk_padding_copy(elk_graph_adapters_node_padding(self.element))
}

///|
pub fn ElkNodeAdapter::set_padding(
  self : ElkNodeAdapter,
  padding_value : ElkPadding,
) -> Unit {
  elk_graph_adapters_node_set_padding(self.element, padding_value)
}

///|
pub fn ElkNodeAdapter::get_margin(self : ElkNodeAdapter) -> ElkMargin {
  elk_graph_adapters_node_margin(self.element)
}

///|
pub fn ElkNodeAdapter::set_margin(
  self : ElkNodeAdapter,
  margin_value : ElkMargin,
) -> Unit {
  elk_graph_adapters_node_set_margin(self.element, margin_value)
}

///|
pub(all) struct ElkPortAdapter {
  element : @graph.ElkPort
  mut label_adapters : Array[ElkLabelAdapter]?
  mut incoming_edge_adapters : Array[ElkEdgeAdapter]?
  mut outgoing_edge_adapters : Array[ElkEdgeAdapter]?
  mut volatile_id : Int
}

///|
pub fn new_elk_port_adapter(port : @graph.ElkPort) -> ElkPortAdapter {
  {
    element: port,
    label_adapters: None,
    incoming_edge_adapters: None,
    outgoing_edge_adapters: None,
    volatile_id: 0,
  }
}

///|
pub fn ElkPortAdapter::get_size(self : ElkPortAdapter) -> KVector {
  new_kvector_xy(
    @graph.port_width(self.element),
    @graph.port_height(self.element),
  )
}

///|
pub fn ElkPortAdapter::set_size(self : ElkPortAdapter, size : KVector) -> Unit {
  @graph.port_set_dimensions(self.element, size.x, size.y)
}

///|
pub fn ElkPortAdapter::get_position(self : ElkPortAdapter) -> KVector {
  new_kvector_xy(@graph.port_x(self.element), @graph.port_y(self.element))
}

///|
pub fn ElkPortAdapter::set_position(
  self : ElkPortAdapter,
  pos : KVector,
) -> Unit {
  @graph.port_set_location(self.element, pos.x, pos.y)
}

///|
pub fn ElkPortAdapter::get_property_int(
  self : ElkPortAdapter,
  property : @graph.IProperty[Int],
) -> Int {
  elk_graph_adapters_port_int_option_or_default(self.element, property)
}

///|
pub fn ElkPortAdapter::has_property_int(
  self : ElkPortAdapter,
  property : @graph.IProperty[Int],
) -> Bool {
  @graph.port_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkPortAdapter::get_property_bool(
  self : ElkPortAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  elk_graph_adapters_port_bool_option_or_default(self.element, property)
}

///|
pub fn ElkPortAdapter::has_property_bool(
  self : ElkPortAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.port_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkPortAdapter::get_property_double(
  self : ElkPortAdapter,
  property : @graph.IProperty[Double],
) -> Double {
  if property.get_id() ==
    elk_graph_adapters_port_border_offset_property.get_id() {
    return elk_graph_adapters_port_double_option_or_default(
      self.element,
      elk_graph_adapters_port_border_offset_property,
    )
  }
  elk_graph_adapters_port_double_option_or_default(self.element, property)
}

///|
pub fn ElkPortAdapter::has_property_double(
  self : ElkPortAdapter,
  property : @graph.IProperty[Double],
) -> Bool {
  @graph.port_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkPortAdapter::get_property_string(
  self : ElkPortAdapter,
  property : @graph.IProperty[String],
) -> String {
  elk_graph_adapters_port_string_option_or_default(self.element, property)
}

///|
pub fn ElkPortAdapter::has_property_string(
  self : ElkPortAdapter,
  property : @graph.IProperty[String],
) -> Bool {
  @graph.port_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkPortAdapter::get_property_string_array(
  self : ElkPortAdapter,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  elk_graph_adapters_port_string_array_option_or_default(self.element, property)
}

///|
pub fn ElkPortAdapter::has_property_string_array(
  self : ElkPortAdapter,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  @graph.port_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkPortAdapter::get_volatile_id(self : ElkPortAdapter) -> Int {
  self.volatile_id
}

///|
pub fn ElkPortAdapter::set_volatile_id(
  self : ElkPortAdapter,
  volatile_id : Int,
) -> Unit {
  self.volatile_id = volatile_id
}

///|
pub fn ElkPortAdapter::get_port(self : ElkPortAdapter) -> @graph.ElkPort {
  self.element
}

///|
pub fn ElkPortAdapter::get_side(self : ElkPortAdapter) -> PortSide {
  elk_graph_adapters_port_side(self.element)
}

///|
pub fn ElkPortAdapter::get_labels(
  self : ElkPortAdapter,
) -> Array[ElkLabelAdapter] {
  match self.label_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for label in @graph.port_labels(self.element) {
        adapters.push(new_elk_label_adapter(label))
      }
      self.label_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn ElkPortAdapter::get_margin(self : ElkPortAdapter) -> ElkMargin {
  elk_graph_adapters_port_margin(self.element)
}

///|
pub fn ElkPortAdapter::set_margin(
  self : ElkPortAdapter,
  margin_value : ElkMargin,
) -> Unit {
  elk_graph_adapters_port_set_margin(self.element, margin_value)
}

///|
pub fn ElkPortAdapter::get_incoming_edges(
  self : ElkPortAdapter,
) -> Array[ElkEdgeAdapter] {
  match self.incoming_edge_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for edge in @graph.port_incoming_edges(self.element) {
        adapters.push(new_elk_edge_adapter(edge))
      }
      self.incoming_edge_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn ElkPortAdapter::get_outgoing_edges(
  self : ElkPortAdapter,
) -> Array[ElkEdgeAdapter] {
  match self.outgoing_edge_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for edge in @graph.port_outgoing_edges(self.element) {
        adapters.push(new_elk_edge_adapter(edge))
      }
      self.outgoing_edge_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn ElkPortAdapter::has_compound_connections(self : ElkPortAdapter) -> Bool {
  if @graph.port_parent(self.element) is Some(node) {
    for edge in @graph.port_outgoing_edges(self.element) {
      for target in @graph.edge_targets(edge) {
        let target_node = @graph.connectable_shape_to_node(Some(target))
        if @graph.is_descendant(target_node, node) {
          return true
        }

        if target_node == node &&
          elk_graph_adapters_edge_inside_self_loops_yo(edge) {
          return true
        }
      }
    }

    for edge in @graph.port_incoming_edges(self.element) {
      for source in @graph.edge_sources(edge) {
        let source_node = @graph.connectable_shape_to_node(Some(source))
        if @graph.is_descendant(source_node, node) {
          return true
        }
      }
    }
  }

  false
}

///|
pub(all) struct ElkLabelAdapter {
  element : @graph.ElkLabel
  mut volatile_id : Int
}

///|
pub fn new_elk_label_adapter(label : @graph.ElkLabel) -> ElkLabelAdapter {
  { element: label, volatile_id: 0 }
}

///|
pub fn ElkLabelAdapter::get_size(self : ElkLabelAdapter) -> KVector {
  new_kvector_xy(
    @graph.label_width(self.element),
    @graph.label_height(self.element),
  )
}

///|
pub fn ElkLabelAdapter::set_size(
  self : ElkLabelAdapter,
  size : KVector,
) -> Unit {
  @graph.label_set_dimensions(self.element, size.x, size.y)
}

///|
pub fn ElkLabelAdapter::get_position(self : ElkLabelAdapter) -> KVector {
  new_kvector_xy(@graph.label_x(self.element), @graph.label_y(self.element))
}

///|
pub fn ElkLabelAdapter::set_position(
  self : ElkLabelAdapter,
  pos : KVector,
) -> Unit {
  @graph.label_set_location(self.element, pos.x, pos.y)
}

///|
pub fn ElkLabelAdapter::get_property_int(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Int],
) -> Int {
  elk_graph_adapters_label_int_option_or_default(self.element, property)
}

///|
pub fn ElkLabelAdapter::has_property_int(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Int],
) -> Bool {
  @graph.label_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkLabelAdapter::get_property_bool(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  elk_graph_adapters_label_bool_option_or_default(self.element, property)
}

///|
pub fn ElkLabelAdapter::has_property_bool(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Bool],
) -> Bool {
  @graph.label_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkLabelAdapter::get_property_double(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Double],
) -> Double {
  if property.get_id() ==
    elk_graph_adapters_port_border_offset_property.get_id() {
    return elk_graph_adapters_label_double_option_or_default(
      self.element,
      elk_graph_adapters_port_border_offset_property,
    )
  }
  elk_graph_adapters_label_double_option_or_default(self.element, property)
}

///|
pub fn ElkLabelAdapter::has_property_double(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Double],
) -> Bool {
  @graph.label_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkLabelAdapter::get_property_string(
  self : ElkLabelAdapter,
  property : @graph.IProperty[String],
) -> String {
  elk_graph_adapters_label_string_option_or_default(self.element, property)
}

///|
pub fn ElkLabelAdapter::has_property_string(
  self : ElkLabelAdapter,
  property : @graph.IProperty[String],
) -> Bool {
  @graph.label_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkLabelAdapter::get_property_string_array(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  elk_graph_adapters_label_string_array_option_or_default(
    self.element,
    property,
  )
}

///|
pub fn ElkLabelAdapter::has_property_string_array(
  self : ElkLabelAdapter,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  @graph.label_layout_option_string_value(self.element, property.get_id())
  is Some(_)
}

///|
pub fn ElkLabelAdapter::get_volatile_id(self : ElkLabelAdapter) -> Int {
  self.volatile_id
}

///|
pub fn ElkLabelAdapter::set_volatile_id(
  self : ElkLabelAdapter,
  volatile_id : Int,
) -> Unit {
  self.volatile_id = volatile_id
}

///|
pub fn ElkLabelAdapter::get_label(self : ElkLabelAdapter) -> @graph.ElkLabel {
  self.element
}

///|
pub fn ElkLabelAdapter::get_side(self : ElkLabelAdapter) -> LabelSide {
  match
    @graph.label_layout_option_string_value(
      self.element,
      elk_graph_adapters_label_side_property.get_id(),
    ) {
    Some(raw) => elk_graph_adapters_parse_label_side(raw)
    None => LabelSide::Unknown
  }
}

///|
pub fn ElkLabelAdapter::get_text(self : ElkLabelAdapter) -> String {
  @graph.label_text(self.element)
}

///|
pub(all) struct ElkEdgeAdapter {
  element : @graph.ElkEdge
  mut label_adapters : Array[ElkLabelAdapter]?
}

///|
pub fn new_elk_edge_adapter(edge : @graph.ElkEdge) -> ElkEdgeAdapter {
  { element: edge, label_adapters: None }
}

///|
pub fn ElkEdgeAdapter::get_element(self : ElkEdgeAdapter) -> @graph.ElkEdge {
  self.element
}

///|
pub fn ElkEdgeAdapter::get_labels(
  self : ElkEdgeAdapter,
) -> Array[ElkLabelAdapter] {
  match self.label_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for label in @graph.edge_labels(self.element) {
        adapters.push(new_elk_label_adapter(label))
      }
      self.label_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub let elk_default_portlist_sorter : ElkPortComparator = new_elk_port_comparator()

///|
pub(all) struct ElkPortComparator {
  unit : Unit
}

///|
pub fn new_elk_port_comparator() -> ElkPortComparator {
  { unit: () }
}

///|
pub fn ElkPortComparator::compare(
  self : ElkPortComparator,
  port1 : @graph.ElkPort,
  port2 : @graph.ElkPort,
) -> Int {
  ignore(self)
  let ordinal_difference = elk_graph_adapters_port_side_rank(
      elk_graph_adapters_port_side(port1),
    ) -
    elk_graph_adapters_port_side_rank(elk_graph_adapters_port_side(port2))

  if ordinal_difference != 0 {
    return ordinal_difference
  }

  match
    (elk_graph_adapters_port_index(port1), elk_graph_adapters_port_index(port2)) {
    (Some(index1), Some(index2)) => {
      let index_difference = index1 - index2
      if index_difference != 0 {
        return index_difference
      }
    }
    _ => ()
  }

  match elk_graph_adapters_port_side(port1) {
    PortSide::North =>
      elk_graph_adapters_compare_double(
        @graph.port_x(port1),
        @graph.port_x(port2),
      )
    PortSide::East =>
      elk_graph_adapters_compare_double(
        @graph.port_y(port1),
        @graph.port_y(port2),
      )
    PortSide::South =>
      elk_graph_adapters_compare_double(
        @graph.port_x(port2),
        @graph.port_x(port1),
      )
    PortSide::West =>
      elk_graph_adapters_compare_double(
        @graph.port_y(port2),
        @graph.port_y(port1),
      )
    PortSide::SideUndefined => abort("Port side is undefined")
  }
}
