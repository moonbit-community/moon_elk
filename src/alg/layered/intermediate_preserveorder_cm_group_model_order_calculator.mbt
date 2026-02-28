///|
pub fn cm_group_model_order_calculate_model_order_or_group_model_order(
  element : LNode,
  other : LNode,
  parent : LGraph,
  offset : Int,
) -> Int {
  let group_order_strategy = group_order_strategy_from_string(
    parent.get_property_string(
      layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    ),
  )
  let enforce_group_model_order = group_order_strategy_equals(
    group_order_strategy,
    GroupOrderStrategy::Enforced,
  )
  let enforced_orders = layered_options_parse_int_list(
    parent.get_property_string(
      layered_options_consider_model_order_group_model_order_cm_enforced_group_orders,
    ),
  )

  if !element.has_property_int(internal_properties_model_order) {
    return -1
  } else if enforce_group_model_order {
    let element_group_id = element.get_property_int(
      layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    )
    let other_group_id = other.get_property_int(
      layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    )
    if layered_options_int_list_contains(enforced_orders, element_group_id) &&
      layered_options_int_list_contains(enforced_orders, other_group_id) {
      return offset * element_group_id +
        element.get_property_int(internal_properties_model_order)
    }
  }

  element.get_property_int(internal_properties_model_order)
}

///|
pub fn cm_group_model_order_calculate_model_order_or_group_model_order_port(
  element : LPort,
  other : LPort,
  parent : LGraph,
  offset : Int,
) -> Int {
  let group_order_strategy = group_order_strategy_from_string(
    parent.get_property_string(
      layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    ),
  )
  let enforce_group_model_order = group_order_strategy_equals(
    group_order_strategy,
    GroupOrderStrategy::Enforced,
  )
  let enforced_orders = layered_options_parse_int_list(
    parent.get_property_string(
      layered_options_consider_model_order_group_model_order_cm_enforced_group_orders,
    ),
  )

  if !element.has_property_int(internal_properties_model_order) {
    return -1
  } else if enforce_group_model_order {
    let element_group_id = element.get_property_int(
      layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    )
    let other_group_id = other.get_property_int(
      layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    )
    if layered_options_int_list_contains(enforced_orders, element_group_id) &&
      layered_options_int_list_contains(enforced_orders, other_group_id) {
      return offset * element_group_id +
        element.get_property_int(internal_properties_model_order)
    }
  }

  element.get_property_int(internal_properties_model_order)
}

///|
pub fn cm_group_model_order_calculate_model_order_or_group_model_order_edge(
  element : LEdge,
  other : LEdge,
  parent : LGraph,
  offset : Int,
) -> Int {
  let group_order_strategy = group_order_strategy_from_string(
    parent.get_property_string(
      layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    ),
  )
  let enforce_group_model_order = group_order_strategy_equals(
    group_order_strategy,
    GroupOrderStrategy::Enforced,
  )
  let enforced_orders = layered_options_parse_int_list(
    parent.get_property_string(
      layered_options_consider_model_order_group_model_order_cm_enforced_group_orders,
    ),
  )

  if !element.has_property_int(internal_properties_model_order) {
    return -1
  } else if enforce_group_model_order {
    let element_group_id = element.get_property_int(
      layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    )
    let other_group_id = other.get_property_int(
      layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    )
    if layered_options_int_list_contains(enforced_orders, element_group_id) &&
      layered_options_int_list_contains(enforced_orders, other_group_id) {
      return offset * element_group_id +
        element.get_property_int(internal_properties_model_order)
    }
  }

  element.get_property_int(internal_properties_model_order)
}
