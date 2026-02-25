///|
pub struct ScanlineOverlapCheck {
  overlap_handler : IOverlapHandler
  svg : SvgImage
}

///|
priv struct SporeTimestamp {
  low : Bool
  node : Node
}

///|
pub fn new_scanline_overlap_check(
  overlap_handler : IOverlapHandler,
  dbg : SvgImage,
) -> ScanlineOverlapCheck {
  dbg.add_groups(["n", "o", "e"])
  { overlap_handler, svg: dbg }
}

///|
fn spore_java_double_compare(left : Double, right : Double) -> Int {
  if left < right {
    return -1
  }
  if left > right {
    return 1
  }
  let left_bits = left.reinterpret_as_int64()
  let right_bits = right.reinterpret_as_int64()
  if left_bits == right_bits {
    0
  } else if left_bits < right_bits {
    -1
  } else {
    1
  }
}

///|
fn spore_scanline_node_compare_left(n1 : Node, n2 : Node) -> Int {
  let cmp_x = spore_java_double_compare(n1.rect.x, n2.rect.x)
  if cmp_x != 0 {
    return cmp_x
  }

  let cmp_origin_x = spore_java_double_compare(
    n1.original_vertex.x,
    n2.original_vertex.x,
  )
  if cmp_origin_x != 0 {
    return cmp_origin_x
  }

  spore_java_double_compare(n1.original_vertex.y, n2.original_vertex.y)
}

///|
fn spore_scanline_timestamp_comparator(
  p1 : SporeTimestamp,
  p2 : SporeTimestamp,
) -> Int {
  let mut y1 = p1.node.rect.y
  if !p1.low {
    y1 = y1 + p1.node.rect.height
  }
  let mut y2 = p2.node.rect.y
  if !p2.low {
    y2 = y2 + p2.node.rect.height
  }

  let cmp = spore_java_double_compare(y1, y2)
  if cmp == 0 {
    if !p1.low && p2.low {
      return -1
    } else if !p2.low && p1.low {
      return 1
    }
  }
  cmp
}

///|
fn spore_scanline_overlap(n1 : Node, n2 : Node) -> Bool {
  if n1.uid == n2.uid {
    return false
  }
  compare_fuzzy_lt(n1.rect.x, n2.rect.x + n2.rect.width) &&
  compare_fuzzy_lt(n2.rect.x, n1.rect.x + n1.rect.width)
}

///|
fn spore_scanline_insert_sorted(intervals : Array[Node], node : Node) -> Bool {
  let mut index = 0
  while index < intervals.length() &&
        spore_scanline_node_compare_left(intervals[index], node) < 0 {
    index = index + 1
  }

  if index < intervals.length() &&
    spore_scanline_node_compare_left(intervals[index], node) == 0 {
    return false
  }

  ignore(intervals.insert(index, node))
  true
}

///|
fn spore_scanline_remove(intervals : Array[Node], node : Node) -> Unit {
  let mut index = 0
  while index < intervals.length() {
    if spore_scanline_node_compare_left(intervals[index], node) == 0 {
      ignore(intervals.remove(index))
      return
    }
    index = index + 1
  }
}

///|
fn spore_scanline_insert(
  checker : ScanlineOverlapCheck,
  intervals : Array[Node],
  node : Node,
) -> Unit {
  if !spore_scanline_insert_sorted(intervals, node) {
    abort("Invalid hitboxes for scanline overlap calculation.")
  }

  let mut overlaps_found = false
  for other in intervals {
    if spore_scanline_overlap(node, other) {
      (checker.overlap_handler)(node, other)
      checker.svg
      .g("o")
      .add_rect_from_elk(
        node.rect,
        "stroke=\"none\" fill=\"red\" opacity=\"0.18\"",
      )
      checker.svg
      .g("o")
      .add_rect_from_elk(
        other.rect,
        "stroke=\"none\" fill=\"red\" opacity=\"0.18\"",
      )
      checker.svg
      .g("e")
      .add_line(
        node.vertex.x,
        node.vertex.y,
        other.vertex.x,
        other.vertex.y,
        attributes="stroke=\"blue\"",
      )
      overlaps_found = true
    } else if overlaps_found {
      return
    }
  }
}

///|
pub fn ScanlineOverlapCheck::sweep(
  self : ScanlineOverlapCheck,
  nodes : Array[Node],
) -> Unit {
  self.svg.clear_group("n")
  self.svg.clear_group("o")
  self.svg.clear_group("e")

  let points : Array[SporeTimestamp] = []
  for node in nodes {
    points.push({ low: true, node })
    points.push({ low: false, node })
    self.svg
    .g("n")
    .add_rect_from_elk(
      node.rect,
      "stroke=\"black\" stroke-width=\"1\" fill=\"none\"",
    )
  }

  self.svg.isave()

  let intervals_sort_left : Array[Node] = []
  scanline_execute_single(points, spore_scanline_timestamp_comparator, timestamp => {
    if timestamp.low {
      spore_scanline_insert(self, intervals_sort_left, timestamp.node)
    } else {
      spore_scanline_remove(intervals_sort_left, timestamp.node)
    }
  })

  self.svg.isave()
}
