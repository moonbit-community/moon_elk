///|
let bk_layered_option_node_placement_bk_fixed_alignment : IProperty[String] = new_property(
  "org.eclipse.elk.layered.nodePlacement.bk.fixedAlignment", "NONE",
)

///|
let bk_layered_option_node_placement_favor_straight_edges : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.nodePlacement.favorStraightEdges", false,
)

///|
fn bk_node_placer_same_node(left : LNode, right : LNode) -> Bool {
  left.get_handle() == right.get_handle()
}

///|
fn bk_node_placer_node_type_is_long_edge(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn bk_node_placer_fixed_alignment_is_none(value : FixedAlignment) -> Bool {
  match value {
    FixedAlignment::NoneType => true
    _ => false
  }
}

///|
fn bk_node_placer_fixed_alignment_is_balanced(value : FixedAlignment) -> Bool {
  match value {
    FixedAlignment::Balanced => true
    _ => false
  }
}

///|
fn bk_node_placer_reverse_layers(layers : Array[Layer]) -> Array[Layer] {
  let reversed : Array[Layer] = []
  for i = layers.length() - 1; i >= 0; i = i - 1 {
    reversed.push(layers[i])
  }
  reversed
}

///|
fn bk_node_placer_parse_fixed_alignment(value : String) -> FixedAlignment {
  match value {
    "LEFTDOWN" => FixedAlignment::LeftDown
    "LEFTUP" => FixedAlignment::LeftUp
    "RIGHTDOWN" => FixedAlignment::RightDown
    "RIGHTUP" => FixedAlignment::RightUp
    "BALANCED" => FixedAlignment::Balanced
    _ => FixedAlignment::NoneType
  }
}

///|
fn bk_node_placer_favor_straight_edges(layered_graph : LGraph) -> Bool {
  if layered_graph.has_property_bool(
      bk_layered_option_node_placement_favor_straight_edges,
    ) {
    return layered_graph.get_property_bool(
      bk_layered_option_node_placement_favor_straight_edges,
    )
  }

  layered_graph.get_property_string(edge_routing) == "ORTHOGONAL"
}

///|
fn bk_node_placer_incident_to_inner_segment(
  node : LNode,
  layer1 : Int,
  layer2 : Int,
  ni : NeighborhoodInformation,
) -> Bool {
  if !bk_node_placer_node_type_is_long_edge(node.get_type()) {
    return false
  }

  for edge in node.get_incoming_edges() {
    let source_port = match edge.get_source() {
      Some(value) => value
      None => continue
    }
    let source_node = match source_port.get_node() {
      Some(value) => value
      None => continue
    }

    if bk_node_placer_node_type_is_long_edge(source_node.get_type()) {
      let source_layer = match source_node.get_layer() {
        Some(value) => value
        None => continue
      }
      let node_layer = match node.get_layer() {
        Some(value) => value
        None => continue
      }

      if ni.layer_index[source_layer.get_id()] == layer2 &&
        ni.layer_index[node_layer.get_id()] == layer1 {
        return true
      }
    }
  }

  false
}

///|
fn bk_node_placer_mark_conflicts(
  layered_graph : LGraph,
  ni : NeighborhoodInformation,
  marked_edges : Map[Int, Bool],
) -> Unit {
  let number_of_layers = layered_graph.get_layers().length()
  if number_of_layers < 3 {
    return
  }

  let layer_size : Array[Int] = []
  for layer in layered_graph.get_layers() {
    layer_size.push(layer.get_nodes().length())
  }

  let layers = layered_graph.get_layers()
  for i = 1; i < number_of_layers - 1; i = i + 1 {
    let current_layer_index = i + 1
    if current_layer_index >= layers.length() {
      break
    }

    let current_layer = layers[current_layer_index]
    let current_nodes = current_layer.get_nodes()

    let mut k_0 = 0
    let mut l = 0

    let upper_limit = if i + 1 < layer_size.length() {
      let raw_limit = layer_size[i + 1]
      if raw_limit < current_nodes.length() {
        raw_limit
      } else {
        current_nodes.length()
      }
    } else {
      current_nodes.length()
    }

    for l_1 = 0; l_1 < upper_limit; l_1 = l_1 + 1 {
      let v_l_i = current_nodes[l_1]

      if l_1 == upper_limit - 1 ||
        bk_node_placer_incident_to_inner_segment(v_l_i, i + 1, i, ni) {
        let mut k_1 = if i < layer_size.length() {
          layer_size[i] - 1
        } else {
          -1
        }

        if bk_node_placer_incident_to_inner_segment(v_l_i, i + 1, i, ni) {
          let left_neighbors = ni.left_neighbors[v_l_i.get_id()]
          if !left_neighbors.is_empty() {
            k_1 = ni.node_index[left_neighbors[0].0.get_id()]
          }
        }

        while l <= l_1 && l < current_nodes.length() {
          let v_l = current_nodes[l]
          if !bk_node_placer_incident_to_inner_segment(v_l, i + 1, i, ni) {
            for upper_neighbor in ni.left_neighbors[v_l.get_id()] {
              let k = ni.node_index[upper_neighbor.0.get_id()]
              if k < k_0 || k > k_1 {
                marked_edges[upper_neighbor.1.get_handle()] = true
              }
            }
          }
          l += 1
        }

        k_0 = k_1
      }
    }
  }
}

///|
fn bk_node_placer_create_balanced_layout(
  l_graph : LGraph,
  layouts : Array[BKAlignedLayout],
  node_count : Int,
) -> BKAlignedLayout {
  if layouts.length() < 4 {
    return layouts[0]
  }

  let no_of_layouts = layouts.length()
  let balanced = new_bk_aligned_layout(l_graph, node_count, None, None)

  let width : Array[Double] = Array::make(no_of_layouts, 0.0)
  let min_value : Array[Double] = Array::make(no_of_layouts, @double.infinity)
  let max_value : Array[Double] = Array::make(
    no_of_layouts, @double.neg_infinity,
  )
  let mut min_width_layout = 0

  for i = 0; i < no_of_layouts; i = i + 1 {
    let bal = layouts[i]
    width[i] = bal.layout_size()
    if width[i] < width[min_width_layout] {
      min_width_layout = i
    }

    for layer in l_graph.get_layers() {
      for node in layer.get_nodes() {
        let node_pos_y = bal.require_y(node) + bal.inner_shift[node.get_id()]
        if node_pos_y < min_value[i] {
          min_value[i] = node_pos_y
        }

        let node_bottom = node_pos_y + node.get_size().y
        if node_bottom > max_value[i] {
          max_value[i] = node_bottom
        }
      }
    }
  }

  let shift : Array[Double] = Array::make(no_of_layouts, 0.0)
  for i = 0; i < no_of_layouts; i = i + 1 {
    if bk_vdirection_is_down(layouts[i].require_vdir()) {
      shift[i] = min_value[min_width_layout] - min_value[i]
    } else {
      shift[i] = max_value[min_width_layout] - max_value[i]
    }
  }

  let calculated_ys : Array[Double] = Array::make(no_of_layouts, 0.0)
  for layer in l_graph.get_layers() {
    for node in layer.get_nodes() {
      for i = 0; i < no_of_layouts; i = i + 1 {
        calculated_ys[i] = layouts[i].require_y(node) +
          layouts[i].inner_shift[node.get_id()] +
          shift[i]
      }

      calculated_ys.sort()
      balanced.y[node.get_id()] = Some(
        (calculated_ys[1] + calculated_ys[2]) / 2.0,
      )
      balanced.inner_shift[node.get_id()] = 0.0
    }
  }

  balanced
}

///|
fn bk_node_placer_check_order_constraint(
  layered_graph : LGraph,
  bal : BKAlignedLayout,
  monitor : IElkProgressMonitor,
) -> Bool {
  let mut feasible = true

  for layer in layered_graph.get_layers() {
    let mut pos = @double.neg_infinity
    let mut previous : LNode? = None

    for node in layer.get_nodes() {
      let top = bal.require_y(node) +
        bal.inner_shift[node.get_id()] -
        node.get_margin().top
      let bottom = bal.require_y(node) +
        bal.inner_shift[node.get_id()] +
        node.get_size().y +
        node.get_margin().bottom

      if top > pos && bottom > pos {
        previous = Some(node)
        pos = bal.require_y(node) +
          bal.inner_shift[node.get_id()] +
          node.get_size().y +
          node.get_margin().bottom
      } else {
        feasible = false
        if monitor.is_logging_enabled() {
          let previous_text = match previous {
            Some(value) => value.to_string()
            None => "none"
          }
          monitor.log(
            "bk node placement breaks on node " +
            node.to_string() +
            " after " +
            previous_text,
          )
        }
        break
      }
    }

    if !feasible {
      break
    }
  }

  if monitor.is_logging_enabled() {
    monitor.log(bal.to_string() + " is feasible: " + feasible.to_string())
  }

  feasible
}

///|
fn bk_node_placer_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Brandes & Koepf node placement", 1.0))

  let ni = neighborhood_information_build_for(layered_graph)
  let marked_edges : Map[Int, Bool] = {}

  let fixed_alignment = bk_node_placer_parse_fixed_alignment(
    layered_graph.get_property_string(
      bk_layered_option_node_placement_bk_fixed_alignment,
    ),
  )
  let favor_straight_edges = bk_node_placer_favor_straight_edges(layered_graph)

  let produce_balanced_layout = (
      bk_node_placer_fixed_alignment_is_none(fixed_alignment) &&
      !favor_straight_edges
    ) ||
    bk_node_placer_fixed_alignment_is_balanced(fixed_alignment)

  bk_node_placer_mark_conflicts(layered_graph, ni, marked_edges)

  let layouts : Array[BKAlignedLayout] = []
  match fixed_alignment {
    FixedAlignment::LeftDown =>
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Down),
          Some(BKHDirection::Left),
        ),
      )
    FixedAlignment::LeftUp =>
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Up),
          Some(BKHDirection::Left),
        ),
      )
    FixedAlignment::RightDown =>
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Down),
          Some(BKHDirection::Right),
        ),
      )
    FixedAlignment::RightUp =>
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Up),
          Some(BKHDirection::Right),
        ),
      )
    _ => {
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Down),
          Some(BKHDirection::Right),
        ),
      )
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Up),
          Some(BKHDirection::Right),
        ),
      )
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Down),
          Some(BKHDirection::Left),
        ),
      )
      layouts.push(
        new_bk_aligned_layout(
          layered_graph,
          ni.node_count,
          Some(BKVDirection::Up),
          Some(BKHDirection::Left),
        ),
      )
    }
  }

  let aligner = new_bk_aligner(layered_graph, ni)
  for bal in layouts {
    aligner.vertical_alignment(bal, marked_edges)
    aligner.inside_block_shift(bal)
  }

  let compactor = new_bk_compactor(layered_graph, ni)
  for bal in layouts {
    compactor.horizontal_compaction(bal)
  }

  let mut chosen_layout : BKAlignedLayout? = None

  if produce_balanced_layout {
    let balanced = bk_node_placer_create_balanced_layout(
      layered_graph,
      layouts,
      ni.node_count,
    )
    if bk_node_placer_check_order_constraint(layered_graph, balanced, monitor) {
      chosen_layout = Some(balanced)
    }
  }

  if chosen_layout is None {
    for bal in layouts {
      if bk_node_placer_check_order_constraint(layered_graph, bal, monitor) {
        match chosen_layout {
          Some(current) =>
            if bal.layout_size() < current.layout_size() {
              chosen_layout = Some(bal)
            }
          None => chosen_layout = Some(bal)
        }
      }
    }
  }

  if chosen_layout is None {
    chosen_layout = Some(layouts[0])
  }

  let final_layout = match chosen_layout {
    Some(value) => value
    None => layouts[0]
  }

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      node.get_position().y = final_layout.require_y(node) +
        final_layout.inner_shift[node.get_id()]
    }
  }

  for bal in layouts {
    bal.cleanup()
  }
  ni.cleanup()
  marked_edges.clear()

  monitor.done()
}

///|
fn bk_node_placer_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  // The current MoonBit repository does not provide
  // HierarchicalPortPositionProcessor yet.
  None
}

///|
pub fn new_bk_node_placer_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(bk_node_placer_process, bk_node_placer_configuration)
}
