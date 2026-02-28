///|
pub let dis_co_debug_view_id : String = "org.eclipse.elk.debug.disCoDebugView"

///|
let active_dis_co_debug_view_ref : Ref[DisCoDebugView?] = Ref::new(None)

///|
pub struct DisCoDebugView {
  graph_canvas : DisCoGraphRenderingCanvas
}

///|
pub fn new_dis_co_debug_view(
  graph_canvas : DisCoGraphRenderingCanvas,
) -> DisCoDebugView {
  let view = { graph_canvas, }
  active_dis_co_debug_view_ref.val = Some(view)
  view
}

///|
pub fn dis_co_debug_view_update_with_graph(graph : @graph.ElkNode?) -> Unit {
  match (graph, dis_co_debug_view_find_view()) {
    (Some(layout_graph), Some(active_view)) =>
      dis_co_graph_rendering_canvas_set_layout_graph(
        active_view.graph_canvas,
        Some(layout_graph),
      )
    _ => ()
  }
}

///|
pub fn dis_co_debug_view_find_view() -> DisCoDebugView? {
  active_dis_co_debug_view_ref.val
}

///|
pub fn dis_co_debug_view_set_focus(_view : DisCoDebugView) -> Unit {
  ()
}

///|
pub fn dis_co_debug_view_get_canvas(
  view : DisCoDebugView,
) -> DisCoGraphRenderingCanvas {
  view.graph_canvas
}
