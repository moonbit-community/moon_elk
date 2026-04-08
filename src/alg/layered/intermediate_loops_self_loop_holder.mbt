///|
let self_loop_holder_unvisited : Int = 0

///|
let self_loop_holder_visited : Int = 1

///|
pub(all) suberror SelfLoopHolderException {
  UnsupportedConfigurationException(String)
  IllegalStateException(String)
} derive(Debug, ToJson)

///|
pub fn self_loop_holder_exception_message(
  error : SelfLoopHolderException,
) -> String {
  match error {
    SelfLoopHolderException::UnsupportedConfigurationException(message) =>
      message
    SelfLoopHolderException::IllegalStateException(message) => message
  }
}

///|
fn[T] self_loop_holder_raise_unsupported_configuration(
  message : String,
) -> T raise SelfLoopHolderException {
  raise SelfLoopHolderException::UnsupportedConfigurationException(message)
}

///|
fn[T] self_loop_holder_raise_illegal_state(
  message : String,
) -> T raise SelfLoopHolderException {
  raise SelfLoopHolderException::IllegalStateException(message)
}

///|
pub struct SelfLoopHolder {
  l_node : LNode
  sl_hyper_loops : Array[SelfHyperLoop]
  sl_ports : Map[Int, SelfLoopPort]
  sl_port_order : Array[Int]
  mut are_ports_hidden : Bool
  routing_slot_count : Array[Int]
}

///|
pub fn new_self_loop_holder(l_node : LNode) -> SelfLoopHolder {
  {
    l_node,
    sl_hyper_loops: [],
    sl_ports: {},
    sl_port_order: [],
    are_ports_hidden: false,
    routing_slot_count: [0, 0, 0, 0, 0],
  }
}

///|
pub fn self_loop_holder_needs_self_loop_processing(l_node : LNode) -> Bool {
  match l_node.get_type() {
    NodeType::Normal => ()
    _ => return false
  }

  for edge in l_node.get_outgoing_edges() {
    if edge.is_self_loop() {
      return true
    }
  }
  false
}

///|
pub fn self_loop_holder_install(
  l_node : LNode,
) -> SelfLoopHolder raise SelfLoopHolderException {
  if !self_loop_holder_needs_self_loop_processing(l_node) {
    self_loop_holder_raise_unsupported_configuration(
      "self loop holder can only be installed on normal nodes with self loops",
    )
  }

  let holder = new_self_loop_holder(l_node)
  l_node.set_property_self_loop_holder(
    internal_properties_self_loop_holder,
    Some(holder),
  )
  self_loop_holder_initialize(holder)
  holder
}

///|
fn self_loop_holder_self_loop_port_for(
  holder : SelfLoopHolder,
  l_port : LPort,
) -> SelfLoopPort {
  let handle = lport_internal_handle(l_port)
  match holder.sl_ports.get(handle) {
    Some(sl_port) => sl_port
    None => {
      let sl_port = new_self_loop_port(l_port)
      holder.sl_ports[handle] = sl_port
      holder.sl_port_order.push(handle)
      sl_port
    }
  }
}

///|
fn self_loop_holder_initialize_hyper_loop(
  holder : SelfLoopHolder,
  sl_port : SelfLoopPort,
) -> SelfHyperLoop {
  let sl_loop = new_self_hyper_loop(holder)

  let bfs_queue = [sl_port]
  let mut queue_index = 0
  while queue_index < bfs_queue.length() {
    let current_sl_port = bfs_queue[queue_index]
    queue_index += 1

    current_sl_port.get_l_port().set_id(self_loop_holder_visited)

    for sl_edge in current_sl_port.get_outgoing_sl_edges() {
      sl_loop.add_self_loop_edge(sl_edge)

      let sl_target_port = sl_edge.get_sl_target()
      if sl_target_port.get_l_port().get_id() == self_loop_holder_unvisited {
        bfs_queue.push(sl_target_port)
      }
    }

    for sl_edge in current_sl_port.get_incoming_sl_edges() {
      sl_loop.add_self_loop_edge(sl_edge)

      let sl_source_port = sl_edge.get_sl_source()
      if sl_source_port.get_l_port().get_id() == self_loop_holder_unvisited {
        bfs_queue.push(sl_source_port)
      }
    }
  }

  sl_loop
}

///|
fn self_loop_holder_initialize(
  holder : SelfLoopHolder,
) -> Unit raise SelfLoopHolderException {
  let sl_edges = []

  for l_edge in holder.l_node.get_outgoing_edges() {
    if !l_edge.is_self_loop() {
      continue
    }

    let source_port = match l_edge.get_source() {
      Some(port) => port
      None =>
        self_loop_holder_raise_illegal_state(
          "self loop edge has no source port",
        )
    }
    let target_port = match l_edge.get_target() {
      Some(port) => port
      None =>
        self_loop_holder_raise_illegal_state(
          "self loop edge has no target port",
        )
    }

    sl_edges.push(
      new_self_loop_edge(
        l_edge,
        self_loop_holder_self_loop_port_for(holder, source_port),
        self_loop_holder_self_loop_port_for(holder, target_port),
      ),
    )
  }

  ignore(sl_edges)

  for sl_port_handle in holder.sl_port_order {
    match holder.sl_ports.get(sl_port_handle) {
      Some(sl_port) => sl_port.get_l_port().set_id(self_loop_holder_unvisited)
      None =>
        self_loop_holder_raise_illegal_state(
          "self loop port map out of sync with insertion order",
        )
    }
  }

  for sl_port_handle in holder.sl_port_order {
    let sl_port = match holder.sl_ports.get(sl_port_handle) {
      Some(value) => value
      None =>
        self_loop_holder_raise_illegal_state(
          "self loop port map out of sync with insertion order",
        )
    }
    if sl_port.get_l_port().get_id() == self_loop_holder_unvisited {
      holder.sl_hyper_loops.push(
        self_loop_holder_initialize_hyper_loop(holder, sl_port),
      )
    }
  }
}

///|
pub fn SelfLoopHolder::get_l_node(self : SelfLoopHolder) -> LNode {
  self.l_node
}

///|
pub fn SelfLoopHolder::get_sl_hyper_loops(
  self : SelfLoopHolder,
) -> Array[SelfHyperLoop] {
  self.sl_hyper_loops
}

///|
pub fn SelfLoopHolder::get_sl_port_map(
  self : SelfLoopHolder,
) -> Map[Int, SelfLoopPort] {
  self.sl_ports
}

///|
pub fn SelfLoopHolder::are_ports_hidden(self : SelfLoopHolder) -> Bool {
  self.are_ports_hidden
}

///|
pub fn SelfLoopHolder::set_ports_hidden(
  self : SelfLoopHolder,
  hidden : Bool,
) -> Unit {
  self.are_ports_hidden = hidden
}

///|
pub fn SelfLoopHolder::get_routing_slot_count(
  self : SelfLoopHolder,
) -> Array[Int] {
  self.routing_slot_count
}
