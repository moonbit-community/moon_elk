///|
pub fn longest_path_compaction(compactor : OneDimensionalCompactor) -> Unit {
  let mut min_start_pos = @double.infinity
  for cnode in compactor.c_graph.c_nodes {
    let group = match cnode.group() {
      Some(value) => value
      None => abort("CNode without CGroup in compaction")
    }

    let reference = match group.reference() {
      Some(value) => value
      None => abort("CGroup without reference node in compaction")
    }

    let reference_hitbox = reference.hitbox()
    let candidate = reference_hitbox.x + cnode.c_group_offset().x
    if candidate < min_start_pos {
      min_start_pos = candidate
    }
  }

  let sinks : Array[CGroup] = []
  for group in compactor.c_graph.c_groups {
    group.set_start_pos(min_start_pos)
    if group.out_degree() == 0 {
      sinks.push(group)
    }
  }

  while !sinks.is_empty() {
    let group = sinks[0]
    ignore(sinks.remove(0))

    let reference = match group.reference() {
      Some(value) => value
      None => abort("CGroup without reference node in compaction")
    }

    let mut diff = reference.hitbox().x

    for node in group.c_nodes() {
      let suggested_x = group.start_pos() + node.c_group_offset().x
      if !compactor.is_locked_group(group, compactor.direction) ||
        node.hitbox().x < suggested_x {
        node.set_start_pos(suggested_x)
      } else {
        node.set_start_pos(node.hitbox().x)
      }
    }

    diff = diff - reference.start_pos()

    group.add_delta(diff)
    if direction_eq(compactor.direction, Rightward) ||
      direction_eq(compactor.direction, Downward) {
      group.add_delta_normalized(diff)
    } else {
      group.add_delta_normalized(-diff)
    }

    for node in group.c_nodes() {
      for inc_node in node.constraints() {
        let spacing = if compactor.direction.is_horizontal() {
          (compactor.spacings_handler.get_horizontal_spacing)(node, inc_node)
        } else {
          (compactor.spacings_handler.get_vertical_spacing)(node, inc_node)
        }

        let inc_group = match inc_node.group() {
          Some(value) => value
          None => abort("Constraint target node without group")
        }

        let suggested = node.start_pos() +
          node.hitbox().width +
          spacing -
          inc_node.c_group_offset().x
        if suggested > inc_group.start_pos() {
          inc_group.set_start_pos(suggested)
        }

        if compactor.is_locked_node(inc_node, compactor.direction) {
          let locked_candidate = inc_node.hitbox().x -
            inc_node.c_group_offset().x
          if locked_candidate > inc_group.start_pos() {
            inc_group.set_start_pos(locked_candidate)
          }
        }

        inc_group.set_out_degree(inc_group.out_degree() - 1)
        if inc_group.out_degree() == 0 {
          sinks.push(inc_group)
        }
      }
    }
  }

  for cnode in compactor.c_graph.c_nodes {
    let hitbox = cnode.hitbox()
    hitbox.x = cnode.start_pos()
    cnode.set_hitbox(hitbox)
  }
}

///|
pub let one_dimensional_compactor_longest_path_compaction : ICompactionAlgorithm = longest_path_compaction
