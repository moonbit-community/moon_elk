///|
let spline_edge_router_max_vertical_diff_for_straight : Double = 0.2

///|
pub let spline_edge_router_spline_dimension : Int = 3

///|
pub enum SplineSideToProcess {
  Left
  Right
}

///|
pub fn spline_side_to_process_values() -> Array[SplineSideToProcess] {
  [Left, Right]
}

///|
pub fn spline_side_to_process_to_string(side : SplineSideToProcess) -> String {
  match side {
    Left => "LEFT"
    Right => "RIGHT"
  }
}

///|
pub struct SplineDependency {
  source : SplineSegment?
  target : SplineSegment?
  weight : Int
}

///|
pub fn new_spline_dependency(
  source : SplineSegment,
  target : SplineSegment,
  weight : Int,
) -> SplineDependency {
  let dependency = { source: Some(source), target: Some(target), weight }
  source.outgoing.push(dependency)
  target.incoming.push(dependency)
  dependency
}

///|
pub fn SplineDependency::to_string(self : SplineDependency) -> String {
  let source_mark = match self.source {
    Some(segment) => segment.mark.to_string()
    None => "null"
  }
  let target_mark = match self.target {
    Some(segment) => segment.mark.to_string()
    None => "null"
  }
  source_mark + " ->(" + self.weight.to_string() + ") " + target_mark
}

///|
pub fn spline_edge_router_is_straight(
  first_y : Double,
  second_y : Double,
) -> Bool {
  (first_y - second_y).abs() < spline_edge_router_max_vertical_diff_for_straight
}

///|
pub fn spline_edge_router_is_normal_node(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::Normal => true
    NodeType::BreakingPoint => true
    _ => false
  }
}

///|
pub fn spline_edge_router_is_qualified_as_starting_node(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::Normal => true
    NodeType::NorthSouthPort => true
    NodeType::ExternalPort => true
    NodeType::BreakingPoint => true
    _ => false
  }
}

///|
fn spline_edge_router_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(layout_processor_configuration_create(layered_phase_descriptor))
}

///|
fn spline_edge_router_process(
  layered_graph : LGraph,
  monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(layered_graph)
  let actual_monitor = match monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(actual_monitor.begin("Spline edge routing", 1.0))
  actual_monitor.done()
}

///|
pub fn new_spline_edge_router_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(spline_edge_router_process, spline_edge_router_configuration)
}
