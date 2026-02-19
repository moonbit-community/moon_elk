///|
fn hypernodes_processor_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn hypernodes_processor_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn hypernodes_processor_remove_first_bendpoint(edge : LEdge) -> @core.KVector {
  let bend_points = edge.get_bend_points()
  if bend_points.is_empty() {
    abort("bend points are empty")
  }
  let points = bend_points.to_array()
  let first = points[0]
  bend_points.clear()
  let mut index = 1
  while index < points.length() {
    bend_points.add_last_vector(points[index])
    index = index + 1
  }
  first
}

///|
fn hypernodes_processor_remove_last_bendpoint(edge : LEdge) -> @core.KVector {
  let bend_points = edge.get_bend_points()
  if bend_points.is_empty() {
    abort("bend points are empty")
  }
  let points = bend_points.to_array()
  let last = points[points.length() - 1]
  bend_points.clear()
  let mut index = 0
  while index + 1 < points.length() {
    bend_points.add_last_vector(points[index])
    index = index + 1
  }
  last
}

///|
fn hypernodes_processor_remove_junction_point(
  junction_points : @core.KVectorChain,
  point : @core.KVector,
) -> Unit {
  let points = junction_points.to_array()
  junction_points.clear()
  let mut removed = false
  for candidate in points {
    if !removed && candidate.x == point.x && candidate.y == point.y {
      removed = true
    } else {
      junction_points.add_last_vector(candidate)
    }
  }
}

///|
fn hypernodes_processor_move_hypernode(
  layered_graph : LGraph,
  hypernode : LNode,
  right : Bool,
) -> Unit {
  let bend_edges : Array[LEdge] = []
  let mut bendx = 2147483647.0
  let mut diffx = 2147483647.0
  let mut diffy = 2147483647.0

  if right {
    bendx = layered_graph.get_size().x
    for port in hypernode.get_ports() {
      for edge in port.get_outgoing_edges() {
        let bend_points = edge.get_bend_points()
        if !bend_points.is_empty() {
          let first_point = bend_points.get(0)
          if first_point.x < bendx {
            diffx = bendx - first_point.x
            diffy = 2147483647.0
            bend_edges.clear()
            bendx = first_point.x
          }
          if first_point.x <= bendx {
            bend_edges.push(edge)
            if bend_points.size() > 1 {
              let second = bend_points.get(1)
              let candidate = (second.y - first_point.y).abs()
              if candidate < diffy {
                diffy = candidate
              }
            }
          }
        }
      }
    }
  } else {
    for port in hypernode.get_ports() {
      for edge in port.get_incoming_edges() {
        let bend_points = edge.get_bend_points()
        if !bend_points.is_empty() {
          let last_point = bend_points.get(bend_points.size() - 1)
          if last_point.x > bendx {
            diffx = last_point.x - bendx
            diffy = 2147483647.0
            bend_edges.clear()
            bendx = last_point.x
          }
          if last_point.x >= bendx {
            bend_edges.push(edge)
            if bend_points.size() > 1 {
              let second = bend_points.get(bend_points.size() - 2)
              let candidate = (second.y - last_point.y).abs()
              if candidate < diffy {
                diffy = candidate
              }
            }
          }
        }
      }
    }
  }

  if !bend_edges.is_empty() &&
    diffx > hypernode.get_size().x / 2.0 &&
    diffy > hypernode.get_size().y / 2.0 {
    let north_port = new_l_port()
    north_port.set_node(Some(hypernode))
    north_port.set_side(@core.PortSide::North)
    north_port.get_position().x = hypernode.get_size().x / 2.0

    let south_port = new_l_port()
    south_port.set_node(Some(hypernode))
    south_port.set_side(@core.PortSide::South)
    south_port.get_position().x = hypernode.get_size().x / 2.0
    south_port.get_position().y = hypernode.get_size().y

    for edge in bend_edges {
      if right {
        let removed_point = hypernodes_processor_remove_first_bendpoint(edge)
        let second_point = if edge.get_bend_points().is_empty() {
          hypernodes_processor_require_target(edge).get_absolute_anchor()
        } else {
          edge.get_bend_points().get(0)
        }

        if second_point.y >= removed_point.y {
          edge.set_source(Some(south_port))
        } else {
          edge.set_source(Some(north_port))
        }

        if edge.has_property_kvector_chain(layered_options_junction_points) {
          let junction_points = edge.get_property_kvector_chain(
            layered_options_junction_points,
          )
          hypernodes_processor_remove_junction_point(
            junction_points, removed_point,
          )
        }
      } else {
        let removed_point = hypernodes_processor_remove_last_bendpoint(edge)
        let second_point = if edge.get_bend_points().is_empty() {
          hypernodes_processor_require_source(edge).get_absolute_anchor()
        } else {
          edge.get_bend_points().get(edge.get_bend_points().size() - 1)
        }

        if second_point.y >= removed_point.y {
          edge.set_target(Some(south_port))
        } else {
          edge.set_target(Some(north_port))
        }

        if edge.has_property_kvector_chain(layered_options_junction_points) {
          let junction_points = edge.get_property_kvector_chain(
            layered_options_junction_points,
          )
          hypernodes_processor_remove_junction_point(
            junction_points, removed_point,
          )
        }
      }
    }

    hypernode.get_position().x = bendx - hypernode.get_size().x / 2.0
  }
}

///|
fn hypernodes_processor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Hypernodes processing", 1.0))

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if node.get_property_bool(layered_options_hypernode) &&
        node.get_ports().length() <= 2 {
        let mut top_edges = 0
        let mut right_edges = 0
        let mut bottom_edges = 0
        let mut left_edges = 0

        for port in node.get_ports() {
          match port.get_side() {
            @core.PortSide::North => top_edges = top_edges + 1
            @core.PortSide::East => right_edges = right_edges + 1
            @core.PortSide::South => bottom_edges = bottom_edges + 1
            @core.PortSide::West => left_edges = left_edges + 1
            _ => ()
          }
        }

        if top_edges == 0 && bottom_edges == 0 {
          hypernodes_processor_move_hypernode(
            layered_graph,
            node,
            left_edges <= right_edges,
          )
        }
      }
    }
  }

  monitor.done()
}

///|
pub fn new_hypernodes_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(hypernodes_processor_process)
}
