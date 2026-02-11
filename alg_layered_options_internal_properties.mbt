///|
pub let internal_properties_origin_l_node : IProperty[LNode?] = new_property(
  "origin",
  None,
)

///|
pub let internal_properties_origin_l_port : IProperty[LPort?] = new_property(
  "origin",
  None,
)

///|
pub let internal_properties_in_layer_layout_unit : IProperty[LNode?] = new_property(
  "inLayerLayoutUnit",
  None,
)

///|
pub let internal_properties_in_layer_successor_constraints : IProperty[
  Array[LNode],
] = new_property("inLayerSuccessorConstraint", [])

///|
pub let internal_properties_in_layer_successor_constraints_between_non_dummies : IProperty[
  Bool,
] = new_property("inLayerSuccessorConstraintBetweenNonDummies", false)

///|
pub let internal_properties_port_dummy : IProperty[LNode?] = new_property(
  "portDummy",
  None,
)

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

///|
pub let internal_properties_barycenter_associates : IProperty[Array[LNode]] = new_property(
  "barycenterAssociates",
  [],
)

///|
pub let internal_properties_weight : IProperty[Double] = new_property(
  "medianHeuristic.weight", 0.0,
)
