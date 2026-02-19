///|
fn expect_some_node(node : @graph.ElkNode?) -> @graph.ElkNode {
  match node {
    Some(value) => value
    None => abort("Expected Some(@graph.ElkNode)")
  }
}

///|
test "SelectivePaintToggleAction toggles renderer visibility" {
  let display = new_dis_co_debug_display()
  let canvas = new_dis_co_graph_rendering_canvas(display)
  let action = new_selective_paint_toggle_action(
    "elkgraph", "Toggle ElkGraph", "Shows and hides the ElkGraph", canvas,
  )
  let renderer = dis_co_graph_rendering_canvas_get_renderer(canvas)

  inspect(selective_paint_toggle_action_is_checked(action), content="true")
  selective_paint_toggle_action_run(action)
  inspect(selective_paint_toggle_action_is_checked(action), content="false")
  inspect(
    dis_co_graph_renderer_is_visible(renderer, "elkgraph"),
    content="false",
  )
  inspect(dis_co_graph_rendering_canvas_get_redraw_count(canvas), content="1")

  selective_paint_toggle_action_run(action)
  inspect(selective_paint_toggle_action_is_checked(action), content="true")
  inspect(
    dis_co_graph_renderer_is_visible(renderer, "elkgraph"),
    content="true",
  )
  inspect(dis_co_graph_rendering_canvas_get_redraw_count(canvas), content="2")
}

///|
test "DropdownIntRangeAction updates label, state and upper bound" {
  let display = new_dis_co_debug_display()
  let canvas = new_dis_co_graph_rendering_canvas(display)
  let config = new_config_state()
  let action = new_dropdown_int_range_action(
    config,
    "Show levels ",
    0,
    0,
    0,
    dis_co_debug_state_at(0),
    canvas,
  )

  dropdown_int_range_action_apply_num(action, 2)
  inspect(dropdown_int_range_action_get_text(action), content="Show levels 2")
  inspect(config_state_get_lower_lvl(config), content="2")
  inspect(config_state_get_upper_lvl(config), content="2")
  inspect(dis_co_graph_rendering_canvas_get_redraw_count(canvas), content="1")

  config_state_set_depth(config, 5)
  inspect(dropdown_int_range_action_get_menu(action), content="[0, 1, 2, 3, 4]")
}

///|
test "DisCoImageExportAction checkFileName mirrors Java rules" {
  inspect(
    dis_co_image_export_action_check_file_name(Some("graph.png")),
    content="Some(\"graph.png\")",
  )
  inspect(
    dis_co_image_export_action_check_file_name(Some("graph.pn")),
    content="Some(\"graph.png\")",
  )
  inspect(
    dis_co_image_export_action_check_file_name(Some("graph.p")),
    content="Some(\"graph.png\")",
  )
  inspect(
    dis_co_image_export_action_check_file_name(Some("graph.")),
    content="Some(\"graph.png\")",
  )
  inspect(
    dis_co_image_export_action_check_file_name(Some("graph")),
    content="Some(\"graph.png\")",
  )
}

///|
test "DisCoImageExportAction stores selected normalized output path" {
  dis_co_image_export_action_reset_for_test()
  let display = new_dis_co_debug_display()
  let canvas = new_dis_co_graph_rendering_canvas(display)
  let root = @graph.create_graph()
  @graph.node_set_dimensions(root, 20.0, 10.0)
  dis_co_graph_rendering_canvas_set_layout_graph(canvas, Some(root))
  let view = new_dis_co_debug_view(canvas)
  let action = new_dis_co_image_export_action(view)
  dis_co_image_export_action_set_selected_file_name(action, Some("render.p"))
  dis_co_image_export_action_run(action)
  inspect(dis_co_image_export_action_get_last_file_name(), content="render.png")
  inspect(
    dis_co_image_export_action_get_exported_files(),
    content="[\"render.png\"]",
  )
}

///|
test "DisCoDebugPlugin listens for layout done notifications" {
  let display = new_dis_co_debug_display()
  let canvas = new_dis_co_graph_rendering_canvas(display)
  let view = new_dis_co_debug_view(canvas)
  ignore(view)
  let plugin = new_dis_co_debug_plugin()
  dis_co_debug_plugin_start(plugin)

  let root = @graph.create_graph()
  @graph.node_set_dimensions(root, 33.0, 44.0)
  let mapping = new_dis_co_layout_mapping(Some(root))
  dis_co_layout_connectors_fire_layout_done(
    mapping,
    @core.new_elk_progress_monitor(),
  )

  let graph_on_canvas = dis_co_graph_rendering_canvas_get_layout_graph(canvas)
  inspect(@graph.node_width(expect_some_node(graph_on_canvas)), content="33")
  inspect(@graph.node_height(expect_some_node(graph_on_canvas)), content="44")

  dis_co_debug_plugin_stop(plugin)
}
