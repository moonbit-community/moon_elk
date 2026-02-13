///|
pub struct GroupModelOrderCalculator {
  mut first_separate_nodes : Int
  mut last_separate_nodes : Int
}

///|
pub fn new_group_model_order_calculator() -> GroupModelOrderCalculator {
  { first_separate_nodes: 0, last_separate_nodes: 0 }
}

///|
pub fn GroupModelOrderCalculator::compute_constraint_model_order(
  self : GroupModelOrderCalculator,
  node : LNode,
  offset : Int,
) -> Int {
  let mut model_order = 0
  match
    layer_constraint_from_string(
      node.get_property_string(layered_options_layering_layer_constraint),
    ) {
    LayerConstraint::FirstSeparate => {
      model_order = 2 * -offset + self.first_separate_nodes
      self.first_separate_nodes += 1
    }
    LayerConstraint::First => model_order = -offset
    LayerConstraint::Last => model_order = offset
    LayerConstraint::LastSeparate => {
      model_order = 2 * offset + self.last_separate_nodes
      self.last_separate_nodes += 1
    }
    _ => ()
  }

  if node.has_property_int(internal_properties_model_order) {
    model_order += node.get_property_int(internal_properties_model_order)
  }
  model_order
}

///|
pub fn GroupModelOrderCalculator::compute_constraint_group_model_order(
  self : GroupModelOrderCalculator,
  node : LNode,
  offset : Int,
  small_offset : Int,
) -> Int {
  let mut model_order = 0
  match
    layer_constraint_from_string(
      node.get_property_string(layered_options_layering_layer_constraint),
    ) {
    LayerConstraint::FirstSeparate => {
      model_order = 2 * -offset + self.first_separate_nodes
      self.first_separate_nodes += 1
    }
    LayerConstraint::First => model_order = -offset
    LayerConstraint::Last => model_order = offset
    LayerConstraint::LastSeparate => {
      model_order = 2 * offset + self.last_separate_nodes
      self.last_separate_nodes += 1
    }
    _ => ()
  }

  if node.has_property_int(internal_properties_model_order) {
    model_order += node.get_property_int(
        layered_options_consider_model_order_group_model_order_cycle_breaking_id,
      ) *
      small_offset +
      node.get_property_int(internal_properties_model_order)
  }
  model_order
}

///|
pub fn GroupModelOrderCalculator::reset_internal_counters(
  self : GroupModelOrderCalculator,
) -> Unit {
  self.first_separate_nodes = 0
  self.last_separate_nodes = 0
}
