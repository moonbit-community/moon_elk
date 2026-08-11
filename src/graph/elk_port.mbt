///|
pub struct ElkPort {
  priv arena : GraphArena
  priv slot : Int
  priv generation : Int
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
priv struct PortSlot {
  mut generation : Int
  handle : ElkPort
  mut data : PortData?
}

///|
fn checked_port_slot(port : ElkPort) -> PortSlot {
  let arena = port.arena
  checked_graph_arena(arena)
  if port.slot < 0 || port.slot >= arena.ports.length() {
    abort("invalid or disposed port id")
  }
  let slot = arena.ports[port.slot]
  if slot.generation != port.generation || slot.data is None {
    abort("invalid or disposed port id")
  }
  slot
}

///|
fn checked_port(port : ElkPort) -> Unit {
  ignore(checked_port_slot(port))
}

///|
fn port_data(port : ElkPort) -> PortData {
  match checked_port_slot(port).data {
    Some(data) => data
    None => abort("invalid or disposed port id")
  }
}

///|
fn set_port_data(port : ElkPort, data : PortData) -> Unit {
  checked_port_slot(port).data = Some(data)
}

///|
fn port_graph_arena(port : ElkPort) -> GraphArena {
  checked_port(port)
  port.arena
}

///|
pub fn ElkPort::graph_arena(self : ElkPort) -> GraphArena {
  port_graph_arena(self)
}

///|
fn dispose_port_slot(port : ElkPort) -> Unit {
  let slot = checked_port_slot(port)
  slot.data = None
  slot.generation += 1
}

///|
fn create_port_in_arena(parent : ElkNode?, arena : GraphArena) -> ElkPort {
  checked_graph_arena(arena)
  let slot = arena.ports.length()
  let port : ElkPort = {
    arena,
    slot,
    generation: 0,
    id: arena.allocate_object_id(),
  }
  arena.ports.push({
    generation: 0,
    handle: port,
    data: Some({
      parent,
      identifier: "",
      x: 0.0,
      y: 0.0,
      width: 0.0,
      height: 0.0,
      layout_option_string_values: Map([]),
    }),
  })
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
  let data = port_data(port)
  set_port_data(port, {
    parent: data.parent,
    identifier: data.identifier,
    x,
    y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn port_x(port : ElkPort) -> Double {
  port_data(port).x
}

///|
pub fn port_y(port : ElkPort) -> Double {
  port_data(port).y
}

///|
pub fn port_set_dimensions(
  port : ElkPort,
  width : Double,
  height : Double,
) -> Unit {
  let data = port_data(port)
  set_port_data(port, {
    parent: data.parent,
    identifier: data.identifier,
    x: data.x,
    y: data.y,
    width,
    height,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn port_width(port : ElkPort) -> Double {
  port_data(port).width
}

///|
pub fn port_height(port : ElkPort) -> Double {
  port_data(port).height
}

///|
pub fn port_set_identifier(port : ElkPort, identifier : String) -> Unit {
  let data = port_data(port)
  set_port_data(port, {
    parent: data.parent,
    identifier,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn port_identifier(port : ElkPort) -> String {
  port_data(port).identifier
}

///|
pub fn port_set_layout_option_string_by_id(
  port : ElkPort,
  option_id : String,
  value : String,
) -> Unit {
  let data = port_data(port)
  data.layout_option_string_values[option_id] = value
  set_port_data(port, data)
}

///|
pub fn port_layout_option_string_entries(
  port : ElkPort,
) -> Array[(String, String)] {
  port_data(port).layout_option_string_values.to_array()
}

///|
pub fn port_layout_option_string_value(
  port : ElkPort,
  option_id : String,
) -> String? {
  port_data(port).layout_option_string_values.get(option_id)
}

///|
pub fn port_parent(port : ElkPort) -> ElkNode? {
  port_data(port).parent
}

///|
pub fn port_incoming_edges(port : ElkPort) -> Array[ElkEdge] {
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
