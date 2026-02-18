///|
pub struct GraphElementAdapter[T] {
  element : T
  get_size_fn : () -> KVector
  set_size_fn : (KVector) -> Unit
  get_position_fn : () -> KVector
  set_position_fn : (KVector) -> Unit
  get_property_int_fn : (IProperty[Int]) -> Int
  has_property_int_fn : (IProperty[Int]) -> Bool
  get_property_bool_fn : (IProperty[Bool]) -> Bool
  has_property_bool_fn : (IProperty[Bool]) -> Bool
  get_property_double_fn : (IProperty[Double]) -> Double
  has_property_double_fn : (IProperty[Double]) -> Bool
  get_property_string_fn : (IProperty[String]) -> String
  has_property_string_fn : (IProperty[String]) -> Bool
  get_property_string_array_fn : (IProperty[Array[String]]) -> Array[String]
  has_property_string_array_fn : (IProperty[Array[String]]) -> Bool
  mut volatile_id : Int
}

///|
pub fn[T] new_graph_element_adapter(
  element : T,
  get_size_fn : () -> KVector,
  set_size_fn : (KVector) -> Unit,
  get_position_fn : () -> KVector,
  set_position_fn : (KVector) -> Unit,
  get_property_int_fn : (IProperty[Int]) -> Int,
  has_property_int_fn : (IProperty[Int]) -> Bool,
  get_property_bool_fn : (IProperty[Bool]) -> Bool,
  has_property_bool_fn : (IProperty[Bool]) -> Bool,
  get_property_double_fn : (IProperty[Double]) -> Double,
  has_property_double_fn : (IProperty[Double]) -> Bool,
  get_property_string_fn : (IProperty[String]) -> String,
  has_property_string_fn : (IProperty[String]) -> Bool,
  get_property_string_array_fn : (IProperty[Array[String]]) -> Array[String],
  has_property_string_array_fn : (IProperty[Array[String]]) -> Bool,
) -> GraphElementAdapter[T] {
  {
    element,
    get_size_fn,
    set_size_fn,
    get_position_fn,
    set_position_fn,
    get_property_int_fn,
    has_property_int_fn,
    get_property_bool_fn,
    has_property_bool_fn,
    get_property_double_fn,
    has_property_double_fn,
    get_property_string_fn,
    has_property_string_fn,
    get_property_string_array_fn,
    has_property_string_array_fn,
    volatile_id: 0,
  }
}

///|
pub fn[T] GraphElementAdapter::get_element(self : GraphElementAdapter[T]) -> T {
  self.element
}

///|
pub fn[T] GraphElementAdapter::get_size(
  self : GraphElementAdapter[T],
) -> KVector {
  (self.get_size_fn)()
}

///|
pub fn[T] GraphElementAdapter::set_size(
  self : GraphElementAdapter[T],
  size : KVector,
) -> Unit {
  (self.set_size_fn)(size)
}

///|
pub fn[T] GraphElementAdapter::get_position(
  self : GraphElementAdapter[T],
) -> KVector {
  (self.get_position_fn)()
}

///|
pub fn[T] GraphElementAdapter::set_position(
  self : GraphElementAdapter[T],
  position : KVector,
) -> Unit {
  (self.set_position_fn)(position)
}

///|
pub fn[T] GraphElementAdapter::get_property_int(
  self : GraphElementAdapter[T],
  property : IProperty[Int],
) -> Int {
  (self.get_property_int_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::has_property_int(
  self : GraphElementAdapter[T],
  property : IProperty[Int],
) -> Bool {
  (self.has_property_int_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::get_property_bool(
  self : GraphElementAdapter[T],
  property : IProperty[Bool],
) -> Bool {
  (self.get_property_bool_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::has_property_bool(
  self : GraphElementAdapter[T],
  property : IProperty[Bool],
) -> Bool {
  (self.has_property_bool_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::get_property_double(
  self : GraphElementAdapter[T],
  property : IProperty[Double],
) -> Double {
  (self.get_property_double_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::has_property_double(
  self : GraphElementAdapter[T],
  property : IProperty[Double],
) -> Bool {
  (self.has_property_double_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::get_property_string(
  self : GraphElementAdapter[T],
  property : IProperty[String],
) -> String {
  (self.get_property_string_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::has_property_string(
  self : GraphElementAdapter[T],
  property : IProperty[String],
) -> Bool {
  (self.has_property_string_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::get_property_string_array(
  self : GraphElementAdapter[T],
  property : IProperty[Array[String]],
) -> Array[String] {
  (self.get_property_string_array_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::has_property_string_array(
  self : GraphElementAdapter[T],
  property : IProperty[Array[String]],
) -> Bool {
  (self.has_property_string_array_fn)(property)
}

///|
pub fn[T] GraphElementAdapter::get_volatile_id(
  self : GraphElementAdapter[T],
) -> Int {
  self.volatile_id
}

///|
pub fn[T] GraphElementAdapter::set_volatile_id(
  self : GraphElementAdapter[T],
  volatile_id : Int,
) -> Unit {
  self.volatile_id = volatile_id
}

///|
pub struct GraphAdapter[T, N] {
  element_adapter : GraphElementAdapter[T]
  get_nodes_fn : () -> Array[N]
}

///|
pub fn[T, N] new_graph_adapter(
  element_adapter : GraphElementAdapter[T],
  get_nodes_fn : () -> Array[N],
) -> GraphAdapter[T, N] {
  { element_adapter, get_nodes_fn }
}

///|
pub fn[T, N] GraphAdapter::element_adapter(
  self : GraphAdapter[T, N],
) -> GraphElementAdapter[T] {
  self.element_adapter
}

///|
pub fn[T, N] GraphAdapter::get_nodes(self : GraphAdapter[T, N]) -> Array[N] {
  (self.get_nodes_fn)()
}

///|
pub struct NodeAdapter[T, G, L, P, E] {
  element_adapter : GraphElementAdapter[T]
  get_graph_fn : () -> G?
  get_labels_fn : () -> Array[L]
  get_ports_fn : () -> Array[P]
  get_incoming_edges_fn : () -> Array[E]
  get_outgoing_edges_fn : () -> Array[E]
  sort_port_list_fn : () -> Unit
  sort_port_list_with_fn : ((P, P) -> Int) -> Unit
  is_compound_node_fn : () -> Bool
  get_padding_fn : () -> ElkPadding
  set_padding_fn : (ElkPadding) -> Unit
  get_margin_fn : () -> ElkMargin
  set_margin_fn : (ElkMargin) -> Unit
}

///|
pub fn[T, G, L, P, E] new_node_adapter(
  element_adapter : GraphElementAdapter[T],
  get_graph_fn : () -> G?,
  get_labels_fn : () -> Array[L],
  get_ports_fn : () -> Array[P],
  get_incoming_edges_fn : () -> Array[E],
  get_outgoing_edges_fn : () -> Array[E],
  sort_port_list_fn : () -> Unit,
  sort_port_list_with_fn : ((P, P) -> Int) -> Unit,
  is_compound_node_fn : () -> Bool,
  get_padding_fn : () -> ElkPadding,
  set_padding_fn : (ElkPadding) -> Unit,
  get_margin_fn : () -> ElkMargin,
  set_margin_fn : (ElkMargin) -> Unit,
) -> NodeAdapter[T, G, L, P, E] {
  {
    element_adapter,
    get_graph_fn,
    get_labels_fn,
    get_ports_fn,
    get_incoming_edges_fn,
    get_outgoing_edges_fn,
    sort_port_list_fn,
    sort_port_list_with_fn,
    is_compound_node_fn,
    get_padding_fn,
    set_padding_fn,
    get_margin_fn,
    set_margin_fn,
  }
}

///|
pub fn[T, G, L, P, E] NodeAdapter::element_adapter(
  self : NodeAdapter[T, G, L, P, E],
) -> GraphElementAdapter[T] {
  self.element_adapter
}

///|
pub fn[T, G, L, P, E] NodeAdapter::get_graph(
  self : NodeAdapter[T, G, L, P, E],
) -> G? {
  (self.get_graph_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::get_labels(
  self : NodeAdapter[T, G, L, P, E],
) -> Array[L] {
  (self.get_labels_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::get_ports(
  self : NodeAdapter[T, G, L, P, E],
) -> Array[P] {
  (self.get_ports_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::get_incoming_edges(
  self : NodeAdapter[T, G, L, P, E],
) -> Array[E] {
  (self.get_incoming_edges_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::get_outgoing_edges(
  self : NodeAdapter[T, G, L, P, E],
) -> Array[E] {
  (self.get_outgoing_edges_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::sort_port_list(
  self : NodeAdapter[T, G, L, P, E],
) -> Unit {
  (self.sort_port_list_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::sort_port_list_with(
  self : NodeAdapter[T, G, L, P, E],
  comparator : (P, P) -> Int,
) -> Unit {
  (self.sort_port_list_with_fn)(comparator)
}

///|
pub fn[T, G, L, P, E] NodeAdapter::is_compound_node(
  self : NodeAdapter[T, G, L, P, E],
) -> Bool {
  (self.is_compound_node_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::get_padding(
  self : NodeAdapter[T, G, L, P, E],
) -> ElkPadding {
  (self.get_padding_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::set_padding(
  self : NodeAdapter[T, G, L, P, E],
  padding_value : ElkPadding,
) -> Unit {
  (self.set_padding_fn)(padding_value)
}

///|
pub fn[T, G, L, P, E] NodeAdapter::get_margin(
  self : NodeAdapter[T, G, L, P, E],
) -> ElkMargin {
  (self.get_margin_fn)()
}

///|
pub fn[T, G, L, P, E] NodeAdapter::set_margin(
  self : NodeAdapter[T, G, L, P, E],
  margin_value : ElkMargin,
) -> Unit {
  (self.set_margin_fn)(margin_value)
}

///|
pub struct PortAdapter[T, L, E] {
  element_adapter : GraphElementAdapter[T]
  get_side_fn : () -> PortSide
  get_labels_fn : () -> Array[L]
  get_margin_fn : () -> ElkMargin
  set_margin_fn : (ElkMargin) -> Unit
  get_incoming_edges_fn : () -> Array[E]
  get_outgoing_edges_fn : () -> Array[E]
  has_compound_connections_fn : () -> Bool
}

///|
pub fn[T, L, E] new_port_adapter(
  element_adapter : GraphElementAdapter[T],
  get_side_fn : () -> PortSide,
  get_labels_fn : () -> Array[L],
  get_margin_fn : () -> ElkMargin,
  set_margin_fn : (ElkMargin) -> Unit,
  get_incoming_edges_fn : () -> Array[E],
  get_outgoing_edges_fn : () -> Array[E],
  has_compound_connections_fn : () -> Bool,
) -> PortAdapter[T, L, E] {
  {
    element_adapter,
    get_side_fn,
    get_labels_fn,
    get_margin_fn,
    set_margin_fn,
    get_incoming_edges_fn,
    get_outgoing_edges_fn,
    has_compound_connections_fn,
  }
}

///|
pub fn[T, L, E] PortAdapter::element_adapter(
  self : PortAdapter[T, L, E],
) -> GraphElementAdapter[T] {
  self.element_adapter
}

///|
pub fn[T, L, E] PortAdapter::get_side(self : PortAdapter[T, L, E]) -> PortSide {
  (self.get_side_fn)()
}

///|
pub fn[T, L, E] PortAdapter::get_labels(
  self : PortAdapter[T, L, E],
) -> Array[L] {
  (self.get_labels_fn)()
}

///|
pub fn[T, L, E] PortAdapter::get_margin(
  self : PortAdapter[T, L, E],
) -> ElkMargin {
  (self.get_margin_fn)()
}

///|
pub fn[T, L, E] PortAdapter::set_margin(
  self : PortAdapter[T, L, E],
  margin_value : ElkMargin,
) -> Unit {
  (self.set_margin_fn)(margin_value)
}

///|
pub fn[T, L, E] PortAdapter::get_incoming_edges(
  self : PortAdapter[T, L, E],
) -> Array[E] {
  (self.get_incoming_edges_fn)()
}

///|
pub fn[T, L, E] PortAdapter::get_outgoing_edges(
  self : PortAdapter[T, L, E],
) -> Array[E] {
  (self.get_outgoing_edges_fn)()
}

///|
pub fn[T, L, E] PortAdapter::has_compound_connections(
  self : PortAdapter[T, L, E],
) -> Bool {
  (self.has_compound_connections_fn)()
}

///|
pub struct LabelAdapter[T] {
  element_adapter : GraphElementAdapter[T]
  get_side_fn : () -> LabelSide
  get_text_fn : () -> String
}

///|
pub fn[T] new_label_adapter(
  element_adapter : GraphElementAdapter[T],
  get_side_fn : () -> LabelSide,
  get_text_fn : () -> String,
) -> LabelAdapter[T] {
  { element_adapter, get_side_fn, get_text_fn }
}

///|
pub fn[T] LabelAdapter::element_adapter(
  self : LabelAdapter[T],
) -> GraphElementAdapter[T] {
  self.element_adapter
}

///|
pub fn[T] LabelAdapter::get_side(self : LabelAdapter[T]) -> LabelSide {
  (self.get_side_fn)()
}

///|
pub fn[T] LabelAdapter::get_text(self : LabelAdapter[T]) -> String {
  (self.get_text_fn)()
}

///|
pub struct EdgeAdapter[T, L] {
  element : T
  get_labels_fn : () -> Array[L]
}

///|
pub fn[T, L] new_edge_adapter(
  element : T,
  get_labels_fn : () -> Array[L],
) -> EdgeAdapter[T, L] {
  { element, get_labels_fn }
}

///|
pub fn[T, L] EdgeAdapter::get_element(self : EdgeAdapter[T, L]) -> T {
  self.element
}

///|
pub fn[T, L] EdgeAdapter::get_labels(self : EdgeAdapter[T, L]) -> Array[L] {
  (self.get_labels_fn)()
}
