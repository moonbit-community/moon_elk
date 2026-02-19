///|
pub type ConfigStateObserver = (State) -> Unit

///|
pub struct ConfigState {
  mut lower_lvl : Int
  mut upper_lvl : Int
  mut max_depth : Int?
  observers : Array[ConfigStateObserver]
}

///|
let config_state_scale : Double = 1.0

///|
let config_state_ghost_parent : Bool = false

///|
let config_state_grid : BaseGridVisibility = Simple

///|
let config_state_mark_center : Bool = false

///|
let config_state_draw_polylines_black : Bool = false

///|
let config_state_draw_labels_enabled : Bool = true

///|
let config_state_make_patterns_solid : Bool = false

///|
let config_state_line_thickness_scale : Double = 1.0

///|
let config_state_pattern_scale : Int = 1

///|
let config_state_remove_level_number : Bool = false

///|
pub fn new_config_state() -> ConfigState {
  { lower_lvl: 0, upper_lvl: 0, max_depth: None, observers: [] }
}

///|
pub fn config_state_add_observer(
  config : ConfigState,
  observer : ConfigStateObserver,
) -> Unit {
  config.observers.push(observer)
}

///|
fn config_state_notify(config : ConfigState, state : State) -> Unit {
  for observer in config.observers {
    observer(state)
  }
}

///|
pub fn config_state_set_low(config : ConfigState, low : Int) -> Unit {
  config.lower_lvl = low
  config_state_notify(config, Lower)
  if config.lower_lvl > config.upper_lvl {
    config.upper_lvl = config.lower_lvl
    config_state_notify(config, Upper)
  }
}

///|
pub fn config_state_set_high(config : ConfigState, high : Int) -> Unit {
  config.upper_lvl = high
  config_state_notify(config, Upper)
  if config.lower_lvl > config.upper_lvl {
    config.lower_lvl = config.upper_lvl
    config_state_notify(config, Lower)
  }
}

///|
pub fn config_state_set_depth(config : ConfigState, depth : Int) -> Unit {
  config.max_depth = Some(depth)
  config_state_notify(config, Depth)
}

///|
pub fn config_state_get_lower_lvl(config : ConfigState) -> Int {
  config.lower_lvl
}

///|
pub fn config_state_get_upper_lvl(config : ConfigState) -> Int {
  config.upper_lvl
}

///|
pub fn config_state_get_max_depth(config : ConfigState) -> Int? {
  config.max_depth
}

///|
pub fn config_state_get_scale(_config : ConfigState) -> Double {
  config_state_scale
}

///|
pub fn config_state_paint_parent_transparently(config : ConfigState) -> Bool {
  config_state_draw_ghost_parent(config)
}

///|
pub fn config_state_how_to_paint_grid(
  _config : ConfigState,
) -> BaseGridVisibility {
  config_state_grid
}

///|
pub fn config_state_mark_the_center(_config : ConfigState) -> Bool {
  config_state_mark_center
}

///|
pub fn config_state_draw_poly_lines_black(_config : ConfigState) -> Bool {
  config_state_draw_polylines_black
}

///|
pub fn config_state_draw_labels(_config : ConfigState) -> Bool {
  config_state_draw_labels_enabled
}

///|
pub fn config_state_make_solid(_config : ConfigState) -> Bool {
  config_state_make_patterns_solid
}

///|
pub fn config_state_get_thickness_scale(_config : ConfigState) -> Double {
  config_state_line_thickness_scale
}

///|
pub fn config_state_get_pattern_scale(_config : ConfigState) -> Int {
  config_state_pattern_scale
}

///|
pub fn config_state_draw_ghost_parent(_config : ConfigState) -> Bool {
  config_state_ghost_parent
}

///|
pub fn config_state_remove_lvl(_config : ConfigState) -> Bool {
  config_state_remove_level_number
}
