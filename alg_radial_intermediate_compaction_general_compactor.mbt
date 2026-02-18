///|
fn radial_compact(graph : ElkNode) -> Unit {
  let compactor = radial_compaction_strategy_create(
    radial_graph_compaction_strategy(graph),
  )
  compactor.compact(graph)
}

///|
pub fn new_radial_general_compactor_layout_processor() -> ILayoutProcessor[
  RadialLayoutPhases,
  ElkNode,
] {
  new_layout_processor((graph, progress_monitor) => {
    match progress_monitor {
      Some(monitor) => ignore(monitor.begin("General Compactor", 1.0))
      None => ()
    }
    radial_compact(graph)
    match progress_monitor {
      Some(monitor) => monitor.done()
      None => ()
    }
  })
}
