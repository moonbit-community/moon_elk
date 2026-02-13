///|
fn layer_size_and_graph_height_calculator_is_external_port(
  node : LNode,
) -> Bool {
  match node.get_type() {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn layer_size_and_graph_height_calculator_process(
  layered_graph : LGraph,
  monitor : IElkProgressMonitor?,
) -> Unit {
  let progress = match monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(progress.begin("Layer size calculation", 1.0))

  let mut min_y = @double.infinity
  let mut max_y = -@double.infinity
  let mut found_nodes = false

  let additional_port_spacing = layered_graph.get_property_elk_margin(
    layered_options_spacing_ports_surrounding,
  )

  for layer in layered_graph.get_layers() {
    let layer_size = layer.get_size()
    layer_size.x = 0.0
    layer_size.y = 0.0

    let nodes = layer.get_nodes()
    if nodes.is_empty() {
      continue
    }

    found_nodes = true

    for node in nodes {
      let node_size = node.get_size()
      let node_margin = node.get_margin()

      let width = node_size.x + node_margin.left + node_margin.right
      if width > layer_size.x {
        layer_size.x = width
      }
    }

    let first_node = nodes[0]
    let mut top = first_node.get_position().y - first_node.get_margin().top
    if layer_size_and_graph_height_calculator_is_external_port(first_node) {
      top = top - additional_port_spacing.top
    }

    let last_node = nodes[nodes.length() - 1]
    let mut bottom = last_node.get_position().y +
      last_node.get_size().y +
      last_node.get_margin().bottom
    if layer_size_and_graph_height_calculator_is_external_port(last_node) {
      bottom = bottom + additional_port_spacing.bottom
    }

    layer_size.y = bottom - top

    if top < min_y {
      min_y = top
    }
    if bottom > max_y {
      max_y = bottom
    }
  }

  if !found_nodes {
    min_y = 0.0
    max_y = 0.0
  }

  layered_graph.get_size().y = max_y - min_y
  layered_graph.get_offset().y = layered_graph.get_offset().y - min_y

  progress.done()
}

///|
pub fn new_layer_size_and_graph_height_calculator_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(layer_size_and_graph_height_calculator_process)
}
