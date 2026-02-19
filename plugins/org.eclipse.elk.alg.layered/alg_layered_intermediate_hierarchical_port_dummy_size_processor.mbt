///|
fn hierarchical_port_dummy_size_processor_set_widths(
  nodes : Array[LNode],
  top_down : Bool,
  delta : Double,
) -> Unit {
  let mut current_width = 0.0
  let mut step = delta

  if !top_down {
    current_width = delta * (nodes.length() - 1).to_double()
    step = -step
  }

  for node in nodes {
    node.set_property_string(alignment, alignment_to_string(Center))
    node.get_size().x = current_width

    for port in node.get_ports_by_side(East) {
      port.get_position().x = current_width
    }

    current_width += step
  }
}

///|
fn hierarchical_port_dummy_size_processor_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Hierarchical port dummy size processing", 1.0))

  let edge_spacing = graph.get_property_double(
    layered_options_spacing_edge_edge_between_layers,
  )
  let delta = edge_spacing * 2.0
  let northern_dummies = []
  let southern_dummies = []

  for layer in graph.get_layers() {
    northern_dummies.clear()
    southern_dummies.clear()

    for node in layer.get_nodes() {
      match node.get_type() {
        ExternalPort => {
          let side = node.get_property_port_side(
            internal_properties_ext_port_side,
          )
          match side {
            North => northern_dummies.push(node)
            South => southern_dummies.push(node)
            _ => ()
          }
        }
        _ => ()
      }
    }

    hierarchical_port_dummy_size_processor_set_widths(
      northern_dummies, true, delta,
    )
    hierarchical_port_dummy_size_processor_set_widths(
      southern_dummies, false, delta,
    )
  }

  monitor.done()
}

///|
pub fn new_hierarchical_port_dummy_size_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(hierarchical_port_dummy_size_processor_process)
}
