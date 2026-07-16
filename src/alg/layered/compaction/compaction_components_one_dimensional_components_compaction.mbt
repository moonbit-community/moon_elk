///|
priv enum ComponentsCompactionAxis {
  Horz
  Vert
}

///|
fn components_compaction_od_double_min(left : Double, right : Double) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn components_compaction_od_double_max(left : Double, right : Double) -> Double {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn[T : Eq] components_compaction_contains(values : Array[T], value : T) -> Bool {
  for current in values {
    if current == value {
      return true
    }
  }
  false
}

///|
fn[T : Eq] components_compaction_array_remove_first(
  array : Array[T],
  value : T,
) -> Bool {
  for i in 0..<array.length() {
    if array[i] == value {
      ignore(array.remove(i))
      return true
    }
  }
  false
}

///|
fn components_compaction_direction_is_horizontal(
  direction : @core.Direction,
) -> Bool {
  match direction {
    Leftward => true
    Rightward => true
    _ => false
  }
}

///|
fn components_compaction_direction_is_vertical(
  direction : @core.Direction,
) -> Bool {
  match direction {
    Upward => true
    Downward => true
    _ => false
  }
}

///|
fn _components_compaction_axis_directions(
  axis : ComponentsCompactionAxis,
) -> Array[@core.Direction] {
  match axis {
    Horz => [Leftward, Rightward]
    Vert => [Upward, Downward]
  }
}

///|
fn components_compaction_direction_in_axis(
  direction : @core.Direction,
  axis : ComponentsCompactionAxis,
) -> Bool {
  match axis {
    Horz => components_compaction_direction_is_horizontal(direction)
    Vert => components_compaction_direction_is_vertical(direction)
  }
}

///|
fn components_compaction_reset_group_deltas(
  groups : Array[@common.CGroup],
) -> Unit {
  for group in groups {
    let current_delta = group.delta()
    if current_delta != 0.0 {
      group.add_delta(-current_delta)
    }
    let current_delta_normalized = group.delta_normalized()
    if current_delta_normalized != 0.0 {
      group.add_delta_normalized(-current_delta_normalized)
    }
  }
}

///|
fn components_compaction_compact_in_direction(
  compactor : @common.OneDimensionalCompactor,
  direction : @core.Direction,
  recalculate_constraints_for_first_run : Bool,
) -> Unit {
  let lock_function = compactor.lock_fun

  ignore(compactor.set_lock_function(None))
  ignore(compactor.change_direction(direction))
  if recalculate_constraints_for_first_run {
    ignore(compactor.force_constraints_recalculation())
  }
  ignore(compactor.compact())

  ignore(compactor.set_lock_function(lock_function))
  ignore(compactor.change_direction(direction.opposite()))
  ignore(compactor.compact())
  ignore(compactor.change_direction(direction))
  ignore(compactor.compact())
}

///|
pub struct OneDimensionalComponentsCompaction[N, E] {
  compaction_graph : @common.CGraph
  transformer : ComponentsToCGraphTransformer[N, E]
  vertical_external_extensions : Array[(@common.CGroup, @common.CNode)]
  horizontal_external_extensions : Array[(@common.CGroup, @common.CNode)]
  mut top_left : @core.KVector
  mut bottom_right : @core.KVector
}

///|
let components_compaction_max_iteration = 10

///|
let components_compaction_epsilon = 0.0001

///|
pub fn[N, E] init_one_dimensional_components_compaction(
  connected_components : IConnectedComponents[N, E],
  spacing : Double,
) -> OneDimensionalComponentsCompaction[N, E] {
  let transformer = new_components_to_cgraph_transformer(spacing)
  let compaction_graph = transformer.transform(connected_components)
  {
    compaction_graph,
    transformer,
    vertical_external_extensions: [],
    horizontal_external_extensions: [],
    top_left: @core.new_kvector_xy(@double.infinity, @double.infinity),
    bottom_right: @core.new_kvector_xy(-@double.infinity, -@double.infinity),
  }
}

///|
pub fn[N, E] new_one_dimensional_components_compaction(
  connected_components : IConnectedComponents[N, E],
  spacing : Double,
) -> OneDimensionalComponentsCompaction[N, E] {
  init_one_dimensional_components_compaction(connected_components, spacing)
}

///|
fn[N, E] OneDimensionalComponentsCompaction::add_external_edge_representations(
  self : OneDimensionalComponentsCompaction[N, E],
  external_edges : Array[(@common.CGroup, @common.CNode)],
) -> Unit {
  for external_edge in external_edges {
    let (group, node) = external_edge
    if !components_compaction_contains(self.compaction_graph.c_nodes, node) {
      self.compaction_graph.c_nodes.push(node)
    }
    if node.group() is None {
      group.add_cnode(node)
    }
  }
}

///|
fn[N, E] OneDimensionalComponentsCompaction::remove_external_edge_representations(
  self : OneDimensionalComponentsCompaction[N, E],
  external_edges : Array[(@common.CGroup, @common.CNode)],
) -> Unit {
  for external_edge in external_edges {
    let (group, node) = external_edge
    ignore(
      components_compaction_array_remove_first(
        self.compaction_graph.c_nodes,
        node,
      ),
    )
    ignore(group.remove_cnode(node))
  }
}

///|
fn[N, E] OneDimensionalComponentsCompaction::add_placeholders(
  self : OneDimensionalComponentsCompaction[N, E],
  axis : ComponentsCompactionAxis,
) -> Unit {
  for placeholder_entry in self.transformer.get_external_placeholders() {
    let (direction, placeholder_pair) = placeholder_entry
    let (_parent_group, node) = placeholder_pair
    if !components_compaction_direction_in_axis(direction, axis) {
      continue
    }
    if !components_compaction_contains(self.compaction_graph.c_nodes, node) {
      self.compaction_graph.c_nodes.push(node)
    }
    match node.group() {
      Some(group) =>
        if !components_compaction_contains(
            self.compaction_graph.c_groups,
            group,
          ) {
          self.compaction_graph.c_groups.push(group)
        }
      None => ()
    }
  }
}

///|
fn[N, E] OneDimensionalComponentsCompaction::remove_placeholders(
  self : OneDimensionalComponentsCompaction[N, E],
  axis : ComponentsCompactionAxis,
) -> Unit {
  for placeholder_entry in self.transformer.get_external_placeholders() {
    let (direction, placeholder_pair) = placeholder_entry
    let (_parent_group, node) = placeholder_pair
    if !components_compaction_direction_in_axis(direction, axis) {
      continue
    }
    ignore(
      components_compaction_array_remove_first(
        self.compaction_graph.c_nodes,
        node,
      ),
    )
    match node.group() {
      Some(group) =>
        ignore(
          components_compaction_array_remove_first(
            self.compaction_graph.c_groups,
            group,
          ),
        )
      None => ()
    }
  }
}

///|
fn[N, E] OneDimensionalComponentsCompaction::update_placeholders(
  self : OneDimensionalComponentsCompaction[N, E],
  axis : ComponentsCompactionAxis,
) -> Unit {
  for placeholder_entry in self.transformer.get_external_placeholders() {
    let (direction, placeholder_pair) = placeholder_entry
    let (parent_group, node) = placeholder_pair
    if !components_compaction_direction_in_axis(direction, axis) {
      continue
    }
    let adelta = parent_group.delta_normalized()
    let hitbox = node.hitbox()
    match direction {
      Leftward => hitbox.y = hitbox.y + adelta
      Rightward => hitbox.y = hitbox.y + adelta
      Upward => hitbox.x = hitbox.x + adelta
      Downward => hitbox.x = hitbox.x + adelta
      Undefined => ()
    }
    node.set_hitbox(hitbox)
  }
}

///|
fn[N, E] OneDimensionalComponentsCompaction::update_external_extension_dimensions(
  self : OneDimensionalComponentsCompaction[N, E],
  axis : ComponentsCompactionAxis,
) -> Unit {
  for external_extension_entry in self.transformer.get_external_extensions() {
    let (external_extension, group_node_pair) = external_extension_entry
    let (group, node) = group_node_pair
    if !components_compaction_direction_in_axis(
        external_extension.get_direction(),
        axis,
      ) {
      continue
    }

    let adelta = group.delta_normalized()
    let hitbox = node.hitbox()

    match external_extension.get_direction() {
      Leftward => {
        hitbox.x = self.top_left.x
        hitbox.width = components_compaction_od_double_max(
          hitbox.width + adelta,
          1.0,
        )
      }
      Rightward => {
        hitbox.x = hitbox.x + adelta
        hitbox.width = components_compaction_od_double_max(
          hitbox.width - adelta,
          1.0,
        )
      }
      Upward => {
        hitbox.y = self.top_left.y
        hitbox.height = components_compaction_od_double_max(
          hitbox.height + adelta,
          1.0,
        )
      }
      Downward => {
        hitbox.y = hitbox.y + adelta
        hitbox.height = components_compaction_od_double_max(
          hitbox.height - adelta,
          1.0,
        )
      }
      Undefined => ()
    }

    node.set_hitbox(hitbox)
  }
}

///|
fn[N, E] OneDimensionalComponentsCompaction::compact_iteration(
  self : OneDimensionalComponentsCompaction[N, E],
  compactor : @common.OneDimensionalCompactor,
) -> Double {
  let mut delta = 0.0

  components_compaction_reset_group_deltas(self.compaction_graph.c_groups)

  self.add_placeholders(Horz)
  self.add_external_edge_representations(self.vertical_external_extensions)
  ignore(compactor.calculate_group_offsets())
  ignore(compactor.force_constraints_recalculation())

  components_compaction_compact_in_direction(compactor, Leftward, false)
  ignore(compactor.change_direction(Leftward))

  self.remove_external_edge_representations(self.vertical_external_extensions)
  self.remove_placeholders(Horz)
  self.update_external_extension_dimensions(Horz)
  self.update_placeholders(Vert)

  self.add_placeholders(Vert)
  self.add_external_edge_representations(self.horizontal_external_extensions)
  ignore(compactor.calculate_group_offsets())

  for group in self.compaction_graph.c_groups {
    delta = delta + group.delta_normalized().abs()
  }

  components_compaction_reset_group_deltas(self.compaction_graph.c_groups)

  components_compaction_compact_in_direction(compactor, Upward, true)
  ignore(compactor.change_direction(Leftward))

  self.remove_external_edge_representations(self.horizontal_external_extensions)
  self.remove_placeholders(Vert)
  self.update_external_extension_dimensions(Vert)
  self.update_placeholders(Horz)

  ignore(compactor.force_constraints_recalculation())

  for group in self.compaction_graph.c_groups {
    delta = delta + group.delta_normalized().abs()
  }

  delta
}

///|
pub fn[N, E] OneDimensionalComponentsCompaction::compact(
  self : OneDimensionalComponentsCompaction[N, E],
  _monitor : @core.IElkProgressMonitor,
) -> Unit {
  let all_nodes : Array[@common.CNode] = []
  self.vertical_external_extensions.clear()
  self.horizontal_external_extensions.clear()

  for external_extension_entry in self.transformer.get_external_extensions() {
    let (external_extension, group_node_pair) = external_extension_entry
    let (group, node) = group_node_pair
    all_nodes.push(node)
    if external_extension.get_direction().is_horizontal() {
      self.horizontal_external_extensions.push((group, node))
    } else {
      self.vertical_external_extensions.push((group, node))
    }
  }

  self.add_external_edge_representations(self.horizontal_external_extensions)
  self.add_external_edge_representations(self.vertical_external_extensions)

  let compactor = @common.new_one_dimensional_compactor(self.compaction_graph)
  ignore(
    compactor.set_spacings_handler(
      components_to_cgraph_spacing_handler(self.transformer),
    ),
  )

  self.remove_external_edge_representations(self.horizontal_external_extensions)
  self.remove_external_edge_representations(self.vertical_external_extensions)

  for node in compactor.c_graph.c_nodes {
    all_nodes.push(node)
  }

  self.top_left = @core.new_kvector_xy(@double.infinity, @double.infinity)
  self.bottom_right = @core.new_kvector_xy(-@double.infinity, -@double.infinity)
  for node in all_nodes {
    let hitbox = node.hitbox()
    self.top_left.x = components_compaction_od_double_min(
      self.top_left.x,
      hitbox.x,
    )
    self.top_left.y = components_compaction_od_double_min(
      self.top_left.y,
      hitbox.y,
    )
    self.bottom_right.x = components_compaction_od_double_max(
      self.bottom_right.x,
      hitbox.x + hitbox.width,
    )
    self.bottom_right.y = components_compaction_od_double_max(
      self.bottom_right.y,
      hitbox.y + hitbox.height,
    )
  }

  if compactor.c_graph.c_nodes.length() <= 1 {
    ignore(compactor.finish())
    self.transformer.apply_layout()
    return
  }

  ignore(
    compactor.set_lock_function(
      Some((node, _direction) => {
        match node.group() {
          Some(group) => group.out_degree() != 0
          None => false
        }
      }),
    ),
  )

  let mut run = 0
  let mut delta = 0.0
  let mut should_continue = true
  while should_continue {
    delta = self.compact_iteration(compactor)
    run = run + 1
    should_continue = (run < 2 || delta > components_compaction_epsilon) &&
      run < components_compaction_max_iteration
  }

  ignore(
    compactor.set_lock_function(
      Some((node, direction) => {
        self.transformer.is_locked(node, direction) ||
        (match node.group() {
          Some(group) =>
            group.out_degree() != 0 &&
            self.transformer.is_locked(node, direction)
          None => false
        })
      }),
    ),
  )
  ignore(self.compact_iteration(compactor))

  ignore(compactor.finish())
  self.transformer.apply_layout()
}

///|
pub fn[N, E] OneDimensionalComponentsCompaction::get_graph_size(
  self : OneDimensionalComponentsCompaction[N, E],
) -> @core.KVector {
  self.transformer.get_graph_size()
}

///|
pub fn[N, E] OneDimensionalComponentsCompaction::get_offset(
  self : OneDimensionalComponentsCompaction[N, E],
  component : IComponent[N, E],
) -> @core.KVector {
  self.transformer
  .get_offset(component)
  .negate()
  .add(self.transformer.get_global_offset())
}
