///|
let selective_paint_toggle_action_id : String = "org.eclipse.elk.debug.disco.selectivepainttoggle"

///|
pub struct SelectivePaintToggleAction {
  id : String
  title : String
  tooltip : String
  canvas : DisCoGraphRenderingCanvas
  renderer : DisCoGraphRenderer
  command : String
  mut val : Bool
  mut checked : Bool
}

///|
pub fn new_selective_paint_toggle_action(
  command : String,
  title : String,
  tooltip : String,
  canvas : DisCoGraphRenderingCanvas,
) -> SelectivePaintToggleAction {
  let renderer = dis_co_graph_rendering_canvas_get_renderer(canvas)
  {
    id: selective_paint_toggle_action_id + command,
    title,
    tooltip,
    canvas,
    renderer,
    command,
    val: false,
    checked: true,
  }
}

///|
pub fn selective_paint_toggle_action_run(
  action : SelectivePaintToggleAction,
) -> Unit {
  dis_co_graph_renderer_set_visible(action.renderer, action.command, action.val)
  action.checked = action.val
  action.val = !action.val
  dis_co_graph_rendering_canvas_redraw(action.canvas)
}

///|
pub fn selective_paint_toggle_action_is_checked(
  action : SelectivePaintToggleAction,
) -> Bool {
  action.checked
}

///|
pub fn selective_paint_toggle_action_get_id(
  action : SelectivePaintToggleAction,
) -> String {
  action.id
}
