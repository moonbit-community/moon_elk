///|
pub struct DisCoPaintRectangle {
  x : Int
  y : Int
  width : Int
  height : Int
}

///|
pub fn new_dis_co_paint_rectangle(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> DisCoPaintRectangle {
  { x, y, width, height }
}

///|
pub struct DisCoGraphRenderer {
  configurator : DisCoGraphRenderingConfigurator
  scale : Double
  mut base_offset : KVector
  state : ConfigState
  visibility : Map[String, Bool]
  dirty_areas : Array[DisCoPaintRectangle]
}

///|
pub fn new_dis_co_graph_renderer(
  configurator : DisCoGraphRenderingConfigurator,
  scale? : Double = 1.0,
) -> DisCoGraphRenderer {
  dis_co_graph_rendering_configurator_initialize(configurator, scale)
  {
    configurator,
    scale,
    base_offset: new_kvector(),
    state: new_config_state(),
    visibility: { "elkgraph": true, "dcgraph": true, "polyominoes": true },
    dirty_areas: [],
  }
}

///|
pub fn dis_co_graph_renderer_dispose(renderer : DisCoGraphRenderer) -> Unit {
  dis_co_graph_rendering_configurator_dispose(renderer.configurator)
}

///|
pub fn dis_co_graph_renderer_get_base_offset(
  renderer : DisCoGraphRenderer,
) -> KVector {
  renderer.base_offset
}

///|
pub fn dis_co_graph_renderer_set_base_offset(
  renderer : DisCoGraphRenderer,
  base_offset : KVector,
) -> Unit {
  renderer.base_offset = base_offset
}

///|
pub fn dis_co_graph_renderer_mark_dirty(
  renderer : DisCoGraphRenderer,
  area : DisCoPaintRectangle,
) -> Unit {
  renderer.dirty_areas.push(area)
}

///|
fn dis_co_graph_renderer_max_depth(node : ElkNode) -> Int {
  let children = node_children(node)
  if children.is_empty() {
    0
  } else {
    let mut depth = 0
    for child in children {
      let child_depth = dis_co_graph_renderer_max_depth(child) + 1
      if child_depth > depth {
        depth = child_depth
      }
    }
    depth
  }
}

///|
pub fn dis_co_graph_renderer_render(
  renderer : DisCoGraphRenderer,
  parent_node : ElkNode,
  _area : DisCoPaintRectangle,
) -> Unit {
  let depth = dis_co_graph_renderer_max_depth(parent_node) + 1
  config_state_set_depth(renderer.state, depth)
}

///|
pub fn dis_co_graph_renderer_set_visible(
  renderer : DisCoGraphRenderer,
  command : String,
  visible : Bool,
) -> Unit {
  renderer.visibility[command] = visible
}

///|
pub fn dis_co_graph_renderer_is_visible(
  renderer : DisCoGraphRenderer,
  command : String,
) -> Bool {
  match renderer.visibility.get(command) {
    Some(value) => value
    None => true
  }
}

///|
pub fn dis_co_graph_renderer_get_scale(renderer : DisCoGraphRenderer) -> Double {
  renderer.scale
}

///|
pub fn dis_co_graph_renderer_get_state(
  renderer : DisCoGraphRenderer,
) -> ConfigState {
  renderer.state
}
