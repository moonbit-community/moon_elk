///|
fn string_starts_with_null_prefix(value : String) -> Bool {
  value.length() >= 4 &&
  (try value[0:4] catch {
    _ => ""
  } noraise {
    prefix => prefix.to_string()
  }) ==
  "null"
}

///|
fn is_finite_double(value : Double) -> Bool {
  !value.is_nan() && !value.is_inf()
}

///|
fn pad_three_digits(value : Int) -> String {
  if value < 10 {
    "00" + value.to_string()
  } else if value < 100 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn svg_scale(image : SvgImage) -> Double {
  let area = image.view_box_h * image.view_box_w
  if area > image.max_area {
    (image.max_area / area).sqrt()
  } else {
    1.0
  }
}

///|
fn svg_group_content(image : SvgImage, key : String) -> String {
  image.groups.get(key).unwrap_or("")
}

///|
fn svg_content(image : SvgImage) -> String {
  let scale = svg_scale(image)
  let output = @buffer.new()
  output.write_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  output.write_string(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"100%\" height=\"100%\" viewBox=\"\{image.view_box_x * scale - image.spacing} \{image.view_box_y * scale - image.spacing} \{image.view_box_w * scale + 2.0 * image.spacing} \{image.view_box_h * scale + 2.0 * image.spacing}\">\n",
  )
  for key in image.group_order {
    output.write_string(
      "<g transform=\"scale(\{scale})\" id=\"\{key}\">\n\{svg_group_content(image, key)}</g>\n",
    )
  }
  output.write_string("</svg>\n")
  output.to_string()
}

///|
pub struct SvgImage {
  spacing : Double
  mut view_box_x : Double
  mut view_box_y : Double
  mut view_box_w : Double
  mut view_box_h : Double
  mut view_box_x2 : Double
  mut view_box_y2 : Double
  mut enable_update_view_box : Bool
  mut current : String
  groups : Map[String, String]
  mut group_order : Array[String]
  file_name : String?
  mut index : Int
  mut debug : Bool
  max_area : Double
  mut last_output : String
}

///|
pub fn new_svg_image(file_name : String?) -> SvgImage {
  let mut debug = false
  let mut saved_file_name : String? = None
  match file_name {
    Some(file) =>
      if file.length() > 0 && !string_starts_with_null_prefix(file) {
        debug = true
        saved_file_name = Some(file)
      }
    None => ()
  }
  {
    spacing: 20.0,
    view_box_x: @double.infinity,
    view_box_y: @double.infinity,
    view_box_w: 0.0,
    view_box_h: 0.0,
    view_box_x2: -@double.infinity,
    view_box_y2: -@double.infinity,
    enable_update_view_box: true,
    current: "main",
    groups: { "main": "" },
    group_order: ["main"],
    file_name: saved_file_name,
    index: 0,
    debug,
    max_area: 8294400.0,
    last_output: "",
  }
}

///|
pub fn SvgImage::g(self : SvgImage, key : String) -> SvgImage {
  if self.debug {
    if !self.groups.contains(key) {
      self.groups[key] = ""
      self.group_order.push(key)
    }
    self.current = key
  }
  self
}

///|
pub fn SvgImage::add_groups(self : SvgImage, keys : Array[String]) -> Unit {
  if self.debug {
    for key in keys {
      if !self.groups.contains(key) {
        self.group_order.push(key)
      }
      self.groups[key] = ""
    }
  }
}

///|
pub fn SvgImage::clear_group(self : SvgImage, key : String) -> Unit {
  if self.debug && self.groups.contains(key) {
    self.groups[key] = ""
  }
}

///|
pub fn SvgImage::remove_group(self : SvgImage, key : String) -> Unit {
  if self.debug {
    if key == "main" {
      self.clear_group(key)
    } else if self.groups.contains(key) {
      self.groups.remove(key)
      let filtered : Array[String] = []
      for group in self.group_order {
        if group != key {
          filtered.push(group)
        }
      }
      self.group_order = filtered
      if self.current == key {
        self.current = "main"
      }
    }
  }
}

///|
pub fn SvgImage::set_view_box(
  self : SvgImage,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
) -> Unit {
  if self.debug {
    self.view_box_x = x
    self.view_box_y = y
    self.view_box_w = w
    self.view_box_h = h
    self.enable_update_view_box = false
  }
}

///|
pub fn SvgImage::clear(self : SvgImage) -> Unit {
  let mut debug = false
  match self.file_name {
    Some(file) => if file.length() > 0 { debug = true }
    None => ()
  }
  self.debug = debug
  if self.debug {
    self.groups.clear()
    self.current = "main"
    self.groups["main"] = ""
    self.group_order = ["main"]
    if self.enable_update_view_box {
      self.view_box_x = @double.infinity
      self.view_box_y = @double.infinity
      self.view_box_w = 0.0
      self.view_box_h = 0.0
      self.view_box_x2 = -@double.infinity
      self.view_box_y2 = -@double.infinity
    }
  }
}

///|
pub fn SvgImage::add_element_str(self : SvgImage, element : String) -> Unit {
  if self.debug {
    let current_group = svg_group_content(self, self.current)
    self.groups[self.current] = current_group + element + "\n"
    self.current = "main"
  }
}

///|
fn svg_update_view_box(image : SvgImage, points : Array[@core.KVector]) -> Unit {
  if image.debug && image.enable_update_view_box {
    for point in points {
      if is_finite_double(point.x) && is_finite_double(point.y) {
        image.view_box_x = if image.view_box_x < point.x {
          image.view_box_x
        } else {
          point.x
        }
        image.view_box_y = if image.view_box_y < point.y {
          image.view_box_y
        } else {
          point.y
        }
        image.view_box_x2 = if image.view_box_x2 > point.x {
          image.view_box_x2
        } else {
          point.x
        }
        image.view_box_y2 = if image.view_box_y2 > point.y {
          image.view_box_y2
        } else {
          point.y
        }
      }
    }
    image.view_box_w = image.view_box_x2 - image.view_box_x
    image.view_box_h = image.view_box_y2 - image.view_box_y
  }
}

///|
pub fn SvgImage::add_circle(
  self : SvgImage,
  x : Double,
  y : Double,
  r? : Double = 5.0,
  attributes? : String = "stroke=\"black\" stroke-width=\"1\" fill=\"none\"",
) -> Unit {
  if self.debug {
    self.add_element_str(
      "<circle cx=\"\{x}\" cy=\"\{y}\" r=\"\{r}\" \{attributes} />",
    )
    svg_update_view_box(self, [
      @core.new_kvector_xy(x - r, y - r),
      @core.new_kvector_xy(x + r, y + r),
    ])
  }
}

///|
pub fn SvgImage::add_line(
  self : SvgImage,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  attributes? : String = "stroke=\"black\" stroke-width=\"1\"",
) -> Unit {
  if self.debug {
    self.add_element_str(
      "<line x1=\"\{x1}\" y1=\"\{y1}\" x2=\"\{x2}\" y2=\"\{y2}\" \{attributes} />",
    )
    svg_update_view_box(self, [
      @core.new_kvector_xy(x1, y1),
      @core.new_kvector_xy(x2, y2),
    ])
  }
}

///|
pub fn SvgImage::add_rect(
  self : SvgImage,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  attributes : String,
) -> Unit {
  if self.debug {
    self.add_element_str(
      "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{w}\" height=\"\{h}\" \{attributes} />",
    )
    svg_update_view_box(self, [
      @core.new_kvector_xy(x, y),
      @core.new_kvector_xy(x + w, y + h),
    ])
  }
}

///|
pub fn SvgImage::add_rect_from_elk(
  self : SvgImage,
  rect : @core.ElkRectangle,
  attributes : String,
) -> Unit {
  if self.debug {
    self.add_rect(rect.x, rect.y, rect.width, rect.height, attributes)
  }
}

///|
pub fn SvgImage::add_poly(
  self : SvgImage,
  attributes : String,
  points : Array[@core.KVector],
) -> Unit {
  if self.debug {
    let output = @buffer.new()
    output.write_string("<polyline points=\"")
    for point in points {
      output.write_string("\{point.x},\{point.y} ")
    }
    output.write_string("\" \{attributes} />")
    self.add_element_str(output.to_string())
    svg_update_view_box(self, points)
  }
}

///|
pub fn SvgImage::add_text(
  self : SvgImage,
  x : Double,
  y : Double,
  text : String,
  attributes : String,
) -> Unit {
  if self.debug {
    self.add_element_str(
      "<text x=\"\{x}\" y=\"\{y}\" \{attributes}>\{text}</text>",
    )
  }
}

///|
pub fn SvgImage::save(self : SvgImage, f_name? : String? = None) -> Unit {
  if self.debug {
    ignore(f_name)
    self.last_output = svg_content(self)
  }
}

///|
pub fn SvgImage::isave(self : SvgImage, f_name? : String? = None) -> Unit {
  if self.debug {
    let base_name = match f_name {
      Some(value) => value
      None =>
        match self.file_name {
          Some(value) => value
          None => ""
        }
    }
    self.save(f_name=Some(base_name + pad_three_digits(self.index)))
    self.index = self.index + 1
  }
}
