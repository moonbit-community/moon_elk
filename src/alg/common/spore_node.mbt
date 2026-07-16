///|
pub struct Node {
  uid : Int
  mut original_vertex : @core.KVector
  vertex : @core.KVector
  rect : @core.ElkRectangle
}

///|
let spore_node_uid_counter : Ref[Int] = Ref(0)

///|
fn next_spore_node_uid() -> Int {
  let uid = spore_node_uid_counter.val
  spore_node_uid_counter.val = uid + 1
  uid
}

///|
pub fn new_node(v : @core.KVector, r : @core.ElkRectangle) -> Node {
  {
    uid: next_spore_node_uid(),
    original_vertex: v,
    vertex: v.clone(),
    rect: @core.new_elk_rectangle_copy(r),
  }
}

///|
pub fn Node::set_original_vertex(self : Node, value : @core.KVector) -> Unit {
  self.original_vertex = value
}

///|
pub fn Node::translate(self : Node, v : @core.KVector) -> Unit {
  ignore(self.vertex.add(v))
  self.rect.x += v.x
  self.rect.y += v.y
}

///|
pub fn Node::set_center_position(self : Node, p : @core.KVector) -> Unit {
  self.translate(p.clone().sub(self.vertex))
}

///|
pub fn Node::underlap(self : Node, other : Node) -> Double {
  let horizontal_center_distance = (self.rect.get_center().x -
  other.rect.get_center().x).abs()
  let vertical_center_distance = (self.rect.get_center().y -
  other.rect.get_center().y).abs()

  let mut horizontal_underlap = 0.0
  let mut vertical_underlap = 0.0
  let mut horizontal_scale = 1.0
  let mut vertical_scale = 1.0

  if horizontal_center_distance > self.rect.width / 2.0 + other.rect.width / 2.0 {
    horizontal_underlap = if (self.rect.x - (other.rect.x + other.rect.width)).abs() <
      (self.rect.x + self.rect.width - other.rect.x).abs() {
      (self.rect.x - (other.rect.x + other.rect.width)).abs()
    } else {
      (self.rect.x + self.rect.width - other.rect.x).abs()
    }
    horizontal_scale = 1.0 - horizontal_underlap / horizontal_center_distance
  }

  if vertical_center_distance > self.rect.height / 2.0 + other.rect.height / 2.0 {
    vertical_underlap = if (self.rect.y - (other.rect.y + other.rect.height)).abs() <
      (self.rect.y + self.rect.height - other.rect.y).abs() {
      (self.rect.y - (other.rect.y + other.rect.height)).abs()
    } else {
      (self.rect.y + self.rect.height - other.rect.y).abs()
    }
    vertical_scale = 1.0 - vertical_underlap / vertical_center_distance
  }

  let scale = if horizontal_scale < vertical_scale {
    horizontal_scale
  } else {
    vertical_scale
  }
  (1.0 - scale) *
  (horizontal_center_distance * horizontal_center_distance +
  vertical_center_distance * vertical_center_distance).sqrt()
}

///|
pub fn Node::distance(self : Node, other : Node, v : @core.KVector) -> Double {
  let mut result = @double.infinity
  for edge1 in get_rect_edges(self.rect) {
    for edge2 in get_rect_edges(other.rect) {
      let current_distance = @core.distance(
        edge1.u,
        edge1.v,
        edge2.u,
        edge2.v,
        v,
      )
      if current_distance < result {
        result = current_distance
      }
    }
  }
  result
}

///|
fn spore_fuzzy_compare(a : Double, b : Double) -> Int {
  if (a - b).abs() <= spore_fuzziness {
    0
  } else if a < b {
    -1
  } else {
    1
  }
}

///|
pub fn Node::touches(self : Node, other : Node) -> Bool {
  spore_fuzzy_compare(self.rect.x, other.rect.x + other.rect.width) <= 0 &&
  spore_fuzzy_compare(other.rect.x, self.rect.x + self.rect.width) <= 0 &&
  spore_fuzzy_compare(self.rect.y, other.rect.y + other.rect.height) <= 0 &&
  spore_fuzzy_compare(other.rect.y, self.rect.y + self.rect.height) <= 0
}
