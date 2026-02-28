///|
fn tarjan_edge_is_reversed(tarjan : Tarjan, edge : LEdge) -> Bool {
  for reversed_edge in tarjan.edges_to_be_reversed {
    if ledge_internal_handle(reversed_edge) == ledge_internal_handle(edge) {
      return true
    }
  }
  false
}

///|
fn tarjan_pop_stack(stack : Array[LNode]) -> LNode {
  match stack.pop() {
    Some(node) => node
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "tarjan stack is empty",
      )
      tarjan_pop_stack(stack)
    }
  }
}

///|
fn tarjan_int_min(left : Int, right : Int) -> Int {
  if left < right {
    left
  } else {
    right
  }
}

///|
pub struct Tarjan {
  edges_to_be_reversed : Array[LEdge]
  mut index : Int
  strongly_connected_components : Array[Array[LNode]]
  stack : Array[LNode]
  node_to_scc_id : Map[Int, Int]
}

///|
pub fn new_tarjan(edges_to_be_reversed : Array[LEdge]) -> Tarjan {
  {
    edges_to_be_reversed,
    index: 0,
    strongly_connected_components: [],
    stack: [],
    node_to_scc_id: {},
  }
}

///|
pub fn Tarjan::get_strongly_connected_components(
  self : Tarjan,
) -> Array[Array[LNode]] {
  self.strongly_connected_components
}

///|
pub fn Tarjan::get_node_to_scc_id(self : Tarjan) -> Map[Int, Int] {
  self.node_to_scc_id
}

///|
pub fn Tarjan::tarjan(self : Tarjan, graph : LGraph) -> Unit {
  self.index = 0
  self.stack.clear()
  self.strongly_connected_components.clear()
  self.node_to_scc_id.clear()

  for node in graph.get_layerless_nodes() {
    if node.get_property_int(internal_properties_tarjan_id) == -1 {
      self.strongly_connected(node)
      self.stack.clear()
    }
  }
}

///|
pub fn Tarjan::strongly_connected(self : Tarjan, node_v : LNode) -> Unit {
  node_v.set_property_int(internal_properties_tarjan_id, self.index)
  node_v.set_property_int(internal_properties_tarjan_lowlink, self.index)
  self.index += 1
  self.stack.push(node_v)
  node_v.set_property_bool(internal_properties_tarjan_on_stack, true)

  for edge in node_v.get_connected_edges() {
    let source_node = match edge.get_source() {
      Some(source_port) => source_port.get_node()
      None => None
    }
    let target_node = match edge.get_target() {
      Some(target_port) => target_port.get_node()
      None => None
    }

    match (source_node, target_node) {
      (Some(source), Some(target)) => {
        let is_reversed = tarjan_edge_is_reversed(self, edge)

        if lnode_internal_handle(source) != lnode_internal_handle(node_v) &&
          !is_reversed {
          continue
        }
        if lnode_internal_handle(source) == lnode_internal_handle(node_v) &&
          is_reversed {
          continue
        }

        let next = if lnode_internal_handle(target) ==
          lnode_internal_handle(node_v) {
          source
        } else {
          target
        }

        if next.get_property_int(internal_properties_tarjan_id) == -1 {
          self.strongly_connected(next)
          node_v.set_property_int(
            internal_properties_tarjan_lowlink,
            tarjan_int_min(
              node_v.get_property_int(internal_properties_tarjan_lowlink),
              next.get_property_int(internal_properties_tarjan_lowlink),
            ),
          )
        } else if next.get_property_bool(internal_properties_tarjan_on_stack) {
          node_v.set_property_int(
            internal_properties_tarjan_lowlink,
            tarjan_int_min(
              node_v.get_property_int(internal_properties_tarjan_lowlink),
              next.get_property_int(internal_properties_tarjan_id),
            ),
          )
        }
      }
      _ => ()
    }
  }

  if node_v.get_property_int(internal_properties_tarjan_lowlink) ==
    node_v.get_property_int(internal_properties_tarjan_id) {
    let scc = []
    let mut current = tarjan_pop_stack(self.stack)
    current.set_property_bool(internal_properties_tarjan_on_stack, false)
    scc.push(current)

    while lnode_internal_handle(current) != lnode_internal_handle(node_v) {
      current = tarjan_pop_stack(self.stack)
      current.set_property_bool(internal_properties_tarjan_on_stack, false)
      scc.push(current)
    }

    if scc.length() > 1 {
      let scc_index = self.strongly_connected_components.length()
      self.strongly_connected_components.push(scc)
      for node in scc {
        self.node_to_scc_id[node.get_handle()] = scc_index
      }
    }
  }
}

///|
pub fn Tarjan::reset_tarjan(self : Tarjan, graph : LGraph) -> Unit {
  for node in graph.get_layerless_nodes() {
    node.set_property_bool(internal_properties_tarjan_on_stack, false)
    node.set_property_int(internal_properties_tarjan_lowlink, -1)
    node.set_property_int(internal_properties_tarjan_id, -1)
    self.stack.clear()

    for edge in node.get_connected_edges() {
      edge.set_property_bool(internal_properties_is_part_of_cycle, false)
    }
  }
}
