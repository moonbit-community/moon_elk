///|
fn dot_debug_util_escape(value : String) -> String {
  value.replace(old="\\", new="\\\\").replace(old="\"", new="\\\"")
}

///|
fn dot_debug_util_node_type_color(node_type : NodeType) -> String {
  match node_type {
    NodeType::ExternalPort => "#cc99cc"
    NodeType::LongEdge => "#eaed00"
    NodeType::NorthSouthPort => "#0034de"
    NodeType::LabelNode => "#75c3c3"
    NodeType::BreakingPoint => "#eeeeff"
    _ => "#eeeeee"
  }
}

///|
fn dot_debug_util_node_label(
  node : LNode,
  layer_number : Int,
  node_number : Int,
) -> String {
  let mut label = ""

  match node.get_designation() {
    Some(designation) => label = designation + " "
    None =>
      match node.get_type() {
        NodeType::Normal => ()
        _ => label = "n_" + node.get_id().to_string() + " "
      }
  }

  match node.get_type() {
    NodeType::NorthSouthPort =>
      match node.get_property_l_node(internal_properties_origin_l_node) {
        Some(origin_node) => label += "(" + origin_node.to_string() + ")"
        None => ()
      }
    _ => ()
  }

  label + "(" + layer_number.to_string() + "," + node_number.to_string() + ")"
}

///|
fn dot_debug_util_write_layer(
  writer : @buffer.Buffer,
  layer_number : Int,
  nodes : Array[LNode],
) -> Unit {
  if nodes.is_empty() {
    return
  }

  let mut node_number = 0
  for node in nodes {
    writer.write_string("    " + node.get_handle().to_string())

    let label = dot_debug_util_escape(
      dot_debug_util_node_label(node, layer_number, node_number),
    )

    let node_options = match node.get_type() {
      NodeType::Normal => "label=\"" + label + "\",shape=box"
      _ =>
        "label=\"" +
        label +
        "\",style=\"rounded,filled\",color=\"" +
        dot_debug_util_node_type_color(node.get_type()) +
        "\""
    }

    writer.write_string("[" + node_options + "];\n")
    node_number = node_number + 1
  }

  for node in nodes {
    for port in node.get_ports() {
      for edge in port.get_outgoing_edges() {
        match edge.get_target() {
          Some(target_port) =>
            match target_port.get_node() {
              Some(target_node) =>
                writer.write_string(
                  "    " +
                  node.get_handle().to_string() +
                  " -> " +
                  target_node.get_handle().to_string() +
                  ";\n",
                )
              None => ()
            }
          None => ()
        }
      }
    }
  }
}

///|
pub fn dot_debug_util_create_debug_graph(lgraph : LGraph) -> String {
  let writer = @buffer.new()
  writer.write_string("digraph {\n")
  writer.write_string("    rankdir=LR;\n")

  dot_debug_util_write_layer(writer, -1, lgraph.get_layerless_nodes())

  let mut layer_number = 0
  for layer in lgraph.get_layers() {
    dot_debug_util_write_layer(writer, layer_number, layer.get_nodes())
    layer_number = layer_number + 1
  }

  writer.write_string("}\n")
  writer.to_string()
}

///|
pub fn dot_debug_util_create_debug_graph_linear_segments(
  layered_graph : LGraph,
  segment_list : Array[LinearSegment],
  outgoing_list : Array[Array[LinearSegment]],
) -> String {
  ignore(layered_graph)

  let writer = @buffer.new()
  writer.write_string("digraph {\n")

  for i = 0; i < segment_list.length(); i = i + 1 {
    let segment = segment_list[i]
    let segment_id = segment.id.to_string()
    writer.write_string(
      "  " +
      segment_id +
      "[label=\"" +
      dot_debug_util_escape("segment " + segment_id) +
      "\"]\n",
    )

    let successors : Array[LinearSegment] = if i < outgoing_list.length() {
      outgoing_list[i]
    } else {
      []
    }
    for successor in successors {
      writer.write_string(
        "  " + segment_id + "->" + successor.id.to_string() + "\n",
      )
    }
  }

  writer.write_string("}\n")
  writer.to_string()
}

///|
pub fn dot_debug_util_create_debug_graph_hypernodes(
  layered_graph : LGraph,
  hypernodes : Array[HyperEdgeSegment],
) -> String {
  ignore(layered_graph)

  let writer = @buffer.new()
  writer.write_string("digraph {\n")

  for hypernode in hypernodes {
    writer.write_string(
      "  " +
      hypernode.get_handle().to_string() +
      "[label=\"" +
      dot_debug_util_escape(hypernode.to_string()) +
      "\"]\n",
    )
  }

  for hypernode in hypernodes {
    for dependency in hypernode.get_outgoing_segment_dependencies() {
      match dependency.get_target() {
        Some(target) =>
          writer.write_string(
            "  " +
            hypernode.get_handle().to_string() +
            "->" +
            target.get_handle().to_string() +
            "[label=\"" +
            dependency_type_to_string(dependency.get_type()) +
            " (" +
            dependency.get_weight().to_string() +
            ")\"]\n",
          )
        None => ()
      }
    }
  }

  writer.write_string("}\n")
  writer.to_string()
}
