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
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_e_map_property_holder_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_graph_element_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_shape_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_label_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_connectable_shape_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_node_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_port_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_edge_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_bend_point_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_edge_section_adapter(
  self : ElkGraphAdapterFactory,
) -> ElkGraphModelAdapter? {
  ignore(self)
  None
}

///|
pub fn ElkGraphAdapterFactory::create_elk_property_to_value_map_entry_adapter(
  self : ElkGraphAdapterFactory,
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
    case_i_property_holder=_ => self.create_i_property_holder_adapter(),
    case_e_map_property_holder=_ => self.create_e_map_property_holder_adapter(),
    case_elk_graph_element=_ => self.create_elk_graph_element_adapter(),
    case_elk_shape=_ => self.create_elk_shape_adapter(),
    case_elk_label=_ => self.create_elk_label_adapter(),
    case_elk_connectable_shape=_ => self.create_elk_connectable_shape_adapter(),
    case_elk_node=_ => self.create_elk_node_adapter(),
    case_elk_port=_ => self.create_elk_port_adapter(),
    case_elk_edge=_ => self.create_elk_edge_adapter(),
    case_elk_bend_point=_ => self.create_elk_bend_point_adapter(),
    case_elk_edge_section=_ => self.create_elk_edge_section_adapter(),
    case_elk_property_to_value_map_entry=_ => {
      self.create_elk_property_to_value_map_entry_adapter()
    },
    default_case=() => self.create_e_object_adapter(),
  ).do_switch(target)
}
