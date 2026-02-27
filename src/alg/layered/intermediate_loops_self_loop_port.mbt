///|
pub struct SelfLoopPort {
  l_port : LPort
  had_only_self_loops : Bool
  incoming_sl_edges : Array[SelfLoopEdge]
  outgoing_sl_edges : Array[SelfLoopEdge]
  mut hidden : Bool
}

///|
fn self_loop_port_connected_edge_count(l_port : LPort) -> Int {
  l_port.get_connected_edges().length()
}

///|
fn self_loop_port_had_only_self_loops(l_port : LPort) -> Bool {
  let connected_edges = l_port.get_connected_edges()
  for edge in connected_edges {
    if !edge.is_self_loop() {
      return false
    }
  }
  true
}

///|
pub fn new_self_loop_port(l_port : LPort) -> SelfLoopPort {
  if self_loop_port_connected_edge_count(l_port) == 0 {
    @core.layout_runtime_report_unsupported_configuration(
      "SelfLoopPort requires at least one connected edge",
    )
  }

  {
    l_port,
    had_only_self_loops: self_loop_port_had_only_self_loops(l_port),
    incoming_sl_edges: [],
    outgoing_sl_edges: [],
    hidden: false,
  }
}

///|
pub fn SelfLoopPort::get_l_port(self : SelfLoopPort) -> LPort {
  self.l_port
}

///|
pub fn SelfLoopPort::had_only_self_loops(self : SelfLoopPort) -> Bool {
  self.had_only_self_loops
}

///|
pub fn SelfLoopPort::is_hidden(self : SelfLoopPort) -> Bool {
  self.hidden
}

///|
pub fn SelfLoopPort::set_hidden(self : SelfLoopPort, hidden : Bool) -> Unit {
  self.hidden = hidden
}

///|
pub fn SelfLoopPort::get_incoming_sl_edges(
  self : SelfLoopPort,
) -> Array[SelfLoopEdge] {
  self.incoming_sl_edges
}

///|
pub fn SelfLoopPort::get_outgoing_sl_edges(
  self : SelfLoopPort,
) -> Array[SelfLoopEdge] {
  self.outgoing_sl_edges
}

///|
pub fn SelfLoopPort::get_sl_net_flow(self : SelfLoopPort) -> Int {
  self.incoming_sl_edges.length() - self.outgoing_sl_edges.length()
}
