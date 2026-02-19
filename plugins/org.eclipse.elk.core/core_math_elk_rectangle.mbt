///|
pub struct ElkRectangle {
  mut x : Double
  mut y : Double
  mut width : Double
  mut height : Double
}

///|
pub fn new_elk_rectangle() -> ElkRectangle {
  new_elk_rectangle_xywh(0.0, 0.0, 0.0, 0.0)
}

///|
pub fn new_elk_rectangle_xywh(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> ElkRectangle {
  { x, y, width, height }
}

///|
pub fn new_elk_rectangle_copy(rect : ElkRectangle) -> ElkRectangle {
  { x: rect.x, y: rect.y, width: rect.width, height: rect.height }
}

///|
pub fn ElkRectangle::set_rect(
  self : ElkRectangle,
  nx : Double,
  ny : Double,
  nw : Double,
  nh : Double,
) -> Unit {
  self.x = nx
  self.y = ny
  self.width = nw
  self.height = nh
}

///|
pub fn ElkRectangle::get_position(self : ElkRectangle) -> KVector {
  new_kvector_xy(self.x, self.y)
}

///|
pub fn ElkRectangle::get_top_left(self : ElkRectangle) -> KVector {
  self.get_position()
}

///|
pub fn ElkRectangle::get_top_right(self : ElkRectangle) -> KVector {
  new_kvector_xy(self.x + self.width, self.y)
}

///|
pub fn ElkRectangle::get_bottom_left(self : ElkRectangle) -> KVector {
  new_kvector_xy(self.x, self.y + self.height)
}

///|
pub fn ElkRectangle::get_bottom_right(self : ElkRectangle) -> KVector {
  new_kvector_xy(self.x + self.width, self.y + self.height)
}

///|
pub fn ElkRectangle::get_center(self : ElkRectangle) -> KVector {
  new_kvector_xy(self.x + self.width / 2.0, self.y + self.height / 2.0)
}

///|
pub fn ElkRectangle::union(self : ElkRectangle, other : ElkRectangle) -> Unit {
  let mut x1 = if self.x < other.x { self.x } else { other.x }
  let mut y1 = if self.y < other.y { self.y } else { other.y }
  let mut x2 = if self.x + self.width > other.x + other.width {
    self.x + self.width
  } else {
    other.x + other.width
  }
  let mut y2 = if self.y + self.height > other.y + other.height {
    self.y + self.height
  } else {
    other.y + other.height
  }
  if x2 < x1 {
    let t = x1
    x1 = x2
    x2 = t
  }
  if y2 < y1 {
    let t = y1
    y1 = y2
    y2 = t
  }
  self.set_rect(x1, y1, x2 - x1, y2 - y1)
}

///|
pub fn ElkRectangle::move(self : ElkRectangle, offset : KVector) -> Unit {
  self.x = self.x + offset.x
  self.y = self.y + offset.y
}

///|
pub fn ElkRectangle::to_string(self : ElkRectangle) -> String {
  "Rect[x=\{self.x},y=\{self.y},w=\{self.width},h=\{self.height}]"
}

///|
pub fn ElkRectangle::equals(self : ElkRectangle, other : ElkRectangle) -> Bool {
  self.x == other.x &&
  self.y == other.y &&
  self.width == other.width &&
  self.height == other.height
}

///|
pub fn ElkRectangle::hash_code(self : ElkRectangle) -> Int {
  self.x.hash() ^ self.y.hash() ^ self.width.hash() ^ self.height.hash()
}

///|
pub fn ElkRectangle::get_max_x(self : ElkRectangle) -> Double {
  self.x + self.width
}

///|
pub fn ElkRectangle::get_max_y(self : ElkRectangle) -> Double {
  self.y + self.height
}

///|
pub fn ElkRectangle::intersects(
  self : ElkRectangle,
  rect : ElkRectangle,
) -> Bool {
  let r1x1 = self.x
  let r1y1 = self.y
  let r1x2 = self.x + self.width
  let r1y2 = self.y + self.height
  let r2x1 = rect.x
  let r2y1 = rect.y
  let r2x2 = rect.x + rect.width
  let r2y2 = rect.y + rect.height
  r1x1 < r2x2 && r1x2 > r2x1 && r1y2 > r2y1 && r1y1 < r2y2
}
