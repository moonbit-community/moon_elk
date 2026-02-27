///|
priv struct ScanlineTimestamp {
  node : CNode
  low : Bool
}

///|
pub suberror ScanlineConstraintCalculatorException {
  ScanlineConstraintCalculatorException(String)
} derive(Show, ToJson)

///|
fn scanline_constraint_calculator_raise_unit(
  message : String,
) -> Unit raise ScanlineConstraintCalculatorException {
  raise ScanlineConstraintCalculatorException(message)
}

///|
fn scanline_center_x(node : CNode) -> Double {
  let hitbox = node.hitbox()
  hitbox.x + hitbox.width / 2.0
}

///|
fn scanline_interval_floor(intervals : Array[CNode], node : CNode) -> CNode? {
  let key = scanline_center_x(node)
  let mut result : CNode? = None
  for current in intervals {
    let current_key = scanline_center_x(current)
    if current_key < key || compare_fuzzy_eq(current_key, key) {
      result = Some(current)
    } else {
      break
    }
  }
  result
}

///|
fn scanline_interval_ceiling(intervals : Array[CNode], node : CNode) -> CNode? {
  let key = scanline_center_x(node)
  for current in intervals {
    let current_key = scanline_center_x(current)
    if current_key > key || compare_fuzzy_eq(current_key, key) {
      return Some(current)
    }
  }
  None
}

///|
fn scanline_interval_lower(intervals : Array[CNode], node : CNode) -> CNode? {
  let key = scanline_center_x(node)
  let mut result : CNode? = None
  for current in intervals {
    let current_key = scanline_center_x(current)
    if current_key < key && !compare_fuzzy_eq(current_key, key) {
      result = Some(current)
    } else {
      break
    }
  }
  result
}

///|
fn scanline_interval_higher(intervals : Array[CNode], node : CNode) -> CNode? {
  let key = scanline_center_x(node)
  for current in intervals {
    let current_key = scanline_center_x(current)
    if current_key > key && !compare_fuzzy_eq(current_key, key) {
      return Some(current)
    }
  }
  None
}

///|
fn scanline_interval_insert(intervals : Array[CNode], node : CNode) -> Bool {
  let key = scanline_center_x(node)
  let mut insert_index = intervals.length()
  for i in 0..<intervals.length() {
    let current_key = scanline_center_x(intervals[i])
    if compare_fuzzy_eq(current_key, key) {
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
fn scanline_overlap(n1 : CNode?, n2 : CNode?) -> Bool {
  match (n1, n2) {
    (Some(left), Some(right)) => {
      if left == right {
        return false
      }
      let left_hitbox = left.hitbox()
      let right_hitbox = right.hitbox()
      compare_fuzzy_le(left_hitbox.x, right_hitbox.x + right_hitbox.width) &&
      compare_fuzzy_le(right_hitbox.x, left_hitbox.x + left_hitbox.width)
    }
    _ => false
  }
}

///|
fn scanline_timestamp_comparator(
  left : ScanlineTimestamp,
  right : ScanlineTimestamp,
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
fn scanline_constraints_sweep(
  compactor : OneDimensionalCompactor,
  filter_fun : (CNode) -> Bool,
) -> Unit {
  let points : Array[ScanlineTimestamp] = []
  for node in compactor.c_graph.c_nodes {
    if filter_fun(node) {
      points.push({ node, low: true })
      points.push({ node, low: false })
    }
  }

  let intervals : Array[CNode] = []
  let candidate : Array[CNode?] = []
  for _ in 0..<compactor.c_graph.c_nodes.length() {
    candidate.push(None)
  }

  let mut index = 0
  for node in compactor.c_graph.c_nodes {
    node.set_id(index)
    index = index + 1
  }

  scanline_execute_single(points, scanline_timestamp_comparator, point => {
    if point.low {
      let success = scanline_interval_insert(intervals, point.node)
      if !success {
        try
          scanline_constraint_calculator_raise_unit(
            "Invalid hitboxes for scanline constraint calculation.",
          )
        catch {
          ScanlineConstraintCalculatorException(message) =>
            @core.layout_runtime_report_unsupported_configuration(
              "org.eclipse.elk.alg.common.compaction.oned.ScanlineConstraintCalculator: " +
              message,
            )
        } noraise {
          _ => ()
        }
        return
      }

      ignore(
        scanline_overlap(
          Some(point.node),
          scanline_interval_floor(intervals, point.node),
        ),
      )
      ignore(
        scanline_overlap(
          Some(point.node),
          scanline_interval_ceiling(intervals, point.node),
        ),
      )

      candidate[point.node.id()] = scanline_interval_lower(
        intervals,
        point.node,
      )

      match scanline_interval_higher(intervals, point.node) {
        Some(right) => candidate[right.id()] = Some(point.node)
        None => ()
      }
    } else {
      let left = scanline_interval_lower(intervals, point.node)
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

      let right = scanline_interval_higher(intervals, point.node)
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

      ignore(array_remove_first(intervals, point.node))
    }
  })
}

///|
pub fn scanline_constraint_calculation(
  compactor : OneDimensionalCompactor,
) -> Unit {
  scanline_constraints_sweep(compactor, _ => true)
}

///|
pub let one_dimensional_compactor_scanline_constraints : IConstraintCalculationAlgorithm = scanline_constraint_calculation
