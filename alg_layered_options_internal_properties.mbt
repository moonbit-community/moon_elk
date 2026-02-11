///|
pub let internal_properties_ext_port_connections : IProperty[Array[PortSide]] = new_property(
  "externalPortConnections", sides_none,
)

///|
pub let internal_properties_tarjan_lowlink : IProperty[Int] = new_property(
  "tarjan.lowlink", @int.max_value,
)

///|
pub let internal_properties_tarjan_id : IProperty[Int] = new_property(
  "tarjan.id", -1,
)

///|
pub let internal_properties_tarjan_on_stack : IProperty[Bool] = new_property(
  "tarjan.onstack", false,
)

///|
pub let internal_properties_is_part_of_cycle : IProperty[Bool] = new_property(
  "partOfCycle", false,
)
