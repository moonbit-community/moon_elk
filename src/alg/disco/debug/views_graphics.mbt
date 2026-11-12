///|
pub let dis_co_swt_normal : Int32 = 0

///|
#derive(Eq)
pub struct DisCoDebugDisplay {
  id : Int32
}

///|
pub fn new_dis_co_debug_display() -> DisCoDebugDisplay {
  { id: 0, }
}

///|
pub struct DisCoDebugColor {
  display : DisCoDebugDisplay
  r : Int32
  g : Int32
  b : Int32
  mut disposed : Bool
}

///|
pub fn new_dis_co_debug_color(
  display : DisCoDebugDisplay,
  r : Int32,
  g : Int32,
  b : Int32,
) -> DisCoDebugColor {
  { display, r, g, b, disposed: false, }
}

///|
pub fn dis_co_debug_color_dispose(color : DisCoDebugColor) -> Unit {
  color.disposed = true
}

///|
pub fn dis_co_debug_color_is_disposed(color : DisCoDebugColor) -> Bool {
  color.disposed
}

///|
pub struct DisCoDebugFont {
  display : DisCoDebugDisplay
  name : String
  size : Int32
  style : Int32
  mut disposed : Bool
}

///|
pub fn new_dis_co_debug_font(
  display : DisCoDebugDisplay,
  name : String,
  size : Int32,
  style : Int32,
) -> DisCoDebugFont {
  { display, name, size, style, disposed: false, }
}

///|
pub fn dis_co_debug_font_dispose(font : DisCoDebugFont) -> Unit {
  font.disposed = true
}

///|
pub fn dis_co_debug_font_is_disposed(font : DisCoDebugFont) -> Bool {
  font.disposed
}

///|
pub struct DisCoDebugPattern {
  width : Int32
  height : Int32
  alpha_data : Array[Int32]
}

///|
pub fn new_dis_co_debug_pattern(
  width : Int32,
  height : Int32,
) -> DisCoDebugPattern {
  let bounded_width = if width > 0 { width } else { 0 }
  let bounded_height = if height > 0 { height } else { 0 }
  let alpha_data : Array[Int32] = []
  let mut index = 0
  let total = bounded_width * bounded_height
  while index < total {
    alpha_data.push(0)
    index = index + 1
  }
  { width: bounded_width, height: bounded_height, alpha_data, }
}

///|
fn dis_co_debug_pattern_index(
  pattern : DisCoDebugPattern,
  x : Int32,
  y : Int32,
) -> Int32? {
  if x < 0 || y < 0 || x >= pattern.width || y >= pattern.height {
    None
  } else {
    Some(y * pattern.width + x)
  }
}

///|
pub fn dis_co_debug_pattern_get_alpha(
  pattern : DisCoDebugPattern,
  x : Int32,
  y : Int32,
) -> Int32 {
  match dis_co_debug_pattern_index(pattern, x, y) {
    Some(index) => pattern.alpha_data[index]
    None => 0
  }
}

///|
fn dis_co_debug_pattern_set_alpha(
  pattern : DisCoDebugPattern,
  x : Int32,
  y : Int32,
  alpha : Int32,
) -> Unit {
  match dis_co_debug_pattern_index(pattern, x, y) {
    Some(index) => pattern.alpha_data[index] = alpha
    None => ()
  }
}

///|
pub fn dis_co_debug_pattern_fill_rectangle(
  pattern : DisCoDebugPattern,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
  alpha : Int32,
) -> Unit {
  if width > 0 && height > 0 {
    let mut py = y
    let y_end = y + height
    while py < y_end {
      let mut px = x
      let x_end = x + width
      while px < x_end {
        dis_co_debug_pattern_set_alpha(pattern, px, py, alpha)
        px = px + 1
      }
      py = py + 1
    }
  }
}

///|
pub extend DisCoDebugDisplay with Eq::{not_equal, equal}
