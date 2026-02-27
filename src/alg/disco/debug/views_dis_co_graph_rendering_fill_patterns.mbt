///|
pub struct DisCoGraphRenderingFillPatterns {
  config : DisCoGraphRenderingConfigurator
  display : DisCoDebugDisplay
  scale : Int
}

///|
pub fn new_dis_co_graph_rendering_fill_patterns(
  config : DisCoGraphRenderingConfigurator,
  scale : Double,
) -> DisCoGraphRenderingFillPatterns {
  {
    config,
    display: dis_co_graph_rendering_configurator_get_display(config),
    scale: scale.to_int(),
  }
}

///|
fn require_color(color : DisCoDebugColor?, name : String) -> DisCoDebugColor {
  match color {
    Some(value) => value
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "Missing color in DisCoGraphRenderingConfigurator: " + name,
      )
      new_dis_co_debug_color(new_dis_co_debug_display(), 0, 0, 0)
    }
  }
}

///|
fn new_transparent_pattern(scale : Int) -> DisCoDebugPattern {
  new_dis_co_debug_pattern(6 * scale, 6 * scale)
}

///|
fn fill_rectangle(
  pattern : DisCoDebugPattern,
  scaling : Int,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  alpha : Int,
) -> Unit {
  dis_co_debug_pattern_fill_rectangle(
    pattern,
    x * scaling,
    y * scaling,
    width * scaling,
    height * scaling,
    alpha,
  )
}

///|
pub fn dis_co_graph_rendering_fill_patterns_get_dc_extension_pattern(
  patterns : DisCoGraphRenderingFillPatterns,
  alpha : Int,
) -> DisCoDebugPattern {
  ignore(
    require_color(
      dis_co_graph_rendering_configurator_get_dc_element_external_fill_color(
        patterns.config,
      ),
      "dcElementExternalFillColor",
    ),
  )

  let pattern = new_transparent_pattern(patterns.scale)
  fill_rectangle(pattern, patterns.scale, 4, 0, 2, 2, alpha)
  fill_rectangle(pattern, patterns.scale, 2, 2, 2, 2, alpha)
  fill_rectangle(pattern, patterns.scale, 0, 4, 2, 2, alpha)
  pattern
}

///|
pub fn dis_co_graph_rendering_fill_patterns_get_polyomino_extension_pattern(
  patterns : DisCoGraphRenderingFillPatterns,
  alpha : Int,
) -> DisCoDebugPattern {
  ignore(
    require_color(
      dis_co_graph_rendering_configurator_get_polyomino_weakly_blocked_color(
        patterns.config,
      ),
      "polyominoWeaklyBlockedColor",
    ),
  )

  let pattern = new_transparent_pattern(patterns.scale)
  fill_rectangle(pattern, patterns.scale, 0, 0, 2, 2, alpha)
  fill_rectangle(pattern, patterns.scale, 2, 2, 2, 2, alpha)
  fill_rectangle(pattern, patterns.scale, 4, 4, 2, 2, alpha)

  if patterns.scale != 1 {
    ignore(patterns.display)
    ignore(new_dis_co_debug_pattern(pattern.width, pattern.height))
  }
  pattern
}

///|
pub fn dis_co_graph_rendering_fill_patterns_get_polyomino_center_pattern(
  patterns : DisCoGraphRenderingFillPatterns,
  alpha : Int,
) -> DisCoDebugPattern {
  ignore(
    require_color(
      dis_co_graph_rendering_configurator_get_polyomino_center_color(
        patterns.config,
      ),
      "polyominoCenterColor",
    ),
  )

  let pattern = new_transparent_pattern(patterns.scale)
  fill_rectangle(pattern, patterns.scale, 2, 0, 2, 2, alpha)
  fill_rectangle(pattern, patterns.scale, 0, 2, 2, 2, alpha)
  fill_rectangle(pattern, patterns.scale, 4, 2, 2, 2, alpha)
  fill_rectangle(pattern, patterns.scale, 2, 4, 2, 2, alpha)
  pattern
}
