///|
pub let dis_co_debug_plugin_id : String = "org.eclipse.elk.alg.disco.debug"

///|
pub struct DisCoLayoutMapping {
  layout_graph : ElkNode?
}

///|
pub fn new_dis_co_layout_mapping(layout_graph : ElkNode?) -> DisCoLayoutMapping {
  { layout_graph, }
}

///|
pub fn dis_co_layout_mapping_get_layout_graph(
  mapping : DisCoLayoutMapping,
) -> ElkNode? {
  mapping.layout_graph
}

///|
pub struct DisCoLayoutListener {
  id : Int
  layout_about_to_start : (DisCoLayoutMapping, IElkProgressMonitor) -> Unit
  layout_done : (DisCoLayoutMapping, IElkProgressMonitor) -> Unit
}

///|
let dis_co_layout_listener_id_ref : Ref[Int] = Ref::new(0)

///|
let dis_co_layout_listeners_ref : Ref[Array[DisCoLayoutListener]] = Ref::new([])

///|
pub fn new_dis_co_layout_listener(
  layout_about_to_start : (DisCoLayoutMapping, IElkProgressMonitor) -> Unit,
  layout_done : (DisCoLayoutMapping, IElkProgressMonitor) -> Unit,
) -> DisCoLayoutListener {
  dis_co_layout_listener_id_ref.val = dis_co_layout_listener_id_ref.val + 1
  { id: dis_co_layout_listener_id_ref.val, layout_about_to_start, layout_done }
}

///|
pub fn dis_co_layout_connectors_add_layout_listener(
  listener : DisCoLayoutListener,
) -> Unit {
  dis_co_layout_listeners_ref.val.push(listener)
}

///|
pub fn dis_co_layout_connectors_remove_layout_listener(
  listener : DisCoLayoutListener,
) -> Unit {
  let mut index = 0
  while index < dis_co_layout_listeners_ref.val.length() {
    if dis_co_layout_listeners_ref.val[index].id == listener.id {
      ignore(dis_co_layout_listeners_ref.val.remove(index))
      return
    }
    index = index + 1
  }
}

///|
pub fn dis_co_layout_connectors_fire_layout_done(
  mapping : DisCoLayoutMapping,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  for listener in dis_co_layout_listeners_ref.val {
    (listener.layout_done)(mapping, progress_monitor)
  }
}

///|
pub struct DisCoDebugPlugin {
  layout_listener : DisCoLayoutListener
}

///|
let dis_co_debug_plugin_ref : Ref[DisCoDebugPlugin?] = Ref::new(None)

///|
pub fn new_dis_co_debug_plugin() -> DisCoDebugPlugin {
  let layout_listener = new_dis_co_layout_listener(
    (_mapping, _progress_monitor) => (),
    (mapping, _progress_monitor) => {
      dis_co_debug_view_update_with_graph(
        dis_co_layout_mapping_get_layout_graph(mapping),
      )
    },
  )
  { layout_listener, }
}

///|
pub fn dis_co_debug_plugin_start(plugin : DisCoDebugPlugin) -> Unit {
  dis_co_debug_plugin_ref.val = Some(plugin)
  dis_co_layout_connectors_add_layout_listener(plugin.layout_listener)
}

///|
pub fn dis_co_debug_plugin_stop(plugin : DisCoDebugPlugin) -> Unit {
  dis_co_debug_plugin_ref.val = None
  dis_co_layout_connectors_remove_layout_listener(plugin.layout_listener)
}

///|
pub fn dis_co_debug_plugin_get_default() -> DisCoDebugPlugin? {
  dis_co_debug_plugin_ref.val
}
