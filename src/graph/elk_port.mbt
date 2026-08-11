///|
pub struct ElkPort {
  priv mut data : PortData
  priv mut arena : GraphArena?
  priv id : Int
}

///|
pub impl Eq for ElkPort with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub impl Hash for ElkPort with fn hash(self) {
  self.id
}

///|
pub impl Hash for ElkPort with fn hash_combine(self, hasher) {
  hasher.combine_int(self.id)
}

///|
pub impl @debug.Debug for ElkPort with fn to_repr(self) {
  Repr(self.id)
}

///|
pub impl Show for ElkPort with fn output(self, logger) {
  logger.write_string(self.id.to_string())
}

///|
priv struct PortData {
  parent : ElkNode?
  identifier : String
  x : Double
  y : Double
  width : Double
  height : Double
  layout_option_string_values : Map[String, String]
}

///|
fn checked_port(port : ElkPort) -> Unit {
  match port.arena {
    Some(arena) => checked_graph_arena(arena)
    None => abort("invalid or disposed port id")
  }
}

///|
fn port_graph_arena(port : ElkPort) -> GraphArena {
  checked_port(port)
  match port.arena {
    Some(arena) => arena
    None => abort("invalid or disposed port id")
  }
}

///|
pub fn ElkPort::graph_arena(self : ElkPort) -> GraphArena {
  port_graph_arena(self)
}

///|
let disposed_port_data : PortData = {
  parent: None,
  identifier: "",
  x: 0.0,
  y: 0.0,
  width: 0.0,
  height: 0.0,
  layout_option_string_values: Map([]),
}

///|
fn dispose_port_slot(port : ElkPort) -> Unit {
  checked_port(port)
  port.data = disposed_port_data
  port.arena = None
}

///|
fn create_port_in_arena(parent : ElkNode?, arena : GraphArena) -> ElkPort {
  let port : ElkPort = {
    data: {
      parent,
      identifier: "",
      x: 0.0,
      y: 0.0,
      width: 0.0,
      height: 0.0,
      layout_option_string_values: Map([]),
    },
    arena: Some(arena),
    id: arena.allocate_object_id(),
  }
  graph_arena_register_port(arena, port)
  if parent is Some(parent_id) {
    append_port(parent_id, port)
  }
  port
}

///|
pub fn GraphArena::create_port(self : GraphArena) -> ElkPort {
  checked_graph_arena(self)
  create_port_in_arena(None, self)
}

///|
pub fn create_port(parent : ElkNode?) -> ElkPort {
  match parent {
    Some(parent_id) => {
      checked_node(parent_id)
      create_port_in_arena(Some(parent_id), node_graph_arena(parent_id))
    }
    None => new_graph_arena().create_port()
  }
}

///|
pub fn port_set_location(port : ElkPort, x : Double, y : Double) -> Unit {
  checked_port(port)
  let data = port.data
  port.data = {
    parent: data.parent,
    identifier: data.identifier,
    x,
    y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn port_x(port : ElkPort) -> Double {
  checked_port(port)
  port.data.x
}

///|
pub fn port_y(port : ElkPort) -> Double {
  checked_port(port)
  port.data.y
}

///|
pub fn port_set_dimensions(
  port : ElkPort,
  width : Double,
  height : Double,
) -> Unit {
  checked_port(port)
  let data = port.data
  port.data = {
    parent: data.parent,
    identifier: data.identifier,
    x: data.x,
    y: data.y,
    width,
    height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn port_width(port : ElkPort) -> Double {
  checked_port(port)
  port.data.width
}

///|
pub fn port_height(port : ElkPort) -> Double {
  checked_port(port)
  port.data.height
}

///|
pub fn port_set_identifier(port : ElkPort, identifier : String) -> Unit {
  checked_port(port)
  let data = port.data
  port.data = {
    parent: data.parent,
    identifier,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn port_identifier(port : ElkPort) -> String {
  checked_port(port)
  port.data.identifier
}

///|
pub fn port_set_layout_option_string_by_id(
  port : ElkPort,
  option_id : String,
  value : String,
) -> Unit {
  checked_port(port)
  let data = port.data
  data.layout_option_string_values[option_id] = value
  port.data = data
}

///|
pub fn port_layout_option_string_entries(
  port : ElkPort,
) -> Array[(String, String)] {
  checked_port(port)
  port.data.layout_option_string_values.to_array()
}

///|
pub fn port_layout_option_string_value(
  port : ElkPort,
  option_id : String,
) -> String? {
  checked_port(port)
  port.data.layout_option_string_values.get(option_id)
}

///|
pub fn port_parent(port : ElkPort) -> ElkNode? {
  checked_port(port)
  port.data.parent
}

///|
pub fn port_incoming_edges(port : ElkPort) -> Array[ElkEdge] {
  checked_port(port)
  let incoming = []
  for edge in port_graph_arena(port).all_edges() {
    for target in edge_targets(edge) {
      match target {
        PortShape(target_port) =>
          if target_port == port {
            incoming.push(edge)
            break
          }
        _ => ()
      }
    }
  }
  incoming
}

///|
pub fn port_outgoing_edges(port : ElkPort) -> Array[ElkEdge] {
  checked_port(port)
  let outgoing = []
  for edge in port_graph_arena(port).all_edges() {
    for source in edge_sources(edge) {
      match source {
        PortShape(source_port) =>
          if source_port == port {
            outgoing.push(edge)
            break
          }
        _ => ()
      }
    }
  }
  outgoing
}
