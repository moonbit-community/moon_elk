///|
let edge_aware_scanline_epsilon : Double = 0.5

///|
let edge_aware_scanline_small_epsilon : Double = 0.01

///|
priv struct EdgeAwareScanlineTimestamp {
  node : @compaction.CNode
  low : Bool
}

///|
priv struct EdgeAwareScanlineCalculation {
  vertical_edge_edge_spacing : Double
  edge_routing : @core.EdgeRouting
  origin_lookup : HorizontalGraphCompactorOriginLookup
}

///|
fn edge_aware_scanline_parse_edge_routing(value : String) -> @core.EdgeRouting {
  let normalized = value.trim().to_owned().to_upper()
  match normalized {
    "POLYLINE" => Polyline
    "SPLINES" => Splines
    "ORTHOGONAL" => Orthogonal
    _ => RoutingUndefined
  }
}

///|
fn[T : Eq] edge_aware_scanline_remove_first(
  array : Array[T],
  value : T,
) -> Bool {
  for i in 0..<array.length() {
    if array[i] == value {
      ignore(array.remove(i))
      return true
    }
  }
  false
}

///|
fn edge_aware_scanline_center_x(node : @compaction.CNode) -> Double {
  let hitbox = node.hitbox()
  hitbox.x + hitbox.width / 2.0
}

///|
fn edge_aware_scanline_interval_floor(
  intervals : Array[@compaction.CNode],
  node : @compaction.CNode,
) -> @compaction.CNode? {
  let key = edge_aware_scanline_center_x(node)
  let mut result : @compaction.CNode? = None
  for current in intervals {
    let current_key = edge_aware_scanline_center_x(current)
    if current_key < key || @compaction.compare_fuzzy_eq(current_key, key) {
      result = Some(current)
    } else {
      break
    }
  }
  result
}

///|
fn edge_aware_scanline_interval_ceiling(
  intervals : Array[@compaction.CNode],
  node : @compaction.CNode,
) -> @compaction.CNode? {
  let key = edge_aware_scanline_center_x(node)
  for current in intervals {
    let current_key = edge_aware_scanline_center_x(current)
    if current_key > key || @compaction.compare_fuzzy_eq(current_key, key) {
      return Some(current)
    }
  }
  None
}

///|
fn edge_aware_scanline_interval_lower(
  intervals : Array[@compaction.CNode],
  node : @compaction.CNode,
) -> @compaction.CNode? {
  let key = edge_aware_scanline_center_x(node)
  let mut result : @compaction.CNode? = None
  for current in intervals {
    let current_key = edge_aware_scanline_center_x(current)
    if current_key < key && !@compaction.compare_fuzzy_eq(current_key, key) {
      result = Some(current)
    } else {
      break
    }
  }
  result
}

///|
fn edge_aware_scanline_interval_higher(
  intervals : Array[@compaction.CNode],
  node : @compaction.CNode,
) -> @compaction.CNode? {
  let key = edge_aware_scanline_center_x(node)
  for current in intervals {
    let current_key = edge_aware_scanline_center_x(current)
    if current_key > key && !@compaction.compare_fuzzy_eq(current_key, key) {
      return Some(current)
    }
  }
  None
}

///|
fn edge_aware_scanline_interval_insert(
  intervals : Array[@compaction.CNode],
  node : @compaction.CNode,
) -> Bool {
  let key = edge_aware_scanline_center_x(node)
  let mut insert_index = intervals.length()
  for i in 0..<intervals.length() {
    let current_key = edge_aware_scanline_center_x(intervals[i])
    if @compaction.compare_fuzzy_eq(current_key, key) {
      return false
    }
    if current_key > key {
      insert_index = i
      break
    }
  }

  intervals.push(node)
  let mut i = intervals.length() - 1
  while i > insert_index {
    intervals[i] = intervals[i - 1]
    i = i - 1
  }
  intervals[insert_index] = node
  true
}

///|
fn edge_aware_scanline_overlap(
  n1 : @compaction.CNode?,
  n2 : @compaction.CNode?,
) -> Bool {
  match (n1, n2) {
    (Some(left), Some(right)) => {
      if left == right {
        return false
      }
      let left_hitbox = left.hitbox()
      let right_hitbox = right.hitbox()
      @compaction.compare_fuzzy_le(
        left_hitbox.x,
        right_hitbox.x + right_hitbox.width,
      ) &&
      @compaction.compare_fuzzy_le(
        right_hitbox.x,
        left_hitbox.x + left_hitbox.width,
      )
    }
    _ => false
  }
}

///|
fn edge_aware_scanline_timestamp_comparator(
  left : EdgeAwareScanlineTimestamp,
  right : EdgeAwareScanlineTimestamp,
) -> Int {
  let left_hitbox = left.node.hitbox()
  let right_hitbox = right.node.hitbox()

  let mut y1 = left_hitbox.y
  if !left.low {
    y1 = y1 + left_hitbox.height
  }
  let mut y2 = right_hitbox.y
  if !right.low {
    y2 = y2 + right_hitbox.height
  }

  if y1 < y2 {
    return -1
  }
  if y1 > y2 {
    return 1
  }

  if !left.low && right.low {
    return -1
  }
  if left.low && !right.low {
    return 1
  }

  0
}

///|
fn edge_aware_scanline_sweep(
  compactor : @compaction.OneDimensionalCompactor,
  filter_fun : (@compaction.CNode) -> Bool,
) -> Unit {
  let points : Array[EdgeAwareScanlineTimestamp] = []
  for node in compactor.c_graph.c_nodes {
    if filter_fun(node) {
      points.push({ node, low: true })
      points.push({ node, low: false })
    }
  }

  let intervals : Array[@compaction.CNode] = []
  let candidate : Array[@compaction.CNode?] = []
  for _ in 0..<compactor.c_graph.c_nodes.length() {
    candidate.push(None)
  }

  let mut index = 0
  for node in compactor.c_graph.c_nodes {
    node.set_id(index)
    index = index + 1
  }

  @compaction.scanline_execute_single(
    points,
    edge_aware_scanline_timestamp_comparator,
    point => {
      if point.low {
        let success = edge_aware_scanline_interval_insert(intervals, point.node)
        if !success {
          @core.layout_runtime_report_unsupported_configuration(
            "Invalid hitboxes for scanline constraint calculation.",
          )
          return
        }

        ignore(
          edge_aware_scanline_overlap(
            Some(point.node),
            edge_aware_scanline_interval_floor(intervals, point.node),
          ),
        )
        ignore(
          edge_aware_scanline_overlap(
            Some(point.node),
            edge_aware_scanline_interval_ceiling(intervals, point.node),
          ),
        )

        candidate[point.node.id()] = edge_aware_scanline_interval_lower(
          intervals,
          point.node,
        )

        match edge_aware_scanline_interval_higher(intervals, point.node) {
          Some(right) => candidate[right.id()] = Some(point.node)
          None => ()
        }
      } else {
        let left = edge_aware_scanline_interval_lower(intervals, point.node)
        match left {
          Some(left_node) =>
            match candidate[point.node.id()] {
              Some(cand) =>
                if cand == left_node {
                  match (left_node.group(), point.node.group()) {
                    (Some(left_group), Some(current_group)) =>
                      if left_group != current_group {
                        left_node.add_constraint(point.node)
                      }
                    _ => ()
                  }
                }
              None => ()
            }
          None => ()
        }

        let right = edge_aware_scanline_interval_higher(intervals, point.node)
        match right {
          Some(right_node) =>
            match candidate[right_node.id()] {
              Some(cand) =>
                if cand == point.node {
                  match (right_node.group(), point.node.group()) {
                    (Some(right_group), Some(current_group)) =>
                      if right_group != current_group {
                        point.node.add_constraint(right_node)
                      }
                    _ => ()
                  }
                }
              None => ()
            }
          None => ()
        }

        ignore(edge_aware_scanline_remove_first(intervals, point.node))
      }
    },
  )
}

///|
fn edge_aware_scanline_alter_hitbox(
  origin_lookup : HorizontalGraphCompactorOriginLookup,
  n : @compaction.CNode,
  spacing : Double,
  fac : Double,
) -> Unit {
  let delta = spacing * fac
  let hitbox = n.hitbox()

  match origin_lookup.get_vertical_segment_or_null(n) {
    Some(vs) => {
      if !vs.ignore_spacing.up {
        hitbox.y = hitbox.y - delta - edge_aware_scanline_small_epsilon
        hitbox.height = hitbox.height +
          delta +
          edge_aware_scanline_small_epsilon
      } else if !vs.ignore_spacing.down {
        hitbox.height = hitbox.height +
          delta +
          edge_aware_scanline_small_epsilon
      }
      n.set_hitbox(hitbox)
    }
    None =>
      match origin_lookup.get_lnode_or_null(n) {
        Some(_) => {
          hitbox.y = hitbox.y - delta
          hitbox.height = hitbox.height + 2.0 * delta
          n.set_hitbox(hitbox)
        }
        None => ()
      }
  }
}

///|
fn edge_aware_scanline_alter_grouped_hitbox_orthogonal(
  origin_lookup : HorizontalGraphCompactorOriginLookup,
  group : @compaction.CGroup,
  spacing : Double,
  fac : Double,
) -> Unit {
  let master = match group.master() {
    Some(value) => value
    None =>
      match group.c_nodes().get(0) {
        Some(value) => value
        None => return
      }
  }

  edge_aware_scanline_alter_hitbox(origin_lookup, master, spacing, fac)
  if group.c_nodes().length() == 1 {
    return
  }

  let delta = spacing * fac
  for n in group.c_nodes() {
    if n == master {
      continue
    }
    match origin_lookup.get_vertical_segment_or_null(n) {
      Some(vs) => {
        let hitbox = n.hitbox()
        if vs.ignore_spacing.up {
          hitbox.y = hitbox.y + delta + edge_aware_scanline_small_epsilon
          hitbox.height = hitbox.height -
            delta -
            edge_aware_scanline_small_epsilon
        } else if vs.ignore_spacing.down {
          hitbox.height = hitbox.height -
            delta -
            edge_aware_scanline_small_epsilon
        }
        n.set_hitbox(hitbox)
      }
      None => ()
    }
  }
}

///|
fn edge_aware_scanline_min_spacing(
  origin_lookup : HorizontalGraphCompactorOriginLookup,
  compactor : @compaction.OneDimensionalCompactor,
  vertical_edge_edge_spacing : Double,
) -> Double {
  let mut min_spacing = @double.infinity
  for node in compactor.c_graph.c_nodes {
    let spacing = match origin_lookup.get_lnode_or_null(node) {
      Some(l_node) =>
        if horizontal_graph_compactor_node_type_equals(
            l_node.get_type(),
            ExternalPort,
          ) {
          @double.infinity
        } else {
          let individual = layered_spacings_get_individual_or_default(
            l_node, @core.spacing_node_node,
          )
          @cmp.maximum(0.0, individual / 2.0 - edge_aware_scanline_epsilon)
        }
      None =>
        match origin_lookup.get_vertical_segment_or_null(node) {
          Some(_) =>
            @cmp.maximum(
              0.0,
              vertical_edge_edge_spacing / 2.0 - edge_aware_scanline_epsilon,
            )
          None => @double.infinity
        }
    }
    if spacing < min_spacing {
      min_spacing = spacing
    }
  }
  if min_spacing == @double.infinity {
    0.0
  } else {
    min_spacing
  }
}

///|
fn edge_aware_scanline_calculate_for_spline(
  calculation : EdgeAwareScanlineCalculation,
  compactor : @compaction.OneDimensionalCompactor,
) -> Unit {
  let origin_lookup = calculation.origin_lookup
  edge_aware_scanline_sweep(compactor, node => {
    origin_lookup.get_vertical_segment_or_null(node) is Some(_)
  })

  let min_spacing = edge_aware_scanline_min_spacing(
    origin_lookup,
    compactor,
    calculation.vertical_edge_edge_spacing,
  )

  let altered_nodes : Array[@compaction.CNode] = []
  for node in compactor.c_graph.c_nodes {
    if origin_lookup.get_lnode_or_null(node) is Some(_) {
      edge_aware_scanline_alter_hitbox(origin_lookup, node, min_spacing, 1.0)
      altered_nodes.push(node)
    }
  }

  edge_aware_scanline_sweep(compactor, _ => true)

  for node in altered_nodes {
    edge_aware_scanline_alter_hitbox(origin_lookup, node, min_spacing, -1.0)
  }
}

///|
fn edge_aware_scanline_calculate_for_orthogonal(
  calculation : EdgeAwareScanlineCalculation,
  compactor : @compaction.OneDimensionalCompactor,
) -> Unit {
  let origin_lookup = calculation.origin_lookup
  let vertical_spacing = @cmp.maximum(
    0.0,
    calculation.vertical_edge_edge_spacing / 2.0 - edge_aware_scanline_epsilon,
  )
  let altered_segments : Array[@compaction.CNode] = []
  for node in compactor.c_graph.c_nodes {
    if origin_lookup.get_vertical_segment_or_null(node) is Some(_) {
      edge_aware_scanline_alter_hitbox(
        origin_lookup, node, vertical_spacing, 1.0,
      )
      altered_segments.push(node)
    }
  }

  edge_aware_scanline_sweep(compactor, node => {
    origin_lookup.get_vertical_segment_or_null(node) is Some(_)
  })

  for node in altered_segments {
    edge_aware_scanline_alter_hitbox(
      origin_lookup, node, vertical_spacing, -1.0,
    )
  }

  let altered_nodes : Array[(@compaction.CNode, Double)] = []
  for node in compactor.c_graph.c_nodes {
    match origin_lookup.get_lnode_or_null(node) {
      Some(l_node) => {
        let spacing = layered_spacings_get_individual_or_default(
          l_node, @core.spacing_edge_edge,
        )
        let final_spacing = @cmp.maximum(
          0.0,
          spacing / 2.0 - edge_aware_scanline_epsilon,
        )
        edge_aware_scanline_alter_hitbox(
          origin_lookup, node, final_spacing, 1.0,
        )
        altered_nodes.push((node, final_spacing))
      }
      None => ()
    }
  }

  edge_aware_scanline_sweep(compactor, node => {
    origin_lookup.get_lnode_or_null(node) is Some(_)
  })

  for entry in altered_nodes {
    let (node, spacing) = entry
    edge_aware_scanline_alter_hitbox(origin_lookup, node, spacing, -1.0)
  }

  let min_spacing = edge_aware_scanline_min_spacing(
    origin_lookup,
    compactor,
    calculation.vertical_edge_edge_spacing,
  )

  let altered_groups : Array[@compaction.CGroup] = []
  for group in compactor.c_graph.c_groups {
    edge_aware_scanline_alter_grouped_hitbox_orthogonal(
      origin_lookup, group, min_spacing, 1.0,
    )
    altered_groups.push(group)
  }

  edge_aware_scanline_sweep(compactor, _ => true)

  for group in altered_groups {
    edge_aware_scanline_alter_grouped_hitbox_orthogonal(
      origin_lookup, group, min_spacing, -1.0,
    )
  }
}

///|
fn edge_aware_scanline_calculate_constraints(
  calculation : EdgeAwareScanlineCalculation,
  compactor : @compaction.OneDimensionalCompactor,
) -> Unit {
  match calculation.edge_routing {
    Orthogonal =>
      edge_aware_scanline_calculate_for_orthogonal(calculation, compactor)
    Splines => edge_aware_scanline_calculate_for_spline(calculation, compactor)
    _ =>
      @core.layout_runtime_report_unsupported_configuration(
        "Unsupported edge routing for edge-aware scanline constraints.",
      )
  }
}

///|
fn new_edge_aware_scanline_constraint_calculation(
  graph : LGraph,
  origin_lookup : HorizontalGraphCompactorOriginLookup,
) -> @compaction.IConstraintCalculationAlgorithm {
  let calculation : EdgeAwareScanlineCalculation = {
    vertical_edge_edge_spacing: graph.get_property_double(
      @core.spacing_edge_edge,
    ),
    edge_routing: edge_aware_scanline_parse_edge_routing(
      graph.get_property_string(@core.edge_routing),
    ),
    origin_lookup,
  }
  compactor => edge_aware_scanline_calculate_constraints(calculation, compactor)
}
