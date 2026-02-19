///|
fn init_model_order_component_group_constraints() -> Map[Int, Array[Int]] {
  let constraints : Map[Int, Array[Int]] = {}

  component_group_add_constraint(constraints, @core.sides_north, @core.sides_none)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_none)
  component_group_add_constraint(constraints, @core.sides_north_east, @core.sides_none)
  component_group_add_constraint(constraints, @core.sides_north_west, @core.sides_none)
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_none,
  )
  component_group_add_constraint(constraints, @core.sides_north_east_west, @core.sides_none)

  component_group_add_constraint(constraints, @core.sides_north_west, @core.sides_north)

  component_group_add_constraint(constraints, @core.sides_none, @core.sides_east)
  component_group_add_constraint(constraints, @core.sides_north, @core.sides_east)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_east)
  component_group_add_constraint(constraints, @core.sides_north_east, @core.sides_east)
  component_group_add_constraint(constraints, @core.sides_north_south, @core.sides_east)
  component_group_add_constraint(constraints, @core.sides_north_west, @core.sides_east)
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_east,
  )
  component_group_add_constraint(constraints, @core.sides_north_east_west, @core.sides_east)
  component_group_add_constraint(constraints, @core.sides_east_west, @core.sides_east)

  component_group_add_constraint(constraints, @core.sides_none, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_north, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_east, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_north_east, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_north_south, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_north_west, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_east_west, @core.sides_south)
  component_group_add_constraint(constraints, @core.sides_south_west, @core.sides_south)
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_south,
  )

  component_group_add_constraint(constraints, @core.sides_north, @core.sides_west)
  component_group_add_constraint(constraints, @core.sides_north_east, @core.sides_west)
  component_group_add_constraint(constraints, @core.sides_north_west, @core.sides_west)
  component_group_add_constraint(constraints, @core.sides_north_east_west, @core.sides_west)

  component_group_add_constraint(constraints, @core.sides_north, @core.sides_north_east)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_north_east)
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_north_east,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_north_east,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_north_east,
  )

  component_group_add_constraint(constraints, @core.sides_none, @core.sides_east_south)
  component_group_add_constraint(constraints, @core.sides_north, @core.sides_east_south)
  component_group_add_constraint(constraints, @core.sides_east, @core.sides_east_south)
  component_group_add_constraint(constraints, @core.sides_south, @core.sides_east_south)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_east_south)
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_south_west, @core.sides_east_south,
  )
  component_group_add_constraint(constraints, @core.sides_east_west, @core.sides_east_south)
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_east_south,
  )

  component_group_add_constraint(constraints, @core.sides_none, @core.sides_south_west)
  component_group_add_constraint(constraints, @core.sides_north, @core.sides_south_west)
  component_group_add_constraint(constraints, @core.sides_east, @core.sides_south_west)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_south_west)
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_south_west,
  )
  component_group_add_constraint(constraints, @core.sides_east_west, @core.sides_south_west)
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_south_west,
  )

  component_group_add_constraint(constraints, @core.sides_north, @core.sides_east_west)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_east_west)
  component_group_add_constraint(constraints, @core.sides_north_east, @core.sides_east_west)
  component_group_add_constraint(constraints, @core.sides_north_west, @core.sides_east_west)
  component_group_add_constraint(constraints, @core.sides_south_west, @core.sides_east_west)
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_east_west,
  )

  component_group_add_constraint(constraints, @core.sides_none, @core.sides_east_south_west)
  component_group_add_constraint(
    constraints, @core.sides_north, @core.sides_east_south_west,
  )
  component_group_add_constraint(constraints, @core.sides_east, @core.sides_east_south_west)
  component_group_add_constraint(constraints, @core.sides_west, @core.sides_east_south_west)
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_west, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_east_south_west,
  )

  component_group_add_constraint(
    constraints, @core.sides_north, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_south, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_north_south_west,
  )

  component_group_add_constraint(
    constraints, @core.sides_none, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_south, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_west, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_north_east_south,
  )

  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_north_east_south_west,
  )

  component_group_add_constraint(constraints, @core.sides_east_west, @core.sides_none)
  component_group_add_constraint(constraints, @core.sides_east_west, @core.sides_west)
  component_group_add_constraint(constraints, @core.sides_east_west, @core.sides_east)

  component_group_add_constraint(constraints, @core.sides_north_south, @core.sides_none)
  component_group_add_constraint(constraints, @core.sides_north_south, @core.sides_north)
  component_group_add_constraint(constraints, @core.sides_north_south, @core.sides_south)

  constraints
}

///|
let model_order_component_group_constraints : Map[Int, Array[Int]] = init_model_order_component_group_constraints()

///|
pub struct ModelOrderComponentGroup {
  components : Map[Int, Array[LGraph]]
  component_order : Array[LGraph]
}

///|
pub fn new_model_order_component_group() -> ModelOrderComponentGroup {
  { components: {}, component_order: [] }
}

///|
pub fn new_model_order_component_group_with_component(
  component : LGraph,
) -> ModelOrderComponentGroup {
  let group = new_model_order_component_group()
  ignore(group.add(component))
  group
}

///|
pub fn ModelOrderComponentGroup::add(
  self : ModelOrderComponentGroup,
  component : LGraph,
) -> Bool {
  if !self.can_add(component) {
    return false
  }

  let sides = component.get_property_port_side_array(
    internal_properties_ext_port_connections,
  )
  let key = component_group_sides_key(sides)
  match self.components.get(key) {
    Some(existing) => {
      existing.push(component)
      self.components[key] = existing
    }
    None => self.components[key] = [component]
  }
  self.component_order.push(component)
  true
}

///|
pub fn ModelOrderComponentGroup::can_add(
  self : ModelOrderComponentGroup,
  component : LGraph,
) -> Bool {
  let candidate_sides = component.get_property_port_side_array(
    internal_properties_ext_port_connections,
  )
  let candidate_key = component_group_sides_key(candidate_sides)

  let common_constraints = match
    component_group_constraints.get(candidate_key) {
    Some(conflicts) => conflicts
    None => []
  }
  for constraint in common_constraints {
    match self.components.get(constraint) {
      Some(conflicting_components) =>
        if !conflicting_components.is_empty() {
          return false
        }
      None => ()
    }
  }

  let model_constraints = match
    model_order_component_group_constraints.get(candidate_key) {
    Some(conflicts) => conflicts
    None => []
  }
  for constraint in model_constraints {
    match self.components.get(constraint) {
      Some(conflicting_components) =>
        if !conflicting_components.is_empty() {
          return false
        }
      None => ()
    }
  }

  true
}

///|
pub fn ModelOrderComponentGroup::get_component_order(
  self : ModelOrderComponentGroup,
) -> Array[LGraph] {
  self.component_order
}

///|
pub fn ModelOrderComponentGroup::get_port_sides(
  self : ModelOrderComponentGroup,
) -> Array[Array[@core.PortSide]] {
  let result = []
  for entry in self.components.to_array() {
    let (key, _value) = entry
    result.push(component_group_key_to_sides(key))
  }
  result
}

///|
pub fn ModelOrderComponentGroup::get_components(
  self : ModelOrderComponentGroup,
) -> Array[LGraph] {
  let result = []
  for entry in self.components.to_array() {
    let (_key, graphs) = entry
    for graph in graphs {
      result.push(graph)
    }
  }
  result
}

///|
pub fn ModelOrderComponentGroup::get_components_with_connections(
  self : ModelOrderComponentGroup,
  connections : Array[@core.PortSide],
) -> Array[LGraph] {
  let key = component_group_sides_key(connections)
  match self.components.get(key) {
    Some(graphs) => graphs.copy()
    None => []
  }
}
