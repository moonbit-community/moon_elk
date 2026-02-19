///|
fn debug_state_equals(left : State, right : State) -> Bool {
  match (left, right) {
    (Lower, Lower) => true
    (Upper, Upper) => true
    (Depth, Depth) => true
    _ => false
  }
}

///|
pub struct DropdownIntRangeAction {
  mut menu : Array[Int]?
  lb : Int
  mut ub : Int
  label : String
  bound : State
  state : ConfigState
  mut canvas : DisCoGraphRenderingCanvas
  mut text : String
}

///|
pub fn new_dropdown_int_range_action(
  observable : ConfigState,
  label : String,
  low : Int,
  high : Int,
  initial : Int,
  bound : State,
  canvas : DisCoGraphRenderingCanvas,
) -> DropdownIntRangeAction {
  let action : DropdownIntRangeAction = {
    menu: None,
    lb: low,
    ub: high,
    label,
    bound,
    state: observable,
    canvas,
    text: label + initial.to_string(),
  }
  config_state_add_observer(observable, arg => {
    dropdown_int_range_action_update(action, arg)
  })
  action
}

///|
pub fn dropdown_int_range_action_dispose(
  action : DropdownIntRangeAction,
) -> Unit {
  action.menu = None
}

///|
pub fn dropdown_int_range_action_get_menu(
  action : DropdownIntRangeAction,
) -> Array[Int] {
  let options : Array[Int] = []
  let mut value = action.lb
  while value <= action.ub {
    options.push(value)
    value = value + 1
  }
  action.menu = Some(options)
  options
}

///|
fn dropdown_int_range_action_update_label(
  action : DropdownIntRangeAction,
  add : String,
) -> Unit {
  action.text = action.label + add
}

///|
pub fn dropdown_int_range_action_update(
  action : DropdownIntRangeAction,
  arg : State,
) -> Unit {
  if debug_state_equals(arg, Lower) && debug_state_equals(action.bound, Lower) {
    dropdown_int_range_action_update_label(
      action,
      config_state_get_lower_lvl(action.state).to_string(),
    )
  } else if debug_state_equals(arg, Upper) &&
    debug_state_equals(action.bound, Upper) {
    dropdown_int_range_action_update_label(
      action,
      config_state_get_upper_lvl(action.state).to_string(),
    )
  } else if debug_state_equals(arg, Depth) {
    match config_state_get_max_depth(action.state) {
      Some(depth) => action.ub = depth - 1
      None => ()
    }
  }
}

///|
pub fn dropdown_int_range_action_apply_num(
  action : DropdownIntRangeAction,
  num : Int,
) -> Unit {
  dropdown_int_range_action_update_label(action, num.to_string())
  if debug_state_equals(action.bound, Lower) {
    config_state_set_low(action.state, num)
  } else {
    config_state_set_high(action.state, num)
  }
  dis_co_graph_rendering_canvas_redraw(action.canvas)
}

///|
pub fn dropdown_int_range_action_get_text(
  action : DropdownIntRangeAction,
) -> String {
  action.text
}

///|
pub fn dropdown_int_range_action_set_canvas(
  action : DropdownIntRangeAction,
  canvas : DisCoGraphRenderingCanvas,
) -> Unit {
  action.canvas = canvas
}
