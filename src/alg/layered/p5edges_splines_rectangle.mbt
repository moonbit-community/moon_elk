///|
pub struct Rectangle {
  mut top : Double
  mut bottom : Double
  mut left : Double
  mut right : Double
}

///|
fn rectangle_min_double(left : Double, right : Double) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn rectangle_max_double(left : Double, right : Double) -> Double {
  if left > right {
    left
  } else {
    right
  }
}

///|
pub fn new_rectangle_values(
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
) -> Rectangle {
  if top > bottom {
    abort("Top must be smaller or equal to bottom.")
  }
  if left > right {
    abort("Left must be smaller or equal to right.")
  }
  { top, right, bottom, left }
}

///|
pub fn new_rectangle_copy(rectangle : Rectangle) -> Rectangle {
  {
    top: rectangle.top,
    right: rectangle.right,
    bottom: rectangle.bottom,
    left: rectangle.left,
  }
}

///|
pub fn new_rectangle_position(position : @core.KVector) -> Rectangle {
  { top: position.y, right: position.x, bottom: position.y, left: position.x }
}

///|
pub fn new_rectangle_shape(shape : LShape) -> Rectangle {
  let position = shape.get_position()
  let extend = position.clone().add(shape.get_size())

  {
    top: rectangle_min_double(position.y, extend.y),
    bottom: rectangle_max_double(position.y, extend.y),
    left: rectangle_min_double(position.x, extend.x),
    right: rectangle_max_double(position.x, extend.x),
  }
}

///|
pub fn new_rectangle_vectors(vectors : Array[@core.KVector]) -> Rectangle {
  if vectors.is_empty() {
    abort("The list of vectors may not be empty.")
  }

  let rectangle = Rectangle::{
    top: @double.max_value,
    bottom: -@double.max_value,
    left: @double.max_value,
    right: -@double.max_value,
  }

  for vector in vectors {
    rectangle.top = rectangle_min_double(rectangle.top, vector.y)
    rectangle.right = rectangle_max_double(rectangle.right, vector.x)
    rectangle.bottom = rectangle_max_double(rectangle.bottom, vector.y)
    rectangle.left = rectangle_min_double(rectangle.left, vector.x)
  }

  rectangle
}

///|
pub fn Rectangle::union_vector(self : Rectangle, vector : @core.KVector) -> Unit {
  self.top = rectangle_min_double(self.top, vector.y)
  self.right = rectangle_max_double(self.right, vector.x)
  self.bottom = rectangle_max_double(self.bottom, vector.y)
  self.left = rectangle_min_double(self.left, vector.x)
}

///|
pub fn Rectangle::union_shape(self : Rectangle, shape : LShape) -> Unit {
  self.union_vector(shape.get_position())
  self.union_vector(shape.get_position().clone().add(shape.get_size()))
}

///|
pub fn Rectangle::union_rectangle(
  self : Rectangle,
  rectangle : Rectangle,
) -> Unit {
  self.top = rectangle_min_double(self.top, rectangle.top)
  self.right = rectangle_max_double(self.right, rectangle.right)
  self.bottom = rectangle_max_double(self.bottom, rectangle.bottom)
  self.left = rectangle_min_double(self.left, rectangle.left)
}

///|
pub fn rectangle_union(
  rectangle1 : Rectangle,
  rectangle2 : Rectangle,
) -> Rectangle {
  let ret_val = new_rectangle_copy(rectangle1)
  ret_val.union_rectangle(rectangle2)
  ret_val
}

///|
pub fn rectangle_union_collection(rectangles : Array[Rectangle]) -> Rectangle {
  if rectangles.is_empty() {
    abort("The list of vectors may not be null.")
  }

  let rectangle = rectangles[0]
  let ret_val = new_rectangle_copy(rectangle)
  for i in 1..<rectangles.length() {
    // Keep upstream behavior exactly, including mutating the first element.
    rectangle.union_rectangle(rectangles[i])
  }
  ret_val
}

///|
pub fn Rectangle::enlarge(self : Rectangle, enlargement : Double) -> Unit {
  self.top = self.top - enlargement
  self.left = self.left - enlargement
  self.right = self.right + enlargement
  self.bottom = self.bottom + enlargement
}

///|
pub fn Rectangle::get_height(self : Rectangle) -> Double {
  self.bottom - self.top
}

///|
pub fn Rectangle::get_width(self : Rectangle) -> Double {
  self.right - self.left
}

///|
pub fn Rectangle::get_top(self : Rectangle) -> Double {
  self.top
}

///|
pub fn Rectangle::get_right(self : Rectangle) -> Double {
  self.right
}

///|
pub fn Rectangle::get_bottom(self : Rectangle) -> Double {
  self.bottom
}

///|
pub fn Rectangle::get_left(self : Rectangle) -> Double {
  self.left
}

///|
pub fn Rectangle::get_from_port_side(
  self : Rectangle,
  side : @core.PortSide,
) -> Double {
  match side {
    North => self.top
    East => self.right
    South => self.bottom
    West => self.left
    @core.PortSide::SideUndefined => 0.0
  }
}

///|
pub fn Rectangle::to_node_margins(
  self : Rectangle,
  shape : LShape,
) -> @core.ElkMargin {
  let ret_val = @core.new_elk_margin()

  let shape_rectangle = new_rectangle_values(
    0.0,
    0.0,
    shape.get_size().x,
    shape.get_size().y,
  )
  ret_val.set_top(rectangle_max_double(0.0, shape_rectangle.top - self.top))
  ret_val.set_left(rectangle_max_double(0.0, shape_rectangle.left - self.left))
  ret_val.set_bottom(
    rectangle_max_double(0.0, self.bottom - shape_rectangle.bottom),
  )
  ret_val.set_right(
    rectangle_max_double(0.0, self.right - shape_rectangle.right),
  )

  ret_val
}

///|
fn rectangle_round_1_decimal(value : Double) -> Double {
  (value * 10.0).round() / 10.0
}

///|
fn rectangle_format_1_decimal(value : Double) -> String {
  let rounded = rectangle_round_1_decimal(value)
  let mut text = rounded.to_string()
  if !text.contains(".") {
    text = text + ".0"
  } else if text.has_suffix(".") {
    text = text + "0"
  }
  text
}

///|
pub fn Rectangle::to_string(self : Rectangle) -> String {
  "[" +
  "top= " +
  rectangle_format_1_decimal(self.top) +
  ",left= " +
  rectangle_format_1_decimal(self.left) +
  ",bottom= " +
  rectangle_format_1_decimal(self.bottom) +
  ",right= " +
  rectangle_format_1_decimal(self.right) +
  "]"
}
