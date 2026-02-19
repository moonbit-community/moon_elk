///|
fn l_graph_adapters_default_node_filter(_node : LNode) -> Bool {
  true
}

///|
fn l_graph_adapters_port_constraints_from_string(
  value : String,
) -> PortConstraints {
  match value {
    "UNDEFINED" => PortConstraints::Undefined
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn l_graph_adapters_port_side_rank(side : PortSide) -> Int {
  match side {
    PortSide::SideUndefined => 0
    PortSide::North => 1
    PortSide::East => 2
    PortSide::South => 3
    PortSide::West => 4
  }
}

///|
fn l_graph_adapters_compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn l_graph_adapters_node_type_is_north_south_port(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn l_graph_adapters_insertion_sort_ports(
  ports : Array[LPort],
  comparator : (LPort, LPort) -> Int,
) -> Unit {
  let mut i = 1
  while i < ports.length() {
    let current = ports[i]
    let mut j = i
    while j > 0 && comparator(ports[j - 1], current) > 0 {
      ports[j] = ports[j - 1]
      j = j - 1
    }
    ports[j] = current
    i = i + 1
  }
}

///|
pub fn adapt_l_graph(graph : LGraph) -> LGraphAdapter {
  adapt_l_graph_with_transparent_north_south_edges(graph, false)
}

///|
pub fn adapt_l_graph_with_transparent_north_south_edges(
  graph : LGraph,
  transparent_north_south_edges : Bool,
) -> LGraphAdapter {
  adapt_l_graph_with_options(
    graph, transparent_north_south_edges, false, l_graph_adapters_default_node_filter,
  )
}

///|
pub fn adapt_l_graph_with_options(
  graph : LGraph,
  transparent_north_south_edges : Bool,
  transparent_comment_nodes : Bool,
  node_filter : (LNode) -> Bool,
) -> LGraphAdapter {
  new_l_graph_adapter(
    graph, transparent_north_south_edges, transparent_comment_nodes, node_filter,
  )
}

///|
pub fn adapt_l_node(
  node : LNode,
  transparent_north_south_edges : Bool,
) -> LNodeAdapter {
  new_l_node_adapter(None, node, transparent_north_south_edges)
}

///|
pub fn adapt_l_label(label : LLabel) -> LLabelAdapter {
  new_l_label_adapter(label)
}

///|
pub struct LGraphAdapter {
  element : LGraph
  mut node_adapters : Array[LNodeAdapter]?
  transparent_north_south_edges : Bool
  transparent_comment_nodes : Bool
  node_filter : (LNode) -> Bool
}

///|
pub fn new_l_graph_adapter(
  element : LGraph,
  transparent_north_south_edges : Bool,
  transparent_comment_nodes : Bool,
  node_filter : (LNode) -> Bool,
) -> LGraphAdapter {
  {
    element,
    node_adapters: None,
    transparent_north_south_edges,
    transparent_comment_nodes,
    node_filter,
  }
}

///|
pub fn LGraphAdapter::get_size(self : LGraphAdapter) -> KVector {
  self.element.get_size()
}

///|
pub fn LGraphAdapter::set_size(self : LGraphAdapter, size : KVector) -> Unit {
  self.element.get_size().x = size.x
  self.element.get_size().y = size.y
}

///|
pub fn LGraphAdapter::get_position(self : LGraphAdapter) -> KVector {
  ignore(self)
  abort("Not supported by LGraph")
}

///|
pub fn LGraphAdapter::set_position(
  self : LGraphAdapter,
  _position : KVector,
) -> Unit {
  ignore(self)
  abort("Not supported by LGraph")
}

///|
pub fn LGraphAdapter::get_graph(self : LGraphAdapter) -> LGraph {
  self.element
}

///|
pub fn LGraphAdapter::get_property_int(
  self : LGraphAdapter,
  property : IProperty[Int],
) -> Int {
  self.element.get_property_int(property)
}

///|
pub fn LGraphAdapter::has_property_int(
  self : LGraphAdapter,
  property : IProperty[Int],
) -> Bool {
  self.element.has_property_int(property)
}

///|
pub fn LGraphAdapter::get_property_bool(
  self : LGraphAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.get_property_bool(property)
}

///|
pub fn LGraphAdapter::has_property_bool(
  self : LGraphAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.has_property_bool(property)
}

///|
pub fn LGraphAdapter::get_property_double(
  self : LGraphAdapter,
  property : IProperty[Double],
) -> Double {
  self.element.get_property_double(property)
}

///|
pub fn LGraphAdapter::has_property_double(
  self : LGraphAdapter,
  property : IProperty[Double],
) -> Bool {
  self.element.has_property_double(property)
}

///|
pub fn LGraphAdapter::get_property_string(
  self : LGraphAdapter,
  property : IProperty[String],
) -> String {
  self.element.get_property_string(property)
}

///|
pub fn LGraphAdapter::has_property_string(
  self : LGraphAdapter,
  property : IProperty[String],
) -> Bool {
  self.element.has_property_string(property)
}

///|
pub fn LGraphAdapter::get_property_string_array(
  self : LGraphAdapter,
  property : IProperty[Array[String]],
) -> Array[String] {
  self.element.get_property_string_array(property)
}

///|
pub fn LGraphAdapter::has_property_string_array(
  self : LGraphAdapter,
  property : IProperty[Array[String]],
) -> Bool {
  self.element.has_property_string_array(property)
}

///|
pub fn LGraphAdapter::get_nodes(self : LGraphAdapter) -> Array[LNodeAdapter] {
  match self.node_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for layer in self.element.get_layers() {
        for node in layer.get_nodes() {
          if (self.node_filter)(node) {
            adapters.push(
              new_l_node_adapter(
                Some(self),
                node,
                self.transparent_north_south_edges,
              ),
            )

            if self.transparent_comment_nodes {
              if node.has_property_l_node_array(
                  internal_properties_top_comments,
                ) {
                for
                  comment in node.get_property_l_node_array(
                    internal_properties_top_comments,
                  ) {
                  adapters.push(new_l_node_adapter(Some(self), comment, false))
                }
              }

              if node.has_property_l_node_array(
                  internal_properties_bottom_comments,
                ) {
                for
                  comment in node.get_property_l_node_array(
                    internal_properties_bottom_comments,
                  ) {
                  adapters.push(new_l_node_adapter(Some(self), comment, false))
                }
              }
            }
          }
        }
      }
      self.node_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn LGraphAdapter::get_volatile_id(self : LGraphAdapter) -> Int {
  self.element.get_id()
}

///|
pub fn LGraphAdapter::set_volatile_id(
  self : LGraphAdapter,
  volatile_id : Int,
) -> Unit {
  self.element.set_id(volatile_id)
}

///|
pub struct LNodeAdapter {
  parent_graph_adapter : LGraphAdapter?
  element : LNode
  mut label_adapters : Array[LLabelAdapter]?
  mut port_adapters : Array[LPortAdapter]?
  transparent_north_south_edges : Bool
}

///|
pub fn new_l_node_adapter(
  parent_graph_adapter : LGraphAdapter?,
  element : LNode,
  transparent_north_south_edges : Bool,
) -> LNodeAdapter {
  {
    parent_graph_adapter,
    element,
    label_adapters: None,
    port_adapters: None,
    transparent_north_south_edges,
  }
}

///|
pub fn LNodeAdapter::get_size(self : LNodeAdapter) -> KVector {
  self.element.get_size()
}

///|
pub fn LNodeAdapter::set_size(self : LNodeAdapter, size : KVector) -> Unit {
  self.element.get_size().x = size.x
  self.element.get_size().y = size.y
}

///|
pub fn LNodeAdapter::get_position(self : LNodeAdapter) -> KVector {
  self.element.get_position()
}

///|
pub fn LNodeAdapter::set_position(
  self : LNodeAdapter,
  position : KVector,
) -> Unit {
  self.element.get_position().x = position.x
  self.element.get_position().y = position.y
}

///|
pub fn LNodeAdapter::get_property_int(
  self : LNodeAdapter,
  property : IProperty[Int],
) -> Int {
  self.element.get_property_int(property)
}

///|
pub fn LNodeAdapter::has_property_int(
  self : LNodeAdapter,
  property : IProperty[Int],
) -> Bool {
  self.element.has_property_int(property)
}

///|
pub fn LNodeAdapter::get_property_bool(
  self : LNodeAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.get_property_bool(property)
}

///|
pub fn LNodeAdapter::has_property_bool(
  self : LNodeAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.has_property_bool(property)
}

///|
pub fn LNodeAdapter::get_property_double(
  self : LNodeAdapter,
  property : IProperty[Double],
) -> Double {
  self.element.get_property_double(property)
}

///|
pub fn LNodeAdapter::has_property_double(
  self : LNodeAdapter,
  property : IProperty[Double],
) -> Bool {
  self.element.has_property_double(property)
}

///|
pub fn LNodeAdapter::get_property_string(
  self : LNodeAdapter,
  property : IProperty[String],
) -> String {
  self.element.get_property_string(property)
}

///|
pub fn LNodeAdapter::has_property_string(
  self : LNodeAdapter,
  property : IProperty[String],
) -> Bool {
  self.element.has_property_string(property)
}

///|
pub fn LNodeAdapter::get_property_string_array(
  self : LNodeAdapter,
  property : IProperty[Array[String]],
) -> Array[String] {
  self.element.get_property_string_array(property)
}

///|
pub fn LNodeAdapter::has_property_string_array(
  self : LNodeAdapter,
  property : IProperty[Array[String]],
) -> Bool {
  self.element.has_property_string_array(property)
}

///|
pub fn LNodeAdapter::get_volatile_id(self : LNodeAdapter) -> Int {
  self.element.get_id()
}

///|
pub fn LNodeAdapter::set_volatile_id(
  self : LNodeAdapter,
  volatile_id : Int,
) -> Unit {
  self.element.set_id(volatile_id)
}

///|
pub fn LNodeAdapter::get_graph(self : LNodeAdapter) -> LGraphAdapter? {
  self.parent_graph_adapter
}

///|
pub fn LNodeAdapter::get_labels(self : LNodeAdapter) -> Array[LLabelAdapter] {
  match self.label_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for label in self.element.get_labels() {
        adapters.push(new_l_label_adapter(label))
      }
      self.label_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn LNodeAdapter::get_ports(self : LNodeAdapter) -> Array[LPortAdapter] {
  match self.port_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for port in self.element.get_ports() {
        adapters.push(
          new_l_port_adapter(port, self.transparent_north_south_edges),
        )
      }
      self.port_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn LNodeAdapter::get_incoming_edges(
  self : LNodeAdapter,
) -> Array[LEdgeAdapter] {
  ignore(self)
  []
}

///|
pub fn LNodeAdapter::get_outgoing_edges(
  self : LNodeAdapter,
) -> Array[LEdgeAdapter] {
  ignore(self)
  []
}

///|
pub fn LNodeAdapter::sort_port_list(self : LNodeAdapter) -> Unit {
  self.sort_port_list_with_comparator((left, right) => {
    default_portlist_sorter.compare(left, right)
  })
}

///|
pub fn LNodeAdapter::sort_port_list_with(
  self : LNodeAdapter,
  comparator : PortComparator,
) -> Unit {
  self.sort_port_list_with_comparator((left, right) => {
    comparator.compare(left, right)
  })
}

///|
pub fn LNodeAdapter::sort_port_list_with_comparator(
  self : LNodeAdapter,
  comparator : (LPort, LPort) -> Int,
) -> Unit {
  let port_constraints_value = self.element.get_property_string(
    port_constraints,
  )
  let parsed_constraints = l_graph_adapters_port_constraints_from_string(
    port_constraints_value,
  )

  if parsed_constraints.is_order_fixed() {
    l_graph_adapters_insertion_sort_ports(self.element.get_ports(), comparator)
  }
}

///|
pub fn LNodeAdapter::is_compound_node(self : LNodeAdapter) -> Bool {
  self.element.get_property_bool(internal_properties_compound_node)
}

///|
pub fn LNodeAdapter::get_padding(self : LNodeAdapter) -> ElkPadding {
  let padding = self.element.get_padding()
  new_spacing_values(padding.top, padding.right, padding.bottom, padding.left)
}

///|
pub fn LNodeAdapter::set_padding(
  self : LNodeAdapter,
  padding : ElkPadding,
) -> Unit {
  let target_padding = self.element.get_padding()
  target_padding.left = padding.left
  target_padding.top = padding.top
  target_padding.right = padding.right
  target_padding.bottom = padding.bottom
}

///|
pub fn LNodeAdapter::get_margin(self : LNodeAdapter) -> ElkMargin {
  let margin = self.element.get_margin()
  new_spacing_values(margin.top, margin.right, margin.bottom, margin.left)
}

///|
pub fn LNodeAdapter::set_margin(
  self : LNodeAdapter,
  margin : ElkMargin,
) -> Unit {
  let target_margin = self.element.get_margin()
  target_margin.left = margin.left
  target_margin.top = margin.top
  target_margin.right = margin.right
  target_margin.bottom = margin.bottom
}

///|
pub struct LPortAdapter {
  element : LPort
  mut label_adapters : Array[LLabelAdapter]?
  mut incoming_edge_adapters : Array[LEdgeAdapter]?
  mut outgoing_edge_adapters : Array[LEdgeAdapter]?
  transparent_north_south_edges : Bool
}

///|
pub fn new_l_port_adapter(
  element : LPort,
  transparent_north_south_edges : Bool,
) -> LPortAdapter {
  {
    element,
    label_adapters: None,
    incoming_edge_adapters: None,
    outgoing_edge_adapters: None,
    transparent_north_south_edges,
  }
}

///|
pub fn LPortAdapter::get_size(self : LPortAdapter) -> KVector {
  self.element.get_size()
}

///|
pub fn LPortAdapter::set_size(self : LPortAdapter, size : KVector) -> Unit {
  self.element.get_size().x = size.x
  self.element.get_size().y = size.y
}

///|
pub fn LPortAdapter::get_position(self : LPortAdapter) -> KVector {
  self.element.get_position()
}

///|
pub fn LPortAdapter::set_position(
  self : LPortAdapter,
  position : KVector,
) -> Unit {
  self.element.get_position().x = position.x
  self.element.get_position().y = position.y
}

///|
pub fn LPortAdapter::get_property_int(
  self : LPortAdapter,
  property : IProperty[Int],
) -> Int {
  self.element.get_property_int(property)
}

///|
pub fn LPortAdapter::has_property_int(
  self : LPortAdapter,
  property : IProperty[Int],
) -> Bool {
  self.element.has_property_int(property)
}

///|
pub fn LPortAdapter::get_property_bool(
  self : LPortAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.get_property_bool(property)
}

///|
pub fn LPortAdapter::has_property_bool(
  self : LPortAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.has_property_bool(property)
}

///|
pub fn LPortAdapter::get_property_double(
  self : LPortAdapter,
  property : IProperty[Double],
) -> Double {
  self.element.get_property_double(property)
}

///|
pub fn LPortAdapter::has_property_double(
  self : LPortAdapter,
  property : IProperty[Double],
) -> Bool {
  self.element.has_property_double(property)
}

///|
pub fn LPortAdapter::get_property_l_node(
  self : LPortAdapter,
  property : IProperty[LNode?],
) -> LNode? {
  self.element.get_property_l_node(property)
}

///|
pub fn LPortAdapter::has_property_l_node(
  self : LPortAdapter,
  property : IProperty[LNode?],
) -> Bool {
  self.element.has_property_l_node(property)
}

///|
pub fn LPortAdapter::get_volatile_id(self : LPortAdapter) -> Int {
  self.element.get_id()
}

///|
pub fn LPortAdapter::set_volatile_id(
  self : LPortAdapter,
  volatile_id : Int,
) -> Unit {
  self.element.set_id(volatile_id)
}

///|
pub fn LPortAdapter::get_side(self : LPortAdapter) -> PortSide {
  self.element.get_side()
}

///|
pub fn LPortAdapter::get_labels(self : LPortAdapter) -> Array[LLabelAdapter] {
  match self.label_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for label in self.element.get_labels() {
        adapters.push(new_l_label_adapter(label))
      }
      self.label_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn LPortAdapter::get_margin(self : LPortAdapter) -> ElkMargin {
  let margin = self.element.get_margin()
  new_spacing_values(margin.top, margin.right, margin.bottom, margin.left)
}

///|
pub fn LPortAdapter::set_margin(
  self : LPortAdapter,
  margin : ElkMargin,
) -> Unit {
  let target_margin = self.element.get_margin()
  target_margin.left = margin.left
  target_margin.top = margin.top
  target_margin.right = margin.right
  target_margin.bottom = margin.bottom
}

///|
pub fn LPortAdapter::get_incoming_edges(
  self : LPortAdapter,
) -> Array[LEdgeAdapter] {
  let node = self.element.get_node()
  if self.transparent_north_south_edges {
    match node {
      Some(owner_node) =>
        if l_graph_adapters_node_type_is_north_south_port(owner_node.get_type()) {
          return []
        }
      None => ()
    }
  }

  match self.incoming_edge_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for edge in self.element.get_incoming_edges() {
        adapters.push(new_l_edge_adapter(edge))
      }

      if self.transparent_north_south_edges {
        match self.element.get_property_l_node(internal_properties_port_dummy) {
          Some(port_dummy) =>
            for edge in port_dummy.get_incoming_edges() {
              adapters.push(new_l_edge_adapter(edge))
            }
          None => ()
        }
      }

      match node {
        Some(owner_node) =>
          if owner_node.has_property_self_loop_holder(
              internal_properties_self_loop_holder,
            ) {
            match
              owner_node.get_property_self_loop_holder(
                internal_properties_self_loop_holder,
              ) {
              Some(slh) =>
                match
                  slh.get_sl_port_map().get(lport_internal_handle(self.element)) {
                  Some(slp) =>
                    for sle in slp.get_incoming_sl_edges() {
                      adapters.push(new_l_edge_adapter(sle.get_l_edge()))
                    }
                  None => ()
                }
              None => ()
            }
          }
        None => ()
      }

      self.incoming_edge_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn LPortAdapter::get_outgoing_edges(
  self : LPortAdapter,
) -> Array[LEdgeAdapter] {
  let node = self.element.get_node()
  if self.transparent_north_south_edges {
    match node {
      Some(owner_node) =>
        if l_graph_adapters_node_type_is_north_south_port(owner_node.get_type()) {
          return []
        }
      None => ()
    }
  }

  match self.outgoing_edge_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for edge in self.element.get_outgoing_edges() {
        adapters.push(new_l_edge_adapter(edge))
      }

      if self.transparent_north_south_edges {
        match self.element.get_property_l_node(internal_properties_port_dummy) {
          Some(port_dummy) =>
            for edge in port_dummy.get_outgoing_edges() {
              adapters.push(new_l_edge_adapter(edge))
            }
          None => ()
        }
      }

      match node {
        Some(owner_node) =>
          if owner_node.has_property_self_loop_holder(
              internal_properties_self_loop_holder,
            ) {
            match
              owner_node.get_property_self_loop_holder(
                internal_properties_self_loop_holder,
              ) {
              Some(slh) =>
                match
                  slh.get_sl_port_map().get(lport_internal_handle(self.element)) {
                  Some(slp) =>
                    for sle in slp.get_outgoing_sl_edges() {
                      adapters.push(new_l_edge_adapter(sle.get_l_edge()))
                    }
                  None => ()
                }
              None => ()
            }
          }
        None => ()
      }

      self.outgoing_edge_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub fn LPortAdapter::has_compound_connections(self : LPortAdapter) -> Bool {
  self.element.get_property_bool(internal_properties_inside_connections)
}

///|
pub struct LLabelAdapter {
  element : LLabel
}

///|
pub fn new_l_label_adapter(element : LLabel) -> LLabelAdapter {
  { element, }
}

///|
pub fn LLabelAdapter::get_size(self : LLabelAdapter) -> KVector {
  self.element.get_size()
}

///|
pub fn LLabelAdapter::set_size(self : LLabelAdapter, size : KVector) -> Unit {
  self.element.get_size().x = size.x
  self.element.get_size().y = size.y
}

///|
pub fn LLabelAdapter::get_position(self : LLabelAdapter) -> KVector {
  self.element.get_position()
}

///|
pub fn LLabelAdapter::set_position(
  self : LLabelAdapter,
  position : KVector,
) -> Unit {
  self.element.get_position().x = position.x
  self.element.get_position().y = position.y
}

///|
pub fn LLabelAdapter::get_property_bool(
  self : LLabelAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.get_property_bool(property)
}

///|
pub fn LLabelAdapter::has_property_bool(
  self : LLabelAdapter,
  property : IProperty[Bool],
) -> Bool {
  self.element.has_property_bool(property)
}

///|
pub fn LLabelAdapter::get_property_string(
  self : LLabelAdapter,
  property : IProperty[String],
) -> String {
  self.element.get_property_string(property)
}

///|
pub fn LLabelAdapter::has_property_string(
  self : LLabelAdapter,
  property : IProperty[String],
) -> Bool {
  self.element.has_property_string(property)
}

///|
pub fn LLabelAdapter::get_property_label_side(
  self : LLabelAdapter,
  property : IProperty[LabelSide],
) -> LabelSide {
  self.element.get_property_label_side(property)
}

///|
pub fn LLabelAdapter::has_property_label_side(
  self : LLabelAdapter,
  property : IProperty[LabelSide],
) -> Bool {
  self.element.has_property_label_side(property)
}

///|
pub fn LLabelAdapter::get_volatile_id(self : LLabelAdapter) -> Int {
  self.element.get_id()
}

///|
pub fn LLabelAdapter::set_volatile_id(
  self : LLabelAdapter,
  volatile_id : Int,
) -> Unit {
  self.element.set_id(volatile_id)
}

///|
pub fn LLabelAdapter::get_side(self : LLabelAdapter) -> LabelSide {
  self.element.get_property_label_side(internal_properties_label_side)
}

///|
pub fn LLabelAdapter::get_text(self : LLabelAdapter) -> String {
  self.element.get_text()
}

///|
pub struct LEdgeAdapter {
  element : LEdge
  mut label_adapters : Array[LLabelAdapter]?
}

///|
pub fn new_l_edge_adapter(edge : LEdge) -> LEdgeAdapter {
  { element: edge, label_adapters: None }
}

///|
pub fn LEdgeAdapter::get_labels(self : LEdgeAdapter) -> Array[LLabelAdapter] {
  match self.label_adapters {
    Some(value) => value
    None => {
      let adapters = []
      for label in self.element.get_labels() {
        adapters.push(new_l_label_adapter(label))
      }
      self.label_adapters = Some(adapters)
      adapters
    }
  }
}

///|
pub let default_portlist_sorter : PortComparator = new_port_comparator()

///|
pub struct PortComparator {
  unit : Unit
}

///|
pub fn new_port_comparator() -> PortComparator {
  { unit: () }
}

///|
pub fn PortComparator::compare(
  self : PortComparator,
  port1 : LPort,
  port2 : LPort,
) -> Int {
  ignore(self)
  let ordinal_difference = l_graph_adapters_port_side_rank(port1.get_side()) -
    l_graph_adapters_port_side_rank(port2.get_side())

  if ordinal_difference != 0 {
    return ordinal_difference
  }

  if port1.has_property_int(layered_options_port_index) &&
    port2.has_property_int(layered_options_port_index) {
    let index_difference = port1.get_property_int(layered_options_port_index) -
      port2.get_property_int(layered_options_port_index)
    if index_difference != 0 {
      return index_difference
    }
  }

  match port1.get_side() {
    PortSide::North =>
      l_graph_adapters_compare_double(
        port1.get_position().x,
        port2.get_position().x,
      )
    PortSide::East =>
      l_graph_adapters_compare_double(
        port1.get_position().y,
        port2.get_position().y,
      )
    PortSide::South =>
      l_graph_adapters_compare_double(
        port2.get_position().x,
        port1.get_position().x,
      )
    PortSide::West =>
      l_graph_adapters_compare_double(
        port2.get_position().y,
        port1.get_position().y,
      )
    PortSide::SideUndefined => abort("Port side is undefined")
  }
}
