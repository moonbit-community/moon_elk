///|
let dis_co_node_font_size : Int = 9

///|
let dis_co_port_font_size : Int = 6

///|
let dis_co_edge_font_size : Int = 8

///|
pub let dis_co_min_font_height : Int = 3

///|
pub struct DisCoGraphRenderingConfigurator {
  black : DisCoDebugColor
  mut node_border_color : DisCoDebugColor?
  mut node_fill_color : DisCoDebugColor?
  mut node_label_font : DisCoDebugFont?
  mut port_border_color : DisCoDebugColor?
  mut port_fill_color : DisCoDebugColor?
  mut port_label_font : DisCoDebugFont?
  mut edge_color : DisCoDebugColor?
  mut edge_label_font : DisCoDebugFont?
  mut label_border_color : DisCoDebugColor?
  mut label_fill_color : DisCoDebugColor?
  mut label_text_color : DisCoDebugColor?
  mut dc_element_fill_color : DisCoDebugColor?
  mut dc_element_external_color : DisCoDebugColor?
  mut dc_element_external_border_text_color : DisCoDebugColor?
  mut dc_element_border_text_color : DisCoDebugColor?
  mut dc_polyomino_fill_color : DisCoDebugColor?
  mut dc_polyomino_center_color : DisCoDebugColor?
  mut dc_polyomino_weakly_blocked_fill_color : DisCoDebugColor?
  mut dc_polyomino_weakly_blocked_border_text_color : DisCoDebugColor?
  mut dc_polyomino_border_text_color : DisCoDebugColor?
  display : DisCoDebugDisplay
}

///|
pub fn new_dis_co_graph_rendering_configurator(
  display : DisCoDebugDisplay,
) -> DisCoGraphRenderingConfigurator {
  {
    black: new_dis_co_debug_color(display, 0, 0, 0),
    node_border_color: None,
    node_fill_color: None,
    node_label_font: None,
    port_border_color: None,
    port_fill_color: None,
    port_label_font: None,
    edge_color: None,
    edge_label_font: None,
    label_border_color: None,
    label_fill_color: None,
    label_text_color: None,
    dc_element_fill_color: None,
    dc_element_external_color: None,
    dc_element_external_border_text_color: None,
    dc_element_border_text_color: None,
    dc_polyomino_fill_color: None,
    dc_polyomino_center_color: None,
    dc_polyomino_weakly_blocked_fill_color: None,
    dc_polyomino_weakly_blocked_border_text_color: None,
    dc_polyomino_border_text_color: None,
    display,
  }
}

///|
fn dis_co_scaled_font_size(base_size : Int, scale : Double) -> Int {
  let scaled = (base_size.to_double() * scale).round().to_int()
  if scaled > 2 {
    scaled
  } else {
    2
  }
}

///|
pub fn dis_co_graph_rendering_configurator_get_display(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugDisplay {
  config.display
}

///|
pub fn dis_co_graph_rendering_configurator_initialize(
  config : DisCoGraphRenderingConfigurator,
  scale : Double,
) -> Unit {
  let dc_kgraph_color = new_dis_co_debug_color(config.display, 0, 115, 127)

  let node_font_size = dis_co_scaled_font_size(dis_co_node_font_size, scale)
  config.node_label_font = Some(
    new_dis_co_debug_font(
      config.display,
      "sans",
      node_font_size,
      dis_co_swt_normal,
    ),
  )
  config.node_border_color = Some(dc_kgraph_color)
  config.node_fill_color = Some(
    new_dis_co_debug_color(config.display, 0, 204, 226),
  )

  config.dc_element_fill_color = Some(
    new_dis_co_debug_color(config.display, 178, 159, 18),
  )
  config.dc_element_external_color = Some(
    new_dis_co_debug_color(config.display, 179, 80, 18),
  )
  config.dc_element_border_text_color = Some(
    new_dis_co_debug_color(config.display, 127, 113, 13),
  )
  config.dc_element_external_border_text_color = Some(
    new_dis_co_debug_color(config.display, 127, 57, 13),
  )
  config.dc_polyomino_fill_color = Some(
    new_dis_co_debug_color(config.display, 178, 9, 101),
  )
  config.dc_polyomino_center_color = Some(config.black)
  config.dc_polyomino_weakly_blocked_fill_color = Some(
    new_dis_co_debug_color(config.display, 170, 9, 178),
  )
  config.dc_polyomino_border_text_color = Some(
    new_dis_co_debug_color(config.display, 127, 6, 72),
  )
  config.dc_polyomino_weakly_blocked_border_text_color = Some(
    new_dis_co_debug_color(config.display, 121, 6, 128),
  )

  let port_font_size = dis_co_scaled_font_size(dis_co_port_font_size, scale)
  config.port_label_font = Some(
    new_dis_co_debug_font(
      config.display,
      "sans",
      port_font_size,
      dis_co_swt_normal,
    ),
  )
  config.port_border_color = Some(dc_kgraph_color)
  config.port_fill_color = Some(dc_kgraph_color)

  let edge_font_size = dis_co_scaled_font_size(dis_co_edge_font_size, scale)
  config.edge_label_font = Some(
    new_dis_co_debug_font(
      config.display,
      "sans",
      edge_font_size,
      dis_co_swt_normal,
    ),
  )
  config.edge_color = Some(dc_kgraph_color)

  config.label_border_color = Some(dc_kgraph_color)
  config.label_fill_color = None
  config.label_text_color = Some(dc_kgraph_color)
}

///|
fn dispose_color(color : DisCoDebugColor?) -> Unit {
  match color {
    Some(value) => dis_co_debug_color_dispose(value)
    None => ()
  }
}

///|
fn dispose_font(font : DisCoDebugFont?) -> Unit {
  match font {
    Some(value) => dis_co_debug_font_dispose(value)
    None => ()
  }
}

///|
pub fn dis_co_graph_rendering_configurator_dispose(
  config : DisCoGraphRenderingConfigurator,
) -> Unit {
  dispose_color(config.node_border_color)
  dispose_color(config.node_fill_color)
  dispose_font(config.node_label_font)
  dispose_color(config.label_border_color)
  dispose_color(config.label_text_color)
  dispose_color(config.port_border_color)
  dispose_color(config.port_fill_color)
  dispose_font(config.port_label_font)
  dispose_color(config.edge_color)
  dispose_font(config.edge_label_font)
  dispose_color(config.dc_element_fill_color)
  dispose_color(config.dc_element_border_text_color)
  dispose_color(config.dc_polyomino_fill_color)
  dispose_color(config.dc_polyomino_border_text_color)
}

///|
pub fn dis_co_graph_rendering_configurator_get_node_border_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.node_border_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_node_fill_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.node_fill_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_node_label_font(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugFont? {
  config.node_label_font
}

///|
pub fn dis_co_graph_rendering_configurator_get_port_border_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.port_border_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_port_fill_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.port_fill_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_port_label_font(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugFont? {
  config.port_label_font
}

///|
pub fn dis_co_graph_rendering_configurator_get_edge_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.edge_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_edge_label_font(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugFont? {
  config.edge_label_font
}

///|
pub fn dis_co_graph_rendering_configurator_get_label_border_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.label_border_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_label_fill_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.label_fill_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_label_text_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.label_text_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_dc_element_fill_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_element_fill_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_dc_element_border_text_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_element_border_text_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_dc_element_external_fill_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_element_external_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_dc_element_external_border_text_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_element_external_border_text_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_polyomino_fill_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_polyomino_fill_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_polyomino_center_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_polyomino_center_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_polyomino_border_text_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_polyomino_border_text_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_polyomino_weakly_blocked_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_polyomino_weakly_blocked_fill_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_polyomino_weakly_blocked_border_text_color(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor? {
  config.dc_polyomino_weakly_blocked_border_text_color
}

///|
pub fn dis_co_graph_rendering_configurator_get_black(
  config : DisCoGraphRenderingConfigurator,
) -> DisCoDebugColor {
  config.black
}
