///|
pub type ElkPort = Int

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
let port_store : Ref[Array[PortData]] = Ref::new([])

///|
fn checked_port(port : ElkPort) -> Unit {
  if port < 0 || port >= port_store.val.length() {
    abort("invalid port id")
  }
}

///|
pub fn create_port(parent : ElkNode?) -> ElkPort {
  let id = port_store.val.length()
  port_store.val.push({
    parent,
    identifier: "",
    x: 0.0,
    y: 0.0,
    width: 0.0,
    height: 0.0,
    layout_option_string_values: {},
  })
  if parent is Some(parent_id) {
    checked_node(parent_id)
    append_port(parent_id, id)
  }
  id
}

///|
pub fn port_set_location(port : ElkPort, x : Double, y : Double) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  port_store.val[port] = {
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
  port_store.val[port].x
}

///|
pub fn port_y(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port].y
}

///|
pub fn port_set_dimensions(
  port : ElkPort,
  width : Double,
  height : Double,
) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  port_store.val[port] = {
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
  port_store.val[port].width
}

///|
pub fn port_height(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port].height
}

///|
pub fn port_set_identifier(port : ElkPort, identifier : String) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  port_store.val[port] = {
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
  port_store.val[port].identifier
}

///|
pub fn port_set_layout_option_string_by_id(
  port : ElkPort,
  option_id : String,
  value : String,
) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  data.layout_option_string_values[option_id] = value
  port_store.val[port] = data
}

///|
pub fn port_layout_option_string_value(
  port : ElkPort,
  option_id : String,
) -> String? {
  checked_port(port)
  port_store.val[port].layout_option_string_values.get(option_id)
}

///|
pub fn port_parent(port : ElkPort) -> ElkNode? {
  checked_port(port)
  port_store.val[port].parent
}

///|
pub fn port_incoming_edges(port : ElkPort) -> Array[ElkEdge] {
  checked_port(port)
  let incoming = []
  for edge in all_edges() {
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
  for edge in all_edges() {
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
