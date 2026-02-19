///|
fn spline_segment_side_to_process_equals(
  left : SplineSideToProcess,
  right : SplineSideToProcess,
) -> Bool {
  match (left, right) {
    (Left, Left) => true
    (Right, Right) => true
    _ => false
  }
}

///|
fn spline_segment_port_side_equals(left : PortSide, right : PortSide) -> Bool {
  match (left, right) {
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    (SideUndefined, SideUndefined) => true
    _ => false
  }
}

///|
fn spline_segment_pair_side(
  pair : Pair[SplineSideToProcess, LEdge],
) -> SplineSideToProcess {
  match pair.get_first() {
    Some(side) => side
    None => abort("missing side information in edge pair")
  }
}

///|
fn spline_segment_pair_edge(pair : Pair[SplineSideToProcess, LEdge]) -> LEdge {
  match pair.get_second() {
    Some(edge) => edge
    None => abort("missing edge in edge pair")
  }
}

///|
fn spline_segment_edge_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(source) => source
    None => abort("edge source is not connected")
  }
}

///|
fn spline_segment_edge_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(target) => target
    None => abort("edge target is not connected")
  }
}

///|
fn spline_segment_add_port_if_absent(
  ports : Array[LPort],
  port : LPort,
) -> Unit {
  let handle = lport_internal_handle(port)
  for existing in ports {
    if lport_internal_handle(existing) == handle {
      return
    }
  }
  ports.push(port)
}

///|
fn spline_segment_add_edge_if_absent(
  edges : Array[LEdge],
  edge : LEdge,
) -> Bool {
  let handle = ledge_internal_handle(edge)
  for existing in edges {
    if ledge_internal_handle(existing) == handle {
      return false
    }
  }
  edges.push(edge)
  true
}

///|
fn spline_segment_anchor_y(port : LPort) -> Double {
  if port_side_is_vertical(port.get_side()) {
    port.get_property_double(internal_properties_spline_ns_port_y_coord)
  } else {
    port.get_absolute_anchor().y
  }
}

///|
let spline_segment_hyper_edge_pos_outer_rate : Double = 0.9

///|
let spline_segment_hyper_edge_pos_mid_rate : Double = 1.0 -
  spline_segment_hyper_edge_pos_outer_rate

///|
let spline_segment_one_half : Double = 0.5

///|
pub struct SplineSegmentEdgeInformation {
  start_y : Double
  end_y : Double
  normal_source_node : Bool
  normal_target_node : Bool
  inverted_left : Bool
  inverted_right : Bool
}

///|
pub struct SplineSegment {
  mut handled : Bool
  left_ports : Array[LPort]
  right_ports : Array[LPort]
  outgoing : Array[SplineDependency]
  incoming : Array[SplineDependency]
  mut mark : Int
  mut inweight : Int
  mut outweight : Int
  mut rank : Int
  edges : Array[LEdge]
  mut is_straight : Bool
  bounding_box : ElkRectangle
  mut is_west_of_initial_layer : Bool
  mut x_delta : Double
  mut source_port : LPort?
  mut target_port : LPort?
  mut initial_segment : Bool
  mut last_segment : Bool
  mut source_node : LNode?
  mut target_node : LNode?
  mut inverse_order : Bool
  mut hyper_edge_top_y_pos : Double
  mut hyper_edge_bottom_y_pos : Double
  mut center_control_point_y : Double
  edge_information : Map[Int, SplineSegmentEdgeInformation]
}

///|
fn new_spline_segment_base(is_straight : Bool) -> SplineSegment {
  {
    handled: false,
    left_ports: [],
    right_ports: [],
    outgoing: [],
    incoming: [],
    mark: 0,
    inweight: 0,
    outweight: 0,
    rank: 0,
    edges: [],
    is_straight,
    bounding_box: new_elk_rectangle(),
    is_west_of_initial_layer: false,
    x_delta: 0.0,
    source_port: None,
    target_port: None,
    initial_segment: false,
    last_segment: false,
    source_node: None,
    target_node: None,
    inverse_order: false,
    hyper_edge_top_y_pos: 0.0,
    hyper_edge_bottom_y_pos: 0.0,
    center_control_point_y: 0.0,
    edge_information: {},
  }
}

///|
fn spline_segment_set_relevant_positions(
  segment : SplineSegment,
  source_y : Double,
  target_y_min : Double,
  target_y_max : Double,
) -> Unit {
  segment.bounding_box.y = if source_y < target_y_min {
    source_y
  } else {
    target_y_min
  }

  let top = if source_y > target_y_max { source_y } else { target_y_max }
  segment.bounding_box.height = top - segment.bounding_box.y

  if source_y < target_y_min {
    segment.center_control_point_y = spline_segment_one_half *
      (source_y + target_y_min)
    segment.hyper_edge_top_y_pos = spline_segment_hyper_edge_pos_mid_rate *
      segment.center_control_point_y +
      spline_segment_hyper_edge_pos_outer_rate * source_y
    segment.hyper_edge_bottom_y_pos = spline_segment_hyper_edge_pos_mid_rate *
      segment.center_control_point_y +
      spline_segment_hyper_edge_pos_outer_rate * target_y_min
  } else {
    segment.center_control_point_y = spline_segment_one_half *
      (source_y + target_y_max)
    segment.hyper_edge_top_y_pos = spline_segment_hyper_edge_pos_mid_rate *
      segment.center_control_point_y +
      spline_segment_hyper_edge_pos_outer_rate * target_y_max
    segment.hyper_edge_bottom_y_pos = spline_segment_hyper_edge_pos_mid_rate *
      segment.center_control_point_y +
      spline_segment_hyper_edge_pos_outer_rate * source_y
  }
}

///|
fn SplineSegment::add_edge(self : SplineSegment, edge : LEdge) -> Unit {
  if !spline_segment_add_edge_if_absent(self.edges, edge) {
    return
  }

  let source = spline_segment_edge_source(edge)
  let target = spline_segment_edge_target(edge)
  let source_side = source.get_side()
  let target_side = target.get_side()

  self.edge_information[ledge_internal_handle(edge)] = {
    start_y: spline_segment_anchor_y(source),
    end_y: spline_segment_anchor_y(target),
    normal_source_node: spline_edge_router_is_normal_node(
      source.get_node().unwrap(),
    ),
    normal_target_node: spline_edge_router_is_normal_node(
      target.get_node().unwrap(),
    ),
    inverted_left: spline_segment_port_side_equals(source_side, West),
    inverted_right: spline_segment_port_side_equals(target_side, East),
  }
}

///|
pub fn new_spline_segment_hyper_edge(
  single_port : LPort,
  edges : Array[Pair[SplineSideToProcess, LEdge]],
  source_side : SplineSideToProcess,
) -> SplineSegment {
  if edges.is_empty() {
    abort("hyperedge segment requires at least one edge")
  }

  let segment = new_spline_segment_base(false)

  if spline_segment_side_to_process_equals(source_side, Left) {
    spline_segment_add_port_if_absent(segment.left_ports, single_port)
  } else {
    spline_segment_add_port_if_absent(segment.right_ports, single_port)
  }

  let single_handle = lport_internal_handle(single_port)
  let mut y_min_pos_of_target = 0.0
  let mut y_max_pos_of_target = 0.0

  for i in 0..<edges.length() {
    let pair = edges[i]
    let side = spline_segment_pair_side(pair)
    let edge = spline_segment_pair_edge(pair)
    let source = spline_segment_edge_source(edge)
    let target = spline_segment_edge_target(edge)

    let mut tgt_port = source
    if lport_internal_handle(source) == single_handle {
      tgt_port = target
    }

    if spline_segment_side_to_process_equals(side, Left) {
      spline_segment_add_port_if_absent(segment.left_ports, tgt_port)
    } else {
      spline_segment_add_port_if_absent(segment.right_ports, tgt_port)
    }

    let y_pos_of_target = spline_segment_anchor_y(tgt_port)
    if i == 0 {
      y_min_pos_of_target = y_pos_of_target
      y_max_pos_of_target = y_pos_of_target
    } else {
      if y_pos_of_target < y_min_pos_of_target {
        y_min_pos_of_target = y_pos_of_target
      }
      if y_pos_of_target > y_max_pos_of_target {
        y_max_pos_of_target = y_pos_of_target
      }
    }
  }

  let y_pos_of_single_side = spline_segment_anchor_y(single_port)
  spline_segment_set_relevant_positions(
    segment, y_pos_of_single_side, y_min_pos_of_target, y_max_pos_of_target,
  )

  for pair in edges {
    segment.add_edge(spline_segment_pair_edge(pair))
  }

  segment
}

///|
pub fn new_spline_segment_single_edge(
  edge : LEdge,
  source_side : SplineSideToProcess,
  target_side : SplineSideToProcess,
) -> SplineSegment {
  let segment = new_spline_segment_base(false)

  let source = spline_segment_edge_source(edge)
  let target = spline_segment_edge_target(edge)

  if spline_segment_side_to_process_equals(source_side, Left) {
    spline_segment_add_port_if_absent(segment.left_ports, source)
  } else {
    spline_segment_add_port_if_absent(segment.right_ports, source)
  }
  if spline_segment_side_to_process_equals(target_side, Left) {
    spline_segment_add_port_if_absent(segment.left_ports, target)
  } else {
    spline_segment_add_port_if_absent(segment.right_ports, target)
  }

  segment.add_edge(edge)

  let source_y = spline_segment_anchor_y(source)
  let target_y = spline_segment_anchor_y(target)
  spline_segment_set_relevant_positions(segment, source_y, target_y, target_y)

  segment.is_straight = spline_edge_router_is_straight(source_y, target_y)
  segment
}

///|
pub fn SplineSegment::is_hyper_edge(self : SplineSegment) -> Bool {
  self.edges.length() > 1
}

///|
pub fn SplineSegment::compare_to(
  self : SplineSegment,
  other : SplineSegment,
) -> Int {
  self.mark - other.mark
}

///|
pub fn SplineSegment::get_edge_information(
  self : SplineSegment,
  edge : LEdge,
) -> SplineSegmentEdgeInformation? {
  self.edge_information.get(ledge_internal_handle(edge))
}
