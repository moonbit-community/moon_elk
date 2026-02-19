///|
fn simple_node_placer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Simple node placement", 1.0))

  let spacings = new_layered_spacings(layered_graph)

  let mut max_height = 0.0
  for layer in layered_graph.get_layers() {
    let layer_size = layer.get_size()
    layer_size.y = 0.0
    let mut last_node : LNode? = None
    for node in layer.get_nodes() {
      match last_node {
        Some(previous) =>
          layer_size.y += spacings.get_vertical_spacing(node, previous)
        None => ()
      }
      let margin = node.get_margin()
      layer_size.y += margin.top + node.get_size().y + margin.bottom
      last_node = Some(node)
    }
    if layer_size.y > max_height {
      max_height = layer_size.y
    }
  }

  for layer in layered_graph.get_layers() {
    let layer_size = layer.get_size()
    let mut pos = (max_height - layer_size.y) / 2.0
    let mut last_node : LNode? = None
    for node in layer.get_nodes() {
      match last_node {
        Some(previous) => pos += spacings.get_vertical_spacing(node, previous)
        None => ()
      }
      let margin = node.get_margin()
      pos += margin.top
      node.get_position().y = pos
      pos += node.get_size().y + margin.bottom
      last_node = Some(node)
    }
  }

  monitor.done()
}

///|
pub fn new_simple_node_placer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(simple_node_placer_process, graph => {
    for
      property in graph.get_property_graph_properties_array(
        internal_properties_graph_properties,
      ) {
      match property {
        GraphProperties::ExternalPorts =>
          return Some(
            @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
              LayeredPhases::P5EdgeRouting,
              layered_intermediate_processor_factory(
                IntermediateProcessorStrategy::HierarchicalPortPositionProcessor,
              ),
            ),
          )
        _ => ()
      }
    }
    None
  })
}
