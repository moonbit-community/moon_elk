///|
pub type ElkGraphModelAdapter = Unit

///|
pub struct ElkGraphAdapterFactory {
  model_package : ElkGraphPackage
}

///|
pub fn new_elk_graph_adapter_factory() -> ElkGraphAdapterFactory {
  { model_package: elk_graph_package_instance }
}

///|
pub fn ElkGraphAdapterFactory::is_factory_for_type(
  self : ElkGraphAdapterFactory,
  package_id : ElkGraphPackage,
) -> Bool {
  package_id == self.model_package
}

///|
pub fn ElkGraphAdapterFactory::create_i_property_holder_adapter(
  self : ElkGraphAdapterFactory,
  _object : IPropertyHolder,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_e_map_property_holder_adapter(
  self : ElkGraphAdapterFactory,
  _object : EMapPropertyHolder,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_graph_element_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkGraphElement,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_shape_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkShape,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_label_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkLabel,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_connectable_shape_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkConnectableShape,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_node_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkNode,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_port_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkPort,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_edge_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkEdge,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_bend_point_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkBendPoint,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_edge_section_adapter(
  self : ElkGraphAdapterFactory,
  _object : ElkEdgeSection,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_property_to_value_map_entry_adapter(
  self : ElkGraphAdapterFactory,
  _object : Json,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_e_object_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_adapter(
  self : ElkGraphAdapterFactory,
  target : ElkGraphSwitchTarget,
) -> ElkGraphModelAdapter? {
  new_elk_graph_switch(
    case_i_property_holder=object => {
      self.create_i_property_holder_adapter(object)
    },
    case_e_map_property_holder=object => {
      self.create_e_map_property_holder_adapter(object)
    },
    case_elk_graph_element=object => {
      self.create_elk_graph_element_adapter(object)
    },
    case_elk_shape=object => self.create_elk_shape_adapter(object),
    case_elk_label=object => self.create_elk_label_adapter(object),
    case_elk_connectable_shape=object => {
      self.create_elk_connectable_shape_adapter(object)
    },
    case_elk_node=object => self.create_elk_node_adapter(object),
    case_elk_port=object => self.create_elk_port_adapter(object),
    case_elk_edge=object => self.create_elk_edge_adapter(object),
    case_elk_bend_point=object => self.create_elk_bend_point_adapter(object),
    case_elk_edge_section=object => self.create_elk_edge_section_adapter(object),
    case_elk_property_to_value_map_entry=object => {
      self.create_elk_property_to_value_map_entry_adapter(object)
    },
    default_case=() => self.create_e_object_adapter(),
  ).do_switch(target)
}
