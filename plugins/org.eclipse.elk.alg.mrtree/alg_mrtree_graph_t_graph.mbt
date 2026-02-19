///|
pub type MrtreeGraph = Int

///|
priv struct MrtreeGraphData {
  nodes : Array[MrtreeNode]
  edges : Array[MrtreeEdge]
  mut origin : ElkNode?
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
  mut padding : ElkPadding
  mut priority : Int
  mut bb_up_left : KVector
  mut bb_low_right : KVector
  mut graph_xmin : Double
  mut graph_ymin : Double
  mut graph_xmax : Double
  mut graph_ymax : Double
}

///|
let mrtree_graph_store : Ref[Array[MrtreeGraphData]] = Ref::new([])

///|
fn checked_mrtree_graph(graph : MrtreeGraph) -> Unit {
  if graph < 0 || graph >= mrtree_graph_store.val.length() {
    abort("invalid mrtree graph id")
  }
}

///|
fn set_mrtree_graph_data(graph : MrtreeGraph, data : MrtreeGraphData) -> Unit {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph] = data
}

///|
fn mrtree_parse_padding(text : String) -> ElkPadding {
  let padding_value = new_elk_padding()
  padding_value.parse(text)
  padding_value
}

///|
pub fn new_mrtree_graph() -> MrtreeGraph {
  let id = mrtree_graph_store.val.length()
  mrtree_graph_store.val.push({
    nodes: [],
    edges: [],
    origin: None,
    separate_connected_components: true,
    direction: "UNDEFINED",
    compaction: false,
    edge_routing_mode: "AVOID_OVERLAP",
    weighting: "MODEL_ORDER",
    search_order: "DFS",
    removable_edges: [],
    spacing_node_node: 20.0,
    spacing_edge_node: 3.0,
    edge_end_texture_length: 7.0,
    aspect_ratio: 1.6,
    padding: new_elk_padding_any(20.0),
    priority: 0,
    bb_up_left: new_kvector(),
    bb_low_right: new_kvector(),
    graph_xmin: 0.0,
    graph_ymin: 0.0,
    graph_xmax: 0.0,
    graph_ymax: 0.0,
  })
  id
}

///|
pub fn mrtree_graph_copy_properties(
  target : MrtreeGraph,
  source : MrtreeGraph,
) -> Unit {
  checked_mrtree_graph(target)
  checked_mrtree_graph(source)
  let target_data = mrtree_graph_store.val[target]
  let source_data = mrtree_graph_store.val[source]
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
  elk_graph : ElkNode,
) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.origin = Some(elk_graph)
  graph_data.separate_connected_components = node_get_bool_property(
    elk_graph, mrtree_separate_connected_components,
  )
  graph_data.direction = node_get_string_property(elk_graph, direction)
  graph_data.compaction = node_get_bool_property(elk_graph, mrtree_compaction)
  graph_data.edge_routing_mode = node_get_string_property(
    elk_graph, mrtree_edge_routing_mode,
  )
  graph_data.weighting = node_get_string_property(elk_graph, mrtree_weighting)
  graph_data.search_order = node_get_string_property(
    elk_graph, mrtree_search_order,
  )
  graph_data.spacing_node_node = node_get_double_property(
    elk_graph, mrtree_spacing_node_node,
  )
  graph_data.spacing_edge_node = node_get_double_property(
    elk_graph, spacing_edge_node,
  )
  graph_data.edge_end_texture_length = node_get_double_property(
    elk_graph, mrtree_edge_end_texture_length,
  )
  let parsed_aspect_ratio = node_get_double_property(
    elk_graph, mrtree_aspect_ratio,
  )
  graph_data.aspect_ratio = if parsed_aspect_ratio > 0.0 {
    parsed_aspect_ratio
  } else {
    1.6
  }
  graph_data.padding = mrtree_parse_padding(
    node_get_string_property(elk_graph, mrtree_padding),
  )
  graph_data.priority = node_get_double_property(elk_graph, mrtree_priority).to_int()
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_origin(graph : MrtreeGraph) -> ElkNode? {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].origin
}

///|
pub fn mrtree_graph_nodes(graph : MrtreeGraph) -> Array[MrtreeNode] {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].nodes
}

///|
pub fn mrtree_graph_edges(graph : MrtreeGraph) -> Array[MrtreeEdge] {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].edges
}

///|
pub fn mrtree_graph_add_existing_node(
  graph : MrtreeGraph,
  node : MrtreeNode,
) -> Unit {
  checked_mrtree_graph(graph)
  checked_mrtree_node(node)
  let graph_data = mrtree_graph_store.val[graph]
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
  checked_mrtree_graph(graph)
  checked_mrtree_edge(edge)
  let graph_data = mrtree_graph_store.val[graph]
  if !graph_data.edges.contains(edge) {
    graph_data.edges.push(edge)
    set_mrtree_graph_data(graph, graph_data)
  }
}

///|
pub fn mrtree_graph_separate_connected_components(graph : MrtreeGraph) -> Bool {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].separate_connected_components
}

///|
pub fn mrtree_graph_direction(graph : MrtreeGraph) -> String {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].direction
}

///|
pub fn mrtree_graph_set_direction(graph : MrtreeGraph, value : String) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
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
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].compaction
}

///|
pub fn mrtree_graph_set_compaction(graph : MrtreeGraph, value : Bool) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.compaction = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_edge_routing_mode(
  graph : MrtreeGraph,
) -> MrtreeEdgeRoutingMode {
  checked_mrtree_graph(graph)
  mrtree_edge_routing_mode_from_string(
    mrtree_graph_store.val[graph].edge_routing_mode,
  )
}

///|
pub fn mrtree_graph_set_edge_routing_mode(
  graph : MrtreeGraph,
  value : String,
) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.edge_routing_mode = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_weighting(graph : MrtreeGraph) -> MrtreeOrderWeighting {
  checked_mrtree_graph(graph)
  mrtree_order_weighting_from_string(mrtree_graph_store.val[graph].weighting)
}

///|
pub fn mrtree_graph_set_weighting(graph : MrtreeGraph, value : String) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.weighting = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_search_order(graph : MrtreeGraph) -> MrtreeTreeifyingOrder {
  checked_mrtree_graph(graph)
  mrtree_treeifying_order_from_string(
    mrtree_graph_store.val[graph].search_order,
  )
}

///|
pub fn mrtree_graph_set_search_order(
  graph : MrtreeGraph,
  value : String,
) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.search_order = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_set_removable_edges(
  graph : MrtreeGraph,
  edges : Array[MrtreeEdge],
) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.removable_edges = edges.copy()
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_removable_edges(graph : MrtreeGraph) -> Array[MrtreeEdge] {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].removable_edges
}

///|
pub fn mrtree_graph_spacing_node_node(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].spacing_node_node
}

///|
pub fn mrtree_graph_spacing_edge_node(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].spacing_edge_node
}

///|
pub fn mrtree_graph_edge_end_texture_length(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].edge_end_texture_length
}

///|
pub fn mrtree_graph_aspect_ratio(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].aspect_ratio
}

///|
pub fn mrtree_graph_padding(graph : MrtreeGraph) -> ElkPadding {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].padding
}

///|
pub fn mrtree_graph_set_priority(graph : MrtreeGraph, priority : Int) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.priority = priority
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_priority(graph : MrtreeGraph) -> Int {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].priority
}

///|
pub fn mrtree_graph_set_bb_up_left(
  graph : MrtreeGraph,
  value : KVector,
) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.bb_up_left = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_bb_up_left(graph : MrtreeGraph) -> KVector {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].bb_up_left
}

///|
pub fn mrtree_graph_set_bb_low_right(
  graph : MrtreeGraph,
  value : KVector,
) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.bb_low_right = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_bb_low_right(graph : MrtreeGraph) -> KVector {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].bb_low_right
}

///|
pub fn mrtree_graph_set_graph_xmin(graph : MrtreeGraph, value : Double) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.graph_xmin = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_xmin(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].graph_xmin
}

///|
pub fn mrtree_graph_set_graph_ymin(graph : MrtreeGraph, value : Double) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.graph_ymin = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_ymin(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].graph_ymin
}

///|
pub fn mrtree_graph_set_graph_xmax(graph : MrtreeGraph, value : Double) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.graph_xmax = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_xmax(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].graph_xmax
}

///|
pub fn mrtree_graph_set_graph_ymax(graph : MrtreeGraph, value : Double) -> Unit {
  checked_mrtree_graph(graph)
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.graph_ymax = value
  set_mrtree_graph_data(graph, graph_data)
}

///|
pub fn mrtree_graph_graph_ymax(graph : MrtreeGraph) -> Double {
  checked_mrtree_graph(graph)
  mrtree_graph_store.val[graph].graph_ymax
}
