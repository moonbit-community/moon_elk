///|
pub struct OneDimensionalCompactor {
  c_graph : CGraph
  mut lock_fun : ILockFunction?
  mut spacings_handler : ISpacingsHandler
  mut direction : @core.Direction
  mut finished : Bool
  mut compaction_algorithm : ICompactionAlgorithm
  mut constraint_algorithm : IConstraintCalculationAlgorithm
}

///|
pub(all) suberror OneDimensionalCompactorException {
  IllegalStateException(String)
  IllegalArgumentException(String)
} derive(Show, ToJson)

///|
fn[T] one_dimensional_compactor_raise_illegal_state(
  message : String,
) -> T raise OneDimensionalCompactorException {
  raise OneDimensionalCompactorException::IllegalStateException(message)
}

///|
fn[T] one_dimensional_compactor_raise_illegal_argument(
  message : String,
) -> T raise OneDimensionalCompactorException {
  raise OneDimensionalCompactorException::IllegalArgumentException(message)
}

///|
fn one_dimensional_compactor_abort_message(message : String) -> Unit {
  @core.layout_runtime_report_unsupported_configuration(message)
}

///|
pub fn new_one_dimensional_compactor(
  c_graph : CGraph,
) -> OneDimensionalCompactor {
  let compactor : OneDimensionalCompactor = {
    c_graph,
    lock_fun: None,
    spacings_handler: default_spacing_handler(),
    direction: Undefined,
    finished: false,
    compaction_algorithm: one_dimensional_compactor_longest_path_compaction,
    constraint_algorithm: one_dimensional_compactor_scanline_constraints,
  }

  ignore(compactor.calculate_group_offsets())

  for node in compactor.c_graph.c_nodes {
    if node.group() is None {
      ignore(cgroup_of().nodes([node]).create(compactor.c_graph))
    }
    node.set_hitbox_pre_compaction(Some(node.hitbox()))
  }

  compactor
}

///|
pub fn OneDimensionalCompactor::set_spacings_handler(
  self : OneDimensionalCompactor,
  handler : ISpacingsHandler,
) -> OneDimensionalCompactor {
  self.spacings_handler = handler
  self
}

///|
pub fn OneDimensionalCompactor::set_compaction_algorithm(
  self : OneDimensionalCompactor,
  algorithm : ICompactionAlgorithm,
) -> OneDimensionalCompactor {
  self.compaction_algorithm = algorithm
  self
}

///|
pub fn OneDimensionalCompactor::set_constraint_algorithm(
  self : OneDimensionalCompactor,
  algorithm : IConstraintCalculationAlgorithm,
) -> OneDimensionalCompactor {
  self.constraint_algorithm = algorithm
  self
}

///|
pub fn OneDimensionalCompactor::set_lock_function(
  self : OneDimensionalCompactor,
  lock_function : ILockFunction?,
) -> OneDimensionalCompactor {
  self.lock_fun = lock_function
  self
}

///|
pub fn OneDimensionalCompactor::compact(
  self : OneDimensionalCompactor,
) -> OneDimensionalCompactor {
  if self.finished {
    one_dimensional_compactor_raise_illegal_state(
      "The OneDimensionalCompactor instance has been finished already.",
    ) catch {
      OneDimensionalCompactorException::IllegalStateException(message) =>
        one_dimensional_compactor_abort_message(message)
      OneDimensionalCompactorException::IllegalArgumentException(message) =>
        one_dimensional_compactor_abort_message(message)
    }
  }

  if direction_eq(self.direction, Undefined) {
    ignore(self.change_direction(Leftward))
  }

  for group in self.c_graph.c_groups {
    group.set_out_degree(group.out_degree_real())
  }
  for node in self.c_graph.c_nodes {
    node.set_start_pos(@double.neg_infinity)
  }

  (self.compaction_algorithm)(self)
  self
}

///|
pub fn OneDimensionalCompactor::finish(
  self : OneDimensionalCompactor,
) -> OneDimensionalCompactor {
  ignore(self.change_direction(Leftward))
  self.finished = true
  self
}

///|
pub fn OneDimensionalCompactor::change_direction(
  self : OneDimensionalCompactor,
  dir : @core.Direction,
) -> OneDimensionalCompactor {
  if self.finished {
    one_dimensional_compactor_raise_illegal_state(
      "The OneDimensionalCompactor instance has been finished already.",
    ) catch {
      OneDimensionalCompactorException::IllegalStateException(message) =>
        one_dimensional_compactor_abort_message(message)
      OneDimensionalCompactorException::IllegalArgumentException(message) =>
        one_dimensional_compactor_abort_message(message)
    }
  }

  if !self.c_graph.supports(dir) {
    one_dimensional_compactor_raise_illegal_argument(
      "The direction is not supported by the CGraph instance.",
    ) catch {
      OneDimensionalCompactorException::IllegalStateException(message) =>
        one_dimensional_compactor_abort_message(message)
      OneDimensionalCompactorException::IllegalArgumentException(message) =>
        one_dimensional_compactor_abort_message(message)
    }
  }

  if direction_eq(dir, self.direction) {
    return self
  }

  let old_direction = self.direction
  self.direction = dir

  match old_direction {
    Undefined =>
      match dir {
        Leftward => one_dimensional_compactor_calculate_constraints(self)
        Rightward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Upward => {
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Downward => {
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Undefined => ()
      }
    Leftward =>
      match dir {
        Rightward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_reverse_constraints(self)
        }
        Upward => {
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Downward => {
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        _ => ()
      }
    Rightward =>
      match dir {
        Leftward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_reverse_constraints(self)
        }
        Upward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Downward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        _ => ()
      }
    Upward =>
      match dir {
        Leftward => {
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Rightward => {
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Downward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_reverse_constraints(self)
        }
        _ => ()
      }
    Downward =>
      match dir {
        Leftward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Rightward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_transpose_hitboxes(self)
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_calculate_constraints(self)
        }
        Upward => {
          one_dimensional_compactor_mirror_hitboxes(self)
          one_dimensional_compactor_reverse_constraints(self)
        }
        _ => ()
      }
  }

  self
}

///|
pub fn OneDimensionalCompactor::force_constraints_recalculation(
  self : OneDimensionalCompactor,
) -> OneDimensionalCompactor {
  one_dimensional_compactor_calculate_constraints(self)
  self
}

///|
pub fn OneDimensionalCompactor::is_locked_group(
  self : OneDimensionalCompactor,
  group : CGroup,
  dir : @core.Direction,
) -> Bool {
  for node in group.c_nodes() {
    if self.is_locked_node(node, dir) {
      return true
    }
  }
  false
}

///|
pub fn OneDimensionalCompactor::is_locked_node(
  self : OneDimensionalCompactor,
  node : CNode,
  dir : @core.Direction,
) -> Bool {
  match self.lock_fun {
    Some(lock_function) => lock_function(node, dir)
    None => false
  }
}

///|
pub fn OneDimensionalCompactor::calculate_group_offsets(
  self : OneDimensionalCompactor,
) -> OneDimensionalCompactor {
  for group in self.c_graph.c_groups {
    group.set_reference(None)

    for node in group.c_nodes() {
      let offset = node.c_group_offset()
      offset.x = 0.0
      offset.y = 0.0
      node.set_c_group_offset(offset)

      match group.reference() {
        Some(reference) =>
          if node.hitbox().x < reference.hitbox().x {
            group.set_reference(Some(node))
          }
        None => group.set_reference(Some(node))
      }
    }

    let reference = match group.reference() {
      Some(value) => value
      None => continue
    }

    for node in group.c_nodes() {
      let offset = node.c_group_offset()
      offset.x = node.hitbox().x - reference.hitbox().x
      offset.y = node.hitbox().y - reference.hitbox().y
      node.set_c_group_offset(offset)
    }
  }

  self
}

///|
fn one_dimensional_compactor_mirror_hitboxes(
  compactor : OneDimensionalCompactor,
) -> Unit {
  for node in compactor.c_graph.c_nodes {
    let hitbox = node.hitbox()
    hitbox.x = -hitbox.x - hitbox.width
    node.set_hitbox(hitbox)
  }

  ignore(compactor.calculate_group_offsets())
}

///|
fn one_dimensional_compactor_transpose_hitboxes(
  compactor : OneDimensionalCompactor,
) -> Unit {
  for node in compactor.c_graph.c_nodes {
    let hitbox = node.hitbox()

    let old_x = hitbox.x
    hitbox.x = hitbox.y
    hitbox.y = old_x

    let old_width = hitbox.width
    hitbox.width = hitbox.height
    hitbox.height = old_width

    node.set_hitbox(hitbox)

    let offset = node.c_group_offset()
    let old_offset_x = offset.x
    offset.x = offset.y
    offset.y = old_offset_x
    node.set_c_group_offset(offset)
  }

  ignore(compactor.calculate_group_offsets())
}

///|
fn one_dimensional_compactor_calculate_constraints(
  compactor : OneDimensionalCompactor,
) -> Unit {
  for node in compactor.c_graph.c_nodes {
    node.clear_constraints()
  }

  let constraints = if compactor.direction.is_horizontal() {
    compactor.c_graph.predefined_horizontal_constraints
  } else {
    compactor.c_graph.predefined_vertical_constraints
  }

  for constraint in constraints {
    let (first, second) = constraint
    if direction_eq(compactor.direction, Leftward) ||
      direction_eq(compactor.direction, Upward) {
      first.add_constraint(second)
    } else {
      second.add_constraint(first)
    }
  }

  (compactor.constraint_algorithm)(compactor)
  one_dimensional_compactor_calculate_constraints_for_groups(compactor)
}

///|
fn one_dimensional_compactor_calculate_constraints_for_groups(
  compactor : OneDimensionalCompactor,
) -> Unit {
  for group in compactor.c_graph.c_groups {
    group.set_out_degree(0)
    group.set_out_degree_real(0)
    group.clear_incoming_constraints()
  }

  for group in compactor.c_graph.c_groups {
    for node in group.c_nodes() {
      for incoming in node.constraints() {
        let incoming_group = match incoming.group() {
          Some(value) => value
          None => continue
        }

        if incoming_group != group {
          ignore(group.add_incoming_constraint(incoming))
          incoming_group.set_out_degree(incoming_group.out_degree() + 1)
          incoming_group.set_out_degree_real(
            incoming_group.out_degree_real() + 1,
          )
        }
      }
    }
  }
}

///|
fn one_dimensional_compactor_reverse_constraints(
  compactor : OneDimensionalCompactor,
) -> Unit {
  let incoming_map : Array[Array[CNode]] = []
  for _ in 0..<compactor.c_graph.c_nodes.length() {
    incoming_map.push([])
  }

  for node in compactor.c_graph.c_nodes {
    node.set_start_pos(@double.neg_infinity)
    for incoming in node.constraints() {
      incoming_map[incoming.handle].push(node)
    }
  }

  for node in compactor.c_graph.c_nodes {
    node.replace_constraints(incoming_map[node.handle])
  }

  one_dimensional_compactor_calculate_constraints_for_groups(compactor)
}
