///|
fn expect_some_color(color : DisCoDebugColor?) -> DisCoDebugColor {
  match color {
    Some(value) => value
    None => abort("Expected Some(Color)")
  }
}

///|
fn expect_some_font(font : DisCoDebugFont?) -> DisCoDebugFont {
  match font {
    Some(value) => value
    None => abort("Expected Some(Font)")
  }
}

///|
fn color_tuple_string(color : DisCoDebugColor) -> String {
  "(" +
  color.r.to_string() +
  "," +
  color.g.to_string() +
  "," +
  color.b.to_string() +
  ")"
}

///|
test "DisCoGraphRenderingConfigurator initializes Java defaults" {
  let display = new_dis_co_debug_display()
  let config = new_dis_co_graph_rendering_configurator(display)
  dis_co_graph_rendering_configurator_initialize(config, 1.0)

  inspect(
    color_tuple_string(
      expect_some_color(
        dis_co_graph_rendering_configurator_get_node_border_color(config),
      ),
    ),
    content="(0,115,127)",
  )
  inspect(
    color_tuple_string(
      expect_some_color(
        dis_co_graph_rendering_configurator_get_node_fill_color(config),
      ),
    ),
    content="(0,204,226)",
  )
  inspect(
    color_tuple_string(
      expect_some_color(
        dis_co_graph_rendering_configurator_get_dc_element_fill_color(config),
      ),
    ),
    content="(178,159,18)",
  )
  inspect(
    color_tuple_string(
      expect_some_color(
        dis_co_graph_rendering_configurator_get_polyomino_weakly_blocked_color(
          config,
        ),
      ),
    ),
    content="(170,9,178)",
  )
  inspect(
    color_tuple_string(dis_co_graph_rendering_configurator_get_black(config)),
    content="(0,0,0)",
  )
  inspect(
    dis_co_graph_rendering_configurator_get_label_fill_color(config) is None,
    content="true",
  )
  inspect(
    expect_some_font(
      dis_co_graph_rendering_configurator_get_node_label_font(config),
    ).size,
    content="9",
  )
  inspect(
    expect_some_font(
      dis_co_graph_rendering_configurator_get_port_label_font(config),
    ).size,
    content="6",
  )
  inspect(
    expect_some_font(
      dis_co_graph_rendering_configurator_get_edge_label_font(config),
    ).size,
    content="8",
  )
}

///|
test "DisCoGraphRenderingConfigurator honors minimum font height" {
  let display = new_dis_co_debug_display()
  let config = new_dis_co_graph_rendering_configurator(display)
  dis_co_graph_rendering_configurator_initialize(config, 0.1)
  inspect(
    expect_some_font(
      dis_co_graph_rendering_configurator_get_node_label_font(config),
    ).size,
    content="2",
  )
  inspect(
    expect_some_font(
      dis_co_graph_rendering_configurator_get_port_label_font(config),
    ).size,
    content="2",
  )
  inspect(
    expect_some_font(
      dis_co_graph_rendering_configurator_get_edge_label_font(config),
    ).size,
    content="2",
  )
}

///|
test "DisCoGraphRenderingConfigurator dispose releases resources" {
  let display = new_dis_co_debug_display()
  let config = new_dis_co_graph_rendering_configurator(display)
  dis_co_graph_rendering_configurator_initialize(config, 1.0)
  dis_co_graph_rendering_configurator_dispose(config)

  inspect(
    dis_co_debug_color_is_disposed(
      expect_some_color(
        dis_co_graph_rendering_configurator_get_node_fill_color(config),
      ),
    ),
    content="true",
  )
  inspect(
    dis_co_debug_font_is_disposed(
      expect_some_font(
        dis_co_graph_rendering_configurator_get_edge_label_font(config),
      ),
    ),
    content="true",
  )
}

///|
fn pattern_non_zero_alpha_count(pattern : DisCoDebugPattern) -> Int {
  let mut count = 0
  let mut index = 0
  while index < pattern.alpha_data.length() {
    if pattern.alpha_data[index] > 0 {
      count = count + 1
    }
    index = index + 1
  }
  count
}

///|
test "DisCoGraphRenderingFillPatterns follows Java rectangles" {
  let display = new_dis_co_debug_display()
  let config = new_dis_co_graph_rendering_configurator(display)
  dis_co_graph_rendering_configurator_initialize(config, 1.0)
  let patterns = new_dis_co_graph_rendering_fill_patterns(config, 1.0)

  let ext = dis_co_graph_rendering_fill_patterns_get_dc_extension_pattern(
    patterns, 61,
  )
  inspect(pattern_non_zero_alpha_count(ext), content="12")
  inspect(dis_co_debug_pattern_get_alpha(ext, 4, 0), content="61")
  inspect(dis_co_debug_pattern_get_alpha(ext, 2, 2), content="61")
  inspect(dis_co_debug_pattern_get_alpha(ext, 0, 4), content="61")
  inspect(dis_co_debug_pattern_get_alpha(ext, 1, 1), content="0")

  let poly_ext = dis_co_graph_rendering_fill_patterns_get_polyomino_extension_pattern(
    patterns, 73,
  )
  inspect(pattern_non_zero_alpha_count(poly_ext), content="12")
  inspect(dis_co_debug_pattern_get_alpha(poly_ext, 0, 0), content="73")
  inspect(dis_co_debug_pattern_get_alpha(poly_ext, 2, 2), content="73")
  inspect(dis_co_debug_pattern_get_alpha(poly_ext, 4, 4), content="73")

  let center = dis_co_graph_rendering_fill_patterns_get_polyomino_center_pattern(
    patterns, 87,
  )
  inspect(pattern_non_zero_alpha_count(center), content="16")
  inspect(dis_co_debug_pattern_get_alpha(center, 2, 0), content="87")
  inspect(dis_co_debug_pattern_get_alpha(center, 0, 2), content="87")
  inspect(dis_co_debug_pattern_get_alpha(center, 4, 2), content="87")
  inspect(dis_co_debug_pattern_get_alpha(center, 2, 4), content="87")
}

///|
test "DisCoGraphRenderingFillPatterns keeps Java scale cast behavior" {
  let display = new_dis_co_debug_display()
  let config = new_dis_co_graph_rendering_configurator(display)
  dis_co_graph_rendering_configurator_initialize(config, 1.0)
  let patterns = new_dis_co_graph_rendering_fill_patterns(config, 2.0)
  let poly_ext = dis_co_graph_rendering_fill_patterns_get_polyomino_extension_pattern(
    patterns, 100,
  )
  inspect(poly_ext.width, content="12")
  inspect(poly_ext.height, content="12")
  inspect(pattern_non_zero_alpha_count(poly_ext), content="48")
}
