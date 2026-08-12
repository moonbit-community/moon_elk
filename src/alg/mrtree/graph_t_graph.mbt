///|
pub struct MrtreeGraph {
  priv mut data : MrtreeGraphData
}

///|
pub impl Eq for MrtreeGraph with fn equal(self, other) {
  physical_equal(self, other)
}

///|
priv struct MrtreeGraphData {
  nodes : Array[MrtreeNode]
  edges : Array[MrtreeEdge]
  mut origin : @graph.ElkNode?
  mut separate_connected_components : Bool
  mut direction : String
  mut compaction : Bool
  mut edge_routing_mode : String
  mut weighting : String
  mut search_order : String
  mut removable_edges : Array[MrtreeEdge]
  mut spacing_node_node : Double
  mut spacing_edge_node : Double
  mut edge_end_texture_length : Double
  mut aspect_ratio : Double
  mut padding : @core.ElkPadding
  mut priority : Int
  mut bb_up_left : @core.KVector
  mut bb_low_right : @core.KVector
  mut graph_xmin : Double
  mut graph_ymin : Double
  mut graph_xmax : Double
  mut graph_ymax : Double
}

///|
fn set_mrtree_graph_data(graph : MrtreeGraph, data : MrtreeGraphData) -> Unit {
  graph.data = data
}

///|
fn mrtree_parse_padding(text : String) -> @core.ElkPadding raise {
  let padding_value = @core.new_elk_padding()
  padding_value.parse(text)
  padding_value
}

///|
pub fn new_mrtree_graph() -> MrtreeGraph {
  {
    data: {
      nodes: [],
      edges: [],
      origin: None,
      separate_connected_components: true,
      direction: "UNDEFINED",
      compaction: false,
      edge_routing_mode: "AVOID_OVERLAP",
      weighting: "FAN",
      search_order: "DFS",
      removable_edges: [],
      spacing_node_node: 20.0,
      spacing_edge_node: 3.0,
      edge_end_texture_length: 7.0,
      aspect_ratio: 1.6,
      padding: @core.new_elk_padding_any(20.0),
      priority: 0,
      bb_up_left: @core.new_kvector(),
      bb_low_right: @core.new_kvector(),
      graph_xmin: 0.0,
      graph_ymin: 0.0,
      graph_xmax: 0.0,
      graph_ymax: 0.0,
    },
  }
}

///|
pub fn mrtree_graph_copy_properties(
  target : MrtreeGraph,
  source : MrtreeGraph,
) -> Unit {
  let target_data = target.data
  let source_data = source.data
  target_data.origin = source_data.origin
  target_data.separate_connected_components = source_data.separate_connected_components
  target_data.direction = source_data.direction
  target_data.compaction = source_data.compaction
  target_data.edge_routing_mode = source_data.edge_routing_mode
  target_data.weighting = source_data.weighting
  target_data.search_order = source_data.search_order
  target_data.removable_edges = source_data.removable_edges.copy()
  target_data.spacing_node_node = source_data.spacing_node_node
  target_data.spacing_edge_node = source_data.spacing_edge_node
  target_data.edge_end_texture_length = source_data.edge_end_texture_length
  target_data.aspect_ratio = source_data.aspect_ratio
  target_data.padding = source_data.padding.clone()
  target_data.priority = source_data.priority
  target_data.bb_up_left = source_data.bb_up_left.clone()
  target_data.bb_low_right = source_data.bb_low_right.clone()
  target_data.graph_xmin = source_data.graph_xmin
  target_data.graph_ymin = source_data.graph_ymin
  target_data.graph_xmax = source_data.graph_xmax
  target_data.graph_ymax = source_data.graph_ymax
  set_mrtree_graph_data(target, target_data)
}

///|
pub fn mrtree_graph_copy_properties_from_elk(
  graph : MrtreeGraph,
  elk_graph : @graph.ElkNode,
) -> Unit raise {
  let graph_data = graph.data
  graph_data.origin = Some(elk_graph)
  graph_data.separate_connected_components = @graph.node_get_bool_property(
    elk_graph, mrtree_separate_connected_components,
  )
  graph_data.direction = @graph.node_get_string_property(
    elk_graph, @core.direction,
  )
  graph_data.compaction = @graph.node_get_bool_property(
    elk_graph, mrtree_compaction,
  )
  graph_data.edge_routing_mode = @graph.node_get_string_property(
    elk_graph, mrtree_edge_routing_mode,
  )
  graph_data.weighting = @graph.node_get_string_property(
    elk_graph, mrtree_weighting,
  )
  graph_data.search_order = @graph.node_get_string_property(
    elk_graph, mrtree_search_order,
  )
  graph_data.spacing_node_node = @graph.node_get_double_property(
    elk_graph, mrtree_spacing_node_node,
  )
  graph_data.spacing_edge_node = @graph.node_get_double_property(
    elk_graph, mrtree_spacing_edge_node,
  )
  graph_data.edge_end_texture_length = @graph.node_get_double_property(
    elk_graph, mrtree_edge_end_texture_length,
  )
  let parsed_aspect_ratio = @graph.node_get_double_property(
    elk_graph, mrtree_aspect_ratio,
  )
  graph_data.aspect_ratio = if parsed_aspect_ratio > 0.0 {
    parsed_aspect_ratio
  } else {
    1.6
  }
  graph_data.padding = mrtree_parse_padding(
    @graph.node_get_string_property(elk_graph, mrtree_padding),
  )
  graph_data.priority = @graph.node_get_double_property(
    elk_graph, mrtree_priority,
  ).to_int()
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_origin(graph : MrtreeGraph) -> @graph.ElkNode? {
  graph.data.origin
}

///|
pub fn mrtree_graph_nodes(graph : MrtreeGraph) -> Array[MrtreeNode] {
  graph.data.nodes
}

///|
pub fn mrtree_graph_edges(graph : MrtreeGraph) -> Array[MrtreeEdge] {
  graph.data.edges
}

///|
pub fn mrtree_graph_add_existing_node(
  graph : MrtreeGraph,
  node : MrtreeNode,
) -> Unit {
  let graph_data = graph.data
  if !graph_data.nodes.contains(node) {
    graph_data.nodes.push(node)
    set_mrtree_graph_data(graph, graph_data)
  }
}

///|
pub fn mrtree_graph_add_existing_edge(
  graph : MrtreeGraph,
  edge : MrtreeEdge,
) -> Unit {
  let graph_data = graph.data
  if !graph_data.edges.contains(edge) {
    graph_data.edges.push(edge)
    set_mrtree_graph_data(graph, graph_data)
  }
}

///|
pub fn mrtree_graph_separate_connected_components(graph : MrtreeGraph) -> Bool {
  graph.data.separate_connected_components
}

///|
pub fn mrtree_graph_direction(graph : MrtreeGraph) -> String {
  graph.data.direction
}

///|
pub fn mrtree_graph_set_direction(graph : MrtreeGraph, value : String) -> Unit {
  let graph_data = graph.data
  graph_data.direction = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_direction_is_horizontal(graph : MrtreeGraph) -> Bool {
  let current_direction = mrtree_graph_direction(graph)
  current_direction == "LEFT" || current_direction == "RIGHT"
}

///|
pub fn mrtree_graph_compaction(graph : MrtreeGraph) -> Bool {
  graph.data.compaction
}

///|
pub fn mrtree_graph_set_compaction(graph : MrtreeGraph, value : Bool) -> Unit {
  let graph_data = graph.data
  graph_data.compaction = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_edge_routing_mode(
  graph : MrtreeGraph,
) -> MrtreeEdgeRoutingMode {
  mrtree_edge_routing_mode_from_string(graph.data.edge_routing_mode)
}

///|
pub fn mrtree_graph_set_edge_routing_mode(
  graph : MrtreeGraph,
  value : String,
) -> Unit {
  let graph_data = graph.data
  graph_data.edge_routing_mode = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_weighting(graph : MrtreeGraph) -> MrtreeOrderWeighting {
  mrtree_order_weighting_from_string(graph.data.weighting)
}

///|
pub fn mrtree_graph_set_weighting(graph : MrtreeGraph, value : String) -> Unit {
  let graph_data = graph.data
  graph_data.weighting = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_search_order(graph : MrtreeGraph) -> MrtreeTreeifyingOrder {
  mrtree_treeifying_order_from_string(graph.data.search_order)
}

///|
pub fn mrtree_graph_set_search_order(
  graph : MrtreeGraph,
  value : String,
) -> Unit {
  let graph_data = graph.data
  graph_data.search_order = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_set_removable_edges(
  graph : MrtreeGraph,
  edges : Array[MrtreeEdge],
) -> Unit {
  let graph_data = graph.data
  graph_data.removable_edges = edges.copy()
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_removable_edges(graph : MrtreeGraph) -> Array[MrtreeEdge] {
  graph.data.removable_edges
}

///|
pub fn mrtree_graph_spacing_node_node(graph : MrtreeGraph) -> Double {
  graph.data.spacing_node_node
}

///|
pub fn mrtree_graph_spacing_edge_node(graph : MrtreeGraph) -> Double {
  graph.data.spacing_edge_node
}

///|
pub fn mrtree_graph_edge_end_texture_length(graph : MrtreeGraph) -> Double {
  graph.data.edge_end_texture_length
}

///|
pub fn mrtree_graph_aspect_ratio(graph : MrtreeGraph) -> Double {
  graph.data.aspect_ratio
}

///|
pub fn mrtree_graph_padding(graph : MrtreeGraph) -> @core.ElkPadding {
  graph.data.padding
}

///|
pub fn mrtree_graph_set_priority(graph : MrtreeGraph, priority : Int) -> Unit {
  let graph_data = graph.data
  graph_data.priority = priority
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_priority(graph : MrtreeGraph) -> Int {
  graph.data.priority
}

///|
pub fn mrtree_graph_set_bb_up_left(
  graph : MrtreeGraph,
  value : @core.KVector,
) -> Unit {
  let graph_data = graph.data
  graph_data.bb_up_left = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_bb_up_left(graph : MrtreeGraph) -> @core.KVector {
  graph.data.bb_up_left
}

///|
pub fn mrtree_graph_set_bb_low_right(
  graph : MrtreeGraph,
  value : @core.KVector,
) -> Unit {
  let graph_data = graph.data
  graph_data.bb_low_right = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_bb_low_right(graph : MrtreeGraph) -> @core.KVector {
  graph.data.bb_low_right
}

///|
pub fn mrtree_graph_set_graph_xmin(graph : MrtreeGraph, value : Double) -> Unit {
  let graph_data = graph.data
  graph_data.graph_xmin = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_xmin(graph : MrtreeGraph) -> Double {
  graph.data.graph_xmin
}

///|
pub fn mrtree_graph_set_graph_ymin(graph : MrtreeGraph, value : Double) -> Unit {
  let graph_data = graph.data
  graph_data.graph_ymin = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_ymin(graph : MrtreeGraph) -> Double {
  graph.data.graph_ymin
}

///|
pub fn mrtree_graph_set_graph_xmax(graph : MrtreeGraph, value : Double) -> Unit {
  let graph_data = graph.data
  graph_data.graph_xmax = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_xmax(graph : MrtreeGraph) -> Double {
  graph.data.graph_xmax
}

///|
pub fn mrtree_graph_set_graph_ymax(graph : MrtreeGraph, value : Double) -> Unit {
  let graph_data = graph.data
  graph_data.graph_ymax = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_ymax(graph : MrtreeGraph) -> Double {
  graph.data.graph_ymax
}
