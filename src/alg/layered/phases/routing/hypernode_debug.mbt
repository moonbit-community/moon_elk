///|
fn hypernode_debug_escape(value : String) -> String {
  value
  .replace(old="\\", new="\\\\")
  .replace(old="\"", new="\\\"")
  .replace(old="\n", new="\\n")
}

///|
fn hypernode_debug_join_entries(entries : Array[String]) -> String {
  if entries.is_empty() {
    ""
  } else {
    "\n" + entries.join(",\n") + "\n  "
  }
}

///|
pub fn dot_debug_util_create_debug_graph_hypernodes(
  layered_graph : @runtime.LGraph,
  hypernodes : Array[HyperEdgeSegment],
) -> String {
  ignore(layered_graph)
  let writer = StringBuilder()
  writer.write_string("digraph {\n")
  for hypernode in hypernodes {
    writer.write_string(
      "  " +
      hypernode.get_handle().to_string() +
      "[label=\"" +
      hypernode_debug_escape(hypernode.to_string()) +
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

///|
pub fn json_debug_util_create_debug_graph_hypernodes(
  layered_graph : @runtime.LGraph,
  hypernodes : Array[HyperEdgeSegment],
) -> String {
  ignore(layered_graph)
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
      hypernode_debug_escape(hypernode.to_string()) +
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
  "  \"children\": [" +
  hypernode_debug_join_entries(node_entries) +
  "],\n" +
  "  \"edges\": [" +
  hypernode_debug_join_entries(edge_entries) +
  "]\n" +
  "}\n"
}

///|
pub fn debug_util_log_debug_graph_hypernodes(
  monitor : @core.IElkProgressMonitor,
  layered_graph : @runtime.LGraph,
  layer_index : Int,
  hypernodes : Array[HyperEdgeSegment],
  debug_prefix : String,
  label : String,
) -> Unit {
  ignore(layer_index)
  let tag = debug_prefix + " - " + label
  ignore(
    dot_debug_util_create_debug_graph_hypernodes(layered_graph, hypernodes),
  )
  ignore(
    json_debug_util_create_debug_graph_hypernodes(layered_graph, hypernodes),
  )
  monitor.log_graph(tag + " [dot]")
  monitor.log_graph(tag + " [json]")
}
