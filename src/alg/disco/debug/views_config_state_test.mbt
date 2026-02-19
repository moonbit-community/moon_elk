///|
fn expect_some_int(value : Int?) -> Int {
  match value {
    Some(v) => v
    None => abort("Expected Some(Int)")
  }
}

///|
test "ConfigState updates bounds and notifies in Java order" {
  let config = new_config_state()
  let events : Array[String] = []
  config_state_add_observer(config, state => {
    events.push(dis_co_debug_state_to_string(state))
  })

  config_state_set_low(config, 2)
  inspect(events, content="[\"LOWER\", \"UPPER\"]")
  assert_eq(config_state_get_lower_lvl(config), 2)
  assert_eq(config_state_get_upper_lvl(config), 2)

  events.clear()
  config_state_set_high(config, 1)
  inspect(events, content="[\"UPPER\", \"LOWER\"]")
  assert_eq(config_state_get_lower_lvl(config), 1)
  assert_eq(config_state_get_upper_lvl(config), 1)

  events.clear()
  config_state_set_depth(config, 5)
  inspect(events, content="[\"DEPTH\"]")
  assert_eq(expect_some_int(config_state_get_max_depth(config)), 5)
}

///|
test "ConfigState constants mirror Java defaults" {
  let config = new_config_state()
  inspect(config_state_get_scale(config), content="1")
  inspect(config_state_paint_parent_transparently(config), content="false")
  inspect(
    base_grid_visibility_to_string(config_state_how_to_paint_grid(config)),
    content="SIMPLE",
  )
  inspect(config_state_mark_the_center(config), content="false")
  inspect(config_state_draw_poly_lines_black(config), content="false")
  inspect(config_state_draw_labels(config), content="true")
  inspect(config_state_make_solid(config), content="false")
  inspect(config_state_get_thickness_scale(config), content="1")
  inspect(config_state_get_pattern_scale(config), content="1")
  inspect(config_state_draw_ghost_parent(config), content="false")
  inspect(config_state_remove_lvl(config), content="false")
}
