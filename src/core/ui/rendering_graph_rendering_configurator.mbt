///|
pub let core_ui_swt_normal : Int = 0

///|
pub(all) struct CoreUiDisplay {
  id : Int
} derive(Eq)

///|
pub fn new_core_ui_display() -> CoreUiDisplay {
  { id: 0 }
}

///|
pub(all) struct CoreUiColor {
  display : CoreUiDisplay
  r : Int
  g : Int
  b : Int
  mut disposed : Bool
}

///|
pub fn new_core_ui_color(
  display : CoreUiDisplay,
  r : Int,
  g : Int,
  b : Int,
) -> CoreUiColor {
  { display, r, g, b, disposed: false }
}

///|
pub fn core_ui_color_dispose(color : CoreUiColor) -> Unit {
  color.disposed = true
}

///|
pub fn core_ui_color_is_disposed(color : CoreUiColor) -> Bool {
  color.disposed
}

///|
pub(all) struct CoreUiFont {
  display : CoreUiDisplay
  name : String
  size : Int
  style : Int
  mut disposed : Bool
}

///|
pub fn new_core_ui_font(
  display : CoreUiDisplay,
  name : String,
  size : Int,
  style : Int,
) -> CoreUiFont {
  { display, name, size, style, disposed: false }
}

///|
pub fn core_ui_font_dispose(font : CoreUiFont) -> Unit {
  font.disposed = true
}

///|
pub fn core_ui_font_is_disposed(font : CoreUiFont) -> Bool {
  font.disposed
}

///|
let core_ui_node_font_size : Int = 9

///|
let core_ui_port_font_size : Int = 6

///|
let core_ui_edge_font_size : Int = 8

///|
pub let core_ui_min_font_height : Int = 3

///|
pub(all) struct GraphRenderingConfigurator {
  mut node_border_color : CoreUiColor?
  mut node_fill_color : CoreUiColor?
  mut node_label_font : CoreUiFont?
  mut node_font_size : Int
  mut port_border_color : CoreUiColor?
  mut port_fill_color : CoreUiColor?
  mut port_label_font : CoreUiFont?
  mut port_font_size : Int
  mut edge_color : CoreUiColor?
  mut edge_label_font : CoreUiFont?
  mut edge_font_size : Int
  mut label_border_color : CoreUiColor?
  mut label_fill_color : CoreUiColor?
  mut label_text_color : CoreUiColor?
  mut out_of_bounds_color : CoreUiColor?
  mut root_node_color : CoreUiColor?
  display : CoreUiDisplay
}

///|
pub fn new_graph_rendering_configurator(
  display : CoreUiDisplay,
) -> GraphRenderingConfigurator {
  let configurator = {
    node_border_color: None,
    node_fill_color: None,
    node_label_font: None,
    node_font_size: 0,
    port_border_color: None,
    port_fill_color: None,
    port_label_font: None,
    port_font_size: 0,
    edge_color: None,
    edge_label_font: None,
    edge_font_size: 0,
    label_border_color: None,
    label_fill_color: None,
    label_text_color: None,
    out_of_bounds_color: None,
    root_node_color: None,
    display,
  }
  configurator.initialize()
  configurator
}

///|
fn core_ui_dispose_color(color : CoreUiColor?) -> Unit {
  match color {
    Some(actual_color) => core_ui_color_dispose(actual_color)
    None => ()
  }
}

///|
fn core_ui_dispose_font(font : CoreUiFont?) -> Unit {
  match font {
    Some(actual_font) => core_ui_font_dispose(actual_font)
    None => ()
  }
}

///|
pub fn GraphRenderingConfigurator::get_display(
  self : GraphRenderingConfigurator,
) -> CoreUiDisplay {
  self.display
}

///|
pub fn GraphRenderingConfigurator::initialize(
  self : GraphRenderingConfigurator,
) -> Unit {
  self.node_label_font = Some(
    new_core_ui_font(
      self.display,
      "sans",
      core_ui_node_font_size,
      core_ui_swt_normal,
    ),
  )
  self.node_font_size = core_ui_node_font_size
  self.node_border_color = Some(new_core_ui_color(self.display, 2, 15, 3))
  self.node_fill_color = Some(new_core_ui_color(self.display, 168, 220, 190))

  self.port_label_font = Some(
    new_core_ui_font(
      self.display,
      "sans",
      core_ui_port_font_size,
      core_ui_swt_normal,
    ),
  )
  self.port_font_size = core_ui_port_font_size
  self.port_border_color = Some(new_core_ui_color(self.display, 2, 9, 40))
  self.port_fill_color = Some(new_core_ui_color(self.display, 2, 9, 40))

  self.edge_label_font = Some(
    new_core_ui_font(
      self.display,
      "sans",
      core_ui_edge_font_size,
      core_ui_swt_normal,
    ),
  )
  self.edge_font_size = core_ui_edge_font_size
  self.edge_color = Some(new_core_ui_color(self.display, 23, 36, 54))

  self.label_border_color = Some(new_core_ui_color(self.display, 63, 117, 67))
  self.label_fill_color = None
  self.label_text_color = Some(new_core_ui_color(self.display, 2, 15, 3))

  self.out_of_bounds_color = Some(
    new_core_ui_color(self.display, 255, 205, 210),
  )
  self.root_node_color = Some(new_core_ui_color(self.display, 240, 240, 240))
}

///|
pub fn GraphRenderingConfigurator::dispose(
  self : GraphRenderingConfigurator,
) -> Unit {
  core_ui_dispose_color(self.node_border_color)
  core_ui_dispose_color(self.node_fill_color)
  core_ui_dispose_font(self.node_label_font)
  core_ui_dispose_color(self.label_border_color)
  core_ui_dispose_color(self.label_text_color)
  core_ui_dispose_color(self.port_border_color)
  core_ui_dispose_color(self.port_fill_color)
  core_ui_dispose_font(self.port_label_font)
  core_ui_dispose_color(self.edge_color)
  core_ui_dispose_font(self.edge_label_font)
  core_ui_dispose_color(self.out_of_bounds_color)
  core_ui_dispose_color(self.root_node_color)
}

///|
fn core_ui_scaled_font_size(base_size : Int, scale : Double) -> Int {
  let scaled = (base_size.to_double() * scale).round().to_int()
  if scaled > 2 {
    scaled
  } else {
    2
  }
}

///|
pub fn GraphRenderingConfigurator::set_scale(
  self : GraphRenderingConfigurator,
  scale : Double,
) -> Unit {
  let new_node_font_size = core_ui_scaled_font_size(
    core_ui_node_font_size, scale,
  )
  if new_node_font_size != self.node_font_size {
    core_ui_dispose_font(self.node_label_font)
    self.node_label_font = Some(
      new_core_ui_font(
        self.display,
        "sans",
        new_node_font_size,
        core_ui_swt_normal,
      ),
    )
    self.node_font_size = new_node_font_size
  }

  let new_port_font_size = core_ui_scaled_font_size(
    core_ui_port_font_size, scale,
  )
  if new_port_font_size != self.port_font_size {
    core_ui_dispose_font(self.port_label_font)
    self.port_label_font = Some(
      new_core_ui_font(
        self.display,
        "sans",
        new_port_font_size,
        core_ui_swt_normal,
      ),
    )
    self.port_font_size = new_port_font_size
  }

  let new_edge_font_size = core_ui_scaled_font_size(
    core_ui_edge_font_size, scale,
  )
  if new_edge_font_size != self.edge_font_size {
    core_ui_dispose_font(self.edge_label_font)
    self.edge_label_font = Some(
      new_core_ui_font(
        self.display,
        "sans",
        new_edge_font_size,
        core_ui_swt_normal,
      ),
    )
    self.edge_font_size = new_edge_font_size
  }
}

///|
pub fn GraphRenderingConfigurator::get_node_border_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.node_border_color
}

///|
pub fn GraphRenderingConfigurator::get_node_fill_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.node_fill_color
}

///|
pub fn GraphRenderingConfigurator::get_node_label_font(
  self : GraphRenderingConfigurator,
) -> CoreUiFont? {
  self.node_label_font
}

///|
pub fn GraphRenderingConfigurator::get_port_border_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.port_border_color
}

///|
pub fn GraphRenderingConfigurator::get_port_fill_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.port_fill_color
}

///|
pub fn GraphRenderingConfigurator::get_port_label_font(
  self : GraphRenderingConfigurator,
) -> CoreUiFont? {
  self.port_label_font
}

///|
pub fn GraphRenderingConfigurator::get_edge_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.edge_color
}

///|
pub fn GraphRenderingConfigurator::get_edge_label_font(
  self : GraphRenderingConfigurator,
) -> CoreUiFont? {
  self.edge_label_font
}

///|
pub fn GraphRenderingConfigurator::get_label_border_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.label_border_color
}

///|
pub fn GraphRenderingConfigurator::get_label_fill_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.label_fill_color
}

///|
pub fn GraphRenderingConfigurator::get_label_text_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.label_text_color
}

///|
pub fn GraphRenderingConfigurator::get_out_of_bounds_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.out_of_bounds_color
}

///|
pub fn GraphRenderingConfigurator::get_root_node_color(
  self : GraphRenderingConfigurator,
) -> CoreUiColor? {
  self.root_node_color
}
