///|
pub let layered_components_separate_connected_components : IProperty[Bool] = new_property(
  "org.eclipse.elk.separateConnectedComponents", true,
)

///|
pub let layered_components_direction : IProperty[Direction] = new_property(
  "org.eclipse.elk.direction",
  Direction::Undefined,
)

///|
pub let layered_components_priority : IProperty[Int] = new_property(
  "org.eclipse.elk.priority", 0,
)

///|
fn layered_components_port_constraints_from_string(
  value : String,
) -> PortConstraints {
  match value {
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn layered_components_graph_has_external_ports(graph : LGraph) -> Bool {
  for
    property in graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    if property is GraphProperties::ExternalPorts {
      return true
    }
  }
  false
}

///|
fn layered_components_port_side_contains(
  sides : Array[PortSide],
  expected : PortSide,
) -> Bool {
  for side in sides {
    if port_side_to_string(side) == port_side_to_string(expected) {
      return true
    }
  }
  false
}

///|
fn layered_components_add_port_side(
  sides : Array[PortSide],
  side : PortSide,
) -> Unit {
  if !layered_components_port_side_contains(sides, side) {
    sides.push(side)
  }
}

///|
fn layered_components_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("Port without owning node in components DFS.")
  }
}

///|
fn layered_components_sort_by_model_order(components : Array[LGraph]) -> Unit {
  let length = components.length()
  for i in 1..<length {
    let current = components[i]
    let current_order = get_minimal_model_order(current)
    let mut j = i
    while j > 0 && current_order < get_minimal_model_order(components[j - 1]) {
      components[j] = components[j - 1]
      j -= 1
    }
    components[j] = current
  }
}

///|
fn layered_components_dfs(
  node : LNode,
  data : (Array[LNode], Array[PortSide])?,
) -> (Array[LNode], Array[PortSide])? {
  if node.get_id() != 0 {
    return None
  }

  node.set_id(1)

  let (component_nodes, ext_port_sides) = match data {
    Some(value) => value
    None => ([], [])
  }

  component_nodes.push(node)

  if node.get_type() is NodeType::ExternalPort {
    layered_components_add_port_side(
      ext_port_sides,
      node.get_property_port_side(internal_properties_ext_port_side),
    )
  }

  for port1 in node.get_ports() {
    for port2 in port1.get_connected_ports() {
      ignore(
        layered_components_dfs(
          layered_components_require_port_node(port2),
          Some((component_nodes, ext_port_sides)),
        ),
      )
    }
  }

  Some((component_nodes, ext_port_sides))
}

///|
enum LayeredGraphPlacerKind {
  SimpleRow
  ComponentGroup
  ComponentGroupModelOrder
  ModelOrderRow
}

///|
pub struct LayeredComponentsProcessor {
  component_group_graph_placer : LayeredComponentGroupGraphPlacer
  component_group_model_order_graph_placer : LayeredComponentGroupModelOrderGraphPlacer
  model_order_row_graph_placer : LayeredModelOrderRowGraphPlacer
  simple_row_graph_placer : LayeredSimpleRowGraphPlacer
  mut graph_placer_kind : LayeredGraphPlacerKind
}

///|
pub fn new_layered_components_processor() -> LayeredComponentsProcessor {
  {
    component_group_graph_placer: new_layered_component_group_graph_placer(),
    component_group_model_order_graph_placer: new_layered_component_group_model_order_graph_placer(),
    model_order_row_graph_placer: new_layered_model_order_row_graph_placer(),
    simple_row_graph_placer: new_layered_simple_row_graph_placer(),
    graph_placer_kind: LayeredGraphPlacerKind::SimpleRow,
  }
}

///|
pub fn LayeredComponentsProcessor::split(
  self : LayeredComponentsProcessor,
  graph : LGraph,
) -> Array[LGraph] {
  self.graph_placer_kind = LayeredGraphPlacerKind::SimpleRow

  let separate = graph.get_property_bool(
    layered_components_separate_connected_components,
  )
  let ext_ports = layered_components_graph_has_external_ports(graph)
  let ext_port_constraints = layered_components_port_constraints_from_string(
    graph.get_property_string(port_constraints),
  )
  let compatible_port_constraints = !ext_port_constraints.is_order_fixed()
  let component_ordering = graph.get_property_component_ordering_strategy(
    layered_options_consider_model_order_components,
  )

  let result : Array[LGraph] = if separate &&
    (compatible_port_constraints || !ext_ports) {
    for node in graph.get_layerless_nodes() {
      node.set_id(0)
    }

    let split_result : Array[LGraph] = []
    for node in graph.get_layerless_nodes() {
      match layered_components_dfs(node, None) {
        Some((component_nodes, ext_port_sides)) => {
          let new_graph = new_l_graph()
          new_graph.copy_properties(graph)
          new_graph.set_property_port_side_array(
            internal_properties_ext_port_connections, ext_port_sides,
          )
          ignore(new_graph.get_padding().copy(graph.get_padding()))
          new_graph.clear_property_string(node_size_minimum)

          for n in component_nodes {
            new_graph.get_layerless_nodes().push(n)
            n.set_graph(Some(new_graph))
          }

          split_result.push(new_graph)
        }
        None => ()
      }
    }

    if ext_ports {
      match component_ordering {
        ComponentOrderingStrategy::GroupModelOrder =>
          self.graph_placer_kind = LayeredGraphPlacerKind::ComponentGroupModelOrder
        ComponentOrderingStrategy::ModelOrder =>
          self.graph_placer_kind = LayeredGraphPlacerKind::ModelOrderRow
        _ => self.graph_placer_kind = LayeredGraphPlacerKind::ComponentGroup
      }
    }

    split_result
  } else {
    [graph]
  }

  if !component_ordering_strategy_equals(
      component_ordering,
      ComponentOrderingStrategy::NoneType,
    ) {
    layered_components_sort_by_model_order(result)
  }

  result
}

///|
pub fn LayeredComponentsProcessor::combine(
  self : LayeredComponentsProcessor,
  components : Array[LGraph],
  target : LGraph,
) -> Unit {
  match self.graph_placer_kind {
    LayeredGraphPlacerKind::SimpleRow =>
      self.simple_row_graph_placer.combine(components, target)
    LayeredGraphPlacerKind::ComponentGroup =>
      self.component_group_graph_placer.combine(components, target)
    LayeredGraphPlacerKind::ComponentGroupModelOrder =>
      self.component_group_model_order_graph_placer.combine(components, target)
    LayeredGraphPlacerKind::ModelOrderRow =>
      self.model_order_row_graph_placer.combine(components, target)
  }
}
