///|
pub let layered_components_separate_connected_components : IProperty[Bool] = new_property(
  "org.eclipse.elk.separateConnectedComponents", true,
)

///|
pub let layered_components_has_external_ports : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.hasExternalPorts", false,
)

///|
pub let layered_components_consider_model_order_components : IProperty[
  ComponentOrderingStrategy,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.components",
  ComponentOrderingStrategy::NoneType,
)

///|
pub let layered_components_compaction_connected_components : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.compaction.connectedComponents", false,
)

///|
pub let layered_components_edge_routing : IProperty[String] = new_property(
  "org.eclipse.elk.edgeRouting", "POLYLINE",
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
enum LayeredGraphPlacerKind {
  SimpleRow
  ComponentGroup
  ComponentGroupModelOrder
  ModelOrderRow
}

///|
fn layered_components_sort_by_model_order(components : Array[LGraph]) -> Unit {
  let length = components.length()
  for i in 1..<length {
    let current = components[i]
    let mut j = i
    while j > 0 && current.get_id() < components[j - 1].get_id() {
      components[j] = components[j - 1]
      j -= 1
    }
    components[j] = current
  }
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
  let ext_ports = graph.get_property_bool(layered_components_has_external_ports)

  let result = if separate { [graph] } else { [graph] }

  if separate && ext_ports {
    match
      graph.get_property_component_ordering_strategy(
        layered_components_consider_model_order_components,
      ) {
      ComponentOrderingStrategy::GroupModelOrder =>
        self.graph_placer_kind = LayeredGraphPlacerKind::ComponentGroupModelOrder
      ComponentOrderingStrategy::ModelOrder =>
        self.graph_placer_kind = LayeredGraphPlacerKind::ModelOrderRow
      _ => self.graph_placer_kind = LayeredGraphPlacerKind::ComponentGroup
    }
  }

  if !component_ordering_strategy_equals(
      graph.get_property_component_ordering_strategy(
        layered_components_consider_model_order_components,
      ),
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
