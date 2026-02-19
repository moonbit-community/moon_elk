///|
pub struct SelfLoopEdge {
  l_edge : LEdge
  mut sl_hyper_loop : SelfHyperLoop?
  sl_source : SelfLoopPort
  sl_target : SelfLoopPort
}

///|
fn self_loop_edge_ports_match_ledge(
  l_edge : LEdge,
  sl_source : SelfLoopPort,
  sl_target : SelfLoopPort,
) -> Bool {
  match (l_edge.get_source(), l_edge.get_target()) {
    (Some(source), Some(target)) =>
      lport_internal_handle(source) ==
      lport_internal_handle(sl_source.get_l_port()) &&
      lport_internal_handle(target) ==
      lport_internal_handle(sl_target.get_l_port())
    _ => false
  }
}

///|
pub fn new_self_loop_edge(
  l_edge : LEdge,
  sl_source : SelfLoopPort,
  sl_target : SelfLoopPort,
) -> SelfLoopEdge {
  if !l_edge.is_self_loop() {
    abort("SelfLoopEdge requires a self loop edge")
  }
  if !self_loop_edge_ports_match_ledge(l_edge, sl_source, sl_target) {
    abort("SelfLoopEdge source/target ports must match the represented edge")
  }

  let sl_edge = { l_edge, sl_hyper_loop: None, sl_source, sl_target }

  sl_source.get_outgoing_sl_edges().push(sl_edge)
  sl_target.get_incoming_sl_edges().push(sl_edge)

  sl_edge
}

///|
pub fn SelfLoopEdge::get_l_edge(self : SelfLoopEdge) -> LEdge {
  self.l_edge
}

///|
pub fn SelfLoopEdge::get_sl_hyper_loop(self : SelfLoopEdge) -> SelfHyperLoop? {
  self.sl_hyper_loop
}

///|
pub fn SelfLoopEdge::set_sl_hyper_loop(
  self : SelfLoopEdge,
  sl_hyper_loop : SelfHyperLoop,
) -> Unit {
  if self.sl_hyper_loop.is_some() {
    abort("SelfLoopEdge hyper loop may only be set once")
  }
  self.sl_hyper_loop = Some(sl_hyper_loop)
}

///|
pub fn SelfLoopEdge::get_sl_source(self : SelfLoopEdge) -> SelfLoopPort {
  self.sl_source
}

///|
pub fn SelfLoopEdge::get_sl_target(self : SelfLoopEdge) -> SelfLoopPort {
  self.sl_target
}

///|
pub fn SelfLoopEdge::is_inline(self : SelfLoopEdge) -> Bool {
  false
}

///|
pub fn SelfLoopEdge::get_label_side(self : SelfLoopEdge) -> @core.PortSide {
  match self.sl_hyper_loop {
    Some(sl_hyper_loop) =>
      match sl_hyper_loop.get_sl_labels() {
        Some(sl_labels) => sl_labels.get_side()
        None => @core.PortSide::SideUndefined
      }
    None => @core.PortSide::SideUndefined
  }
}
