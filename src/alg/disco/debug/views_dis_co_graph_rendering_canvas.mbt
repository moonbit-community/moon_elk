///|
pub struct DisCoPaintEvent {
  x : Int
  y : Int
  width : Int
  height : Int
}

///|
pub suberror DisCoGraphRenderingCanvasException {
  DisCoGraphRenderingCanvasException(String)
} derive(Show, ToJson)

///|
fn dis_co_graph_rendering_canvas_raise_unit(
  message : String,
) -> Unit raise DisCoGraphRenderingCanvasException {
  raise DisCoGraphRenderingCanvasException(message)
}

///|
let _dis_co_default_paint_event : DisCoPaintEvent = {
  x: 0,
  y: 0,
  width: 0,
  height: 0,
}

///|
pub struct DisCoGraphRenderingCanvas {
  mut layout_graph : @graph.ElkNode?
  graph_renderer : DisCoGraphRenderer
  background_color : DisCoDebugColor
  display : DisCoDebugDisplay
  mut redraw_count : Int
  mut width : Int
  mut height : Int
}

///|
pub fn new_dis_co_graph_rendering_canvas(
  display : DisCoDebugDisplay,
) -> DisCoGraphRenderingCanvas {
  let configurator = new_dis_co_graph_rendering_configurator(display)
  let graph_renderer = new_dis_co_graph_renderer(configurator)
  let background_color = new_dis_co_debug_color(display, 255, 255, 255)
  {
    layout_graph: None,
    graph_renderer,
    background_color,
    display,
    redraw_count: 0,
    width: 0,
    height: 0,
  }
}

///|
pub fn new_dis_co_graph_rendering_canvas_with_configurator(
  display : DisCoDebugDisplay,
  configurator : DisCoGraphRenderingConfigurator,
) -> DisCoGraphRenderingCanvas {
  let graph_renderer = if dis_co_graph_rendering_configurator_get_display(
      configurator,
    ) !=
    display {
    try
      dis_co_graph_rendering_canvas_raise_unit(
        "configurator and parent composite must use the same display.",
      )
    catch {
      DisCoGraphRenderingCanvasException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.alg.disco.debug.views.DisCoGraphRenderingCanvas: " +
          message,
        )
    } noraise {
      _ => ()
    }
    new_dis_co_graph_renderer(new_dis_co_graph_rendering_configurator(display))
  } else {
    new_dis_co_graph_renderer(configurator)
  }
  let background_color = new_dis_co_debug_color(display, 255, 255, 255)
  {
    layout_graph: None,
    graph_renderer,
    background_color,
    display,
    redraw_count: 0,
    width: 0,
    height: 0,
  }
}

///|
pub fn dis_co_graph_rendering_canvas_dispose(
  canvas : DisCoGraphRenderingCanvas,
) -> Unit {
  dis_co_graph_renderer_dispose(canvas.graph_renderer)
  dis_co_debug_color_dispose(canvas.background_color)
}

///|
pub fn dis_co_graph_rendering_canvas_set_layout_graph(
  canvas : DisCoGraphRenderingCanvas,
  layout_graph : @graph.ElkNode?,
) -> Unit {
  if layout_graph is Some(graph) {
    let scale = dis_co_graph_renderer_get_scale(canvas.graph_renderer)
    canvas.width = ((@graph.node_width(graph) + 1.0) * scale).to_int()
    canvas.height = ((@graph.node_height(graph) + 1.0) * scale).to_int()
  }
  canvas.layout_graph = layout_graph
  dis_co_graph_rendering_canvas_redraw(canvas)
}

///|
pub fn dis_co_graph_rendering_canvas_get_layout_graph(
  canvas : DisCoGraphRenderingCanvas,
) -> @graph.ElkNode? {
  canvas.layout_graph
}

///|
pub fn dis_co_graph_rendering_canvas_get_renderer(
  canvas : DisCoGraphRenderingCanvas,
) -> DisCoGraphRenderer {
  canvas.graph_renderer
}

///|
pub fn dis_co_graph_rendering_canvas_redraw(
  canvas : DisCoGraphRenderingCanvas,
) -> Unit {
  canvas.redraw_count = canvas.redraw_count + 1
}

///|
pub fn dis_co_graph_rendering_canvas_get_redraw_count(
  canvas : DisCoGraphRenderingCanvas,
) -> Int {
  canvas.redraw_count
}

///|
pub fn dis_co_graph_rendering_canvas_get_display(
  canvas : DisCoGraphRenderingCanvas,
) -> DisCoDebugDisplay {
  canvas.display
}

///|
pub fn dis_co_graph_rendering_canvas_paint_control(
  canvas : DisCoGraphRenderingCanvas,
  event : DisCoPaintEvent,
) -> Unit {
  match canvas.layout_graph {
    Some(graph) => {
      let area = new_dis_co_paint_rectangle(
        event.x,
        event.y,
        event.width,
        event.height,
      )
      dis_co_graph_renderer_mark_dirty(canvas.graph_renderer, area)
      dis_co_graph_renderer_render(canvas.graph_renderer, graph, area)
    }
    None => ()
  }
}
