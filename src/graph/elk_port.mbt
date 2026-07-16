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
let port_store : Ref[Array[PortData]] = Ref([])

///|
let port_next_handle : Ref[Int] = Ref(0)

///|
let port_free_slots : Ref[Array[Int]] = Ref([])

///|
let port_handle_slots : Ref[Map[Int, Int]] = Ref(Map([]))

///|
let port_slot_handles : Ref[Array[Int]] = Ref([])

///|
fn port_allocated_slot(port : ElkPort) -> Int {
  match port_handle_slots.val.get(port) {
    Some(slot) => slot
    None => abort("invalid or disposed port id")
  }
}

///|
fn port_slot(port : ElkPort) -> Int {
  let slot = port_allocated_slot(port)
  if port_arena_store.val[slot] < 0 {
    abort("invalid or disposed port id")
  }
  slot
}

///|
fn checked_port(port : ElkPort) -> Unit {
  ignore(port_slot(port))
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
  let slot = port_slot(port)
  port_store.val[slot] = disposed_port_data
  port_arena_store.val[slot] = -1
  graph_handle_release(
    port,
    slot,
    port_handle_slots.val,
    port_slot_handles.val,
    port_free_slots.val,
  )
}

///|
fn create_port_in_arena(parent : ElkNode?, arena_id : Int) -> ElkPort {
  let slot = match port_free_slots.val.pop() {
    Some(reused) => reused
    None => {
      let fresh = port_store.val.length()
      port_store.val.push(disposed_port_data)
      port_arena_store.val.push(-1)
      port_slot_handles.val.push(-1)
      fresh
    }
  }
  let id = graph_handle_allocate(
    slot,
    port_next_handle,
    port_handle_slots.val,
    port_slot_handles.val,
  )
  port_store.val[slot] = {
    parent,
    identifier: "",
    x: 0.0,
    y: 0.0,
    width: 0.0,
    height: 0.0,
    layout_option_string_values: Map([]),
  }
  graph_arena_register_port(arena_id, id)
  if parent is Some(parent_id) {
    append_port(parent_id, id)
  }
  id
}

///|
pub fn GraphArena::create_port(self : GraphArena) -> ElkPort {
  checked_graph_arena(self)
  create_port_in_arena(None, self.id)
}

///|
pub fn create_port(parent : ElkNode?) -> ElkPort {
  match parent {
    Some(parent_id) => {
      checked_node(parent_id)
      create_port_in_arena(
        Some(parent_id),
        node_arena_store.val[node_slot(parent_id)],
      )
    }
    None => new_graph_arena().create_port()
  }
}

///|
pub fn port_set_location(port : ElkPort, x : Double, y : Double) -> Unit {
  checked_port(port)
  let data = port_store.val[port_slot(port)]
  port_store.val[port_slot(port)] = {
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
  port_store.val[port_slot(port)].x
}

///|
pub fn port_y(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port_slot(port)].y
}

///|
pub fn port_set_dimensions(
  port : ElkPort,
  width : Double,
  height : Double,
) -> Unit {
  checked_port(port)
  let data = port_store.val[port_slot(port)]
  port_store.val[port_slot(port)] = {
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
  port_store.val[port_slot(port)].width
}

///|
pub fn port_height(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port_slot(port)].height
}

///|
pub fn port_set_identifier(port : ElkPort, identifier : String) -> Unit {
  checked_port(port)
  let data = port_store.val[port_slot(port)]
  port_store.val[port_slot(port)] = {
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
  port_store.val[port_slot(port)].identifier
}

///|
pub fn port_set_layout_option_string_by_id(
  port : ElkPort,
  option_id : String,
  value : String,
) -> Unit {
  checked_port(port)
  let data = port_store.val[port_slot(port)]
  data.layout_option_string_values[option_id] = value
  port_store.val[port_slot(port)] = data
}

///|
pub fn port_layout_option_string_entries(
  port : ElkPort,
) -> Array[(String, String)] {
  checked_port(port)
  port_store.val[port_slot(port)].layout_option_string_values.to_array()
}

///|
pub fn port_layout_option_string_value(
  port : ElkPort,
  option_id : String,
) -> String? {
  checked_port(port)
  port_store.val[port_slot(port)].layout_option_string_values.get(option_id)
}

///|
pub fn port_parent(port : ElkPort) -> ElkNode? {
  checked_port(port)
  port_store.val[port_slot(port)].parent
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
