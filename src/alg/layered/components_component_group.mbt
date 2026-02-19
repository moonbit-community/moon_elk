///|
fn component_group_side_bit(side : @core.PortSide) -> Int {
  match side {
    North => 1
    East => 2
    South => 4
    West => 8
    @core.PortSide::SideUndefined => 0
  }
}

///|
fn component_group_sides_key(sides : Array[@core.PortSide]) -> Int {
  let mut key = 0
  for side in sides {
    key = key | component_group_side_bit(side)
  }
  key
}

///|
fn component_group_key_to_sides(key : Int) -> Array[@core.PortSide] {
  let result = []
  if (key & 1) != 0 {
    result.push(@core.PortSide::North)
  }
  if (key & 2) != 0 {
    result.push(@core.PortSide::East)
  }
  if (key & 4) != 0 {
    result.push(@core.PortSide::South)
  }
  if (key & 8) != 0 {
    result.push(@core.PortSide::West)
  }
  result
}

///|
fn component_group_add_constraint(
  constraints : Map[Int, Array[Int]],
  source : Array[@core.PortSide],
  target : Array[@core.PortSide],
) -> Unit {
  let source_key = component_group_sides_key(source)
  let target_key = component_group_sides_key(target)
  match constraints.get(source_key) {
    Some(existing) => {
      existing.push(target_key)
      constraints[source_key] = existing
    }
    None => constraints[source_key] = [target_key]
  }
}

///|
fn init_component_group_constraints() -> Map[Int, Array[Int]] {
  let constraints : Map[Int, Array[Int]] = {}

  component_group_add_constraint(
    constraints, @core.sides_none, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_west, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_south, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_south, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_west, @core.sides_north_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_west, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_west, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_north_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_north_east,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_south_west, @core.sides_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_south_west, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_south_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north_east,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_west, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_north_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_east_south_west, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_north_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_south_west, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_east,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_north_east,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south, @core.sides_north_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_none,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_east,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_north,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_north_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_north_east_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_east_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_north_south_west,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_north_east_south,
  )
  component_group_add_constraint(
    constraints, @core.sides_north_east_south_west, @core.sides_north_east_south_west,
  )

  constraints
}

///|
let component_group_constraints : Map[Int, Array[Int]] = init_component_group_constraints()

///|
pub struct ComponentGroup {
  components : Map[Int, Array[LGraph]]
}

///|
pub fn new_component_group() -> ComponentGroup {
  { components: {} }
}

///|
pub fn new_component_group_with_component(component : LGraph) -> ComponentGroup {
  let group = new_component_group()
  ignore(group.add(component))
  group
}

///|
pub fn ComponentGroup::add(self : ComponentGroup, component : LGraph) -> Bool {
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
  true
}

///|
pub fn ComponentGroup::can_add(
  self : ComponentGroup,
  component : LGraph,
) -> Bool {
  let candidate_sides = component.get_property_port_side_array(
    internal_properties_ext_port_connections,
  )
  let candidate_key = component_group_sides_key(candidate_sides)
  let constraints = match component_group_constraints.get(candidate_key) {
    Some(conflicts) => conflicts
    None => []
  }

  for constraint in constraints {
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
pub fn ComponentGroup::get_port_sides(
  self : ComponentGroup,
) -> Array[Array[@core.PortSide]] {
  let result = []
  for entry in self.components.to_array() {
    let (key, _value) = entry
    result.push(component_group_key_to_sides(key))
  }
  result
}

///|
pub fn ComponentGroup::get_components(self : ComponentGroup) -> Array[LGraph] {
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
pub fn ComponentGroup::get_components_with_connections(
  self : ComponentGroup,
  connections : Array[@core.PortSide],
) -> Array[LGraph] {
  let key = component_group_sides_key(connections)
  match self.components.get(key) {
    Some(graphs) => graphs.copy()
    None => []
  }
}
