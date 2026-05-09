///|
fn[T] vertical_segment_add_all(target : Array[T], source : Array[T]) -> Unit {
  for item in source {
    target.push(item)
  }
}

///|
fn vertical_segment_compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn vertical_segment_represented_edges_to_string(
  represented_edges : Array[LEdge],
) -> String {
  let mut result = ""
  let mut i = 0
  while i < represented_edges.length() {
    if i > 0 {
      result = result + ", "
    }
    result = result + represented_edges[i].to_string()
    i = i + 1
  }
  result
}

///|
let vertical_segment_next_id_ref : Ref[Int] = Ref(0)

///|
fn vertical_segment_next_id() -> Int {
  let id = vertical_segment_next_id_ref.val
  vertical_segment_next_id_ref.val = id + 1
  id
}

///|
pub struct VerticalSegment {
  id : Int
  potential_group_parents : Array[@common.CNode]
  represented_l_edges : Array[LEdge]
  affected_bends : Array[@core.KVector]
  affected_bounding_boxes : Array[@core.ElkRectangle]
  hitbox : @core.ElkRectangle
  junction_points : @core.KVectorChain
  ignore_spacing : @common.Quadruplet
  constraints : Array[VerticalSegment]
  mut a_port : LPort?
  joined : Array[VerticalSegment]
}

///|
pub fn new_vertical_segment(
  bend1 : @core.KVector,
  bend2 : @core.KVector,
  c_node : @common.CNode?,
  l_edge : LEdge,
) -> VerticalSegment {
  let affected_bends = []
  affected_bends.push(bend1)
  affected_bends.push(bend2)

  let hitbox = @core.new_elk_rectangle()
  hitbox.x = if bend1.x < bend2.x { bend1.x } else { bend2.x }
  hitbox.y = if bend1.y < bend2.y { bend1.y } else { bend2.y }
  hitbox.width = (bend1.x - bend2.x).abs()
  hitbox.height = (bend1.y - bend2.y).abs()

  let junction_points = @core.new_kvector_chain()
  if l_edge.has_property_kvector_chain(layered_options_junction_points) {
    let in_junction_points = l_edge.get_property_kvector_chain(
      layered_options_junction_points,
    )
    for junction_point in in_junction_points.to_array() {
      if @common.compare_fuzzy_eq(junction_point.x, bend1.x) {
        junction_points.add_vector(junction_point)
      }
    }
  }

  let potential_group_parents = []
  match c_node {
    Some(parent) => potential_group_parents.push(parent)
    None => ()
  }

  let represented_l_edges = []
  represented_l_edges.push(l_edge)

  {
    potential_group_parents,
    represented_l_edges,
    affected_bends,
    affected_bounding_boxes: [],
    id: vertical_segment_next_id(),
    hitbox,
    junction_points,
    ignore_spacing: @common.new_quadruplet(),
    constraints: [],
    a_port: None,
    joined: [],
  }
}

///|
pub fn VerticalSegment::get_id(self : VerticalSegment) -> Int {
  self.id
}

///|
pub fn vertical_segment_origin_key(segment : VerticalSegment) -> String {
  "vs:" + segment.get_id().to_string()
}

///|
pub fn VerticalSegment::join_with(
  self : VerticalSegment,
  other : VerticalSegment,
) -> VerticalSegment {
  vertical_segment_add_all(self.represented_l_edges, other.represented_l_edges)
  vertical_segment_add_all(self.affected_bends, other.affected_bends)
  vertical_segment_add_all(
    self.affected_bounding_boxes,
    other.affected_bounding_boxes,
  )
  self.junction_points.add_all(other.junction_points.to_array())
  vertical_segment_add_all(self.constraints, other.constraints)
  vertical_segment_add_all(
    self.potential_group_parents,
    other.potential_group_parents,
  )

  let new_x = if self.hitbox.x < other.hitbox.x {
    self.hitbox.x
  } else {
    other.hitbox.x
  }
  let new_y = if self.hitbox.y < other.hitbox.y {
    self.hitbox.y
  } else {
    other.hitbox.y
  }
  let max_x = if self.hitbox.x + self.hitbox.width >
    other.hitbox.x + other.hitbox.width {
    self.hitbox.x + self.hitbox.width
  } else {
    other.hitbox.x + other.hitbox.width
  }
  let new_w = max_x - new_x
  let max_y = if self.hitbox.y + self.hitbox.height >
    other.hitbox.y + other.hitbox.height {
    self.hitbox.y + self.hitbox.height
  } else {
    other.hitbox.y + other.hitbox.height
  }
  let new_h = max_y - new_y
  self.hitbox.set_rect(new_x, new_y, new_w, new_h)

  self.ignore_spacing.apply_or(other.ignore_spacing)

  match self.a_port {
    Some(_) => ()
    None => self.a_port = other.a_port
  }

  vertical_segment_add_all(self.joined, other.joined)
  self.joined.push(other)

  self
}

///|
pub fn VerticalSegment::intersects(
  self : VerticalSegment,
  other : VerticalSegment,
) -> Bool {
  @common.compare_fuzzy_eq(self.hitbox.x, other.hitbox.x) &&
  !(@common.compare_fuzzy_lt(self.hitbox.get_bottom_left().y, other.hitbox.y) ||
  @common.compare_fuzzy_lt(other.hitbox.get_bottom_left().y, self.hitbox.y))
}

///|
pub fn VerticalSegment::compare_to(
  self : VerticalSegment,
  other : VerticalSegment,
) -> Int {
  if @common.compare_fuzzy_lt(self.hitbox.x, other.hitbox.x) {
    -1
  } else if @common.compare_fuzzy_gt(self.hitbox.x, other.hitbox.x) {
    1
  } else {
    vertical_segment_compare_double(self.hitbox.y, other.hitbox.y)
  }
}

///|
pub fn VerticalSegment::set_a_port(
  self : VerticalSegment,
  port : LPort?,
) -> Unit {
  self.a_port = port
}

///|
pub fn VerticalSegment::get_a_port(self : VerticalSegment) -> LPort? {
  self.a_port
}

///|
pub fn VerticalSegment::to_string(self : VerticalSegment) -> String {
  "VerticalSegment " +
  self.hitbox.to_string() +
  " " +
  vertical_segment_represented_edges_to_string(self.represented_l_edges)
}
