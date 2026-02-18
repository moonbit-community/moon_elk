///|
pub enum ElkGraphSwitchTarget {
  IPropertyHolderTarget(IPropertyHolder)
  EMapPropertyHolderTarget(EMapPropertyHolder)
  ElkGraphElementTarget(ElkGraphElement)
  ElkShapeTarget(ElkShape)
  ElkLabelTarget(ElkLabel)
  ElkConnectableShapeTarget(ElkConnectableShape)
  ElkNodeTarget(ElkNode)
  ElkPortTarget(ElkPort)
  ElkEdgeTarget(ElkEdge)
  ElkBendPointTarget(ElkBendPoint)
  ElkEdgeSectionTarget(ElkEdgeSection)
  ElkPropertyToValueMapEntryTarget(Json)
}

///|
pub fn elk_switch_target_i_property_holder(
  object : IPropertyHolder,
) -> ElkGraphSwitchTarget {
  IPropertyHolderTarget(object)
}

///|
pub fn elk_switch_target_e_map_property_holder(
  object : EMapPropertyHolder,
) -> ElkGraphSwitchTarget {
  EMapPropertyHolderTarget(object)
}

///|
pub fn elk_switch_target_elk_graph_element(
  object : ElkGraphElement,
) -> ElkGraphSwitchTarget {
  ElkGraphElementTarget(object)
}

///|
pub fn elk_switch_target_elk_shape(object : ElkShape) -> ElkGraphSwitchTarget {
  ElkShapeTarget(object)
}

///|
pub fn elk_switch_target_elk_label(object : ElkLabel) -> ElkGraphSwitchTarget {
  ElkLabelTarget(object)
}

///|
pub fn elk_switch_target_elk_connectable_shape(
  object : ElkConnectableShape,
) -> ElkGraphSwitchTarget {
  ElkConnectableShapeTarget(object)
}

///|
pub fn elk_switch_target_elk_node(object : ElkNode) -> ElkGraphSwitchTarget {
  ElkNodeTarget(object)
}

///|
pub fn elk_switch_target_elk_port(object : ElkPort) -> ElkGraphSwitchTarget {
  ElkPortTarget(object)
}

///|
pub fn elk_switch_target_elk_edge(object : ElkEdge) -> ElkGraphSwitchTarget {
  ElkEdgeTarget(object)
}

///|
pub fn elk_switch_target_elk_bend_point(
  object : ElkBendPoint,
) -> ElkGraphSwitchTarget {
  ElkBendPointTarget(object)
}

///|
pub fn elk_switch_target_elk_edge_section(
  object : ElkEdgeSection,
) -> ElkGraphSwitchTarget {
  ElkEdgeSectionTarget(object)
}

///|
pub fn elk_switch_target_elk_property_to_value_map_entry(
  object : Json,
) -> ElkGraphSwitchTarget {
  ElkPropertyToValueMapEntryTarget(object)
}

///|
pub struct ElkGraphSwitch[T] {
  model_package : ElkGraphPackage
  case_i_property_holder_fn : (IPropertyHolder) -> T?
  case_e_map_property_holder_fn : (EMapPropertyHolder) -> T?
  case_elk_graph_element_fn : (ElkGraphElement) -> T?
  case_elk_shape_fn : (ElkShape) -> T?
  case_elk_label_fn : (ElkLabel) -> T?
  case_elk_connectable_shape_fn : (ElkConnectableShape) -> T?
  case_elk_node_fn : (ElkNode) -> T?
  case_elk_port_fn : (ElkPort) -> T?
  case_elk_edge_fn : (ElkEdge) -> T?
  case_elk_bend_point_fn : (ElkBendPoint) -> T?
  case_elk_edge_section_fn : (ElkEdgeSection) -> T?
  case_elk_property_to_value_map_entry_fn : (Json) -> T?
  default_case_fn : () -> T?
}

///|
pub fn[T] new_elk_graph_switch(
  case_i_property_holder? : (IPropertyHolder) -> T? = _ => None,
  case_e_map_property_holder? : (EMapPropertyHolder) -> T? = _ => None,
  case_elk_graph_element? : (ElkGraphElement) -> T? = _ => None,
  case_elk_shape? : (ElkShape) -> T? = _ => None,
  case_elk_label? : (ElkLabel) -> T? = _ => None,
  case_elk_connectable_shape? : (ElkConnectableShape) -> T? = _ => None,
  case_elk_node? : (ElkNode) -> T? = _ => None,
  case_elk_port? : (ElkPort) -> T? = _ => None,
  case_elk_edge? : (ElkEdge) -> T? = _ => None,
  case_elk_bend_point? : (ElkBendPoint) -> T? = _ => None,
  case_elk_edge_section? : (ElkEdgeSection) -> T? = _ => None,
  case_elk_property_to_value_map_entry? : (Json) -> T? = _ => None,
  default_case? : () -> T? = () => None,
) -> ElkGraphSwitch[T] {
  {
    model_package: elk_graph_package_instance,
    case_i_property_holder_fn: case_i_property_holder,
    case_e_map_property_holder_fn: case_e_map_property_holder,
    case_elk_graph_element_fn: case_elk_graph_element,
    case_elk_shape_fn: case_elk_shape,
    case_elk_label_fn: case_elk_label,
    case_elk_connectable_shape_fn: case_elk_connectable_shape,
    case_elk_node_fn: case_elk_node,
    case_elk_port_fn: case_elk_port,
    case_elk_edge_fn: case_elk_edge,
    case_elk_bend_point_fn: case_elk_bend_point,
    case_elk_edge_section_fn: case_elk_edge_section,
    case_elk_property_to_value_map_entry_fn: case_elk_property_to_value_map_entry,
    default_case_fn: default_case,
  }
}

///|
pub fn[T] ElkGraphSwitch::is_switch_for(
  self : ElkGraphSwitch[T],
  package_id : ElkGraphPackage,
) -> Bool {
  package_id == self.model_package
}

///|
pub fn[T] ElkGraphSwitch::do_switch(
  self : ElkGraphSwitch[T],
  target : ElkGraphSwitchTarget,
) -> T? {
  fn chain(result : T?, fallback : () -> T?) -> T? {
    match result {
      Some(_) => result
      None => fallback()
    }
  }

  match target {
    IPropertyHolderTarget(holder) =>
      chain((self.case_i_property_holder_fn)(holder), self.default_case_fn)
    EMapPropertyHolderTarget(holder) =>
      chain((self.case_e_map_property_holder_fn)(holder), () => {
        chain((self.case_i_property_holder_fn)(holder), self.default_case_fn)
      })
    ElkGraphElementTarget(element) =>
      chain((self.case_elk_graph_element_fn)(element), self.default_case_fn)
    ElkShapeTarget(shape) =>
      chain((self.case_elk_shape_fn)(shape), () => {
        chain((self.case_elk_graph_element_fn)(shape), self.default_case_fn)
      })
    ElkLabelTarget(label) =>
      chain((self.case_elk_label_fn)(label), () => {
        chain((self.case_elk_shape_fn)(label), () => {
          chain((self.case_elk_graph_element_fn)(label), self.default_case_fn)
        })
      })
    ElkConnectableShapeTarget(shape) => {
      let shape_as_shape = match shape {
        NodeShape(node) => node
        PortShape(port) => port
      }
      chain((self.case_elk_connectable_shape_fn)(shape), () => {
        chain((self.case_elk_shape_fn)(shape_as_shape), () => {
          chain(
            (self.case_elk_graph_element_fn)(shape_as_shape),
            self.default_case_fn,
          )
        })
      })
    }
    ElkNodeTarget(node) =>
      chain((self.case_elk_node_fn)(node), () => {
        chain((self.case_elk_connectable_shape_fn)(make_node_shape(node)), () => {
          chain((self.case_elk_shape_fn)(node), () => {
            chain((self.case_elk_graph_element_fn)(node), self.default_case_fn)
          })
        })
      })
    ElkPortTarget(port) =>
      chain((self.case_elk_port_fn)(port), () => {
        chain((self.case_elk_connectable_shape_fn)(make_port_shape(port)), () => {
          chain((self.case_elk_shape_fn)(port), () => {
            chain((self.case_elk_graph_element_fn)(port), self.default_case_fn)
          })
        })
      })
    ElkEdgeTarget(edge) =>
      chain((self.case_elk_edge_fn)(edge), () => {
        chain((self.case_elk_graph_element_fn)(edge), self.default_case_fn)
      })
    ElkBendPointTarget(bend_point) =>
      chain((self.case_elk_bend_point_fn)(bend_point), self.default_case_fn)
    ElkEdgeSectionTarget(section) =>
      chain((self.case_elk_edge_section_fn)(section), self.default_case_fn)
    ElkPropertyToValueMapEntryTarget(entry) =>
      chain(
        (self.case_elk_property_to_value_map_entry_fn)(entry),
        self.default_case_fn,
      )
  }
}
