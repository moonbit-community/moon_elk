///|
struct BetweenLayerAdjacency {
  position : Int
  mut cardinality : Int
  mut current_cardinality : Int
}

///|
struct BetweenLayerAdjacencyList {
  node : LNode
  side : PortSide
  adjacency_list : Array[BetweenLayerAdjacency]
  mut size : Int
  mut current_size : Int
  mut current_index : Int
}

///|
fn between_layer_connected_edges(port : LPort, side : PortSide) -> Array[LEdge] {
  if lnode_port_side_equals(side, PortSide::West) {
    port.get_incoming_edges()
  } else {
    port.get_outgoing_edges()
  }
}

///|
fn between_layer_adjacent_port_of(edge : LEdge, side : PortSide) -> LPort? {
  if lnode_port_side_equals(side, PortSide::West) {
    edge.get_source()
  } else {
    edge.get_target()
  }
}

///|
fn between_layer_is_not_in_layer(edge : LEdge) -> Bool {
  match (edge.get_source(), edge.get_target()) {
    (Some(source), Some(target)) =>
      match (source.get_node(), target.get_node()) {
        (Some(source_node), Some(target_node)) =>
          match (source_node.get_layer(), target_node.get_layer()) {
            (Some(source_layer), Some(target_layer)) =>
              layer_internal_handle(source_layer) !=
              layer_internal_handle(target_layer)
            _ => false
          }
        _ => false
      }
    _ => false
  }
}

///|
fn between_layer_sort_adjacencies_by_position(
  adjacency_list : Array[BetweenLayerAdjacency],
) -> Unit {
  for i in 1..<adjacency_list.length() {
    let current = adjacency_list[i]
    let mut j = i
    while j > 0 && adjacency_list[j - 1].position > current.position {
      adjacency_list[j] = adjacency_list[j - 1]
      j = j - 1
    }
    adjacency_list[j] = current
  }
}

///|
fn between_layer_add_adjacency(
  adjacency_list : BetweenLayerAdjacencyList,
  edge : LEdge,
  side : PortSide,
  port_positions : Map[Int, Int],
) -> Bool {
  match between_layer_adjacent_port_of(edge, side) {
    Some(adjacent_port) =>
      match port_positions.get(lport_internal_handle(adjacent_port)) {
        Some(adjacent_position) => {
          let last_index = adjacency_list.adjacency_list.length() - 1
          if !adjacency_list.adjacency_list.is_empty() &&
            adjacency_list.adjacency_list[last_index].position ==
            adjacent_position {
            let last = adjacency_list.adjacency_list[last_index]
            last.cardinality = last.cardinality + 1
            last.current_cardinality = last.current_cardinality + 1
            adjacency_list.adjacency_list[last_index] = last
          } else {
            adjacency_list.adjacency_list.push({
              position: adjacent_position,
              cardinality: 1,
              current_cardinality: 1,
            })
          }
          true
        }
        None => false
      }
    None => false
  }
}

///|
fn between_layer_collect_adjacencies(
  node : LNode,
  side : PortSide,
  port_positions : Map[Int, Int],
) -> BetweenLayerAdjacencyList {
  let list : BetweenLayerAdjacencyList = {
    node,
    side,
    adjacency_list: [],
    size: 0,
    current_size: 0,
    current_index: 0,
  }

  for port in in_north_south_east_west_order(node, side) {
    for edge in between_layer_connected_edges(port, side) {
      if !edge.is_self_loop() && between_layer_is_not_in_layer(edge) {
        if between_layer_add_adjacency(list, edge, side, port_positions) {
          list.size = list.size + 1
          list.current_size = list.current_size + 1
        }
      }
    }
  }

  between_layer_sort_adjacencies_by_position(list.adjacency_list)
  list
}

///|
fn BetweenLayerAdjacencyList::is_empty(
  self : BetweenLayerAdjacencyList,
) -> Bool {
  self.current_size == 0
}

///|
fn BetweenLayerAdjacencyList::reset_current_entry(
  self : BetweenLayerAdjacencyList,
) -> Unit {
  if self.current_index >= 0 &&
    self.current_index < self.adjacency_list.length() {
    let entry = self.adjacency_list[self.current_index]
    entry.current_cardinality = entry.cardinality
    self.adjacency_list[self.current_index] = entry
  }
}

///|
fn BetweenLayerAdjacencyList::reset(self : BetweenLayerAdjacencyList) -> Unit {
  self.current_index = 0
  self.current_size = self.size
  if !self.is_empty() {
    self.reset_current_entry()
  }
}

///|
fn BetweenLayerAdjacencyList::first(self : BetweenLayerAdjacencyList) -> Int {
  self.adjacency_list[self.current_index].position
}

///|
fn BetweenLayerAdjacencyList::size(self : BetweenLayerAdjacencyList) -> Int {
  self.current_size
}

///|
fn BetweenLayerAdjacencyList::count_adjacencies_below_node_of_first_port(
  self : BetweenLayerAdjacencyList,
) -> Int {
  self.current_size -
  self.adjacency_list[self.current_index].current_cardinality
}

///|
fn BetweenLayerAdjacencyList::remove_first(
  self : BetweenLayerAdjacencyList,
) -> Unit {
  if self.is_empty() {
    return
  }

  let current = self.adjacency_list[self.current_index]
  if current.current_cardinality == 1 {
    self.current_index = self.current_index + 1
    if self.current_index < self.adjacency_list.length() {
      self.reset_current_entry()
    }
  } else {
    current.current_cardinality = current.current_cardinality - 1
    self.adjacency_list[self.current_index] = current
  }

  self.current_size = self.current_size - 1
}

///|
pub struct BetweenLayerEdgeTwoNodeCrossingsCounter {
  mut upper_lower_crossings : Int
  mut lower_upper_crossings : Int
  current_node_order : Array[Array[LNode]]
  free_layer_index : Int
  port_positions : Map[Int, Int]
  eastern_adjacencies : Map[Int, BetweenLayerAdjacencyList]
  western_adjacencies : Map[Int, BetweenLayerAdjacencyList]
}

///|
pub fn new_between_layer_edge_two_node_crossings_counter(
  current_node_order : Array[Array[LNode]],
  free_layer_index : Int,
) -> BetweenLayerEdgeTwoNodeCrossingsCounter {
  let counter : BetweenLayerEdgeTwoNodeCrossingsCounter = {
    upper_lower_crossings: 0,
    lower_upper_crossings: 0,
    current_node_order,
    free_layer_index,
    port_positions: {},
    eastern_adjacencies: {},
    western_adjacencies: {},
  }
  counter.set_port_positions_for_neighbouring_layers()
  counter
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::free_layer_is_not_first_layer(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
) -> Bool {
  self.free_layer_index > 0
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::free_layer_is_not_last_layer(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
) -> Bool {
  self.free_layer_index < self.current_node_order.length() - 1
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::set_port_positions_for_layer(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  layer_index : Int,
  port_side : PortSide,
) -> Unit {
  let mut port_id = 0
  for node in self.current_node_order[layer_index] {
    for port in in_north_south_east_west_order(node, port_side) {
      self.port_positions[lport_internal_handle(port)] = port_id
      port_id = port_id + 1
    }
  }
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::set_port_positions_for_neighbouring_layers(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
) -> Unit {
  if self.free_layer_is_not_first_layer() {
    self.set_port_positions_for_layer(self.free_layer_index - 1, PortSide::East)
  }
  if self.free_layer_is_not_last_layer() {
    self.set_port_positions_for_layer(self.free_layer_index + 1, PortSide::West)
  }
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::reset_crossing_count(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
) -> Unit {
  self.upper_lower_crossings = 0
  self.lower_upper_crossings = 0
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::is_below(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  first_port : Int,
  second_port : Int,
) -> Bool {
  ignore(self)
  first_port > second_port
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::get_adjacency_for(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  node : LNode,
  side : PortSide,
  adjacencies : Map[Int, BetweenLayerAdjacencyList],
) -> BetweenLayerAdjacencyList {
  if adjacencies.is_empty() {
    for candidate in self.current_node_order[self.free_layer_index] {
      let key = lnode_internal_handle(candidate)
      adjacencies[key] = between_layer_collect_adjacencies(
        candidate,
        side,
        self.port_positions,
      )
    }
  }

  let key = lnode_internal_handle(node)
  match adjacencies.get(key) {
    Some(list) => {
      list.reset()
      list
    }
    None => {
      let list = between_layer_collect_adjacencies(
        node,
        side,
        self.port_positions,
      )
      list.reset()
      list
    }
  }
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::count_crossings_by_merging_adjacency_lists(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  upper_adjacencies : BetweenLayerAdjacencyList,
  lower_adjacencies : BetweenLayerAdjacencyList,
) -> Unit {
  while !upper_adjacencies.is_empty() && !lower_adjacencies.is_empty() {
    if self.is_below(upper_adjacencies.first(), lower_adjacencies.first()) {
      self.upper_lower_crossings = self.upper_lower_crossings +
        upper_adjacencies.size()
      lower_adjacencies.remove_first()
    } else if self.is_below(
        lower_adjacencies.first(),
        upper_adjacencies.first(),
      ) {
      self.lower_upper_crossings = self.lower_upper_crossings +
        lower_adjacencies.size()
      upper_adjacencies.remove_first()
    } else {
      self.upper_lower_crossings = self.upper_lower_crossings +
        upper_adjacencies.count_adjacencies_below_node_of_first_port()
      self.lower_upper_crossings = self.lower_upper_crossings +
        lower_adjacencies.count_adjacencies_below_node_of_first_port()
      upper_adjacencies.remove_first()
      lower_adjacencies.remove_first()
    }
  }
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::add_eastern_crossings(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  let upper_adjacencies = self.get_adjacency_for(
    upper_node,
    PortSide::East,
    self.eastern_adjacencies,
  )
  let lower_adjacencies = self.get_adjacency_for(
    lower_node,
    PortSide::East,
    self.eastern_adjacencies,
  )
  if upper_adjacencies.size() == 0 || lower_adjacencies.size() == 0 {
    return
  }
  self.count_crossings_by_merging_adjacency_lists(
    upper_adjacencies, lower_adjacencies,
  )
}

///|
fn BetweenLayerEdgeTwoNodeCrossingsCounter::add_western_crossings(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  let upper_adjacencies = self.get_adjacency_for(
    upper_node,
    PortSide::West,
    self.western_adjacencies,
  )
  let lower_adjacencies = self.get_adjacency_for(
    lower_node,
    PortSide::West,
    self.western_adjacencies,
  )
  if upper_adjacencies.size() == 0 || lower_adjacencies.size() == 0 {
    return
  }
  self.count_crossings_by_merging_adjacency_lists(
    upper_adjacencies, lower_adjacencies,
  )
}

///|
fn between_layer_same_node(left : LNode, right : LNode) -> Bool {
  lnode_internal_handle(left) == lnode_internal_handle(right)
}

///|
pub fn BetweenLayerEdgeTwoNodeCrossingsCounter::count_eastern_edge_crossings(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  self.reset_crossing_count()
  if between_layer_same_node(upper_node, lower_node) {
    return
  }
  self.add_eastern_crossings(upper_node, lower_node)
}

///|
pub fn BetweenLayerEdgeTwoNodeCrossingsCounter::count_western_edge_crossings(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  self.reset_crossing_count()
  if between_layer_same_node(upper_node, lower_node) {
    return
  }
  self.add_western_crossings(upper_node, lower_node)
}

///|
pub fn BetweenLayerEdgeTwoNodeCrossingsCounter::count_both_side_crossings(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  self.reset_crossing_count()
  if between_layer_same_node(upper_node, lower_node) {
    return
  }
  self.add_western_crossings(upper_node, lower_node)
  self.add_eastern_crossings(upper_node, lower_node)
}

///|
pub fn BetweenLayerEdgeTwoNodeCrossingsCounter::get_upper_lower_crossings(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
) -> Int {
  self.upper_lower_crossings
}

///|
pub fn BetweenLayerEdgeTwoNodeCrossingsCounter::get_lower_upper_crossings(
  self : BetweenLayerEdgeTwoNodeCrossingsCounter,
) -> Int {
  self.lower_upper_crossings
}
