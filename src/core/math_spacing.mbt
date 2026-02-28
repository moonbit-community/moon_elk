///|
priv suberror SpacingParseException {
  SpacingParseException(String)
} derive(Show, ToJson)

///|
fn spacing_parse_raise_unit(
  message : String,
) -> Unit raise SpacingParseException {
  raise SpacingParseException(message)
}

///|
fn spacing_parse_exception_message(err : SpacingParseException) -> String {
  match err {
    SpacingParseException(message) => message
  }
}

///|
pub(all) struct Spacing {
  mut top : Double
  mut bottom : Double
  mut left : Double
  mut right : Double
}

///|
pub fn new_spacing() -> Spacing {
  { top: 0.0, bottom: 0.0, left: 0.0, right: 0.0 }
}

///|
pub fn new_spacing_values(
  top : Double,
  right : Double,
  bottom : Double,
  left : Double,
) -> Spacing {
  { top, right, bottom, left }
}

///|
pub fn Spacing::set_spacing(self : Spacing, spacing : Spacing) -> Unit {
  self.set_values(spacing.top, spacing.right, spacing.bottom, spacing.left)
}

///|
pub fn Spacing::set_values(
  self : Spacing,
  new_top : Double,
  new_right : Double,
  new_bottom : Double,
  new_left : Double,
) -> Unit {
  self.top = new_top
  self.right = new_right
  self.bottom = new_bottom
  self.left = new_left
}

///|
pub fn Spacing::get_top(self : Spacing) -> Double {
  self.top
}

///|
pub fn Spacing::set_top(self : Spacing, top : Double) -> Unit {
  self.top = top
}

///|
pub fn Spacing::get_right(self : Spacing) -> Double {
  self.right
}

///|
pub fn Spacing::set_right(self : Spacing, right : Double) -> Unit {
  self.right = right
}

///|
pub fn Spacing::get_bottom(self : Spacing) -> Double {
  self.bottom
}

///|
pub fn Spacing::set_bottom(self : Spacing, bottom : Double) -> Unit {
  self.bottom = bottom
}

///|
pub fn Spacing::get_left(self : Spacing) -> Double {
  self.left
}

///|
pub fn Spacing::set_left(self : Spacing, left : Double) -> Unit {
  self.left = left
}

///|
pub fn Spacing::set_left_right(self : Spacing, value : Double) -> Unit {
  self.left = value
  self.right = value
}

///|
pub fn Spacing::set_top_bottom(self : Spacing, value : Double) -> Unit {
  self.top = value
  self.bottom = value
}

///|
pub fn Spacing::get_horizontal(self : Spacing) -> Double {
  self.get_left() + self.get_right()
}

///|
pub fn Spacing::get_vertical(self : Spacing) -> Double {
  self.get_top() + self.get_bottom()
}

///|
pub fn Spacing::equals(self : Spacing, other : Spacing) -> Bool {
  self.top == other.top &&
  self.bottom == other.bottom &&
  self.left == other.left &&
  self.right == other.right
}

///|
pub fn Spacing::hash_code(self : Spacing) -> Int {
  let code1 = (self.left.hash() << 16) | (self.bottom.hash() & 0xffff)
  let code2 = (self.right.hash() << 16) | (self.top.hash() & 0xffff)
  code1 ^ code2
}

///|
pub fn Spacing::to_string(self : Spacing) -> String {
  "[top=\{self.top},left=\{self.left},bottom=\{self.bottom},right=\{self.right}]"
}

///|
pub fn Spacing::parse(self : Spacing, string : String) -> Unit {
  let (start, end) = _trim_delim_bounds(
    string, "([{\"' \t\r\n", ")]}\"' \t\r\n",
  )
  if start >= end {
    return
  }
  let body = _substring_chars(string, start, end)
  let tokens = _split_by_any_delims_drop_trailing_empty(body, ",;")
  for token in tokens {
    let key_and_value = _split_by_any_delims_drop_trailing_empty(token, "=")
    if key_and_value.length() != 2 {
      try
        spacing_parse_raise_unit("Expecting a list of key-value pairs.")
      catch {
        err =>
          layout_runtime_report_unsupported_configuration(
            spacing_parse_exception_message(err),
          )
      } noraise {
        _ => ()
      }
      return
    }
    let key = key_and_value[0].trim().to_string()
    let value = _parse_double_or_abort(
      key_and_value[1],
      "The given string contains parts that cannot be parsed as numbers.",
    )
    if key == "top" {
      self.top = value
    } else if key == "left" {
      self.left = value
    } else if key == "bottom" {
      self.bottom = value
    } else if key == "right" {
      self.right = value
    }
  }
}

///|
pub fn Spacing::copy(self : Spacing, other : Spacing) -> Spacing {
  self.left = other.left
  self.right = other.right
  self.top = other.top
  self.bottom = other.bottom
  self
}

///|
pub fn Spacing::add(self : Spacing, other : Spacing) -> Spacing {
  self.left = self.left + other.left
  self.right = self.right + other.right
  self.top = self.top + other.top
  self.bottom = self.bottom + other.bottom
  self
}

///|
pub fn Spacing::clone(self : Spacing) -> Spacing {
  new_spacing_values(self.top, self.right, self.bottom, self.left)
}
