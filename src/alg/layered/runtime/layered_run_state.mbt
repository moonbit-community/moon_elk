///|
/// Owns every mutable value whose lifetime is one layered layout execution.
///
/// Graph elements deliberately do not retain this object. Processors receive
/// it from the execution plan, so clearing the state deterministically breaks
/// temporary references to graph nodes, edges, labels, and routing objects.
pub struct LayeredRunState {
  random_state : @state.LayeredLayoutState
  end_label_cells : Map[Int, Array[EndLabelCell]]
  breaking_points : Map[Int, BPInfo]
  self_loop_holders : Map[Int, SelfLoopHolder]
  spline_segments : Map[Int, Array[SplineSegment]]
}

///|
pub fn new_layered_run_state() -> LayeredRunState {
  {
    random_state: @state.new_layered_layout_state(),
    end_label_cells: Map([]),
    breaking_points: Map([]),
    self_loop_holders: Map([]),
    spline_segments: Map([]),
  }
}

///|
pub fn LayeredRunState::initialize_random(
  self : LayeredRunState,
  seed_value : Int,
) -> Unit {
  self.random_state.initialize_random(seed_value)
}

///|
pub fn LayeredRunState::random(
  self : LayeredRunState,
  seed_value : Int,
) -> @state.GreedySwitchMockRandom {
  self.random_state.random(seed_value)
}

///|
pub fn LayeredRunState::install_random(
  self : LayeredRunState,
  random : @state.GreedySwitchMockRandom,
  first_boolean : Bool?,
) -> Unit {
  self.random_state.install_random(random, first_boolean)
}

///|
pub fn LayeredRunState::first_random_boolean(self : LayeredRunState) -> Bool? {
  self.random_state.first_random_boolean()
}

///|
pub fn LayeredRunState::set_end_label_cells(
  self : LayeredRunState,
  node : LNode,
  cells : Array[EndLabelCell],
) -> Unit {
  self.end_label_cells[lnode_internal_handle(node)] = cells
}

///|
pub fn LayeredRunState::get_end_label_cells(
  self : LayeredRunState,
  node : LNode,
) -> Array[EndLabelCell] {
  self.end_label_cells.get(lnode_internal_handle(node)).unwrap_or([])
}

///|
pub fn LayeredRunState::has_end_label_cells(
  self : LayeredRunState,
  node : LNode,
) -> Bool {
  self.end_label_cells.contains(lnode_internal_handle(node))
}

///|
pub fn LayeredRunState::clear_end_label_cells(
  self : LayeredRunState,
  node : LNode,
) -> Unit {
  let handle = lnode_internal_handle(node)
  match self.end_label_cells.get(handle) {
    Some(cells) =>
      for cell in cells {
        cell.dispose()
      }
    None => ()
  }
  self.end_label_cells.remove(handle)
}

///|
pub fn LayeredRunState::set_breaking_point(
  self : LayeredRunState,
  node : LNode,
  info : BPInfo?,
) -> Unit {
  match info {
    Some(value) => self.breaking_points[lnode_internal_handle(node)] = value
    None => ignore(self.breaking_points.remove(lnode_internal_handle(node)))
  }
}

///|
pub fn LayeredRunState::get_breaking_point(
  self : LayeredRunState,
  node : LNode,
) -> BPInfo? {
  self.breaking_points.get(lnode_internal_handle(node))
}

///|
pub fn LayeredRunState::set_self_loop_holder(
  self : LayeredRunState,
  node : LNode,
  holder : SelfLoopHolder?,
) -> Unit {
  match holder {
    Some(value) => self.self_loop_holders[lnode_internal_handle(node)] = value
    None => ignore(self.self_loop_holders.remove(lnode_internal_handle(node)))
  }
}

///|
pub fn LayeredRunState::get_self_loop_holder(
  self : LayeredRunState,
  node : LNode,
) -> SelfLoopHolder? {
  self.self_loop_holders.get(lnode_internal_handle(node))
}

///|
pub fn LayeredRunState::has_self_loop_holder(
  self : LayeredRunState,
  node : LNode,
) -> Bool {
  self.self_loop_holders.contains(lnode_internal_handle(node))
}

///|
pub fn LayeredRunState::set_spline_segments(
  self : LayeredRunState,
  edge : LEdge,
  segments : Array[SplineSegment],
) -> Unit {
  self.spline_segments[ledge_internal_handle(edge)] = segments
}

///|
pub fn LayeredRunState::get_spline_segments(
  self : LayeredRunState,
  edge : LEdge,
) -> Array[SplineSegment] {
  self.spline_segments.get(ledge_internal_handle(edge)).unwrap_or([])
}

///|
pub fn LayeredRunState::has_spline_segments(
  self : LayeredRunState,
  edge : LEdge,
) -> Bool {
  self.spline_segments.contains(ledge_internal_handle(edge))
}

///|
pub fn LayeredRunState::clear(self : LayeredRunState) -> Unit {
  self.random_state.clear()
  for cells in self.end_label_cells.values() {
    for cell in cells {
      cell.dispose()
    }
  }
  self.end_label_cells.clear()
  self.breaking_points.clear()
  self.self_loop_holders.clear()
  self.spline_segments.clear()
}
