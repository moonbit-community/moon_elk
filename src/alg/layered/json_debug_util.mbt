///|
fn json_debug_util_escape(value : String) -> String {
  value
  .replace(old="\\", new="\\\\")
  .replace(old="\"", new="\\\"")
  .replace(old="\n", new="\\n")
}

///|
fn json_debug_util_node_id(node : LNode) -> String {
  "n" + node.get_handle().to_string()
}

///|
fn json_debug_util_calculate_min_max_positions(
  min : @core.KVector,
  max : @core.KVector,
  node : LNode,
) -> Unit {
  min.x = @math.minimum(min.x, node.get_position().x - node.get_margin().left)
  max.x = @math.maximum(
    max.x,
    node.get_position().x + node.get_size().x + node.get_margin().right,
  )
  min.y = @math.minimum(min.y, node.get_position().y - node.get_margin().top)
  max.y = @math.maximum(
    max.y,
    node.get_position().y + node.get_size().y + node.get_margin().bottom,
  )

  for port in node.get_ports() {
    min.x = @math.minimum(
      min.x,
      node.get_position().x + port.get_position().x - port.get_margin().left,
    )
    max.x = @math.maximum(
      max.x,
      node.get_position().x +
      port.get_position().x +
      port.get_size().x +
      port.get_margin().right,
    )
    min.y = @math.minimum(
      min.y,
      node.get_position().y + port.get_position().y - port.get_margin().top,
    )
    max.y = @math.maximum(
      max.y,
      node.get_position().y +
      port.get_position().y +
      port.get_size().y +
      port.get_margin().bottom,
    )
  }

  for edge in node.get_outgoing_edges() {
    for bendpoint in edge.get_bend_points().to_array() {
      min.x = @math.minimum(min.x, bendpoint.x)
      max.x = @math.maximum(max.x, bendpoint.x)
      min.y = @math.minimum(min.y, bendpoint.y)
      max.y = @math.maximum(max.y, bendpoint.y)
    }
  }
}

///|
fn json_debug_util_calculate_graph_size(lgraph : LGraph) -> (@core.KVector, @core.KVector) {
  let min = @core.new_kvector()
  let max = @core.new_kvector()

  for node in lgraph.get_layerless_nodes() {
    json_debug_util_calculate_min_max_positions(min, max, node)
  }
  for layer in lgraph.get_layers() {
    for node in layer.get_nodes() {
      json_debug_util_calculate_min_max_positions(min, max, node)
    }
  }

  max.x = max.x - min.x
  max.y = max.y - min.y
  (min, max)
}

///|
fn json_debug_util_node_label(
  node : LNode,
  layer_number : Int,
  node_number : Int,
) -> String {
  let mut label = match node.get_designation() {
    Some(designation) => designation
    None =>
      match node.get_type() {
        NodeType::Normal => "NORMAL"
        NodeType::LongEdge => "LONG_EDGE"
        NodeType::ExternalPort => "EXTERNAL_PORT"
        NodeType::NorthSouthPort => "NORTH_SOUTH_PORT"
        NodeType::LabelNode => "LABEL"
        NodeType::BreakingPoint => "BREAKING_POINT"
        NodeType::Placeholder => "PLACEHOLDER"
        NodeType::NonshiftingPlaceholder => "NONSHIFTING_PLACEHOLDER"
      }
  }
  label += " (" + layer_number.to_string() + "," + node_number.to_string() + ")"
  json_debug_util_escape(label)
}

///|
fn json_debug_util_append_edge_entries(
  node : LNode,
  edge_entries : Array[String],
  edge_counter : Ref[Int],
) -> Unit {
  for port in node.get_ports() {
    for edge in port.get_outgoing_edges() {
      match (edge.get_source(), edge.get_target()) {
        (Some(source_port), Some(target_port)) =>
          match (source_port.get_node(), target_port.get_node()) {
            (Some(source_node), Some(target_node)) => {
              let edge_id = edge_counter.val
              edge_counter.val = edge_counter.val + 1
              edge_entries.push(
                "    {\n" +
                "      \"id\": \"e" +
                edge_id.to_string() +
                "\",\n" +
                "      \"source\": \"" +
                json_debug_util_node_id(source_node) +
                "\",\n" +
                "      \"target\": \"" +
                json_debug_util_node_id(target_node) +
                "\"\n" +
                "    }",
              )
            }
            _ => ()
          }
        _ => ()
      }
    }
  }
}

///|
fn json_debug_util_append_layer_nodes(
  node_entries : Array[String],
  edge_entries : Array[String],
  edge_counter : Ref[Int],
  layer_number : Int,
  nodes : Array[LNode],
  offset : @core.KVector,
) -> Unit {
  let mut node_number = 0
  for node in nodes {
    node_entries.push(
      "    {\n" +
      "      \"id\": \"" +
      json_debug_util_node_id(node) +
      "\",\n" +
      "      \"x\": " +
      (node.get_position().x + offset.x).to_string() +
      ",\n" +
      "      \"y\": " +
      (node.get_position().y + offset.y).to_string() +
      ",\n" +
      "      \"width\": " +
      node.get_size().x.to_string() +
      ",\n" +
      "      \"height\": " +
      node.get_size().y.to_string() +
      ",\n" +
      "      \"labels\": [ { \"text\": \"" +
      json_debug_util_node_label(node, layer_number, node_number) +
      "\" } ]\n" +
      "    }",
    )

    json_debug_util_append_edge_entries(node, edge_entries, edge_counter)
    node_number = node_number + 1
  }
}

///|
fn json_debug_util_join_entries(entries : Array[String]) -> String {
  if entries.is_empty() {
    ""
  } else {
    "\n" + entries.join(",\n") + "\n  "
  }
}

///|
pub fn json_debug_util_create_debug_graph(lgraph : LGraph) -> String {
  let (min, max_size) = json_debug_util_calculate_graph_size(lgraph)
  let offset = @core.new_kvector_copy(lgraph.get_offset()).add_xy(
    lgraph.get_padding().left,
    lgraph.get_padding().top,
  )

  let node_entries : Array[String] = []
  let edge_entries : Array[String] = []
  let edge_counter : Ref[Int] = Ref::new(0)

  json_debug_util_append_layer_nodes(
    node_entries,
    edge_entries,
    edge_counter,
    -1,
    lgraph.get_layerless_nodes(),
    offset,
  )

  let mut layer_number = 0
  for layer in lgraph.get_layers() {
    json_debug_util_append_layer_nodes(
      node_entries,
      edge_entries,
      edge_counter,
      layer_number,
      layer.get_nodes(),
      offset,
    )
    layer_number = layer_number + 1
  }

  "{\n" +
  "  \"id\": \"root\",\n" +
  "  \"x\": " +
  min.x.to_string() +
  ",\n" +
  "  \"y\": " +
  min.y.to_string() +
  ",\n" +
  "  \"width\": " +
  max_size.x.to_string() +
  ",\n" +
  "  \"height\": " +
  max_size.y.to_string() +
  ",\n" +
  "  \"children\": [" +
  json_debug_util_join_entries(node_entries) +
  "],\n" +
  "  \"edges\": [" +
  json_debug_util_join_entries(edge_entries) +
  "]\n" +
  "}\n"
}

///|
pub fn json_debug_util_create_debug_graph_linear_segments(
  layered_graph : LGraph,
  segment_list : Array[LinearSegment],
  outgoing_list : Array[Array[LinearSegment]],
) -> String {
  let (min, max_size) = json_debug_util_calculate_graph_size(layered_graph)

  let node_entries : Array[String] = []
  let edge_entries : Array[String] = []
  let mut edge_id = 0

  for i = 0; i < segment_list.length(); i = i + 1 {
    let segment = segment_list[i]
    let segment_id = segment.id.to_string()

    node_entries.push(
      "    {\n" +
      "      \"id\": \"n" +
      segment_id +
      "\",\n" +
      "      \"labels\": [ { \"text\": \"segment " +
      segment_id +
      "\" } ],\n" +
      "      \"width\": 50,\n" +
      "      \"height\": 25\n" +
      "    }",
    )

    let successors : Array[LinearSegment] = if i < outgoing_list.length() {
      outgoing_list[i]
    } else {
      []
    }
    for successor in successors {
      edge_entries.push(
        "    {\n" +
        "      \"id\": \"e" +
        edge_id.to_string() +
        "\",\n" +
        "      \"source\": \"n" +
        segment_id +
        "\",\n" +
        "      \"target\": \"n" +
        successor.id.to_string() +
        "\"\n" +
        "    }",
      )
      edge_id = edge_id + 1
    }
  }

  "{\n" +
  "  \"id\": \"root\",\n" +
  "  \"x\": " +
  min.x.to_string() +
  ",\n" +
  "  \"y\": " +
  min.y.to_string() +
  ",\n" +
  "  \"width\": " +
  max_size.x.to_string() +
  ",\n" +
  "  \"height\": " +
  max_size.y.to_string() +
  ",\n" +
  "  \"children\": [" +
  json_debug_util_join_entries(node_entries) +
  "],\n" +
  "  \"edges\": [" +
  json_debug_util_join_entries(edge_entries) +
  "]\n" +
  "}\n"
}

///|
pub fn json_debug_util_create_debug_graph_hypernodes(
  layered_graph : LGraph,
  hypernodes : Array[HyperEdgeSegment],
) -> String {
  let (min, max_size) = json_debug_util_calculate_graph_size(layered_graph)
  let node_entries : Array[String] = []
  let edge_entries : Array[String] = []
  let mut edge_id = 0

  for hypernode in hypernodes {
    node_entries.push(
      "    {\n" +
      "      \"id\": \"n" +
      hypernode.get_handle().to_string() +
      "\",\n" +
      "      \"labels\": [ { \"text\": \"" +
      json_debug_util_escape(hypernode.to_string()) +
      "\" } ],\n" +
      "      \"width\": 50,\n" +
      "      \"height\": 25\n" +
      "    }",
    )

    for dependency in hypernode.get_outgoing_segment_dependencies() {
      match dependency.get_target() {
        Some(target) => {
          edge_entries.push(
            "    {\n" +
            "      \"id\": \"e" +
            edge_id.to_string() +
            "\",\n" +
            "      \"source\": \"n" +
            hypernode.get_handle().to_string() +
            "\",\n" +
            "      \"target\": \"n" +
            target.get_handle().to_string() +
            "\"\n" +
            "    }",
          )
          edge_id = edge_id + 1
        }
        None => ()
      }
    }
  }

  "{\n" +
  "  \"id\": \"root\",\n" +
  "  \"x\": " +
  min.x.to_string() +
  ",\n" +
  "  \"y\": " +
  min.y.to_string() +
  ",\n" +
  "  \"width\": " +
  max_size.x.to_string() +
  ",\n" +
  "  \"height\": " +
  max_size.y.to_string() +
  ",\n" +
  "  \"children\": [" +
  json_debug_util_join_entries(node_entries) +
  "],\n" +
  "  \"edges\": [" +
  json_debug_util_join_entries(edge_entries) +
  "]\n" +
  "}\n"
}
